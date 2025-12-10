-- ============================================================================
-- PXC (PlatformX Communications) AI Demo - Cortex Search Services (DataOps Template)
-- ============================================================================
-- Description: Parses unstructured documents and creates Cortex Search services
-- for semantic search over finance, HR, marketing, sales, strategy, demo, and network docs
-- ============================================================================

USE ROLE {{ env.EVENT_ATTENDEE_ROLE | default('TELCO_ANALYST_ROLE') }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }};
USE DATABASE {{ env.EVENT_DATABASE | default('PXC_AI_DEMO') }};
USE SCHEMA {{ env.EVENT_SCHEMA | default('PXC_SCHEMA') }};

-- ============================================================================
-- Step 1: Parse Unstructured Documents (PDF, DOCX, PPTX, MD)
-- ============================================================================

-- Parse structured documents (PDF, DOCX, PPTX) using PARSE_DOCUMENT
CREATE OR REPLACE TABLE parsed_content_docs AS 
SELECT 
    relative_path, 
    BUILD_STAGE_FILE_URL('@{{ env.EVENT_DATA_STAGE | default("DATA_STAGE") }}', relative_path) as file_url,
    TO_FILE(BUILD_STAGE_FILE_URL('@{{ env.EVENT_DATA_STAGE | default("DATA_STAGE") }}', relative_path)) as file_object,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }},
        relative_path,
        {'mode':'LAYOUT'}
    ):content::string as content
FROM directory(@{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}) 
WHERE relative_path ilike 'unstructured_docs/%.pdf'
   OR relative_path ilike 'unstructured_docs/%.docx'
   OR relative_path ilike 'unstructured_docs/%.pptx';

-- Parse Markdown files using PARSE_DOCUMENT (supports plain text extraction)
CREATE OR REPLACE TABLE parsed_content_md AS
SELECT 
    relative_path,
    BUILD_STAGE_FILE_URL('@{{ env.EVENT_DATA_STAGE | default("DATA_STAGE") }}', relative_path) as file_url,
    TO_FILE(BUILD_STAGE_FILE_URL('@{{ env.EVENT_DATA_STAGE | default("DATA_STAGE") }}', relative_path)) as file_object,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        @{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }},
        relative_path,
        {'mode':'LAYOUT'}
    ):content::string as content
FROM directory(@{{ env.EVENT_DATA_STAGE | default('DATA_STAGE') }}) 
WHERE relative_path ilike 'unstructured_docs/%.md';

-- Combine all document types into unified parsed_content table
CREATE OR REPLACE TABLE parsed_content AS
SELECT relative_path, file_url, file_object, content FROM parsed_content_docs
UNION ALL
SELECT relative_path, file_url, file_object, content FROM parsed_content_md;

-- Verify document counts by type
SELECT 
    CASE 
        WHEN relative_path ILIKE '%.pdf' THEN 'PDF'
        WHEN relative_path ILIKE '%.docx' THEN 'DOCX'
        WHEN relative_path ILIKE '%.pptx' THEN 'PPTX'
        WHEN relative_path ILIKE '%.md' THEN 'Markdown'
        ELSE 'Other'
    END as file_type,
    COUNT(*) as file_count
FROM parsed_content
GROUP BY file_type
ORDER BY file_count DESC;

-- ============================================================================
-- Step 2: Create Cortex Search Services
-- ============================================================================

-- Finance Documents Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_finance_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/finance/%'
    );

-- HR Documents Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_hr_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/hr/%'
    );

-- Marketing Documents Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_marketing_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/marketing/%'
    );

-- Sales Documents Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_sales_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/sales/%'
    );

-- Strategy Documents Search Service (CEO/Executive content)
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_strategy_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/strategy/%'
    );

-- Demo Scripts Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_demo_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('PXC_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/demo/%'
    );

-- Network Infrastructure Documents Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_network_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = {{ env.EVENT_WAREHOUSE | default('CITYFIBRE_UK_DEMO_WH') }}
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ilike '%/network/%'
    );

-- ============================================================================
-- Step 3: Verification
-- ============================================================================

-- Show all search services
SHOW CORTEX SEARCH SERVICES;

-- Count documents per search service category
SELECT 
    CASE 
        WHEN relative_path ilike '%/finance/%' THEN 'Finance'
        WHEN relative_path ilike '%/hr/%' THEN 'HR'
        WHEN relative_path ilike '%/marketing/%' THEN 'Marketing'
        WHEN relative_path ilike '%/sales/%' THEN 'Sales'
        WHEN relative_path ilike '%/strategy/%' THEN 'Strategy'
        WHEN relative_path ilike '%/demo/%' THEN 'Demo'
        WHEN relative_path ilike '%/network/%' THEN 'Network'
        ELSE 'Other'
    END as search_category,
    COUNT(*) as document_count
FROM parsed_content
GROUP BY search_category
ORDER BY document_count DESC;

SELECT 'Cortex Search services created successfully!' AS status,
       '7 search services: finance, hr, marketing, sales, strategy, demo, network' AS services_created,
       CURRENT_TIMESTAMP() AS deployed_at;
