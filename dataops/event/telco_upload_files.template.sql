-- ============================================================================
-- PXC (PlatformX Communications) AI Demo - Upload Files to Stages (DataOps Template)
-- ============================================================================
-- Description: Uploads CSV data files and unstructured documents to stages
-- Variables: {{ DATABASE_NAME }}, {{ WAREHOUSE_NAME }}, {{ SCHEMA_NAME }}
-- ============================================================================

USE ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};
USE DATABASE {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }};
USE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }};

-- ============================================================================
-- Step 1: Upload CSV Data Files to DATA_STAGE/demo_data/
-- ============================================================================

-- Upload all PXC demo CSV data files (dimensions, facts, salesforce tables)
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/account_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/campaign_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/channel_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/customer_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/department_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/employee_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/finance_transactions.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/hr_employee_fact.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/job_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/location_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/marketing_campaign_fact.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/product_category_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/product_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/pxc_kpi.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/region_rfs_progress.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/arpu_segment.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/install_lead_time.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/region_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/sales_fact.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/sales_rep_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/sf_accounts.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/sf_contacts.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/sf_opportunities.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/b2c_customers.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/b2c_subscriptions.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/pxc_kpi.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/city_subs.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/demo_data/vendor_dim.csv' @DATA_STAGE/demo_data/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- ============================================================================
-- Step 2: Upload PXC Unstructured Documents to DATA_STAGE/unstructured_docs/
-- ============================================================================

-- Upload PXC finance/strategy/network/sales/marketing/HR docs (markdown)
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/finance/*.md' @DATA_STAGE/unstructured_docs/finance/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/strategy/*.md' @DATA_STAGE/unstructured_docs/strategy/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/network/*.md' @DATA_STAGE/unstructured_docs/network/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/sales/*.md' @DATA_STAGE/unstructured_docs/sales/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/marketing/*.md' @DATA_STAGE/unstructured_docs/marketing/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/hr/*.md' @DATA_STAGE/unstructured_docs/hr/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;
PUT 'file://{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/unstructured_docs/demo/*.md' @DATA_STAGE/unstructured_docs/demo/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE PARALLEL=4;

-- Optional: upload PXC / Liberty Global reports (provide your own files)
-- Example:
-- PUT 'file://{{ env.CI_PROJECT_DIR }}/reports/FY24-Trading-Update-FINAL2100225.pdf' @DATA_STAGE/unstructured_docs/finance/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT 'file://{{ env.CI_PROJECT_DIR }}/reports/LibertyGlobal-Investor-Update.pdf' @DATA_STAGE/unstructured_docs/strategy/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- ============================================================================
-- Step 3: Refresh Stage Metadata (for Directory Tables)
-- ============================================================================

-- Refresh all stages to update directory metadata after file uploads
ALTER STAGE DATA_STAGE REFRESH;

SELECT 'Stage metadata refreshed' AS status;

-- ============================================================================
-- Step 4: Verify Uploaded Files
-- ============================================================================

-- List files in DATA_STAGE
SELECT 'Files in DATA_STAGE:' as stage_info;
LIST @DATA_STAGE;

-- Count files by folder
SELECT 
    CASE 
        WHEN RELATIVE_PATH LIKE 'demo_data/%' THEN 'demo_data (CSVs)'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/demo/%' THEN 'unstructured_docs/demo'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/finance/%' THEN 'unstructured_docs/finance'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/hr/%' THEN 'unstructured_docs/hr'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/marketing/%' THEN 'unstructured_docs/marketing'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/network/%' THEN 'unstructured_docs/network'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/sales/%' THEN 'unstructured_docs/sales'
        WHEN RELATIVE_PATH LIKE 'unstructured_docs/strategy/%' THEN 'unstructured_docs/strategy'
        ELSE 'Other'
    END as folder,
    COUNT(*) as file_count,
    ROUND(SUM(SIZE) / 1024 / 1024, 2) as total_size_mb
FROM DIRECTORY(@DATA_STAGE)
GROUP BY folder
ORDER BY folder;

-- ============================================================================
-- Verification Output
-- ============================================================================

SELECT 'File upload complete!' AS status,
       '{{ env.EVENT_DATABASE | default("PXC_AI_DEMO") }}' AS database_name,
       CURRENT_TIMESTAMP() AS uploaded_at;
