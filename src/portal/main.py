import httpx
import streamlit as st

SERVER_URL = "http://server_service:8000"

st.set_page_config(page_title="ScholarBot", layout="centered")
st.title("ScholarBot")
st.caption("Deep Research Agent")

# Server status indicator
try:
    response = httpx.get(f"{SERVER_URL}/health", timeout=2)
    st.success("Server connected", icon="✅") if response.status_code == 200 else st.warning("Server unreachable", icon="⚠️")
except Exception:
    st.warning("Server unreachable", icon="⚠️")

st.divider()

question = st.text_area("Ask a research question", height=100)

if st.button("Research", type="primary") and question.strip():
    with st.spinner("Researching..."):
        try:
            response = httpx.post(
                f"{SERVER_URL}/chat",
                json={"question": question},
                timeout=30,
            )
            response.raise_for_status()
            answer = response.json()["answer"]
            with st.chat_message("assistant"):
                st.write(answer)
        except Exception as e:
            st.error(f"Request failed: {e}")
