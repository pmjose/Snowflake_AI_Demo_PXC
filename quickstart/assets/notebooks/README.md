# Snowflake Notebooks

## Overview

This directory contains 4 Snowflake notebooks for data processing and machine learning.

**Important**: These are **Snowflake notebooks** (not Jupyter), they run natively in Snowflake UI.

---

## Environment Files

- **environment.yml** - Dependencies for notebooks 1, 2, 4 (Document AI, Audio, Search)
- **ds_environment.yml** - Dependencies for notebook 3 (ML training with GPU)

---

## Notebooks

### 1. 1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb

**Purpose**: Document AI extraction from financial reports

**Features**:
- AI_PARSE_DOCUMENT for structure extraction
- AI_EXTRACT for data extraction
- Process 850+ financial reports
- Extract tables and metrics

**Try**: Extract revenue data from annual reports

---

### 2. 2_ANALYSE_SOUND.ipynb

**Purpose**: Audio transcription and sentiment analysis

**Features**:
- AI_TRANSCRIBE for earnings call audio
- AI_SENTIMENT for sentiment scoring
- Speaker diarization
- Transcript analysis

**Try**: Transcribe and analyze earnings call audio

---

### 3. 3_BUILD_A_QUANTITIVE_MODEL.ipynb

**Purpose**: ML model training for stock prediction

**Features**:
- XGBoost model training
- GPU acceleration
- Model registry integration
- Batch inference

**Try**: Train a stock price prediction model

---

### 4. 4_CREATE_SEARCH_SERVICE.ipynb

**Purpose**: Create and test Cortex Search services

**Features**:
- Create search services
- Test semantic search
- Build RAG applications
- Vector embeddings

**Try**: Build custom search service

---

## Deployment

Notebooks are automatically deployed by `05_deploy_notebooks.sql`.

## Access

After deployment:
1. Navigate to: **AI & ML Studio** → **Notebooks**
2. Select a notebook to open
3. Click "Run All" or run cells individually

---

## Important Notes

- These run **inside Snowflake** (not locally)
- No connection setup needed
- Direct access to all Snowflake data
- Pre-installed Snowpark and Cortex libraries
- Session object automatically available

**Always say "Snowflake notebooks" not "Jupyter notebooks"**

