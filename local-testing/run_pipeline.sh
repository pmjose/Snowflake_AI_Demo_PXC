#!/bin/bash
# =============================================================================
# Telco AI Demo - Local Pipeline Runner using Snowflake CLI
# =============================================================================
# Wrapper script for run_pipeline.py
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the Python script with all arguments
python3 "$SCRIPT_DIR/run_pipeline.py" "$@"
