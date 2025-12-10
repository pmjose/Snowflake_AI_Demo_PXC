# <h1black>Run Snowflake </h1black><h1blue>Notebooks</h1blue>

In this section, you'll run three Snowflake Notebooks that process data and demonstrate Cortex AI capabilities.

---

## <h1black>📓 Step 2: Run Data Processing </h1black><h1blue>Notebook (10 minutes)</h1blue>

This notebook loads data from stages and processes it with Cortex AI.

### <h1sub>Navigate to Notebooks</h1sub>

1. In Snowsight, click **Projects** in the left navigation
2. Click **Notebooks**
3. Find and open **1_DATA_PROCESSING**

### <h1sub>What This Notebook Does</h1sub>

**Part 1: Load Structured Data (Cell 3)**
- Loads 6 CSV files from `@raw_files` stage:
  - `network_performance.csv` (49,864 records)
  - `customer_details.csv` (10,000 customers)
  - `customer_feedback_summary.csv` (20,061 records)
  - `infrastructure_capacity.csv` (1,500 snapshots)
  - `csat_surveys.csv` (25 surveys)
  - `customer_interaction_history.csv` (25 summaries)

**Part 2: Process Audio Files (Cell 5)**
- Finds all MP3 files in `@raw_files` stage
- Uses `AI_TRANSCRIBE` to convert audio to text
- Applies `AI_SENTIMENT` for sentiment analysis
- Generates summaries and extracts key information
- Saves to `customer_call_transcripts` table

**Part 3: Process PDF Documents (Cell 7)**
- Finds all PDF files in `@raw_files/pdfs/` directory
- Uses `AI_PARSE_DOCUMENT` to extract text from PDFs
- Processes PXC help and product documentation
- Saves to `customer_complaint_documents` table

**Part 4: Verify Data Loading (Cell 9)**
- Shows record counts for all tables
- Confirms all data loaded successfully

### <h1sub>Run the Notebook</h1sub>

1. Click **Run all** at the top of the notebook, OR
2. Run each cell individually by clicking the play button on each cell
3. Wait for all cells to complete (green checkmarks)
4. Review the output to verify data loaded successfully

### <h1sub>Expected Results</h1sub>
- All 6 CSV tables loaded with data
- `customer_call_transcripts` populated with transcribed audio
- `customer_complaint_documents` populated with PDF text

---

## <h1black>🎧 Step 3: Analyze Call Audio </h1black><h1blue>Notebook (5 minutes)</h1blue>

This notebook demonstrates how to analyze pre-transcribed call audio data and explore sentiment patterns.

### <h1sub>Navigate to the Notebook</h1sub>

1. **Projects** → **Notebooks**
2. Open **2_ANALYZE_CALL_AUDIO**

### <h1sub>What This Notebook Does</h1sub>

**Review Audio Files:**
- Lists available audio files from `@AUDIO_STAGE`
- Shows audio file metadata (size, last modified)
- Displays the directory structure

**Explore Transcribed Data:**
- Queries the `CALL_TRANSCRIPTS` table populated in Step 2
- Reviews call segments with speaker identification
- Examines sentiment scores for each segment

**Sentiment Analysis:**
- Analyzes sentiment distribution across all calls
- Identifies calls with negative sentiment
- Calculates average sentiment by speaker role (agent vs customer)
- Finds calls requiring follow-up action

### <h1sub>Run the Notebook</h1sub>

1. Run each cell sequentially
2. Review the audio file listings and transcription data
3. Examine the sentiment analysis results

### <h1sub>Expected Results</h1sub>
- View of all audio files stored in the stage
- Sample transcribed call segments with sentiment scores
- Insights into customer sentiment patterns
- Identification of calls with issues requiring attention

### <h1sub>Key Insights</h1sub>

This notebook helps you:
- ✅ Understand the structure of transcribed audio data
- ✅ Identify sentiment trends across customer calls
- ✅ Spot calls with negative sentiment for quality review
- ✅ Measure customer vs agent sentiment differences

---

## <h1black>🔬 Step 4: Run Intelligence Lab </h1black><h1blue>Notebook (15 minutes)</h1blue>

This notebook provides hands-on exercises with Cortex AI functions.

### <h1sub>Navigate to the Notebook</h1sub>

1. **Projects** → **Notebooks**
2. Open **3_INTELLIGENCE_LAB**

### <h1sub>What You'll Do (11 Exercises)</h1sub>

**Exercise 1: Data Volume Check**
- Verify all tables have data
- Review sample call transcripts

**Exercise 2: Multi-Language Translation**
- Use `AI_TRANSLATE` to translate summaries to Chinese and Japanese
- Test translation quality for regional teams

**Exercise 3: Sentiment Distribution Analysis**
- Analyze sentiment scores across all calls
- Create bar charts showing positive/negative/neutral distribution
- Identify sentiment trends

**Exercise 4: CSAT Analysis**
- Examine customer satisfaction scores
- Calculate average CSAT by segment
- Create histograms of score distribution

**Exercise 5: Network Performance by Region**
- Analyze latency and packet loss by region
- Create bar charts comparing regions
- Identify areas needing improvement

**Exercise 6: Semantic Search**
- Use `CORTEX.SEARCH_PREVIEW` to search call transcripts
- Find calls mentioning "network problems"
- Get top matching results with context

**Exercise 7: At-Risk Customer Analysis**
- Identify customers with high churn risk
- Analyze by customer segment
- Visualize total vs at-risk customers

**Exercise 8: Revenue at Risk**
- Calculate revenue from at-risk customers
- Group by customer segment
- Prioritize retention efforts

**Exercise 9: PII Redaction**
- Use `AI_REDACT` to remove sensitive information
- Compare original vs redacted transcripts
- Ensure compliance with privacy regulations

**Exercise 10: Custom Analysis**
- Search for competitor mentions (incumbents and regional altnets)
- Analyze call reasons and resolution status
- Write your own queries

**Exercise 11: Churn Prediction**
- Build simple ML model to predict churn
- Identify key features (CSAT, complaints, tenure)
- Evaluate model accuracy

### <h1sub>Run the Notebook</h1sub>

1. Run each cell sequentially (all packages are pre-installed)
2. Review the output and charts for each exercise
3. Experiment with the custom analysis section

### <h1sub>Key Takeaways</h1sub>

After completing all three notebooks, you'll have:
- ✅ Loaded and processed 50,000+ records from multiple sources
- ✅ Transcribed audio files using `AI_TRANSCRIBE`
- ✅ Extracted text from PDFs using `AI_PARSE_DOCUMENT`
- ✅ Analyzed sentiment across customer interactions
- ✅ Explored pre-transcribed call data and audio file management
- ✅ Identified at-risk customers and revenue impact
- ✅ Built visualizations with matplotlib
- ✅ Explored semantic search capabilities
- ✅ Redacted PII for compliance

---

**Next:** Proceed to explore Cortex Search services and Cortex Analyst to query your data with natural language.