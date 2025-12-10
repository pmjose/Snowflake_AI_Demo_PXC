-- Use ACCOUNTADMIN role for setup
USE ROLE ACCOUNTADMIN;

ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"PXC AI Demo", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';

-- ============================================================================
-- Create Warehouse Early (required for EXECUTE IMMEDIATE blocks)
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'Demo warehouse for Telco AI hands-on lab';

USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};

-- ============================================================================
-- Disable Behavior Change Bundle and Configure Authentication Policy
-- ============================================================================

SELECT SYSTEM$DISABLE_BEHAVIOR_CHANGE_BUNDLE('2025_06');

CREATE DATABASE IF NOT EXISTS policy_db;

USE DATABASE policy_db;

CREATE SCHEMA IF NOT EXISTS policies;

USE SCHEMA policies;

CREATE AUTHENTICATION POLICY IF NOT EXISTS event_authentication_policy;

ALTER AUTHENTICATION POLICY event_authentication_policy SET
  MFA_ENROLLMENT=OPTIONAL
  CLIENT_TYPES = ('ALL')
  AUTHENTICATION_METHODS = ('ALL');

-- Clear any existing account-level authentication policy first
EXECUTE IMMEDIATE $$
    BEGIN
        ALTER ACCOUNT UNSET AUTHENTICATION POLICY;
    EXCEPTION
        WHEN STATEMENT_ERROR THEN
            -- Ignore if no policy exists
            NULL;
    END;
$$
;

-- Now set the new authentication policy
EXECUTE IMMEDIATE $$
    BEGIN
        ALTER ACCOUNT SET AUTHENTICATION POLICY event_authentication_policy;
    EXCEPTION
        WHEN STATEMENT_ERROR THEN
            RETURN SQLERRM;
    END;
$$
;

-- ============================================================================
-- Step 0: Cleanup - Remove FSI Lab Objects (if exists)
-- ============================================================================

-- Drop FSI database to clean up test account
DROP DATABASE IF EXISTS ACCELERATE_AI_IN_FSI;

-- Note: DEFAULT_WH warehouse is not dropped as it may be used by other workloads

SELECT 'FSI lab database cleanup complete!' AS cleanup_status;

-- ============================================================================
-- Step 1: Create Custom Role for Telco Analytics
-- ============================================================================

CREATE ROLE IF NOT EXISTS {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }}
    COMMENT = 'Role for Telco Operations AI hands-on lab - Event: {{ env.EVENT_NAME | default("Telco AI Lab") }}';

-- Grant necessary privileges (warehouse grants will be added after warehouse creation)
GRANT CREATE DATABASE ON ACCOUNT TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

-- Grant CORTEX_USER database role (required for Cortex AI functions)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

-- Grant role to ACCOUNTADMIN and SYSADMIN for administrative access
GRANT ROLE TELCO_ANALYST_ROLE TO ROLE {{ ACCOUNT_ROLE | default('ACCOUNTADMIN') }};
GRANT ROLE TELCO_ANALYST_ROLE TO ROLE SYSADMIN;

-- ============================================================================
-- Step 1b: Migrate Current User from ATTENDEE_ROLE to TELCO_ANALYST_ROLE
-- ============================================================================

-- Grant {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} to current user
SET current_user = (SELECT CURRENT_USER());
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} TO USER IDENTIFIER($current_user);

-- Set ACCOUNTADMIN as the default role for current user
-- This ensures the user maintains full access when ATTENDEE_ROLE is dropped
ALTER USER IDENTIFIER($current_user) SET DEFAULT_ROLE = ACCOUNTADMIN;

SELECT 'Current user role configuration complete' AS user_migration_status,
       CURRENT_USER() as migrated_user,
       'ACCOUNTADMIN' as new_default_role,
       '{{ TELCO_ANALYST_ROLE | default("TELCO_ANALYST_ROLE") }}' as additional_role_granted;

-- ============================================================================
-- Step 1c: Drop FSI Role (after user migration)
-- ============================================================================

-- Now safe to drop ATTENDEE_ROLE after current user has been migrated
-- Note: If other users in your account have ATTENDEE_ROLE, you may need to
-- manually grant them TELCO_ANALYST_ROLE and update their default role
DROP ROLE IF EXISTS ATTENDEE_ROLE;

SELECT 'FSI lab role cleanup complete!' AS role_cleanup_status,
       'ATTENDEE_ROLE dropped - current user default role is ACCOUNTADMIN' AS cleanup_info;

-- ============================================================================
-- Step 2: Create Dedicated Warehouse
-- ============================================================================

CREATE WAREHOUSE IF NOT EXISTS {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    WAREHOUSE_SIZE = '{{ env.EVENT_WAREHOUSE_SIZE | default("MEDIUM") }}'
    AUTO_SUSPEND = {{ env.EVENT_AUTO_SUSPEND | default(300) }}
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Telco Operations AI - Event: {{ EVENT_NAME }}';

GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};
GRANT OPERATE ON WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

-- ============================================================================
-- Step 3: Create Database and Schemas
-- ============================================================================

USE ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

CREATE DATABASE IF NOT EXISTS {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }}
    COMMENT = 'Database for PXC AI demo - All stages and data pre-loaded';

USE DATABASE {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }};

-- Create schemas
CREATE OR REPLACE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }}
    COMMENT = 'Main schema for call center data tables';

CREATE OR REPLACE SCHEMA {{ env.EVENT_CORTEX_ANALYST_SCHEMA | default('CORTEX_ANALYST') }}
    COMMENT = 'Schema for Cortex Analyst semantic views';

CREATE OR REPLACE SCHEMA {{ env.EVENT_NOTEBOOKS_SCHEMA | default('NOTEBOOKS') }}
    COMMENT = 'Schema for Snowflake notebooks';

CREATE OR REPLACE SCHEMA {{ env.EVENT_STREAMLIT_SCHEMA | default('STREAMLIT') }}
    COMMENT = 'Schema for Streamlit applications';

CREATE OR REPLACE SCHEMA {{ env.EVENT_MODELS_SCHEMA | default('MODELS') }}
    COMMENT = 'Schema for ML models and UDFs';

-- ============================================================================
-- Step 4: Create File Formats
-- ============================================================================

USE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }};

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE_UNENCLOSED_FIELD = NONE
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    NULL_IF = ('NULL', 'null', '')
    COMMENT = 'Standard CSV format for telco data files';

CREATE OR REPLACE FILE FORMAT JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'JSON format for structured data';

-- ============================================================================
-- Step 5: Create Stages
-- ============================================================================

CREATE OR REPLACE STAGE {{ env.EVENT_AUDIO_STAGE | default('AUDIO_STAGE') }}
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for call center audio files - PRE-LOADED with 500+ MP3/WAV recordings';

CREATE OR REPLACE STAGE {{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}
    DIRECTORY = (ENABLE = TRUE)
    FILE_FORMAT = CSV_FORMAT
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for CSV data files - customer profiles, transcripts, tickets';

-- Create raw_files stage alias for notebook compatibility (used by 1_DATA_PROCESSING.ipynb)
CREATE OR REPLACE STAGE raw_files
    DIRECTORY = (ENABLE = TRUE)
    FILE_FORMAT = CSV_FORMAT
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for raw data files - used by data processing notebook';

CREATE OR REPLACE STAGE {{ env.EVENT_NOTEBOOK_STAGE | default('NOTEBOOK_STAGE') }}
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for Snowflake notebook files';

CREATE OR REPLACE STAGE {{ env.EVENT_STREAMLIT_STAGE | default('STREAMLIT_STAGE') }}
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    COMMENT = 'Stage for Streamlit application files';

-- ============================================================================
-- Step 6: Enable Snowflake Intelligence
-- ============================================================================

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE NETWORK RULE telco_web_access_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443')
  COMMENT = 'Permissive network access for PXC demo web scraping';

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION pxc_external_access_integration
  ALLOWED_NETWORK_RULES = (telco_web_access_rule)
  ENABLED = TRUE
  COMMENT = 'External access for web scraping and API calls';

GRANT USAGE ON INTEGRATION pxc_external_access_integration TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

-- ============================================================================
-- Step 8: Create Email Notification Integration
-- ============================================================================

CREATE OR REPLACE NOTIFICATION INTEGRATION pxc_email_int
  TYPE = EMAIL
  ENABLED = TRUE
  COMMENT = 'Email integration for sending notifications from Intelligence Agent';

GRANT USAGE ON INTEGRATION pxc_email_int TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

-- ============================================================================
-- Step 9: Create Users
-- ============================================================================

USE ROLE USERADMIN;

-- Create the event user
CREATE USER IF NOT EXISTS {{ env.EVENT_USER_NAME }}
    PASSWORD = '{{ env.EVENT_USER_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_USER_NAME }}
    FIRST_NAME = '{{ env.EVENT_USER_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_USER_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

-- Create the event admin user
CREATE USER IF NOT EXISTS {{ env.EVENT_ADMIN_NAME }}
    PASSWORD = '{{ env.EVENT_ADMIN_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_ADMIN_NAME }}
    FIRST_NAME = '{{ env.EVENT_ADMIN_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_ADMIN_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

-- Create CEO user
CREATE USER IF NOT EXISTS {{ env.EVENT_CEO_NAME }}
    PASSWORD = '{{ env.EVENT_CEO_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_CEO_NAME }}
    FIRST_NAME = '{{ env.EVENT_CEO_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_CEO_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

-- Create CFO user
CREATE USER IF NOT EXISTS {{ env.EVENT_CFO_NAME }}
    PASSWORD = '{{ env.EVENT_CFO_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_CFO_NAME }}
    FIRST_NAME = '{{ env.EVENT_CFO_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_CFO_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

-- Create CRO user
CREATE USER IF NOT EXISTS {{ env.EVENT_CRO_NAME }}
    PASSWORD = '{{ env.EVENT_CRO_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_CRO_NAME }}
    FIRST_NAME = '{{ env.EVENT_CRO_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_CRO_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

-- ============================================================================
-- Step 10: Grant Roles to Users
-- ============================================================================

USE ROLE SECURITYADMIN;

-- Grant roles to event user
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} TO USER {{ env.EVENT_USER_NAME }};
GRANT ROLE ACCOUNTADMIN TO USER {{ env.EVENT_USER_NAME }};

-- Grant warehouse access
GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};

-- Grant roles to event admin user
GRANT ROLE ACCOUNTADMIN TO USER {{ env.EVENT_ADMIN_NAME }};
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} TO USER {{ env.EVENT_ADMIN_NAME }};

-- Grant roles to CEO user
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} TO USER {{ env.EVENT_CEO_NAME }};
GRANT ROLE ACCOUNTADMIN TO USER {{ env.EVENT_CEO_NAME }};

-- Grant roles to CFO user
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} TO USER {{ env.EVENT_CFO_NAME }};
GRANT ROLE ACCOUNTADMIN TO USER {{ env.EVENT_CFO_NAME }};

-- Grant roles to CRO user
GRANT ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }} TO USER {{ env.EVENT_CRO_NAME }};
GRANT ROLE ACCOUNTADMIN TO USER {{ env.EVENT_CRO_NAME }};

-- ============================================================================
-- Step 11: Set Default Role and Warehouse for Users
-- ============================================================================

USE ROLE USERADMIN;

-- Set defaults for event user
ALTER USER {{ env.EVENT_USER_NAME }} SET
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};

-- Set defaults for event admin user
ALTER USER {{ env.EVENT_ADMIN_NAME }} SET
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};

-- Set defaults for CEO user
ALTER USER {{ env.EVENT_CEO_NAME }} SET
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};

-- Set defaults for CFO user
ALTER USER {{ env.EVENT_CFO_NAME }} SET
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};

-- Set defaults for CRO user
ALTER USER {{ env.EVENT_CRO_NAME }} SET
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};

-- ============================================================================
-- Set Context
-- ============================================================================

USE ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};
USE DATABASE {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }};
USE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }};

-- ============================================================================
-- Verification
-- ============================================================================

SELECT 'Account configuration complete!' AS status,
       '{{ EVENT_DATABASE | default("PXC_AI_DEMO") }}' AS database_created,
       '{{ EVENT_WAREHOUSE | default("PXC_DEMO_WH") }}' AS warehouse_created,
       '{{ EVENT_ATTENDEE_ROLE | default("TELCO_ANALYST_ROLE") }}' AS role_created,
       'Users: {{ env.EVENT_USER_NAME }}, {{ env.EVENT_ADMIN_NAME }}, {{ env.EVENT_CEO_NAME }}, {{ env.EVENT_CFO_NAME }}, {{ env.EVENT_CRO_NAME }}' AS users_created;

-- Output for DataOps pipeline
SELECT 
    '{{ EVENT_ATTENDEE_ROLE | default("TELCO_ANALYST_ROLE") }}' as role_name,
    '{{ EVENT_DATABASE | default("PXC_AI_DEMO") }}' as database_name,
    '{{ EVENT_WAREHOUSE | default("PXC_DEMO_WH") }}' as warehouse_name,
    CURRENT_TIMESTAMP() as deployed_at;

