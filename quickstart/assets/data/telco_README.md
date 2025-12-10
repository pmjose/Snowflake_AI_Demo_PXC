# Telco Operations AI - Data Files

This directory contains all pre-loaded data files for the Telco Operations AI hands-on lab.

## Overview

All data is **synthetic** and generated for educational purposes. No real customer data is included.

## Data Files

### Call Center Data

#### 1. `call_transcripts.csv` (~10,000 rows)
Pre-transcribed call segments with sentiment analysis.

**Columns**:
- `CALL_ID`: Unique call identifier
- `SEGMENT_ID`: Segment number within call
- `SEGMENT_NUMBER`: Sequence order
- `SPEAKER_ID`: 0 = Customer, 1 = Agent
- `SPEAKER_ROLE`: "Customer" or "Agent"
- `SEGMENT_TEXT`: Transcribed text
- `SENTIMENT_SCORE`: -1 (negative) to +1 (positive)
- `SEGMENT_START_TIME`: Seconds from call start
- `SEGMENT_END_TIME`: Seconds from call end
- `CALL_TIMESTAMP`: When call occurred
- `CALL_DURATION_SECONDS`: Total call length

**Sample Data**:
```csv
CALL_ID,SEGMENT_ID,SEGMENT_NUMBER,SPEAKER_ID,SPEAKER_ROLE,SEGMENT_TEXT,SENTIMENT_SCORE,SEGMENT_START_TIME,SEGMENT_END_TIME,CALL_TIMESTAMP,CALL_DURATION_SECONDS
call_001,seg_001_001,1,0,Customer,"Hi I'm calling because my internet has been down for two days",0.15,0,8,2025-01-15 09:23:00,450
call_001,seg_001_002,2,1,Agent,"I'm sorry to hear that. Let me pull up your account and see what's going on",0.45,8,18,2025-01-15 09:23:00,450
call_001,seg_001_003,3,0,Customer,"I've already called twice and nothing has been fixed. This is really frustrating",-0.65,18,28,2025-01-15 09:23:00,450
```

#### 2. `call_sentiment_summary.csv` (~500 rows)
Aggregated sentiment per call.

**Columns**:
- `CALL_ID`: Unique call identifier
- `CALL_TIMESTAMP`: When call occurred
- `CALL_DURATION_SECONDS`: Total call length
- `CUSTOMER_ID`: Customer identifier
- `AGENT_ID`: Agent identifier
- `CALL_CATEGORY`: "Billing", "Technical", "Sales", "General"
- `RESOLUTION_STATUS`: "Resolved", "Escalated", "Follow-up Required"
- `AVG_SENTIMENT_SCORE`: Average across all segments
- `MIN_SENTIMENT_SCORE`: Lowest sentiment point
- `MAX_SENTIMENT_SCORE`: Highest sentiment point
- `SENTIMENT_TREND`: "Improving", "Declining", "Stable"
- `CUSTOMER_SENTIMENT_AVG`: Customer segments only
- `AGENT_SENTIMENT_AVG`: Agent segments only

**Sample Data**:
```csv
CALL_ID,CALL_TIMESTAMP,CALL_DURATION_SECONDS,CUSTOMER_ID,AGENT_ID,CALL_CATEGORY,RESOLUTION_STATUS,AVG_SENTIMENT_SCORE,MIN_SENTIMENT_SCORE,MAX_SENTIMENT_SCORE,SENTIMENT_TREND,CUSTOMER_SENTIMENT_AVG,AGENT_SENTIMENT_AVG
call_001,2025-01-15 09:23:00,450,cust_1234,agent_42,Technical,Resolved,0.28,-0.65,0.85,Improving,-0.15,0.62
call_002,2025-01-15 09:45:00,320,cust_5678,agent_23,Billing,Resolved,0.65,0.25,0.92,Stable,0.55,0.75
```

### Customer Data

#### 3. `customer_profiles.csv` (~5,000 rows)
Customer demographics and account information.

**Columns**:
- `CUSTOMER_ID`: Unique customer identifier
- `CUSTOMER_NAME`: Full name
- `EMAIL`: Email address
- `PHONE`: Phone number
- `ACCOUNT_NUMBER`: Account identifier
- `CUSTOMER_SEGMENT`: "Consumer", "Small Business", "Enterprise", "VIP"
- `TENURE_MONTHS`: How long they've been a customer
- `MONTHLY_CHARGES`: Current monthly bill
- `TOTAL_LIFETIME_VALUE`: Total revenue from customer
- `SERVICE_PLAN`: "Basic", "Standard", "Premium", "Enterprise"
- `CONTRACT_TYPE`: "Month-to-Month", "1-Year", "2-Year"
- `AUTO_PAY_ENABLED`: TRUE/FALSE
- `PAYMENT_METHOD`: "Credit Card", "Bank Account", "Check"
- `CHURN_RISK_SCORE`: 0 (low) to 1 (high)
- `CHURNED`: TRUE/FALSE
- `CHURN_DATE`: Date customer churned (if applicable)

**Sample Data**:
```csv
CUSTOMER_ID,CUSTOMER_NAME,EMAIL,PHONE,ACCOUNT_NUMBER,CUSTOMER_SEGMENT,TENURE_MONTHS,MONTHLY_CHARGES,TOTAL_LIFETIME_VALUE,SERVICE_PLAN,CONTRACT_TYPE,AUTO_PAY_ENABLED,PAYMENT_METHOD,CHURN_RISK_SCORE,CHURNED,CHURN_DATE
cust_1234,John Smith,jsmith@email.com,555-1234,ACC789012,Consumer,24,89.99,2159.76,Standard,Month-to-Month,TRUE,Credit Card,0.35,FALSE,
cust_5678,Sarah Johnson,sjohnson@email.com,555-5678,ACC789013,Small Business,48,249.99,11999.52,Premium,2-Year,TRUE,Bank Account,0.12,FALSE,
```

#### 4. `support_tickets.csv` (~1,000 rows)
Customer support ticket data.

**Columns**:
- `TICKET_ID`: Unique ticket identifier
- `CUSTOMER_ID`: Customer who created ticket
- `CREATED_AT`: When ticket was created
- `UPDATED_AT`: Last update
- `STATUS`: "Open", "In Progress", "Resolved", "Closed"
- `PRIORITY`: "Low", "Medium", "High", "Critical"
- `CATEGORY`: "Billing", "Technical", "Account", "General"
- `SUBCATEGORY`: Specific issue type
- `SUBJECT`: Ticket subject line
- `DESCRIPTION`: Full ticket description
- `AGENT_ID`: Assigned agent
- `RESOLUTION_TIME_HOURS`: Hours to resolve (if resolved)
- `CUSTOMER_SATISFACTION_RATING`: 1-5 stars
- `SENTIMENT_SCORE`: Sentiment of description text
- `ESCALATED`: TRUE/FALSE
- `REOPENED_COUNT`: Number of times reopened

**Sample Data**:
```csv
TICKET_ID,CUSTOMER_ID,CREATED_AT,UPDATED_AT,STATUS,PRIORITY,CATEGORY,SUBCATEGORY,SUBJECT,DESCRIPTION,AGENT_ID,RESOLUTION_TIME_HOURS,CUSTOMER_SATISFACTION_RATING,SENTIMENT_SCORE,ESCALATED,REOPENED_COUNT
tick_001,cust_1234,2025-01-14 08:00:00,2025-01-14 12:30:00,Resolved,High,Technical,Internet Outage,Internet down for 2 days,"My internet service has been down since Tuesday morning. I work from home and this is causing major problems.",agent_42,4.5,5,0.25,FALSE,0
tick_002,cust_5678,2025-01-15 10:15:00,2025-01-15 10:45:00,Resolved,Low,Billing,Overcharge,Question about last bill,"I noticed a small charge on my bill I don't recognize. Can you help explain it?",agent_23,0.5,4,0.60,FALSE,0
```

### Communication Data

#### 5. `customer_communications.csv` (~2,000 rows)
Emails, chats, and SMS messages.

**Columns**:
- `COMMUNICATION_ID`: Unique identifier
- `CUSTOMER_ID`: Customer involved
- `COMMUNICATION_TYPE`: "Email", "Chat", "SMS"
- `DIRECTION`: "Inbound", "Outbound"
- `TIMESTAMP`: When communication occurred
- `SUBJECT`: Email subject or chat topic
- `MESSAGE_TEXT`: Full message content
- `AGENT_ID`: Agent involved (if any)
- `RELATED_TICKET_ID`: Associated ticket (if any)
- `SENTIMENT_SCORE`: Sentiment of message
- `RESPONSE_TIME_MINUTES`: Time to respond (for inbound)
- `RESOLVED`: TRUE/FALSE

**Sample Data**:
```csv
COMMUNICATION_ID,CUSTOMER_ID,COMMUNICATION_TYPE,DIRECTION,TIMESTAMP,SUBJECT,MESSAGE_TEXT,AGENT_ID,RELATED_TICKET_ID,SENTIMENT_SCORE,RESPONSE_TIME_MINUTES,RESOLVED
comm_001,cust_1234,Email,Inbound,2025-01-13 14:30:00,Internet service down,"Hi, my internet has been down since this morning. I've rested the router but nothing works. Please help!",agent_42,tick_001,-0.25,45,TRUE
comm_002,cust_5678,Chat,Inbound,2025-01-15 10:12:00,Billing question,"Quick question about a charge on my bill",,agent_23,tick_002,0.50,3,TRUE
```

### Agent Performance Data

#### 6. `agent_performance.csv` (~50 rows)
Agent metrics and KPIs.

**Columns**:
- `AGENT_ID`: Unique agent identifier
- `AGENT_NAME`: Full name
- `HIRE_DATE`: When agent started
- `TEAM`: Team assignment
- `SHIFT`: "Morning", "Afternoon", "Evening", "Night"
- `CALLS_HANDLED_LAST_30_DAYS`: Call volume
- `AVG_CALL_DURATION_SECONDS`: Average handle time
- `FIRST_CALL_RESOLUTION_RATE`: Percentage resolved on first call
- `AVG_CUSTOMER_SENTIMENT`: Average sentiment from calls
- `AVG_SATISFACTION_RATING`: Average customer rating
- `ESCALATION_RATE`: Percentage of calls escalated
- `TICKETS_HANDLED_LAST_30_DAYS`: Ticket volume
- `AVG_TICKET_RESOLUTION_TIME_HOURS`: Time to resolve tickets
- `QUALITY_SCORE`: 0-100 QA score
- `CERTIFICATION_LEVEL`: "Junior", "Standard", "Senior", "Expert"

**Sample Data**:
```csv
AGENT_ID,AGENT_NAME,HIRE_DATE,TEAM,SHIFT,CALLS_HANDLED_LAST_30_DAYS,AVG_CALL_DURATION_SECONDS,FIRST_CALL_RESOLUTION_RATE,AVG_CUSTOMER_SENTIMENT,AVG_SATISFACTION_RATING,ESCALATION_RATE,TICKETS_HANDLED_LAST_30_DAYS,AVG_TICKET_RESOLUTION_TIME_HOURS,QUALITY_SCORE,CERTIFICATION_LEVEL
agent_42,Mike Anderson,2022-03-15,Technical Support,Morning,245,420,0.82,0.62,4.5,0.08,67,3.2,92,Senior
agent_23,Lisa Chen,2023-06-01,Billing,Afternoon,312,280,0.91,0.75,4.7,0.04,89,2.1,95,Expert
```

### Network Operations Data

#### 7. `network_incidents.csv` (~300 rows)
Network outages and performance issues.

**Columns**:
- `INCIDENT_ID`: Unique incident identifier
- `INCIDENT_TYPE`: "Outage", "Degradation", "Maintenance"
- `SEVERITY`: "Low", "Medium", "High", "Critical"
- `STATUS`: "Active", "Investigating", "Resolved"
- `START_TIME`: When incident started
- `END_TIME`: When incident resolved
- `DURATION_MINUTES`: Total incident duration
- `AFFECTED_AREA`: Geographic area
- `AFFECTED_CUSTOMERS_COUNT`: Number of customers impacted
- `SERVICE_TYPE`: "Internet", "Voice", "TV", "Mobile"
- `ROOT_CAUSE`: Cause description
- `RESOLUTION_NOTES`: How it was resolved
- `RELATED_CALLS_COUNT`: Number of customer calls related to incident

**Sample Data**:
```csv
INCIDENT_ID,INCIDENT_TYPE,SEVERITY,STATUS,START_TIME,END_TIME,DURATION_MINUTES,AFFECTED_AREA,AFFECTED_CUSTOMERS_COUNT,SERVICE_TYPE,ROOT_CAUSE,RESOLUTION_NOTES,RELATED_CALLS_COUNT
inc_001,Outage,High,Resolved,2025-01-13 08:00:00,2025-01-13 14:30:00,390,Downtown District,1247,Internet,"Fiber cable cut during construction","Rerouted traffic to backup fiber path. Permanent repair scheduled.",156
inc_002,Degradation,Medium,Resolved,2025-01-15 16:00:00,2025-01-15 18:00:00,120,North Suburbs,432,Internet,"Router firmware issue","Applied firmware patch and restarted equipment.",28
```

### Knowledge Base Data

#### 8. `agent_knowledge_base.csv` (~150 rows)
Internal documentation and troubleshooting guides.

**Columns**:
- `ARTICLE_ID`: Unique article identifier
- `TITLE`: Article title
- `CATEGORY`: "Technical", "Billing", "Process", "Product"
- `SUBCATEGORY`: Specific topic
- `ARTICLE_CONTENT`: Full article text
- `KEYWORDS`: Search keywords
- `CREATED_DATE`: When article was created
- `LAST_UPDATED`: Last update
- `VIEW_COUNT`: Number of times viewed
- `HELPFULNESS_RATING`: 1-5 stars from agents
- `RELATED_PRODUCTS`: Applicable products/services

**Sample Data**:
```csv
ARTICLE_ID,TITLE,CATEGORY,SUBCATEGORY,ARTICLE_CONTENT,KEYWORDS,CREATED_DATE,LAST_UPDATED,VIEW_COUNT,HELPFULNESS_RATING,RELATED_PRODUCTS
kb_001,Troubleshooting Internet Connectivity,Technical,Internet,"Step 1: Check if modem is powered on...",connectivity;internet;modem;router,2024-01-10,2025-01-05,1247,4.8,Internet Service
kb_002,Explaining Billing Charges,Billing,Invoices,"Common questions about bill charges...",billing;charges;invoice;fees,2024-02-15,2024-12-20,892,4.5,All Services
```

## Audio Files

**Note**: Audio files are stored separately and uploaded to `@AUDIO_STAGE/call_recordings/` during deployment.

**File Structure**:
```
audio_files/
├── call_001_customer_support.mp3
├── call_002_technical_issue.mp3
├── call_003_billing_inquiry.mp3
├── ...
└── call_500_general_inquiry.mp3
```

**Audio Specifications**:
- **Format**: MP3, 48kbps mono
- **Duration**: 3-15 minutes per call
- **Language**: English (90%), Spanish (7%), French (3%)
- **Quality**: Clear audio, minimal background noise
- **Content**: Synthetic conversations matching transcript data

## Data Relationships

```
CUSTOMER_PROFILES
    ├─→ CALL_TRANSCRIPTS (via CUSTOMER_ID)
    ├─→ SUPPORT_TICKETS (via CUSTOMER_ID)
    ├─→ CUSTOMER_COMMUNICATIONS (via CUSTOMER_ID)
    └─→ Churn predictions

AGENT_PERFORMANCE
    ├─→ CALL_TRANSCRIPTS (via AGENT_ID)
    ├─→ SUPPORT_TICKETS (via AGENT_ID)
    └─→ CUSTOMER_COMMUNICATIONS (via AGENT_ID)

NETWORK_INCIDENTS
    └─→ CALL_TRANSCRIPTS (via timestamp correlation)

AGENT_KNOWLEDGE_BASE
    └─→ Search service for agent assist
```

## Data Generation Notes

All data is synthetically generated using:
- GPT-4 for realistic conversation text
- Statistical distributions for metrics (normal, Poisson, beta)
- Time-series patterns for call volumes and sentiment trends
- Realistic business rules (e.g., VIP customers have lower churn)

**Privacy**: No real customer data or PII is included.

## Loading Data

Data is automatically loaded during deployment using COPY INTO statements:

```sql
-- Example
COPY INTO CALL_TRANSCRIPTS
FROM @DATA_STAGE/call_transcripts.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```

## File Sizes

| File | Rows | Size |
|------|------|------|
| call_transcripts.csv | 10,000 | ~5 MB |
| call_sentiment_summary.csv | 500 | ~150 KB |
| customer_profiles.csv | 5,000 | ~1.5 MB |
| support_tickets.csv | 1,000 | ~800 KB |
| customer_communications.csv | 2,000 | ~1.2 MB |
| agent_performance.csv | 50 | ~15 KB |
| network_incidents.csv | 300 | ~200 KB |
| agent_knowledge_base.csv | 150 | ~500 KB |
| **Total CSV** | **18,000+** | **~10 MB** |
| **Audio files** | **500** | **~2 GB** |

## Next Steps

1. Review data structure and columns
2. Run deployment script to load data
3. Verify data in Snowflake tables
4. Start building search services and semantic views

---

**Questions?** See [DEPLOYMENT_README.md](../../DEPLOYMENT_README.md) for more details.

