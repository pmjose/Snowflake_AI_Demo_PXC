"""
Snowflake Intelligence - SnowMail
Gmail-style email viewer with split-pane layout
"""

import streamlit as st
import streamlit.components.v1 as components
from snowflake.snowpark.context import get_active_session
import pandas as pd
from datetime import datetime

# Page config
st.set_page_config(
    page_title="SnowMail",
    page_icon="❄️",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS for Gmail-like styling
st.markdown("""
<style>
    .stApp {
        background-color: #f5f7fa;
    }
    .main .block-container {
        padding-top: 1rem;
        padding-left: 0;
        padding-right: 0;
        max-width: 100%;
    }
    section[data-testid="stSidebar"] {
        display: none;
    }
    /* Custom button styling for email list */
    div[data-testid="column"] .stButton button {
        background: white !important;
        border: none !important;
        padding: 14px 16px !important;
        width: 100% !important;
        text-align: left !important;
        color: #202124 !important;
        font-size: 13px !important;
        border-radius: 0 !important;
        border-bottom: 1px solid #f0f0f0 !important;
        margin: 0 !important;
        transition: background 0.1s !important;
    }
    div[data-testid="column"] .stButton button:hover {
        background-color: #f5f5f5 !important;
        box-shadow: inset 4px 0 0 #29B5E8 !important;
    }
    div[data-testid="column"] .stButton button[kind="primary"] {
        background-color: #e8f4f8 !important;
        box-shadow: inset 4px 0 0 #29B5E8 !important;
        font-weight: 500 !important;
    }
    /* Action buttons styling */
    .action-btn button {
        background: #29B5E8 !important;
        color: white !important;
        border: none !important;
        border-radius: 6px !important;
        padding: 8px 20px !important;
        font-weight: 600 !important;
        font-size: 14px !important;
        width: auto !important;
        min-width: 140px !important;
    }
    .action-btn button:hover {
        background: #1e8bb5 !important;
    }
    .delete-btn button {
        background: white !important;
        color: #d93025 !important;
        border: 1px solid #dadce0 !important;
        border-radius: 6px !important;
        padding: 8px 20px !important;
        font-weight: 600 !important;
        font-size: 14px !important;
        width: auto !important;
        min-width: 100px !important;
    }
    .delete-btn button:hover {
        background: #fef7f6 !important;
        border-color: #d93025 !important;
    }
</style>
""", unsafe_allow_html=True)

# Get Snowflake session
session = get_active_session()

# Initialize session state
if 'selected_email_id' not in st.session_state:
    st.session_state['selected_email_id'] = None

# Header
st.markdown("""
<div style="padding: 16px 24px; background: white; border-bottom: 1px solid #e0e0e0; margin-bottom: 0;">
    <h1 style="margin: 0; font-size: 26px; color: #29B5E8; font-family: Lato, sans-serif; font-weight: 700;">
        ❄️ SnowMail
    </h1>
</div>
""", unsafe_allow_html=True)

# Query emails from table
try:
    emails_query = """
    SELECT 
        EMAIL_ID,
        RECIPIENT_EMAIL,
        SUBJECT,
        CREATED_AT,
        LENGTH(HTML_CONTENT) as HTML_SIZE
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS
    ORDER BY CREATED_AT DESC
    LIMIT 500
    """
    
    emails_df = session.sql(emails_query).to_pandas()
    
    if len(emails_df) == 0:
        st.info("📭 Your SnowMail inbox is empty. Use the Population Health, Clinical Trials, or Cost of Care agents to generate email reports.")
    else:
        # Format timestamps
        emails_df['CREATED_AT'] = pd.to_datetime(emails_df['CREATED_AT'])
        emails_df['Time'] = emails_df['CREATED_AT'].dt.strftime('%b %d, %I:%M %p')
        emails_df['Full_Time'] = emails_df['CREATED_AT'].dt.strftime('%b %d, %Y, %I:%M %p')
        
        # Create two-column layout
        col_list, col_detail = st.columns([1.5, 2.5])
        
        # LEFT PANE: Email List
        with col_list:
            # List header
            st.markdown(f"""
            <div style="background: white; padding: 16px 16px 12px 16px; border-bottom: 2px solid #e0e0e0;">
                <span style="font-size: 15px; color: #202124; font-weight: 600;">📬 Inbox</span>
                <span style="font-size: 13px; color: #5f6368; margin-left: 8px;">({len(emails_df)})</span>
            </div>
            """, unsafe_allow_html=True)
            
            # Create container for email list
            st.markdown('<div style="background: white;">', unsafe_allow_html=True)
            
            # Email list
            for idx, row in emails_df.iterrows():
                is_selected = (st.session_state['selected_email_id'] == row['EMAIL_ID'])
                
                # Truncate subject and recipient
                subject = row['SUBJECT'][:50] + "..." if len(row['SUBJECT']) > 50 else row['SUBJECT']
                recipient = row['RECIPIENT_EMAIL'][:30] + "..." if len(row['RECIPIENT_EMAIL']) > 30 else row['RECIPIENT_EMAIL']
                
                button_label = f"**{subject}**\nTo: {recipient} • {row['Time']}"
                
                if st.button(button_label, key=f"email_{row['EMAIL_ID']}", type="primary" if is_selected else "secondary"):
                    st.session_state['selected_email_id'] = row['EMAIL_ID']
                    st.experimental_rerun()
            
            st.markdown('</div>', unsafe_allow_html=True)
        
        # RIGHT PANE: Email Detail
        with col_detail:
            if st.session_state['selected_email_id']:
                # Get selected email
                selected_email = emails_df[emails_df['EMAIL_ID'] == st.session_state['selected_email_id']].iloc[0]
                
                # Email header
                st.markdown(f"""
                <div style="background: white; padding: 24px; border-bottom: 1px solid #e0e0e0;">
                    <div style="font-size: 20px; font-weight: 500; color: #202124; margin-bottom: 20px;">
                        {selected_email['SUBJECT']}
                    </div>
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <div style="width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, #29B5E8 0%, #11567F 100%); display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 16px; flex-shrink: 0;">
                            SI
                        </div>
                        <div style="flex: 1;">
                            <div style="font-size: 14px; font-weight: 600; color: #202124;">
                                Snowflake Intelligence Portfolio Analytics
                            </div>
                            <div style="font-size: 13px; color: #5f6368; margin-top: 2px;">
                                to {selected_email['RECIPIENT_EMAIL']}
                            </div>
                        </div>
                        <div style="font-size: 12px; color: #5f6368; flex-shrink: 0;">
                            {selected_email['Full_Time']}
                        </div>
                    </div>
                </div>
                """, unsafe_allow_html=True)
                
                # Action buttons
                st.markdown('<div style="background: white; padding: 16px 24px; border-bottom: 1px solid #e0e0e0;">', unsafe_allow_html=True)
                
                btn_col1, btn_col2, btn_col3, btn_col4 = st.columns([1.5, 1.5, 1.2, 3])
                
                with btn_col1:
                    st.markdown('<div class="action-btn">', unsafe_allow_html=True)
                    if st.button("📧 View Email", key="btn_view"):
                        st.session_state['email_view_mode'] = 'rendered'
                        st.experimental_rerun()
                    st.markdown('</div>', unsafe_allow_html=True)
                
                with btn_col2:
                    st.markdown('<div class="action-btn">', unsafe_allow_html=True)
                    if st.button("</> HTML Source", key="btn_html"):
                        st.session_state['email_view_mode'] = 'html'
                        st.experimental_rerun()
                    st.markdown('</div>', unsafe_allow_html=True)
                
                with btn_col3:
                    st.markdown('<div class="delete-btn">', unsafe_allow_html=True)
                    if st.button("🗑️ Delete", key="btn_delete"):
                        delete_query = f"""
                        DELETE FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS
                        WHERE EMAIL_ID = '{st.session_state['selected_email_id']}'
                        """
                        session.sql(delete_query).collect()
                        st.session_state['selected_email_id'] = None
                        st.experimental_rerun()
                    st.markdown('</div>', unsafe_allow_html=True)
                
                st.markdown('</div>', unsafe_allow_html=True)
                
                # Fetch HTML content
                html_query = f"""
                SELECT HTML_CONTENT
                FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS
                WHERE EMAIL_ID = '{st.session_state['selected_email_id']}'
                """
                html_result = session.sql(html_query).collect()
                
                if html_result:
                    html_content = html_result[0]['HTML_CONTENT']
                    
                    # Display content
                    st.markdown('<div style="background: white; padding: 0;">', unsafe_allow_html=True)
                    
                    if st.session_state.get('email_view_mode', 'rendered') == 'rendered':
                        components.html(html_content, height=700, scrolling=True)
                    else:
                        st.markdown('<div style="padding: 20px;">', unsafe_allow_html=True)
                        st.code(html_content, language="html", line_numbers=True)
                        st.markdown('</div>', unsafe_allow_html=True)
                    
                    st.markdown('</div>', unsafe_allow_html=True)
                else:
                    st.error("Email content not found")
            
            else:
                # No email selected
                st.markdown("""
                <div style="background: white; padding: 120px 40px; text-align: center; min-height: 700px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                    <div style="font-size: 64px; margin-bottom: 24px; opacity: 0.3;">📧</div>
                    <div style="font-size: 18px; color: #5f6368; font-weight: 500;">
                        Select an email to view
                    </div>
                    <div style="font-size: 14px; color: #80868b; margin-top: 8px;">
                        Choose a message from the inbox to read
                    </div>
                </div>
                """, unsafe_allow_html=True)

except Exception as e:
    st.error(f"""
    **Error loading emails**
    
    {str(e)}
    
    Make sure the EMAIL_PREVIEWS table exists and you have the correct permissions.
    """)
