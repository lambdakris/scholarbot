import httpx
import streamlit as st

SERVER_URL = "http://server_service:8000"

st.set_page_config(page_title="ScholarBot", layout="centered")
st.title("ScholarBot")
st.caption("Deep Research Agent")

# Server status indicator
try:
    response = httpx.get(f"{SERVER_URL}/health", timeout=2)
    if response.status_code == 200:
        st.success("Server connected", icon="✅")
    else:
        st.warning("Server unreachable", icon="⚠️")
except Exception:
    st.warning("Server unreachable", icon="⚠️")

st.divider()

question = st.text_area("Ask a research question", height=100)

if st.button("Research", type="primary") and question.strip():
    with st.chat_message("assistant"):
        st.write("*(Agent not yet connected — coming in Milestone 1)*")
