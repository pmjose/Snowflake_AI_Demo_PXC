#!/usr/bin/env python3
"""
Local Pipeline Runner for Telco AI Demo
Uses Snowflake CLI (snow) to execute the pipeline locally.

This script:
1. Renders Jinja2 template SQL files (handles DataOps {{ env.VAR }} syntax)
2. Executes them in the correct order using `snow sql`
"""

import os
import sys
import subprocess
import yaml
from pathlib import Path
import re
import argparse
from datetime import datetime

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_DIR = SCRIPT_DIR.parent
DATAOPS_DIR = PROJECT_DIR / "dataops" / "event"
VARIABLES_FILE = DATAOPS_DIR / "variables.yml"
OUTPUT_DIR = SCRIPT_DIR / ".rendered"

# Pipeline steps in order (matching full-ci.yml)
PIPELINE_STEPS = [
    ("1_configure_account", "telco_configure_account.template.sql"),
    ("2_upload_files", "telco_upload_files.template.sql"),
    ("3_data_foundation", "telco_data_foundation.template.sql"),
    ("4_deploy_search", "telco_deploy_search.template.sql"),
    ("5_deploy_analyst", "telco_deploy_analyst.template.sql"),
    ("6_deploy_applications", "telco_deploy_applications.template.sql"),
    ("7_run_notebooks", "telco_run_notebooks.template.sql"),
    # ("8_deploy_snowmail", "deploy_snow_mail.template.sql"),  # Optional - requires EMAIL_PREVIEWS table
]


def load_variables() -> dict:
    """Load variables from variables.yml"""
    print(f"📋 Loading variables from {VARIABLES_FILE}")
    
    with open(VARIABLES_FILE, 'r') as f:
        data = yaml.safe_load(f)
    
    variables = data.get('variables', {})
    
    # Add CI_PROJECT_DIR (maps to local project directory)
    variables['CI_PROJECT_DIR'] = str(PROJECT_DIR)
    variables['ACCOUNT_ROLE'] = 'ACCOUNTADMIN'
    
    print(f"   Loaded {len(variables)} variables")
    return variables


def render_template(template_path: Path, variables: dict) -> str:
    """Render template SQL file using simple string substitution"""
    with open(template_path, 'r') as f:
        content = f.read()
    
    # Pattern for {{ env.VAR | default('value') }} or {{ env.VAR | default("value") }}
    # Also handles escaped quotes like \"value\"
    pattern = r'\{\{\s*env\.(\w+)\s*\|\s*default\(\\?[\'"]([^"\']*?)\\?[\'"]\)\s*\}\}'
    
    def replace_with_default(match):
        var_name = match.group(1)
        default_value = match.group(2)
        return str(variables.get(var_name, default_value))
    
    content = re.sub(pattern, replace_with_default, content)
    
    # Pattern for {{ env.VAR | default(number) }} - numeric defaults without quotes
    pattern_numeric = r'\{\{\s*env\.(\w+)\s*\|\s*default\((\d+)\)\s*\}\}'
    
    def replace_with_numeric_default(match):
        var_name = match.group(1)
        default_value = match.group(2)
        return str(variables.get(var_name, default_value))
    
    content = re.sub(pattern_numeric, replace_with_numeric_default, content)
    
    # Pattern for {{ env.VAR }} without default
    pattern2 = r'\{\{\s*env\.(\w+)\s*\}\}'
    
    def replace_var(match):
        var_name = match.group(1)
        return str(variables.get(var_name, ''))
    
    content = re.sub(pattern2, replace_var, content)
    
    # Pattern for {{ VAR | default('value') }} (top-level vars) - also handles escaped quotes
    pattern3 = r'\{\{\s*(\w+)\s*\|\s*default\(\\?[\'"]([^"\']*?)\\?[\'"]\)\s*\}\}'
    
    def replace_toplevel_default(match):
        var_name = match.group(1)
        default_value = match.group(2)
        return str(variables.get(var_name, default_value))
    
    content = re.sub(pattern3, replace_toplevel_default, content)
    
    # Pattern for {{ VAR | default(number) }} (top-level vars) - numeric defaults
    pattern3_numeric = r'\{\{\s*(\w+)\s*\|\s*default\((\d+)\)\s*\}\}'
    
    def replace_toplevel_numeric_default(match):
        var_name = match.group(1)
        default_value = match.group(2)
        return str(variables.get(var_name, default_value))
    
    content = re.sub(pattern3_numeric, replace_toplevel_numeric_default, content)
    
    # Pattern for {{ VAR }} (top-level vars)
    pattern4 = r'\{\{\s*(\w+)\s*\}\}'
    
    def replace_toplevel(match):
        var_name = match.group(1)
        return str(variables.get(var_name, match.group(0)))  # Keep original if not found
    
    content = re.sub(pattern4, replace_toplevel, content)
    
    return content


def save_rendered_sql(step_name: str, sql_content: str) -> Path:
    """Save rendered SQL to output directory"""
    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / f"{step_name}.sql"
    
    with open(output_path, 'w') as f:
        f.write(sql_content)
    
    return output_path


def execute_sql(sql_path: Path, connection: str, dry_run: bool = False) -> bool:
    """Execute SQL file using Snowflake CLI"""
    if dry_run:
        print(f"   [DRY RUN] Would execute: snow sql -c {connection} -f {sql_path}")
        return True
    
    cmd = ["snow", "sql", "-c", connection, "-f", str(sql_path)]
    
    print(f"   Executing: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, cwd=PROJECT_DIR)
        return result.returncode == 0
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False


def run_step(step_name: str, template_file: str, variables: dict, 
             connection: str, dry_run: bool = False, render_only: bool = False) -> bool:
    """Run a single pipeline step"""
    template_path = DATAOPS_DIR / template_file
    
    if not template_path.exists():
        print(f"   ⚠️  Template not found: {template_path}")
        return False
    
    # Render template
    print(f"   📝 Rendering: {template_file}")
    try:
        sql_content = render_template(template_path, variables)
    except Exception as e:
        print(f"   ❌ Render failed: {e}")
        return False
    
    # Save rendered SQL
    output_path = save_rendered_sql(step_name, sql_content)
    print(f"   💾 Saved to: {output_path}")
    
    if render_only:
        return True
    
    # Execute SQL
    return execute_sql(output_path, connection, dry_run)


def main():
    parser = argparse.ArgumentParser(
        description="Run the Telco AI Demo pipeline locally using Snowflake CLI"
    )
    parser.add_argument("-c", "--connection", default="telco-local",
                        help="Snowflake CLI connection name (default: telco-local)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print commands without executing them")
    parser.add_argument("--render-only", action="store_true",
                        help="Only render templates, don't execute SQL")
    parser.add_argument("--step", type=int,
                        help="Run only a specific step (1-8)")
    parser.add_argument("--start-from", type=int, default=1,
                        help="Start from a specific step (1-8)")
    parser.add_argument("--list", action="store_true",
                        help="List all pipeline steps")
    
    args = parser.parse_args()
    
    if args.list:
        print("\n📋 Pipeline Steps:")
        print("-" * 60)
        for i, (name, template) in enumerate(PIPELINE_STEPS, 1):
            desc = name.split('_', 1)[1].replace('_', ' ').title()
            print(f"  {i}. {desc}")
            print(f"     Template: {template}")
        print()
        return 0
    
    print("\n" + "=" * 60)
    print("🚀 Telco AI Demo - Local Pipeline Runner")
    print("=" * 60)
    print(f"   Connection: {args.connection}")
    print(f"   Mode: {'Dry Run' if args.dry_run else 'Render Only' if args.render_only else 'Execute'}")
    print("=" * 60 + "\n")
    
    # Load variables
    try:
        variables = load_variables()
    except Exception as e:
        print(f"❌ Failed to load variables: {e}")
        return 1
    
    # Test connection (unless render-only or dry-run)
    if not args.render_only and not args.dry_run:
        print("🔌 Testing Snowflake connection...")
        result = subprocess.run(
            ["snow", "connection", "test", "-c", args.connection],
            capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"❌ Connection failed: {result.stderr}")
            return 1
        print("   ✅ Connection OK\n")
    
    # Determine which steps to run
    if args.step:
        steps_to_run = [(args.step - 1, PIPELINE_STEPS[args.step - 1])]
    else:
        steps_to_run = [(i, step) for i, step in enumerate(PIPELINE_STEPS) 
                        if i >= args.start_from - 1]
    
    # Run pipeline
    success_count = 0
    fail_count = 0
    
    for idx, (step_name, template_file) in steps_to_run:
        step_num = idx + 1
        desc = step_name.split('_', 1)[1].replace('_', ' ').title()
        
        print(f"\n{'='*60}")
        print(f"🔧 Step {step_num}: {desc}")
        print(f"{'='*60}")
        
        success = run_step(step_name, template_file, variables, 
                          args.connection, args.dry_run, args.render_only)
        
        if success:
            print(f"   ✅ Complete")
            success_count += 1
        else:
            print(f"   ❌ Failed")
            fail_count += 1
            if not args.dry_run and not args.render_only:
                print(f"\n⚠️  Pipeline stopped. Re-run with --start-from {step_num}")
                break
    
    # Summary
    print(f"\n{'='*60}")
    print("📊 Summary")
    print(f"{'='*60}")
    print(f"   ✅ Successful: {success_count}")
    print(f"   ❌ Failed: {fail_count}")
    print(f"   📁 Rendered SQL: {OUTPUT_DIR}")
    print()
    
    return 0 if fail_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
