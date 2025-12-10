import streamlit as st
import json
import _snowflake
import re
from snowflake.snowpark.context import get_active_session
logo = 'snowflake_logo_color_rgb.svg'
session = get_active_session()
model = 'llama3.3-70b'
st.set_page_config(layout="wide")
with open('extra.css') as ab:
    st.markdown(f"<style>{ab.read()}</style>", unsafe_allow_html=True)

st.logo(logo)
session = get_active_session()
#st.write(session)




API_ENDPOINT = "/api/v2/cortex/agent:run"
API_TIMEOUT = 50000  # in milliseconds

CORTEX_SEARCH_SERVICES = "DEFAULT_SCHEMA.CHUNKED_REPORTS"
SEMANTIC_MODELS = "@CORTEX_ANALYST.CORTEX_ANALYST/semantic_model.yaml"

def run_snowflake_query(query):
    """Run Snowflake SQL Query"""
    try:
        df = session.sql(query.replace(';',''))
        return df

    except Exception as e:
        st.error(f"Error executing SQL: {str(e)}")
        return None, None

def snowflake_api_call(query: str, limit: int = 10):
    """Make an Agent API Call"""
    payload = {
        "model": f"{model}",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": query
                    }
                ]
            }
        ],
        "tools": [
            {
                "tool_spec": {
                    "type": "cortex_analyst_text_to_sql",
                    "name": "analyst1"
                }
            },
            {
                "tool_spec": {
                    "type": "cortex_search",
                    "name": "search1"
                }
            }
        ],
        "tool_resources": {
            "analyst1": {"semantic_model_file": SEMANTIC_MODELS},
            "search1": {
                "name": CORTEX_SEARCH_SERVICES,
                "max_results": 10,
                "id_column": "RELATIVE_PATH"
            }
        }
    }
    
    try:
        resp = _snowflake.send_snow_api_request(
            "POST",  # method
            API_ENDPOINT,  # path
            {},  # headers
            {},  # params
            payload,  # body
            None,  # request_guid
            API_TIMEOUT,  # timeout in milliseconds,
        )
        
        if resp["status"] != 200:
            st.error(f"❌ HTTP Error: {resp['status']} - {resp.get('reason', 'Unknown reason')}")
            st.error(f"Response details: {resp}")
            return None
        
        try:
            response_content = json.loads(resp["content"])
        except json.JSONDecodeError:
            st.error("❌ Failed to parse API response. The server may have returned an invalid JSON format.")
            st.error(f"Raw response: {resp['content'][:200]}...")
            return None
            
        return response_content
            
    except Exception as e:
        st.error(f"Error making request: {str(e)}")
        return None

def process_sse_response(response):
    """Process SSE response"""
    text = ""
    sql = ""
    citations = []
    
    if not response:
        return text, sql, citations
    if isinstance(response, str):
        return text, sql, citations
    try:
        for event in response:
            if event.get('event') == "message.delta":
                data = event.get('data', {})
                delta = data.get('delta', {})
                
                for content_item in delta.get('content', []):
                    content_type = content_item.get('type')
                    if content_type == "tool_results":
                        tool_results = content_item.get('tool_results', {})
                        if 'content' in tool_results:
                            for result in tool_results['content']:
                                if result.get('type') == 'json':
                                    text += result.get('json', {}).get('text', '')
                                    search_results = result.get('json', {}).get('searchResults', [])
                                    for search_result in search_results:
                                        citations.append({'source_id':search_result.get('source_id',''), 'doc_id':search_result.get('doc_id', '')})
                                    sql = result.get('json', {}).get('sql', '')
                    if content_type == 'text':
                        text += content_item.get('text', '')
                            
    except json.JSONDecodeError as e:
        st.error(f"Error processing events: {str(e)}")
                
    except Exception as e:
        st.error(f"Error processing events: {str(e)}")
        
    return text, sql, citations

@st.cache_data
def execute_cortex_complete_sql(prompt):
    """
    Execute Cortex Complete using the SQL API
    """
    cmd = "SELECT snowflake.cortex.complete(?, ?) AS response"
    df_response = session.sql(cmd, params=[f"{model}", prompt]).collect()
    response_txt = df_response[0].RESPONSE
    return response_txt

@st.cache_data
def extract_python_code(text):
    """
    Extract only the Streamlit chart execution code from LLM output, including all arguments.
    """
    pattern = r"st\.(line_chart|bar_chart|scatter_chart)\((.*)\)"
    match = re.search(pattern, text, re.DOTALL)
    
    if match:
        code = f"st.{match.group(1)}({match.group(2)})"
        return code.strip()  # Ensure clean extraction
    return None  # Return None if no chart code is found


def replace_chart_function(chart_string, new_chart_type):
    return re.sub(r"st\.(\w+_chart)", f"st.{new_chart_type}", chart_string)




def main():
    st.markdown('<h0black>SNOWFLAKE | </h0black><h0blue>STOCK ANALYSIS</h0blue><BR>', unsafe_allow_html=True)

    # Sidebar for new chat
    with st.sidebar:
        if st.button("NEW CONVERSATION", key="new_chat", type="secondary"):
            st.session_state.messages = []
            st.rerun()

    # Initialize session state
    if 'messages' not in st.session_state:
        st.session_state.messages = []

    for message in st.session_state.messages:
        with st.chat_message(message['role'],avatar='🦋'):
            st.markdown(message['content'].replace("•", "\n\n"))

    if query := st.chat_input("Ask me any question about snowflake?"):
        # Add user message to chat
        with st.chat_message("user",avatar="🐟"):
            st.markdown(query)
        st.session_state.messages.append({"role": "user", "content": query})
        
        # Get response from API
        with st.spinner("Processing your request..."):
            response = snowflake_api_call(query, 1)
            text, sql, citations = process_sse_response(response)
            
            # Add assistant response to chat
            if text:
                text = text.replace("【†", "[")
                text = text.replace("†】", "]")
                st.session_state.messages.append({"role": "assistant", "content": text})
                
                with st.chat_message("assistant", avatar="🐬"):
                    st.markdown(text.replace("•", "\n\n"))
                    
                    # Display citations if present
                    if citations:
                        st.markdown('<h0blue>CITATIONS</h0blue><BR>', unsafe_allow_html=True)
                        for citation in citations:
                            doc_id = citation.get("doc_id", "")
                            if doc_id:
                                query = f"SELECT TEXT FROM DEFAULT_SCHEMA.TEXT_AND_SOUND WHERE RELATIVE_PATH = '{doc_id}'"
                                result = run_snowflake_query(query)
                                result_df = result.to_pandas()
                                if not result_df.empty:
                                    transcript_text = result_df.iloc[0, 0]
                                else:
                                    transcript_text = "No transcript available"
                    
                                with st.expander(f"[{citation.get('source_id', '')}]"):
                                    st.write(transcript_text)
        
            # Display SQL if present
            if sql:
                st.markdown('<h0blue>STRUCTURED DATA</h0blue><BR>', unsafe_allow_html=True)
                with st.expander("SQL", expanded=True):
                    st.code(sql, language="sql")

                with st.expander("Data Analysis", expanded=True):
                    analysis_results = run_snowflake_query(sql).to_pandas()

                    if len(analysis_results.index) > 1:
                        data_tab, suggested_plot, line_tab, bar_tab, scatter_tab = st.tabs(
                         ["Data", "Suggested Plot", "Line Chart", "Bar Chart","Scatter Chart"]
                     )
                        data_tab.dataframe(analysis_results)
                        
                        if len(analysis_results.columns) > 1:
                            analysis_results = analysis_results.set_index(analysis_results.columns[0])
                        
                        with suggested_plot:
                            try:
                                prompt = f'''
                                            Create a streamlit plot using st.line_chart OR st.bar_chart OR st.scatter_chart 
                                            based on the dataframe is called "analysis_results" with given columns: {analysis_results.columns}.
                                            Give me ONLY the code itself based on the columns. 
                                            select only columns relevant to the query - {query}.
                                            Do not create fake data.
                                            Do not include imports.
                                            Do not include any columns that are not provided.
                                            only return the best chart for the data
                                            Choose only 1 value for X and 1 value for Y. for each chart, add color='#29B5E8'
                                            
                                            '''
                                code = execute_cortex_complete_sql(prompt)
                                #st.write(code)
                                execution_code = extract_python_code(code)
                                
                                st.code(execution_code, language="python", line_numbers=False)
                                exec(execution_code)
                            except:
                                pass
                        
                        with line_tab:

                            
                            
                            try:
                                exec(replace_chart_function(execution_code, 'line_chart'))
                                #st.line_chart(analysis_results,color='#29B5E8')
                            except:
                                pass
                        
                        with bar_tab:
                            try: 
                                exec(replace_chart_function(execution_code, 'bar_chart'))
                                #st.bar_chart(analysis_results,color='#29B5E8')
                            except:
                                pass
                                
                        with scatter_tab:
                            try: 
                                exec(replace_chart_function(execution_code, 'scatter_chart'))
                                #st.bar_chart(analysis_results,color='#29B5E8')
                            except:
                                pass
                    else:
                        st.dataframe(analysis_results)

if __name__ == "__main__":
    main()

# Questions to try:
    
# - i would like to see the sentiment score for each minute and also what has been said in the last earnings call
# - What analyst gave a rating of sell?
# - what is the SNOW stock price by year?
# - what is the SNOW stock price by month during 2023