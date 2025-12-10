-- ============================================================================
-- PXC (PlatformX Communications) AI Demo - Semantic Views for Cortex Analyst (DataOps Template)
-- ============================================================================
-- Description: Creates business unit-specific semantic views for natural language queries
-- Based on: https://docs.snowflake.com/en/user-guide/views-semantic/sql
-- ============================================================================

-- Use ACCOUNTADMIN to own semantic views (allows editing in Snowsight)
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};
USE DATABASE {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }};
USE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }};

-- ============================================================================
-- FINANCE SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW FINANCE_SEMANTIC_VIEW
    tables (
        TRANSACTIONS as FINANCE_TRANSACTIONS primary key (TRANSACTION_ID) with synonyms=('finance transactions','financial data') comment='All financial transactions across departments',
        ACCOUNTS as ACCOUNT_DIM primary key (ACCOUNT_KEY) with synonyms=('chart of accounts','account types') comment='Account dimension for financial categorization',
        DEPARTMENTS as DEPARTMENT_DIM primary key (DEPARTMENT_KEY) with synonyms=('business units','departments') comment='Department dimension for cost center analysis',
        VENDORS as VENDOR_DIM primary key (VENDOR_KEY) with synonyms=('suppliers','vendors') comment='Vendor information for spend analysis',
        PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','items') comment='Product dimension for transaction analysis',
        CUSTOMERS as CUSTOMER_DIM primary key (CUSTOMER_KEY) with synonyms=('clients','customers') comment='Customer dimension for revenue analysis'
    )
    relationships (
        TRANSACTIONS_TO_ACCOUNTS as TRANSACTIONS(ACCOUNT_KEY) references ACCOUNTS(ACCOUNT_KEY),
        TRANSACTIONS_TO_DEPARTMENTS as TRANSACTIONS(DEPARTMENT_KEY) references DEPARTMENTS(DEPARTMENT_KEY),
        TRANSACTIONS_TO_VENDORS as TRANSACTIONS(VENDOR_KEY) references VENDORS(VENDOR_KEY),
        TRANSACTIONS_TO_PRODUCTS as TRANSACTIONS(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
        TRANSACTIONS_TO_CUSTOMERS as TRANSACTIONS(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY)
    )
    facts (
        TRANSACTIONS.TRANSACTION_AMOUNT as amount comment='Transaction amount in pounds (GBP)',
        TRANSACTIONS.TRANSACTION_RECORD as 1 comment='Count of transactions'
    )
    dimensions (
        TRANSACTIONS.TRANSACTION_DATE as date with synonyms=('date','transaction date') comment='Date of the financial transaction',
        TRANSACTIONS.TRANSACTION_MONTH as MONTH(date) comment='Month of the transaction',
        TRANSACTIONS.TRANSACTION_YEAR as YEAR(date) comment='Year of the transaction',
        ACCOUNTS.ACCOUNT_NAME as account_name with synonyms=('account','account type') comment='Name of the account',
        ACCOUNTS.ACCOUNT_TYPE as account_type with synonyms=('type','category') comment='Type of account (Income/Expense)',
        DEPARTMENTS.DEPARTMENT_NAME as department_name with synonyms=('department','business unit') comment='Name of the department',
        VENDORS.VENDOR_NAME as vendor_name with synonyms=('vendor','supplier') comment='Name of the vendor',
        PRODUCTS.PRODUCT_NAME as product_name with synonyms=('product','item') comment='Name of the product',
        CUSTOMERS.CUSTOMER_NAME as customer_name with synonyms=('customer','client') comment='Name of the customer',
        CUSTOMERS.INDUSTRY as INDUSTRY with synonyms=('industry','customer industry','sector') comment='Customer industry sector',
        CUSTOMERS.VERTICAL as VERTICAL with synonyms=('vertical','segment','customer segment') comment='Customer vertical/segment (SMB/Enterprise/Public Sector/Partner)',
        TRANSACTIONS.APPROVAL_STATUS as approval_status with synonyms=('approval','status','approval state') comment='Transaction approval status (Approved/Pending/Rejected)',
        TRANSACTIONS.PROCUREMENT_METHOD as procurement_method with synonyms=('procurement','method','purchase method') comment='Method of procurement (RFP/Quotes/Emergency/Contract)',
        TRANSACTIONS.APPROVER_ID as approver_id with synonyms=('approver','approver employee id') comment='Employee ID of the approver from HR',
        TRANSACTIONS.APPROVAL_DATE as approval_date with synonyms=('approved date','date approved') comment='Date when transaction was approved',
        TRANSACTIONS.PURCHASE_ORDER_NUMBER as purchase_order_number with synonyms=('PO number','PO','purchase order') comment='Purchase order number for tracking',
        TRANSACTIONS.CONTRACT_REFERENCE as contract_reference with synonyms=('contract','contract number','contract ref') comment='Reference to related contract'
    )
    metrics (
        TRANSACTIONS.AVERAGE_AMOUNT as AVG(transactions.amount) comment='Average transaction amount',
        TRANSACTIONS.TOTAL_AMOUNT as SUM(transactions.amount) comment='Total transaction amount',
        TRANSACTIONS.TOTAL_TRANSACTIONS as COUNT(transactions.transaction_record) comment='Total number of transactions'
    )
    comment='Semantic view for financial analysis and reporting';

-- ============================================================================
-- SALES SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SALES_SEMANTIC_VIEW
  tables (
    CUSTOMERS as CUSTOMER_DIM primary key (CUSTOMER_KEY) with synonyms=('clients','customers','accounts') comment='Customer information for sales analysis',
    PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','items','SKUs') comment='Product catalog for sales analysis',
    PRODUCT_CATEGORY_DIM primary key (CATEGORY_KEY),
    REGIONS as REGION_DIM primary key (REGION_KEY) with synonyms=('territories','regions','areas') comment='Regional information for territory analysis',
    SALES as SALES_FACT primary key (SALE_ID) with synonyms=('sales transactions','sales data') comment='All sales transactions and deals',
    SALES_REPS as SALES_REP_DIM primary key (SALES_REP_KEY) with synonyms=('sales representatives','reps','salespeople') comment='Sales representative information',
    VENDORS as VENDOR_DIM primary key (VENDOR_KEY) with synonyms=('suppliers','vendors') comment='Vendor information for supply chain analysis',
    ISP_TARIFFS as ISP_TARIFFS with synonyms=('isp pricing','tariffs','retail pricing') comment='ISP tariffs on PXC footprint with promo and contract details'
  )
  relationships (
    PRODUCT_TO_CATEGORY as PRODUCTS(CATEGORY_KEY) references PRODUCT_CATEGORY_DIM(CATEGORY_KEY),
    SALES_TO_CUSTOMERS as SALES(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY),
    SALES_TO_PRODUCTS as SALES(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
    SALES_TO_REGIONS as SALES(REGION_KEY) references REGIONS(REGION_KEY),
    SALES_TO_REPS as SALES(SALES_REP_KEY) references SALES_REPS(SALES_REP_KEY),
    SALES_TO_VENDORS as SALES(VENDOR_KEY) references VENDORS(VENDOR_KEY)
  )
  facts (
    SALES.SALE_AMOUNT as amount comment='Sale amount in pounds (GBP)',
    SALES.SALE_RECORD as 1 comment='Count of sales transactions',
    SALES.UNITS_SOLD as units comment='Number of units sold'
  )
  dimensions (
    CUSTOMERS.INDUSTRY as INDUSTRY with synonyms=('industry','customer type','customer industry') comment='Customer industry sector',
    CUSTOMERS.CUSTOMER_KEY as CUSTOMER_KEY,
    CUSTOMERS.CUSTOMER_NAME as customer_name with synonyms=('customer','client','account') comment='Name of the customer',
    PRODUCTS.CATEGORY_KEY as CATEGORY_KEY with synonyms=('category_id','product_category','category_code','classification_key','group_key','product_group_id') comment='Unique identifier for the product category.',
    PRODUCTS.PRODUCT_KEY as PRODUCT_KEY,
    PRODUCTS.PRODUCT_NAME as product_name with synonyms=('product','item') comment='Name of the product',
    PRODUCT_CATEGORY_DIM.CATEGORY_KEY as CATEGORY_KEY with synonyms=('category_id','category_code','product_category_number','category_identifier','classification_key') comment='Unique identifier for a product category.',
    PRODUCT_CATEGORY_DIM.CATEGORY_NAME as CATEGORY_NAME with synonyms=('category_title','product_group','classification_name','category_label','product_category_description') comment='The category to which a product belongs, such as electronics, clothing, or software as a service.',
    PRODUCT_CATEGORY_DIM.VERTICAL as VERTICAL with synonyms=('industry','sector','market','category_group','business_area','domain') comment='The industry or sector in which a product is categorized, such as retail, technology, or manufacturing.',
    REGIONS.REGION_KEY as REGION_KEY,
    REGIONS.REGION_NAME as region_name with synonyms=('region','territory','area') comment='Name of the region',
    SALES.CUSTOMER_KEY as CUSTOMER_KEY,
    SALES.PRODUCT_KEY as PRODUCT_KEY,
    SALES.REGION_KEY as REGION_KEY,
    SALES.SALES_REP_KEY as SALES_REP_KEY,
    SALES.SALE_DATE as date with synonyms=('date','sale date','transaction date') comment='Date of the sale',
    SALES.SALE_ID as SALE_ID,
    SALES.SALE_MONTH as MONTH(date) comment='Month of the sale',
    SALES.SALE_YEAR as YEAR(date) comment='Year of the sale',
    SALES.VENDOR_KEY as VENDOR_KEY,
    SALES_REPS.SALES_REP_KEY as SALES_REP_KEY,
    SALES_REPS.SALES_REP_NAME as REP_NAME with synonyms=('sales rep','representative','salesperson') comment='Name of the sales representative',
    VENDORS.VENDOR_KEY as VENDOR_KEY,
    VENDORS.VENDOR_NAME as vendor_name with synonyms=('vendor','supplier','provider') comment='Name of the vendor',
    ISP_TARIFFS.ISP as isp with synonyms=('provider','partner','isp partner') comment='Retail ISP on PXC footprint',
    ISP_TARIFFS.PRODUCT as isp_product with synonyms=('tariff','isp offer') comment='ISP retail product name',
    ISP_TARIFFS.SPEED_MBPS as isp_speed_mbps with synonyms=('speed','tier') comment='Advertised downstream speed in Mbps',
    ISP_TARIFFS.STANDARD_FEE_GBP as isp_standard_fee_gbp with synonyms=('standard price','monthly fee') comment='Standard monthly fee in GBP',
    ISP_TARIFFS.PROMO_FEE_GBP as isp_promo_fee_gbp with synonyms=('promo price','offer price') comment='Promotional monthly fee in GBP',
    ISP_TARIFFS.PROMO_MONTHS as isp_promo_months with synonyms=('promo duration','offer months') comment='Months promo pricing applies',
    ISP_TARIFFS.CONTRACT_MONTHS as isp_contract_months with synonyms=('contract length','term') comment='Contract term in months',
    ISP_TARIFFS.CITYFIBRE_FOOTPRINT as isp_on_cityfibre with synonyms=('on cityfibre','cf footprint') comment='Whether tariff applies on PXC footprint',
    ISP_TARIFFS.NOTES as isp_notes comment='Tariff notes'
  )
  metrics (
    SALES.AVERAGE_DEAL_SIZE as AVG(sales.amount) comment='Average deal size',
    SALES.AVERAGE_UNITS_PER_SALE as AVG(sales.units) comment='Average units per sale',
    SALES.TOTAL_DEALS as COUNT(sales.sale_record) comment='Total number of deals',
    SALES.TOTAL_REVENUE as SUM(sales.amount) comment='Total sales revenue',
    SALES.TOTAL_UNITS as SUM(sales.units) comment='Total units sold',
    ISP_TARIFFS.AVG_STANDARD_FEE as AVG(isp_tariffs.standard_fee_gbp) comment='Average standard monthly fee (GBP)',
    ISP_TARIFFS.AVG_PROMO_FEE as AVG(isp_tariffs.promo_fee_gbp) comment='Average promotional monthly fee (GBP)'
  )
  comment='Semantic view for PXC UK broadband/TV/mobile sales analysis'
  with extension (CA='{"tables":[{"name":"CUSTOMERS","dimensions":[{"name":"CUSTOMER_KEY"},{"name":"CUSTOMER_NAME","sample_values":["Manchester Media Group","Leeds Retail Holdings","Glasgow Tech Services"]},{"name":"INDUSTRY","sample_values":["Healthcare","Manufacturing","Financial Services","Technology","Public Sector","Retail","Hospitality"]}]},{"name":"PRODUCTS","dimensions":[{"name":"CATEGORY_KEY","unique":false},{"name":"PRODUCT_KEY"},{"name":"PRODUCT_NAME","sample_values":["PXC Fibre Broadband 1G","Business Internet 10G","Metro Dark Fibre Pair","Small Cell Backhaul","Data Centre Connect London"]}]},{"name":"PRODUCT_CATEGORY_DIM","dimensions":[{"name":"CATEGORY_KEY","sample_values":["1","2","3","4","5","6","7","8","9","10"]},{"name":"CATEGORY_NAME","sample_values":["Home Broadband & WiFi","Business Internet & Ethernet","Backbone & Dark Fibre","Mobile & Backhaul","Wholesale & Partner Access","Smart City & Public Sector","Professional & Managed Services","Managed WiFi & Security","Channel Partner Enablement","Cloud & Data Centre Access"]},{"name":"VERTICAL","sample_values":["Homes","Enterprise","Public Sector","Partner","Mobile","All"]}]},{"name":"REGIONS","dimensions":[{"name":"REGION_KEY"},{"name":"REGION_NAME","sample_values":["London & South East","Midlands","North West England","Yorkshire & Humber","North East England","Scotland Central Belt","Scotland North","Wales","South West England"]}]},{"name":"SALES","dimensions":[{"name":"CUSTOMER_KEY"},{"name":"PRODUCT_KEY"},{"name":"REGION_KEY"},{"name":"SALES_REP_KEY"},{"name":"SALE_DATE","sample_values":["2024-01-01","2024-06-15","2024-12-01"]},{"name":"SALE_ID"},{"name":"SALE_MONTH"},{"name":"SALE_YEAR"},{"name":"VENDOR_KEY"}],"facts":[{"name":"SALE_AMOUNT"},{"name":"SALE_RECORD"},{"name":"UNITS_SOLD"}],"metrics":[{"name":"AVERAGE_DEAL_SIZE"},{"name":"AVERAGE_UNITS_PER_SALE"},{"name":"TOTAL_DEALS"},{"name":"TOTAL_REVENUE"},{"name":"TOTAL_UNITS"}]},{"name":"SALES_REPS","dimensions":[{"name":"SALES_REP_KEY"},{"name":"SALES_REP_NAME","sample_values":["Daniel Jones","Luna Anderson","Charlotte Scott"]}]},{"name":"VENDORS","dimensions":[{"name":"VENDOR_KEY"},{"name":"VENDOR_NAME","sample_values":["Construction Partner A","Cisco UK","Amazon Web Services UK","Openreach","Sky UK"]}]}],"relationships":[{"name":"PRODUCT_TO_CATEGORY"},{"name":"SALES_TO_CUSTOMERS","relationship_type":"many_to_one"},{"name":"SALES_TO_PRODUCTS","relationship_type":"many_to_one"},{"name":"SALES_TO_REGIONS","relationship_type":"many_to_one"},{"name":"SALES_TO_REPS","relationship_type":"many_to_one"},{"name":"SALES_TO_VENDORS","relationship_type":"many_to_one"}]}');

-- ============================================================================
-- MARKETING SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW MARKETING_SEMANTIC_VIEW
  tables (
    ACCOUNTS as SF_ACCOUNTS primary key (ACCOUNT_ID) with synonyms=('customers','accounts','clients') comment='Customer account information for revenue analysis',
    CAMPAIGNS as MARKETING_CAMPAIGN_FACT primary key (CAMPAIGN_FACT_ID) with synonyms=('marketing campaigns','campaign data') comment='Marketing campaign performance data',
    CAMPAIGN_DETAILS as CAMPAIGN_DIM primary key (CAMPAIGN_KEY) with synonyms=('campaign info','campaign details') comment='Campaign dimension with objectives and names',
    CHANNELS as CHANNEL_DIM primary key (CHANNEL_KEY) with synonyms=('marketing channels','channels') comment='Marketing channel information',
    CONTACTS as SF_CONTACTS primary key (CONTACT_ID) with synonyms=('leads','contacts','prospects') comment='Contact records generated from marketing campaigns',
    CONTACTS_FOR_OPPORTUNITIES as SF_CONTACTS primary key (CONTACT_ID) with synonyms=('opportunity contacts') comment='Contact records generated from marketing campaigns, specifically for opportunities, not leads',
    OPPORTUNITIES as SF_OPPORTUNITIES primary key (OPPORTUNITY_ID) with synonyms=('deals','opportunities','sales pipeline') comment='Sales opportunities and revenue data',
    PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','items') comment='Product dimension for campaign-specific analysis',
    REGIONS as REGION_DIM primary key (REGION_KEY) with synonyms=('territories','regions','markets') comment='Regional information for campaign analysis'
  )
  relationships (
    CAMPAIGNS_TO_CHANNELS as CAMPAIGNS(CHANNEL_KEY) references CHANNELS(CHANNEL_KEY),
    CAMPAIGNS_TO_DETAILS as CAMPAIGNS(CAMPAIGN_KEY) references CAMPAIGN_DETAILS(CAMPAIGN_KEY),
    CAMPAIGNS_TO_PRODUCTS as CAMPAIGNS(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
    CAMPAIGNS_TO_REGIONS as CAMPAIGNS(REGION_KEY) references REGIONS(REGION_KEY),
    CONTACTS_TO_ACCOUNTS as CONTACTS(ACCOUNT_ID) references ACCOUNTS(ACCOUNT_ID),
    CONTACTS_TO_CAMPAIGNS as CONTACTS(CAMPAIGN_NO) references CAMPAIGNS(CAMPAIGN_FACT_ID),
    CONTACTS_TO_OPPORTUNITIES as CONTACTS_FOR_OPPORTUNITIES(OPPORTUNITY_ID) references OPPORTUNITIES(OPPORTUNITY_ID),
    OPPORTUNITIES_TO_ACCOUNTS as OPPORTUNITIES(ACCOUNT_ID) references ACCOUNTS(ACCOUNT_ID),
    OPPORTUNITIES_TO_CAMPAIGNS as OPPORTUNITIES(CAMPAIGN_ID) references CAMPAIGNS(CAMPAIGN_FACT_ID)
  )
  facts (
    PUBLIC CAMPAIGNS.CAMPAIGN_RECORD as 1 comment='Count of campaign activities',
    PUBLIC CAMPAIGNS.CAMPAIGN_SPEND as spend comment='Marketing spend in pounds (GBP)',
    PUBLIC CAMPAIGNS.IMPRESSIONS as IMPRESSIONS comment='Number of impressions',
    PUBLIC CAMPAIGNS.LEADS_GENERATED as LEADS_GENERATED comment='Number of leads generated',
    PUBLIC CONTACTS.CONTACT_RECORD as 1 comment='Count of contacts generated',
    PUBLIC OPPORTUNITIES.OPPORTUNITY_RECORD as 1 comment='Count of opportunities created',
    PUBLIC OPPORTUNITIES.REVENUE as AMOUNT comment='Opportunity revenue in pounds (GBP)'
  )
  dimensions (
    PUBLIC ACCOUNTS.ACCOUNT_ID as ACCOUNT_ID,
    PUBLIC ACCOUNTS.ACCOUNT_NAME as ACCOUNT_NAME with synonyms=('customer name','client name','company') comment='Name of the customer account',
    PUBLIC ACCOUNTS.ACCOUNT_TYPE as ACCOUNT_TYPE with synonyms=('customer type','account category') comment='Type of customer account',
    PUBLIC ACCOUNTS.ANNUAL_REVENUE as ANNUAL_REVENUE with synonyms=('customer revenue','company revenue') comment='Customer annual revenue',
    PUBLIC ACCOUNTS.EMPLOYEES as EMPLOYEES with synonyms=('company size','employee count') comment='Number of employees at customer',
    PUBLIC ACCOUNTS.INDUSTRY as INDUSTRY with synonyms=('industry','sector') comment='Customer industry',
    PUBLIC ACCOUNTS.SALES_CUSTOMER_KEY as CUSTOMER_KEY with synonyms=('Customer No','Customer ID') comment='This is the customer key thank links the Salesforce account to customers table.',
    PUBLIC CAMPAIGNS.CAMPAIGN_DATE as date with synonyms=('date','campaign date') comment='Date of the campaign activity',
    PUBLIC CAMPAIGNS.CAMPAIGN_FACT_ID as CAMPAIGN_FACT_ID,
    PUBLIC CAMPAIGNS.CAMPAIGN_KEY as CAMPAIGN_KEY,
    PUBLIC CAMPAIGNS.CAMPAIGN_MONTH as MONTH(date) comment='Month of the campaign',
    PUBLIC CAMPAIGNS.CAMPAIGN_YEAR as YEAR(date) comment='Year of the campaign',
    PUBLIC CAMPAIGNS.CHANNEL_KEY as CHANNEL_KEY,
    PUBLIC CAMPAIGNS.PRODUCT_KEY as PRODUCT_KEY with synonyms=('product_id','product identifier') comment='Product identifier for campaign targeting',
    PUBLIC CAMPAIGNS.REGION_KEY as REGION_KEY,
    PUBLIC CAMPAIGN_DETAILS.CAMPAIGN_KEY as CAMPAIGN_KEY,
    PUBLIC CAMPAIGN_DETAILS.CAMPAIGN_NAME as CAMPAIGN_NAME with synonyms=('campaign','campaign title') comment='Name of the marketing campaign',
    PUBLIC CAMPAIGN_DETAILS.CAMPAIGN_OBJECTIVE as OBJECTIVE with synonyms=('objective','goal','purpose') comment='Campaign objective',
    PUBLIC CHANNELS.CHANNEL_KEY as CHANNEL_KEY,
    PUBLIC CHANNELS.CHANNEL_NAME as CHANNEL_NAME with synonyms=('channel','marketing channel') comment='Name of the marketing channel',
    PUBLIC CONTACTS.ACCOUNT_ID as ACCOUNT_ID,
    PUBLIC CONTACTS.CAMPAIGN_NO as CAMPAIGN_NO,
    PUBLIC CONTACTS.CONTACT_ID as CONTACT_ID,
    PUBLIC CONTACTS.DEPARTMENT as DEPARTMENT with synonyms=('department','business unit') comment='Contact department',
    PUBLIC CONTACTS.EMAIL as EMAIL with synonyms=('email','email address') comment='Contact email address',
    PUBLIC CONTACTS.FIRST_NAME as FIRST_NAME with synonyms=('first name','contact name') comment='Contact first name',
    PUBLIC CONTACTS.LAST_NAME as LAST_NAME with synonyms=('last name','surname') comment='Contact last name',
    PUBLIC CONTACTS.LEAD_SOURCE as LEAD_SOURCE with synonyms=('lead source','source') comment='How the contact was generated',
    PUBLIC CONTACTS.OPPORTUNITY_ID as OPPORTUNITY_ID,
    PUBLIC CONTACTS.TITLE as TITLE with synonyms=('job title','position') comment='Contact job title',
    PUBLIC OPPORTUNITIES.ACCOUNT_ID as ACCOUNT_ID,
    PUBLIC OPPORTUNITIES.CAMPAIGN_ID as CAMPAIGN_ID with synonyms=('campaign fact id','marketing campaign id') comment='Campaign fact ID that links opportunity to marketing campaign',
    PUBLIC OPPORTUNITIES.CLOSE_DATE as CLOSE_DATE with synonyms=('close date','expected close') comment='Expected or actual close date',
    PUBLIC OPPORTUNITIES.OPPORTUNITY_ID as OPPORTUNITY_ID,
    PUBLIC OPPORTUNITIES.OPPORTUNITY_LEAD_SOURCE as lead_source with synonyms=('opportunity source','deal source') comment='Source of the opportunity',
    PUBLIC OPPORTUNITIES.OPPORTUNITY_NAME as OPPORTUNITY_NAME with synonyms=('deal name','opportunity title') comment='Name of the sales opportunity',
    PUBLIC OPPORTUNITIES.OPPORTUNITY_STAGE as STAGE_NAME comment='Stage name of the opportinity. Closed Won indicates an actual sale with revenue',
    PUBLIC OPPORTUNITIES.OPPORTUNITY_TYPE as TYPE with synonyms=('deal type','opportunity type') comment='Type of opportunity',
    PUBLIC OPPORTUNITIES.SALES_SALE_ID as SALE_ID with synonyms=('sales id','invoice no') comment='Sales_ID for sales_fact table that links this opp to a sales record.',
    PUBLIC PRODUCTS.PRODUCT_CATEGORY as CATEGORY_NAME with synonyms=('category','product category') comment='Category of the product',
    PUBLIC PRODUCTS.PRODUCT_KEY as PRODUCT_KEY,
    PUBLIC PRODUCTS.PRODUCT_NAME as PRODUCT_NAME with synonyms=('product','item','product title') comment='Name of the product being promoted',
    PUBLIC PRODUCTS.PRODUCT_VERTICAL as VERTICAL with synonyms=('vertical','industry') comment='Business vertical of the product',
    PUBLIC REGIONS.REGION_KEY as REGION_KEY,
    PUBLIC REGIONS.REGION_NAME as REGION_NAME with synonyms=('region','market','territory') comment='Name of the region'
  )
  metrics (
    PUBLIC CAMPAIGNS.AVERAGE_SPEND as AVG(CAMPAIGNS.spend) comment='Average campaign spend',
    PUBLIC CAMPAIGNS.TOTAL_CAMPAIGNS as COUNT(CAMPAIGNS.campaign_record) comment='Total number of campaign activities',
    PUBLIC CAMPAIGNS.TOTAL_IMPRESSIONS as SUM(CAMPAIGNS.impressions) comment='Total impressions across campaigns',
    PUBLIC CAMPAIGNS.TOTAL_LEADS as SUM(CAMPAIGNS.leads_generated) comment='Total leads generated from campaigns',
    PUBLIC CAMPAIGNS.TOTAL_SPEND as SUM(CAMPAIGNS.spend) comment='Total marketing spend',
    PUBLIC CONTACTS.TOTAL_CONTACTS as COUNT(CONTACTS.contact_record) comment='Total contacts generated from campaigns',
    PUBLIC OPPORTUNITIES.AVERAGE_DEAL_SIZE as AVG(OPPORTUNITIES.revenue) comment='Average opportunity size from marketing',
    PUBLIC OPPORTUNITIES.CLOSED_WON_REVENUE as SUM(CASE WHEN OPPORTUNITIES.opportunity_stage = 'Closed Won' THEN OPPORTUNITIES.revenue ELSE 0 END) comment='Revenue from closed won opportunities',
    PUBLIC OPPORTUNITIES.TOTAL_OPPORTUNITIES as COUNT(OPPORTUNITIES.opportunity_record) comment='Total opportunities from marketing',
    PUBLIC OPPORTUNITIES.TOTAL_REVENUE as SUM(OPPORTUNITIES.revenue) comment='Total revenue from marketing-driven opportunities'
  )
  comment='Enhanced semantic view for marketing campaign analysis with complete revenue attribution and ROI tracking'
  with extension (CA='{"tables":[{"name":"ACCOUNTS","dimensions":[{"name":"ACCOUNT_ID"},{"name":"ACCOUNT_NAME"},{"name":"ACCOUNT_TYPE"},{"name":"ANNUAL_REVENUE"},{"name":"EMPLOYEES"},{"name":"INDUSTRY"},{"name":"SALES_CUSTOMER_KEY"}]},{"name":"CAMPAIGNS","dimensions":[{"name":"CAMPAIGN_DATE"},{"name":"CAMPAIGN_FACT_ID"},{"name":"CAMPAIGN_KEY"},{"name":"CAMPAIGN_MONTH"},{"name":"CAMPAIGN_YEAR"},{"name":"CHANNEL_KEY"},{"name":"PRODUCT_KEY"},{"name":"REGION_KEY"}],"facts":[{"name":"CAMPAIGN_RECORD"},{"name":"CAMPAIGN_SPEND"},{"name":"IMPRESSIONS"},{"name":"LEADS_GENERATED"}],"metrics":[{"name":"AVERAGE_SPEND"},{"name":"TOTAL_CAMPAIGNS"},{"name":"TOTAL_IMPRESSIONS"},{"name":"TOTAL_LEADS"},{"name":"TOTAL_SPEND"}]},{"name":"CAMPAIGN_DETAILS","dimensions":[{"name":"CAMPAIGN_KEY"},{"name":"CAMPAIGN_NAME"},{"name":"CAMPAIGN_OBJECTIVE"}]},{"name":"CHANNELS","dimensions":[{"name":"CHANNEL_KEY"},{"name":"CHANNEL_NAME"}]},{"name":"CONTACTS","dimensions":[{"name":"ACCOUNT_ID"},{"name":"CAMPAIGN_NO"},{"name":"CONTACT_ID"},{"name":"DEPARTMENT"},{"name":"EMAIL"},{"name":"FIRST_NAME"},{"name":"LAST_NAME"},{"name":"LEAD_SOURCE"},{"name":"OPPORTUNITY_ID"},{"name":"TITLE"}],"facts":[{"name":"CONTACT_RECORD"}],"metrics":[{"name":"TOTAL_CONTACTS"}]},{"name":"CONTACTS_FOR_OPPORTUNITIES"},{"name":"OPPORTUNITIES","dimensions":[{"name":"ACCOUNT_ID"},{"name":"CAMPAIGN_ID"},{"name":"CLOSE_DATE"},{"name":"OPPORTUNITY_ID"},{"name":"OPPORTUNITY_LEAD_SOURCE"},{"name":"OPPORTUNITY_NAME"},{"name":"OPPORTUNITY_STAGE","sample_values":["Closed Won","Perception Analysis","Qualification"]},{"name":"OPPORTUNITY_TYPE"},{"name":"SALES_SALE_ID"}],"facts":[{"name":"OPPORTUNITY_RECORD"},{"name":"REVENUE"}],"metrics":[{"name":"AVERAGE_DEAL_SIZE"},{"name":"CLOSED_WON_REVENUE"},{"name":"TOTAL_OPPORTUNITIES"},{"name":"TOTAL_REVENUE"}]},{"name":"PRODUCTS","dimensions":[{"name":"PRODUCT_CATEGORY"},{"name":"PRODUCT_KEY"},{"name":"PRODUCT_NAME"},{"name":"PRODUCT_VERTICAL"}]},{"name":"REGIONS","dimensions":[{"name":"REGION_KEY"},{"name":"REGION_NAME"}]}],"relationships":[{"name":"CAMPAIGNS_TO_CHANNELS","relationship_type":"many_to_one"},{"name":"CAMPAIGNS_TO_DETAILS","relationship_type":"many_to_one"},{"name":"CAMPAIGNS_TO_PRODUCTS","relationship_type":"many_to_one"},{"name":"CAMPAIGNS_TO_REGIONS","relationship_type":"many_to_one"},{"name":"CONTACTS_TO_ACCOUNTS","relationship_type":"many_to_one"},{"name":"CONTACTS_TO_CAMPAIGNS","relationship_type":"many_to_one"},{"name":"CONTACTS_TO_OPPORTUNITIES","relationship_type":"many_to_one"},{"name":"OPPORTUNITIES_TO_ACCOUNTS","relationship_type":"many_to_one"},{"name":"OPPORTUNITIES_TO_CAMPAIGNS"}],"verified_queries":[{"name":"include opps that turned in to sales deal","question":"include opps that turned in to sales deal","sql":"WITH campaign_impressions AS (\\n  SELECT\\n    c.campaign_key,\\n    cd.campaign_name,\\n    SUM(c.impressions) AS total_impressions\\n  FROM\\n    campaigns AS c\\n    LEFT OUTER JOIN campaign_details AS cd ON c.campaign_key = cd.campaign_key\\n  WHERE\\n    c.campaign_year = 2025\\n  GROUP BY\\n    c.campaign_key,\\n    cd.campaign_name\\n),\\ncampaign_opportunities AS (\\n  SELECT\\n    c.campaign_key,\\n    COUNT(o.opportunity_record) AS total_opportunities,\\n    COUNT(\\n      CASE\\n        WHEN o.opportunity_stage = ''Closed Won'' THEN o.opportunity_record\\n      END\\n    ) AS closed_won_opportunities\\n  FROM\\n    campaigns AS c\\n    LEFT OUTER JOIN opportunities AS o ON c.campaign_fact_id = o.campaign_id\\n  WHERE\\n    c.campaign_year = 2025\\n  GROUP BY\\n    c.campaign_key\\n)\\nSELECT\\n  ci.campaign_name,\\n  ci.total_impressions,\\n  COALESCE(co.total_opportunities, 0) AS total_opportunities,\\n  COALESCE(co.closed_won_opportunities, 0) AS closed_won_opportunities\\nFROM\\n  campaign_impressions AS ci\\n  LEFT JOIN campaign_opportunities AS co ON ci.campaign_key = co.campaign_key\\nORDER BY\\n  ci.total_impressions DESC NULLS LAST","use_as_onboarding_question":false,"verified_by":"Nick Akincilar","verified_at":1757262696}]}');

-- ============================================================================
-- KPI / CITY SUBS SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW KPI_SEMANTIC_VIEW
  tables (
    KPI as PXC_KPI primary key (METRIC) with synonyms=('kpis','metrics','key performance indicators') comment='PXC UK KPI metrics',
    CITY_SUBS as CITY_SUBS primary key (CITY) with synonyms=('city subscribers','subs by city') comment='City-level subscribers for broadband, tv, voice, and MVNO mobile'
  )
  facts (
    KPI.VALUE as kpi_value comment='KPI numeric value',
    CITY_SUBS.BROADBAND_SUBS as broadband_subs comment='Broadband subscribers in city',
    CITY_SUBS.TV_SUBS as tv_subs comment='TV subscribers in city',
    CITY_SUBS.VOICE_SUBS as voice_subs comment='Voice subscribers in city',
    CITY_SUBS.MOBILE_SUBS as mobile_subs comment='MVNO mobile subscribers in city'
  )
  dimensions (
    KPI.METRIC as metric,
    KPI.AS_OF_NOTE as as_of_note,
    KPI.CATEGORY as category,
    CITY_SUBS.CITY as city
  )
  comment='Semantic view for PXC UK KPIs and city-level subscriber counts';

-- ============================================================================
-- B2C SUBSCRIPTIONS SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW B2C_SUBS_SEMANTIC_VIEW
  tables (
    CUSTOMERS as B2C_CUSTOMERS primary key (CUSTOMER_ID) with synonyms=('households','consumers') comment='B2C customers (households)',
    SUBSCRIPTIONS as B2C_SUBSCRIPTIONS primary key (SUBSCRIPTION_ID) with synonyms=('plans','subscriptions','contracts') comment='B2C subscription records'
  )
  relationships (
    SUBS_TO_CUSTOMERS as SUBSCRIPTIONS(CUSTOMER_ID) references CUSTOMERS(CUSTOMER_ID)
  )
  facts (
    SUBSCRIPTIONS.MONTHLY_FEE_EUR as monthly_fee_eur comment='Monthly subscription fee (GBP) from partners',
    SUBSCRIPTIONS.MOBILE_SIMS as mobile_sims comment='Number of mobile SIMs on the subscription'
  )
  dimensions (
    CUSTOMERS.CUSTOMER_ID as CUSTOMER_ID,
    CUSTOMERS.FIRST_NAME as FIRST_NAME,
    CUSTOMERS.LAST_NAME as LAST_NAME,
    CUSTOMERS.CITY as CITY,
    CUSTOMERS.COUNTY as COUNTY,
    CUSTOMERS.EIRCODE as EIRCODE,
    CUSTOMERS.PLAN_NAME as PLAN_NAME,
    CUSTOMERS.SPEED_MBPS as SPEED_MBPS,
    CUSTOMERS.BUNDLE as BUNDLE,
    CUSTOMERS.TV_PACKAGE as TV_PACKAGE,
    CUSTOMERS.WIFI_GUARANTEE as WIFI_GUARANTEE,
    CUSTOMERS.ADD_ONS as ADD_ONS,
    CUSTOMERS.STATUS as STATUS,
    CUSTOMERS.REGION_KEY as REGION_KEY,
    SUBSCRIPTIONS.SUBSCRIPTION_ID as SUBSCRIPTION_ID,
    SUBSCRIPTIONS.PRODUCT_NAME as PRODUCT_NAME,
    SUBSCRIPTIONS.CATEGORY_NAME as CATEGORY_NAME,
    SUBSCRIPTIONS.START_DATE as START_DATE,
    SUBSCRIPTIONS.STATUS as SUB_STATUS,
    SUBSCRIPTIONS.TV_PACKAGE as SUB_TV_PACKAGE,
    SUBSCRIPTIONS.WIFI_GUARANTEE as SUB_WIFI_GUARANTEE
  )
  comment='Semantic view for PXC UK B2C customers and subscriptions (broadband/TV/mobile bundles)';

-- ============================================================================
-- B2B SUMMARY SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW B2B_SUMMARY_SEMANTIC_VIEW
  tables (
    CUSTOMERS as CUSTOMER_DIM primary key (CUSTOMER_KEY) with synonyms=('accounts','customers','clients') comment='B2B/B2G customers',
    PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','services') comment='Product catalog',
    REGIONS as REGION_DIM primary key (REGION_KEY) with synonyms=('regions','markets','territories') comment='Regions across the UK footprint',
    SALES as SALES_FACT primary key (SALE_ID) with synonyms=('transactions','sales') comment='B2B sales transactions',
    ACCOUNTS as SF_ACCOUNTS primary key (ACCOUNT_ID) with synonyms=('sf accounts','crm accounts') comment='Salesforce account records'
  )
  relationships (
    SALES_TO_CUSTOMERS as SALES(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY),
    SALES_TO_PRODUCTS as SALES(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
    SALES_TO_REGIONS as SALES(REGION_KEY) references REGIONS(REGION_KEY),
    ACCOUNTS_TO_CUSTOMERS as ACCOUNTS(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY)
  )
  facts (
    SALES.AMOUNT as revenue_eur comment='Sales revenue in pounds (GBP)',
    SALES.UNITS as units_sold comment='Units sold'
  )
  dimensions (
    CUSTOMERS.CUSTOMER_KEY as CUSTOMER_KEY,
    CUSTOMERS.CUSTOMER_NAME as CUSTOMER_NAME,
    CUSTOMERS.INDUSTRY as INDUSTRY,
    CUSTOMERS.VERTICAL as VERTICAL,
    REGIONS.REGION_KEY as REGION_KEY,
    REGIONS.REGION_NAME as REGION_NAME,
    PRODUCTS.PRODUCT_KEY as PRODUCT_KEY,
    PRODUCTS.PRODUCT_NAME as PRODUCT_NAME,
    PRODUCTS.CATEGORY_NAME as PRODUCT_CATEGORY,
    PRODUCTS.VERTICAL as PRODUCT_VERTICAL,
    SALES.SALE_ID as SALE_ID,
    SALES.DATE as SALE_DATE,
    SALES.SALE_YEAR as SALE_YEAR,
    SALES.SALE_MONTH as SALE_MONTH,
    ACCOUNTS.ACCOUNT_ID as ACCOUNT_ID,
    ACCOUNTS.ACCOUNT_NAME as ACCOUNT_NAME,
    ACCOUNTS.ACCOUNT_TYPE as ACCOUNT_TYPE
  )
  comment='Summary semantic view for PXC UK B2B/B2G revenue and units by customer, product, and region';

-- ============================================================================
-- HR SEMANTIC VIEW
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW HR_SEMANTIC_VIEW
  tables (
    DEPARTMENTS as DEPARTMENT_DIM primary key (DEPARTMENT_KEY) with synonyms=('departments','business units') comment='Department dimension for organizational analysis',
    EMPLOYEES as EMPLOYEE_DIM primary key (EMPLOYEE_KEY) with synonyms=('employees','staff','workforce') comment='Employee dimension with personal information',
    HR_RECORDS as HR_EMPLOYEE_FACT primary key (HR_FACT_ID) with synonyms=('hr data','employee records') comment='HR employee fact data for workforce analysis',
    JOBS as JOB_DIM primary key (JOB_KEY) with synonyms=('job titles','positions','roles') comment='Job dimension with titles and levels',
    LOCATIONS as LOCATION_DIM primary key (LOCATION_KEY) with synonyms=('locations','offices','sites') comment='Location dimension for geographic analysis'
  )
  relationships (
    HR_TO_DEPARTMENTS as HR_RECORDS(DEPARTMENT_KEY) references DEPARTMENTS(DEPARTMENT_KEY),
    HR_TO_EMPLOYEES as HR_RECORDS(EMPLOYEE_KEY) references EMPLOYEES(EMPLOYEE_KEY),
    HR_TO_JOBS as HR_RECORDS(JOB_KEY) references JOBS(JOB_KEY),
    HR_TO_LOCATIONS as HR_RECORDS(LOCATION_KEY) references LOCATIONS(LOCATION_KEY)
  )
  facts (
    HR_RECORDS.ATTRITION_FLAG as attrition_flag with synonyms=('turnover_indicator','employee_departure_flag','separation_flag','employee_retention_status','churn_status','employee_exit_indicator') comment='Attrition flag. value is 0 if employee is currently active. 1 if employee quit & left the company. Always filter by 0 to show active employees unless specified otherwise',
    HR_RECORDS.EMPLOYEE_RECORD as 1 comment='Count of employee records',
    HR_RECORDS.EMPLOYEE_SALARY as salary comment='Employee salary in pounds (GBP)'
  )
  dimensions (
    DEPARTMENTS.DEPARTMENT_KEY as DEPARTMENT_KEY,
    DEPARTMENTS.DEPARTMENT_NAME as department_name with synonyms=('department','business unit','division') comment='Name of the department',
    EMPLOYEES.EMPLOYEE_KEY as EMPLOYEE_KEY,
    EMPLOYEES.EMPLOYEE_NAME as employee_name with synonyms=('employee','staff member','person','sales rep','manager','director','executive') comment='Name of the employee',
    EMPLOYEES.GENDER as gender with synonyms=('gender','sex') comment='Employee gender',
    EMPLOYEES.HIRE_DATE as hire_date with synonyms=('hire date','start date') comment='Date when employee was hired',
    HR_RECORDS.DEPARTMENT_KEY as DEPARTMENT_KEY,
    HR_RECORDS.EMPLOYEE_KEY as EMPLOYEE_KEY,
    HR_RECORDS.HR_FACT_ID as HR_FACT_ID,
    HR_RECORDS.JOB_KEY as JOB_KEY,
    HR_RECORDS.LOCATION_KEY as LOCATION_KEY,
    HR_RECORDS.RECORD_DATE as date with synonyms=('date','record date') comment='Date of the HR record',
    HR_RECORDS.RECORD_MONTH as MONTH(date) comment='Month of the HR record',
    HR_RECORDS.RECORD_YEAR as YEAR(date) comment='Year of the HR record',
    JOBS.JOB_KEY as JOB_KEY,
    JOBS.JOB_LEVEL as job_level with synonyms=('level','grade','seniority') comment='Job level or grade',
    JOBS.JOB_TITLE as job_title with synonyms=('job title','position','role') comment='Employee job title',
    LOCATIONS.LOCATION_KEY as LOCATION_KEY,
    LOCATIONS.LOCATION_NAME as location_name with synonyms=('location','office','site') comment='Work location'
  )
  metrics (
    HR_RECORDS.ATTRITION_COUNT as SUM(hr_records.attrition_flag) comment='Number of employees who left',
    HR_RECORDS.AVG_SALARY as AVG(hr_records.employee_salary) comment='average employee salary',
    HR_RECORDS.TOTAL_EMPLOYEES as COUNT(hr_records.employee_record) comment='Total number of employees',
    HR_RECORDS.TOTAL_SALARY_COST as SUM(hr_records.EMPLOYEE_SALARY) comment='Total salary cost'
  )
  comment='Semantic view for HR analytics and workforce management'
  with extension (CA='{"tables":[{"name":"DEPARTMENTS","dimensions":[{"name":"DEPARTMENT_KEY"},{"name":"DEPARTMENT_NAME","sample_values":["Finance","Accounting","Treasury"]}]},{"name":"EMPLOYEES","dimensions":[{"name":"EMPLOYEE_KEY"},{"name":"EMPLOYEE_NAME","sample_values":["Grant Frey","Elizabeth George","Olivia Mcdaniel"]},{"name":"GENDER"},{"name":"HIRE_DATE"}]},{"name":"HR_RECORDS","dimensions":[{"name":"DEPARTMENT_KEY"},{"name":"EMPLOYEE_KEY"},{"name":"HR_FACT_ID"},{"name":"JOB_KEY"},{"name":"LOCATION_KEY"},{"name":"RECORD_DATE"},{"name":"RECORD_MONTH"},{"name":"RECORD_YEAR"}],"facts":[{"name":"ATTRITION_FLAG","sample_values":["0","1"]},{"name":"EMPLOYEE_RECORD"},{"name":"EMPLOYEE_SALARY"}],"metrics":[{"name":"ATTRITION_COUNT"},{"name":"AVG_SALARY"},{"name":"TOTAL_EMPLOYEES"},{"name":"TOTAL_SALARY_COST"}]},{"name":"JOBS","dimensions":[{"name":"JOB_KEY"},{"name":"JOB_LEVEL"},{"name":"JOB_TITLE"}]},{"name":"LOCATIONS","dimensions":[{"name":"LOCATION_KEY"},{"name":"LOCATION_NAME"}]}],"relationships":[{"name":"HR_TO_DEPARTMENTS","relationship_type":"many_to_one"},{"name":"HR_TO_EMPLOYEES","relationship_type":"many_to_one"},{"name":"HR_TO_JOBS","relationship_type":"many_to_one"},{"name":"HR_TO_LOCATIONS","relationship_type":"many_to_one"}],"verified_queries":[{"name":"List of all active employees","question":"List of all active employees","sql":"select\\n  h.employee_key,\\n  e.employee_name,\\nfrom\\n  employees e\\n  left join hr_records h on e.employee_key = h.employee_key\\ngroup by\\n  all\\nhaving\\n  sum(h.attrition_flag) = 0;","use_as_onboarding_question":false,"verified_by":"Nick Akincilar","verified_at":1753846263},{"name":"List of all inactive employees","question":"List of all inactive employees","sql":"SELECT\\n  h.employee_key,\\n  e.employee_name\\nFROM\\n  employees AS e\\n  LEFT JOIN hr_records AS h ON e.employee_key = h.employee_key\\nGROUP BY\\n  ALL\\nHAVING\\n  SUM(h.attrition_flag) > 0","use_as_onboarding_question":false,"verified_by":"Nick Akincilar","verified_at":1753846300}],"custom_instructions":"- Each employee can have multiple hr_employee_fact records. \\n- Only one hr_employee_fact record per employee is valid and that is the one which has the highest date value."}');

-- ============================================================================
-- Verification
-- ============================================================================

SHOW SEMANTIC VIEWS;

SHOW SEMANTIC DIMENSIONS;

SHOW SEMANTIC METRICS;

SELECT 'Semantic views created successfully!' AS status,
       'FINANCE_SEMANTIC_VIEW, SALES_SEMANTIC_VIEW, MARKETING_SEMANTIC_VIEW, HR_SEMANTIC_VIEW' AS views_created,
       'Owner: ACCOUNTADMIN' AS ownership,
       CURRENT_TIMESTAMP() AS deployed_at;
