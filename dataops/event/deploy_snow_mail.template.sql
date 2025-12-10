-- ========================================
-- Deploy SnowMail Native App
-- ========================================
-- This script deploys SnowMail as a Snowflake Native Application
-- providing a Gmail-style email viewer for Telco Operations AI demos

-- Use ACCOUNTADMIN for creating application packages and granting permissions
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('CITYFIBRE_DEMO_WH') }};

-- ========================================
-- Step 1: Create Application Package Infrastructure
-- ========================================

CREATE DATABASE IF NOT EXISTS {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG;
CREATE SCHEMA IF NOT EXISTS {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG.APP_CODE;

CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for SnowMail Native App artifacts';

-- ========================================
-- Step 2: Upload Application Files
-- ========================================

-- Note: PUT commands execute relative to where the SQL script runs from (project root)
-- Upload manifest.yml
PUT file://dataops/event/native_app_snowmail/manifest.yml 
    @{{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE/ 
    OVERWRITE=TRUE 
    AUTO_COMPRESS=FALSE
    SOURCE_COMPRESSION=NONE;

-- Upload setup.sql
PUT file://dataops/event/native_app_snowmail/setup.sql 
    @{{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE/ 
    OVERWRITE=TRUE 
    AUTO_COMPRESS=FALSE
    SOURCE_COMPRESSION=NONE;

-- Upload Streamlit email_viewer.py
PUT file://dataops/event/native_app_snowmail/streamlit/email_viewer.py 
    @{{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE/streamlit/ 
    OVERWRITE=TRUE 
    AUTO_COMPRESS=FALSE
    SOURCE_COMPRESSION=NONE;

-- Verify files uploaded
LIST @{{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE;

-- ========================================
-- Step 3: Clean Deployment - Drop and Recreate Package
-- ========================================

-- Drop the application first
DROP APPLICATION IF EXISTS SNOWMAIL;

-- Drop and recreate the application package completely
-- This is the cleanest approach to avoid version accumulation issues
DROP APPLICATION PACKAGE IF EXISTS SNOWMAIL_PKG;

CREATE APPLICATION PACKAGE SNOWMAIL_PKG
    COMMENT = 'SnowMail - Gmail-style email viewer for Telco Operations AI'
    ENABLE_RELEASE_CHANNELS = FALSE;

-- Add the version (simpler syntax when release channels are disabled)
ALTER APPLICATION PACKAGE SNOWMAIL_PKG 
    ADD VERSION V1_0
    USING '@{{ DATABASE_NAME | default("CITYFIBRE_AI_DEMO") }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE'
    LABEL = 'SnowMail v1.0 - Pipeline {{ env.CI_PIPELINE_ID | default("Manual") }} - Deployed {{ env.CI_COMMIT_TIMESTAMP | default("Manual") }}';

-- Set as the default version
ALTER APPLICATION PACKAGE SNOWMAIL_PKG
    SET DEFAULT RELEASE DIRECTIVE
    VERSION = V1_0
    PATCH = 0;

-- ========================================
-- Step 4: Create Application Instance
-- ========================================

-- Create the application from the package
CREATE APPLICATION SNOWMAIL
    FROM APPLICATION PACKAGE SNOWMAIL_PKG
    COMMENT = 'SnowMail Email Viewer for Telco Operations AI Demos';

-- ========================================
-- Step 5: Grant Permissions to SnowMail Application
-- ========================================

-- Grant database and schema access
GRANT USAGE ON DATABASE {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }} TO APPLICATION SNOWMAIL;
GRANT USAGE ON SCHEMA {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}.{{ env.EVENT_SCHEMA | default('CITYFIBRE_SCHEMA') }} TO APPLICATION SNOWMAIL;

-- Grant table permissions on EMAIL_PREVIEWS
-- SELECT: Read emails for display in UI
-- DELETE: Allow users to delete emails from inbox
-- Note: INSERT is handled by SEND_EMAIL_NOTIFICATION procedure, not by the app
GRANT SELECT, DELETE ON TABLE {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}.{{ env.EVENT_SCHEMA | default('CITYFIBRE_SCHEMA') }}.EMAIL_PREVIEWS TO APPLICATION SNOWMAIL;

-- Grant warehouse access for Streamlit execution
GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE | default('CITYFIBRE_DEMO_WH') }} TO APPLICATION SNOWMAIL;

-- ========================================
-- Step 6: Create Email Notification Procedure
-- ========================================

/*
This procedure enables the Snowflake Intelligence Agent to send email notifications.
The agent can call this procedure as a tool to send alerts, reports, and updates
to network operations, customer care, and executive teams.

Example agent use cases:
- Send network capacity alerts when towers reach 85%+ utilization
- Email churn risk reports to customer retention team
- Notify executives of critical incidents or SLA breaches
- Send automated billing dispute summaries to operations
- Alert technical teams about performance degradations

Emails are displayed in the SnowMail Native App for easy viewing.
*/

-- Create stored procedure to send email notifications via SnowMail
CREATE OR REPLACE PROCEDURE {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}.{{ env.EVENT_SCHEMA | default('CITYFIBRE_SCHEMA') }}.SEND_EMAIL_NOTIFICATION(
    SUBJECT_TEXT VARCHAR,
    MESSAGE_CONTENT VARCHAR,
    RECIPIENT_EMAIL VARCHAR
)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    email_id VARCHAR;
    snowmail_url VARCHAR;
    org_name VARCHAR;
    account_name VARCHAR;
BEGIN
    -- Generate unique email ID
    email_id := 'EMAIL_' || TO_VARCHAR(DATEADD(ms, UNIFORM(1, 999, RANDOM()), CURRENT_TIMESTAMP()), 'YYYYMMDDHH24MISSFF3');
    
    -- Get account info for URL construction
    org_name := (SELECT CURRENT_ORGANIZATION_NAME());
    account_name := (SELECT CURRENT_ACCOUNT_NAME());
    
    -- Insert email into EMAIL_PREVIEWS table
    INSERT INTO {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}.{{ env.EVENT_SCHEMA | default('CITYFIBRE_SCHEMA') }}.EMAIL_PREVIEWS (
        EMAIL_ID,
        RECIPIENT_EMAIL,
        SUBJECT,
        HTML_CONTENT,
        CREATED_AT,
        IS_READ,
        IS_STARRED
    )
    VALUES (
        :email_id,
        :RECIPIENT_EMAIL,
        :SUBJECT_TEXT,
        '<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 20px auto; padding: 20px;">' ||
        '<h2 style="color: #29B5E8;">' || :SUBJECT_TEXT || '</h2>' ||
        '<p><strong>Date:</strong> ' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'Mon DD, YYYY HH24:MI') || '</p>' ||
        '<div style="margin-top: 20px;">' || :MESSAGE_CONTENT || '</div>' ||
        '</body></html>',
        CURRENT_TIMESTAMP(),
        FALSE,
        FALSE
    );
    
    -- Construct SnowMail URL
    snowmail_url := 'https://app.snowflake.com/' || LOWER(:org_name) || '/' || LOWER(:account_name) || '/#/apps/application/SNOWMAIL/schema/APP_SCHEMA/streamlit/EMAIL_VIEWER';
    
    -- Return success message with URL
    RETURN '📧 Email sent! Email ID: ' || :email_id || '\n' ||
           '📬 VIEW IN SNOWMAIL: ' || :snowmail_url;
END;
$$;

-- Grant execute permission on procedure to public
GRANT USAGE ON PROCEDURE {{ env.EVENT_DATABASE | default('CITYFIBRE_AI_DEMO') }}.{{ env.EVENT_SCHEMA | default('CITYFIBRE_SCHEMA') }}.SEND_EMAIL_NOTIFICATION(VARCHAR, VARCHAR, VARCHAR) TO ROLE PUBLIC;

SELECT 'Email notification procedure created' as status;

-- ========================================
-- Deployment Complete
-- ========================================

SELECT 'SnowMail Native App deployed successfully!' as STATUS,
       'Application: SNOWMAIL' as APP_NAME,
       'Package: SNOWMAIL_PKG' as PACKAGE_NAME,
       'Version: V1_0' as VERSION,
       '{{ DATABASE_NAME | default("CITYFIBRE_AI_DEMO") }}' as DATABASE_NAME,
       'Pipeline: {{ env.CI_PIPELINE_ID | default("Manual") }}' as PIPELINE_ID,
       'Access URL: https://app.snowflake.com/<org>/<account>/#/apps/application/SNOWMAIL/schema/APP_SCHEMA/streamlit/EMAIL_VIEWER' as URL;
