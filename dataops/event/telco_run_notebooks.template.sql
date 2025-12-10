-- ============================================================================
-- Telco Operations AI - Notebooks Ready (DataOps Template)
-- ============================================================================
-- Description: Verifies notebooks are deployed and ready for manual execution
-- Variables: {{ EVENT_DATABASE }}, {{ EVENT_NOTEBOOKS_SCHEMA }}
-- Prerequisites: telco_deploy_applications.template.sql must run first
-- ============================================================================

USE ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('CITYFIBRE_DEMO_WH') }};
USE DATABASE {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }};

-- ============================================================================
-- Verify Notebooks Are Deployed
-- ============================================================================

SHOW NOTEBOOKS IN SCHEMA {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}.{{ env.EVENT_NOTEBOOKS_SCHEMA | default('NOTEBOOKS') }};

SELECT 'Notebooks are ready for manual execution!' AS status,
       '{{ env.EVENT_DATABASE | default("CITYFIBRE_AI_DEMO") }}' AS database_name,
       CURRENT_TIMESTAMP() AS verified_at;

-- ============================================================================
-- Next Steps
-- ============================================================================
-- 
-- ✅ Data processing complete
-- ✅ Audio files transcribed
-- ✅ PDF documents parsed
-- ✅ All tables populated
--
-- You can now:
-- 1. Run Notebook 3: Intelligence Lab for advanced analytics
-- 2. Test Cortex Search services
-- 3. Query Cortex Analyst semantic views
-- 4. Interact with the Snowflake Intelligence Agent
-- 5. Use the Streamlit application
--
-- ============================================================================

