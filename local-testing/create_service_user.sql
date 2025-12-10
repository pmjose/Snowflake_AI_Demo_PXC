-- ============================================================================
-- Create Service User for Local Testing / DataOps.live
-- ============================================================================
-- Run this SQL in Snowflake as ACCOUNTADMIN
-- 
-- Before running:
-- 1. Run ./generate_keys.sh to create your key pair
-- 2. Copy the public key content (without BEGIN/END lines)
-- 3. Paste it in the RSA_PUBLIC_KEY value below
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- Step 1: Create the Service User
-- ============================================================================

CREATE USER IF NOT EXISTS DATAOPS_SERVICE_USER
    TYPE = SERVICE
    COMMENT = 'Service user for DataOps.live pipelines and local testing';

-- ============================================================================
-- Step 2: Set the RSA Public Key
-- ============================================================================
-- IMPORTANT: Replace the placeholder below with your actual public key
-- Remove the "-----BEGIN PUBLIC KEY-----" and "-----END PUBLIC KEY-----" lines
-- Join all lines into one continuous string (no spaces or newlines)

ALTER USER DATAOPS_SERVICE_USER SET RSA_PUBLIC_KEY = '
PASTE_YOUR_PUBLIC_KEY_HERE_AS_ONE_CONTINUOUS_STRING
';

-- ============================================================================
-- Step 3: Grant Necessary Roles
-- ============================================================================

-- Grant ACCOUNTADMIN for full access (required for account setup)
GRANT ROLE ACCOUNTADMIN TO USER DATAOPS_SERVICE_USER;

-- Grant TELCO_ANALYST_ROLE if it exists
GRANT ROLE TELCO_ANALYST_ROLE TO USER DATAOPS_SERVICE_USER;

-- Grant SYSADMIN for object management
GRANT ROLE SYSADMIN TO USER DATAOPS_SERVICE_USER;

-- ============================================================================
-- Step 4: Set Default Role and Warehouse
-- ============================================================================

ALTER USER DATAOPS_SERVICE_USER SET 
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = TELCO_WH;

-- ============================================================================
-- Step 5: Verify the User
-- ============================================================================

DESCRIBE USER DATAOPS_SERVICE_USER;

-- Show granted roles
SHOW GRANTS TO USER DATAOPS_SERVICE_USER;

SELECT 'Service user DATAOPS_SERVICE_USER created successfully!' AS status;

