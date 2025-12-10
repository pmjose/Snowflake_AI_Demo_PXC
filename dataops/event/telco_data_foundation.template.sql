-- ============================================================================
-- PXC (PlatformX Communications) AI Demo - Data Foundation (DataOps Template)
-- ============================================================================
-- Description: Creates tables and loads PXC UK connectivity/voice/security data
-- Variables: {{ DATABASE_NAME }}, {{ SCHEMA_NAME }}, {{ DATA_STAGE }}
-- ============================================================================

USE ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};
USE DATABASE {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }};
USE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }};

-- ============================================================================
-- Step 1: Create File Format for CSV Files
-- ============================================================================

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ESCAPE = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = '\134'
    DATE_FORMAT = 'YYYY-MM-DD'
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
    NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');

-- ============================================================================
-- Step 2: Create Dimension Tables
-- ============================================================================

-- Product Category Dimension
CREATE OR REPLACE TABLE product_category_dim (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    vertical VARCHAR(50) NOT NULL
) COMMENT = 'Product categories for PXC UK connectivity, voice, cloud, and managed security services';

-- Product Dimension
CREATE OR REPLACE TABLE product_dim (
    product_key INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_key INT NOT NULL,
    category_name VARCHAR(100),
    vertical VARCHAR(50)
) COMMENT = 'PXC UK services: broadband, TV, mobile, WiFi guarantee, voice/collaboration, and business connectivity';

-- Vendor Dimension
CREATE OR REPLACE TABLE vendor_dim (
    vendor_key INT PRIMARY KEY,
    vendor_name VARCHAR(200) NOT NULL,
    vertical VARCHAR(50) NOT NULL,
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(10),
    zip VARCHAR(20)
) COMMENT = 'PXC UK suppliers and partners: network build, CPE/WiFi, cloud, and content';

-- Customer Dimension
CREATE OR REPLACE TABLE customer_dim (
    customer_key INT PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    industry VARCHAR(100),
    vertical VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(10),
    zip VARCHAR(20)
) COMMENT = 'PXC UK customers across residential, business, public sector, and partner verticals';

-- Account Dimension (Finance)
CREATE OR REPLACE TABLE account_dim (
    account_key INT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50)
) COMMENT = 'Financial account dimension for revenue/expense categorization';

-- Department Dimension
CREATE OR REPLACE TABLE department_dim (
    department_key INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
) COMMENT = 'PXC UK organizational departments';

-- Region Dimension
CREATE OR REPLACE TABLE region_dim (
    region_key INT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL
) COMMENT = 'UK regions: London & South East, Midlands, North West, Yorkshire & Humber, North East, Scotland, Wales, South West, and national backbone';

-- Sales Rep Dimension
CREATE OR REPLACE TABLE sales_rep_dim (
    sales_rep_key INT PRIMARY KEY,
    rep_name VARCHAR(200) NOT NULL,
    hire_date DATE
) COMMENT = 'PXC UK sales representatives and channel account managers';

-- Campaign Dimension (Marketing)
CREATE OR REPLACE TABLE campaign_dim (
    campaign_key INT PRIMARY KEY,
    campaign_name VARCHAR(300) NOT NULL,
    objective VARCHAR(100)
) COMMENT = 'Marketing campaigns: Horizon Launch, Teams Phone Migration, Partner Recruitment';

-- Channel Dimension (Marketing)
CREATE OR REPLACE TABLE channel_dim (
    channel_key INT PRIMARY KEY,
    channel_name VARCHAR(100) NOT NULL
) COMMENT = 'Marketing channels: Channel Partners, Direct Enterprise, Webinars, LinkedIn, Events';

-- Employee Dimension (HR)
CREATE OR REPLACE TABLE employee_dim (
    employee_key INT PRIMARY KEY,
    employee_name VARCHAR(200) NOT NULL,
    gender VARCHAR(1),
    hire_date DATE
) COMMENT = 'PXC UK employees for HR analysis';

-- Job Dimension (HR)
CREATE OR REPLACE TABLE job_dim (
    job_key INT PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    job_level INT
) COMMENT = 'Job titles and levels within PXC UK';

-- Location Dimension (HR)
CREATE OR REPLACE TABLE location_dim (
    location_key INT PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL
) COMMENT = 'PXC UK offices, network hubs, and data centres';

-- ============================================================================
-- Step 3: Create Fact Tables
-- ============================================================================

-- PXC UK KPI Reference (demo)
CREATE OR REPLACE TABLE pxc_kpi (
    metric VARCHAR(200) PRIMARY KEY,
    value NUMBER(18,2),
    as_of_note VARCHAR(200),
    category VARCHAR(50)
) COMMENT = 'Reference KPIs for PXC UK demo (RFS, take-up, financing, speed)';

-- Region RFS and take-up (demo)
CREATE OR REPLACE TABLE region_rfs_progress (
    region_key INT PRIMARY KEY,
    region_name VARCHAR(200),
    premises_rfs NUMBER(18,0),
    takeup_pct NUMBER(6,3),
    avg_install_days INT,
    data_as_of VARCHAR(50)
) COMMENT = 'Region-level ready-for-service counts, take-up %, and install cycle time';

-- Segment ARPA/ARPU (demo)
CREATE OR REPLACE TABLE arpu_segment (
    segment VARCHAR(100) PRIMARY KEY,
    arpa_eur NUMBER(10,2),
    arpu_eur NUMBER(10,2),
    as_of_note VARCHAR(100)
) COMMENT = 'Illustrative ARPA/ARPU by segment for PXC UK demo (values in GBP, column names retained for compatibility)';

-- Install lead time by product category (demo)
CREATE OR REPLACE TABLE install_lead_time (
    product_category VARCHAR(150) PRIMARY KEY,
    avg_install_days INT,
    p90_install_days INT,
    notes VARCHAR(200)
) COMMENT = 'Illustrative install lead times by product category';

-- B2C Customers (demo)
CREATE OR REPLACE TABLE b2c_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    county VARCHAR(100),
    postcode VARCHAR(10),
    plan_name VARCHAR(200),
    speed_mbps INT,
    bundle VARCHAR(100),
    tv_package VARCHAR(100),
    wifi_guarantee BOOLEAN,
    add_ons VARCHAR(200),
    status VARCHAR(50),
    region_key INT
) COMMENT = 'PXC UK B2C broadband/TV/mobile customers (demo)';

-- B2C Subscriptions (demo)
CREATE OR REPLACE TABLE b2c_subscriptions (
    subscription_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES b2c_customers(customer_id),
    product_name VARCHAR(200),
    category_name VARCHAR(150),
    start_date DATE,
    status VARCHAR(50),
    monthly_fee_eur NUMBER(10,2),
    tv_package VARCHAR(100),
    mobile_sims INT,
    wifi_guarantee BOOLEAN
) COMMENT = 'PXC UK B2C subscriptions with bundle details (demo)';

-- City-level subscriber distribution (demo)
CREATE OR REPLACE TABLE city_subs (
    city VARCHAR(100) PRIMARY KEY,
    broadband_subs INT,
    tv_subs INT,
    voice_subs INT,
    mobile_subs INT,
    premises_rfs NUMBER(18,0),
    takeup_pct NUMBER(6,3)
) COMMENT = 'City-level subs, premises RFS, and take-up for broadband, TV, voice, and mobile';

-- Postcode-sector RFS/take-up (demo)
CREATE OR REPLACE TABLE city_sector_rfs (
    city VARCHAR(100),
    postcode_sector VARCHAR(10),
    premises_rfs NUMBER(18,0),
    takeup_pct NUMBER(6,3),
    avg_install_days INT,
    data_as_of VARCHAR(50)
) COMMENT = 'Postcode-sector ready-for-service and take-up by city';

-- ISP tariffs (PXC footprint)
CREATE OR REPLACE TABLE isp_tariffs (
    isp VARCHAR(100),
    product VARCHAR(150),
    speed_mbps NUMBER(10,0),
    standard_fee_gbp NUMBER(10,2),
    promo_fee_gbp NUMBER(10,2),
    promo_months INT,
    contract_months INT,
    cityfibre_footprint BOOLEAN,
    notes VARCHAR(200)
) COMMENT = 'Current ISP tariffs on PXC footprint with promo and contract detail';

-- Sales Fact Table
CREATE OR REPLACE TABLE sales_fact (
    sale_id INT PRIMARY KEY,
    date DATE NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    sales_rep_key INT NOT NULL,
    region_key INT NOT NULL,
    vendor_key INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    units INT NOT NULL
) COMMENT = 'B2B sales transactions for UCaaS, CCaaS, Voice, Connectivity products';

-- Finance Transactions Fact Table
CREATE OR REPLACE TABLE finance_transactions (
    transaction_id INT PRIMARY KEY,
    date DATE NOT NULL,
    account_key INT NOT NULL,
    department_key INT NOT NULL,
    vendor_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    procurement_method VARCHAR(50),
    approver_id INT,
    approval_date DATE,
    purchase_order_number VARCHAR(50),
    contract_reference VARCHAR(100),
    CONSTRAINT fk_approver FOREIGN KEY (approver_id) REFERENCES employee_dim(employee_key)
) COMMENT = 'Financial transactions with compliance tracking. approval_status should be Approved/Pending/Rejected. procurement_method should be RFP/Quotes/Emergency/Contract';

-- Marketing Campaign Fact Table
CREATE OR REPLACE TABLE marketing_campaign_fact (
    campaign_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    campaign_key INT NOT NULL,
    product_key INT NOT NULL,
    channel_key INT NOT NULL,
    region_key INT NOT NULL,
    spend DECIMAL(10,2) NOT NULL,
    leads_generated INT NOT NULL,
    impressions INT NOT NULL
) COMMENT = 'Marketing campaign performance metrics';

-- HR Employee Fact Table
CREATE OR REPLACE TABLE hr_employee_fact (
    hr_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    job_key INT NOT NULL,
    location_key INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    attrition_flag INT NOT NULL
) COMMENT = 'HR employee records for workforce analysis';

-- ============================================================================
-- Step 4: Create Salesforce CRM Tables
-- ============================================================================

-- Salesforce Accounts Table
CREATE OR REPLACE TABLE sf_accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    account_name VARCHAR(200) NOT NULL,
    customer_key INT NOT NULL,
    industry VARCHAR(100),
    vertical VARCHAR(50),
    billing_street VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(10),
    billing_postal_code VARCHAR(20),
    account_type VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    employees INT,
    created_date DATE
) COMMENT = 'Salesforce accounts linked to customer dimension';

-- Salesforce Opportunities Table
CREATE OR REPLACE TABLE sf_opportunities (
    opportunity_id VARCHAR(20) PRIMARY KEY,
    sale_id INT,
    account_id VARCHAR(20) NOT NULL,
    opportunity_name VARCHAR(200) NOT NULL,
    stage_name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    probability DECIMAL(5,2),
    close_date DATE,
    created_date DATE,
    lead_source VARCHAR(100),
    type VARCHAR(100),
    campaign_id INT
) COMMENT = 'Sales pipeline opportunities with stage tracking';

-- Salesforce Contacts Table
CREATE OR REPLACE TABLE sf_contacts (
    contact_id VARCHAR(20) PRIMARY KEY,
    opportunity_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    title VARCHAR(100),
    department VARCHAR(100),
    lead_source VARCHAR(100),
    campaign_no INT,
    created_date DATE
) COMMENT = 'CRM contacts associated with accounts and opportunities';

-- ============================================================================
-- Step 5: Load Dimension Data from Stage
-- ============================================================================

-- Load Product Category Dimension
COPY INTO product_category_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/product_category_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Product Dimension
COPY INTO product_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/product_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Vendor Dimension
COPY INTO vendor_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/vendor_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Customer Dimension
COPY INTO customer_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/customer_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Account Dimension
COPY INTO account_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/account_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Department Dimension
COPY INTO department_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/department_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Region Dimension
COPY INTO region_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/region_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Sales Rep Dimension
COPY INTO sales_rep_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/sales_rep_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Campaign Dimension
COPY INTO campaign_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/campaign_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Channel Dimension
COPY INTO channel_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/channel_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Employee Dimension
COPY INTO employee_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/employee_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Job Dimension
COPY INTO job_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/job_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Location Dimension
COPY INTO location_dim
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/location_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load PXC UK KPI Reference
COPY INTO pxc_kpi
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/pxc_kpi.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Region RFS/Take-up
COPY INTO region_rfs_progress
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/region_rfs_progress.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load ARPA/ARPU by Segment
COPY INTO arpu_segment
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/arpu_segment.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Install Lead Times
COPY INTO install_lead_time
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/install_lead_time.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load B2C Customers
COPY INTO b2c_customers
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/b2c_customers.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load B2C Subscriptions
COPY INTO b2c_subscriptions
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/b2c_subscriptions.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load City-level subscriber distribution
COPY INTO city_subs
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/city_subs.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Postcode-sector RFS
COPY INTO city_sector_rfs
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/city_sector_rfs.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load ISP tariffs
COPY INTO isp_tariffs
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/isp_tariffs.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load PXC UK KPI Reference
COPY INTO pxc_kpi
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/pxc_kpi.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================================
-- Step 6: Load Fact Data from Stage
-- ============================================================================

-- Load Sales Fact
COPY INTO sales_fact
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/sales_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Finance Transactions
COPY INTO finance_transactions
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/finance_transactions.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Marketing Campaign Fact
COPY INTO marketing_campaign_fact
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/marketing_campaign_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load HR Employee Fact
COPY INTO hr_employee_fact
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/hr_employee_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================================
-- Step 7: Load Salesforce Data from Stage
-- ============================================================================

-- Load Salesforce Accounts
COPY INTO sf_accounts
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/sf_accounts.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Salesforce Opportunities
COPY INTO sf_opportunities
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/sf_opportunities.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Salesforce Contacts
COPY INTO sf_contacts
FROM @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}/demo_data/sf_contacts.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ============================================================================
-- Step 8: Verification
-- ============================================================================

-- Verify data loads
SELECT 'DIMENSION TABLES' as category, '' as table_name, NULL as row_count
UNION ALL
SELECT '', 'product_category_dim', COUNT(*) FROM product_category_dim
UNION ALL
SELECT '', 'product_dim', COUNT(*) FROM product_dim
UNION ALL
SELECT '', 'vendor_dim', COUNT(*) FROM vendor_dim
UNION ALL
SELECT '', 'customer_dim', COUNT(*) FROM customer_dim
UNION ALL
SELECT '', 'account_dim', COUNT(*) FROM account_dim
UNION ALL
SELECT '', 'department_dim', COUNT(*) FROM department_dim
UNION ALL
SELECT '', 'region_dim', COUNT(*) FROM region_dim
UNION ALL
SELECT '', 'sales_rep_dim', COUNT(*) FROM sales_rep_dim
UNION ALL
SELECT '', 'campaign_dim', COUNT(*) FROM campaign_dim
UNION ALL
SELECT '', 'channel_dim', COUNT(*) FROM channel_dim
UNION ALL
SELECT '', 'employee_dim', COUNT(*) FROM employee_dim
UNION ALL
SELECT '', 'job_dim', COUNT(*) FROM job_dim
UNION ALL
SELECT '', 'location_dim', COUNT(*) FROM location_dim
UNION ALL
SELECT '', 'b2c_customers', COUNT(*) FROM b2c_customers
UNION ALL
SELECT '', 'city_subs', COUNT(*) FROM city_subs
UNION ALL
SELECT '', '', NULL
UNION ALL
SELECT 'FACT TABLES', '', NULL
UNION ALL
SELECT '', 'sales_fact', COUNT(*) FROM sales_fact
UNION ALL
SELECT '', 'finance_transactions', COUNT(*) FROM finance_transactions
UNION ALL
SELECT '', 'marketing_campaign_fact', COUNT(*) FROM marketing_campaign_fact
UNION ALL
SELECT '', 'hr_employee_fact', COUNT(*) FROM hr_employee_fact
UNION ALL
SELECT '', 'region_rfs_progress', COUNT(*) FROM region_rfs_progress
UNION ALL
SELECT '', 'arpu_segment', COUNT(*) FROM arpu_segment
UNION ALL
SELECT '', 'install_lead_time', COUNT(*) FROM install_lead_time
UNION ALL
SELECT '', 'pxc_kpi', COUNT(*) FROM pxc_kpi
UNION ALL
SELECT '', 'b2c_subscriptions', COUNT(*) FROM b2c_subscriptions
UNION ALL
SELECT '', '', NULL
UNION ALL
SELECT 'SALESFORCE TABLES', '', NULL
UNION ALL
SELECT '', 'sf_accounts', COUNT(*) FROM sf_accounts
UNION ALL
SELECT '', 'sf_opportunities', COUNT(*) FROM sf_opportunities
UNION ALL
SELECT '', 'sf_contacts', COUNT(*) FROM sf_contacts;

-- Show all tables
SHOW TABLES IN SCHEMA {{ env.EVENT_SCHEMA | default('CITYFIBRE_UK_SCHEMA') }};

SELECT 'PXC AI Demo data foundation complete!' AS status,
       '{{ env.EVENT_DATABASE | default("CITYFIBRE_UK_AI_DEMO") }}' AS database_name,
       CURRENT_TIMESTAMP() AS loaded_at;
