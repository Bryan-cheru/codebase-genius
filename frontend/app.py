import streamlit as st
import requests
import time
import os

# Page config
st.set_page_config(
    page_title="Codebase Genius - AI Documentation Generator",
    page_icon="📚",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for professional styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: 700;
        color: #1f77b4;
        margin-bottom: 0.5rem;
    }
    .subtitle {
        font-size: 1.1rem;
        color: #555;
        margin-bottom: 2rem;
    }
    .section-header {
        font-size: 1.3rem;
        font-weight: 600;
        color: #1f77b4;
        margin-top: 1.5rem;
        margin-bottom: 1rem;
    }
    .info-box {
        background-color: #f0f7ff;
        border-left: 4px solid #1f77b4;
        padding: 1rem;
        margin: 1rem 0;
        border-radius: 4px;
    }
    .success-box {
        background-color: #f0fdf4;
        border-left: 4px solid #22c55e;
        padding: 1rem;
        margin: 1rem 0;
        border-radius: 4px;
    }
    .error-box {
        background-color: #fef2f2;
        border-left: 4px solid #ef4444;
        padding: 1rem;
        margin: 1rem 0;
        border-radius: 4px;
    }
    .stat-card {
        background-color: #f8f9fa;
        padding: 1rem;
        border-radius: 6px;
        text-align: center;
        margin: 0.5rem 0;
    }
    .stat-value {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1f77b4;
    }
    .stat-label {
        font-size: 0.9rem;
        color: #666;
        margin-top: 0.25rem;
    }
</style>
""", unsafe_allow_html=True)

# Constants - Use environment variable for API URL, fallback to localhost for development
BASE_URL = os.environ.get("BACKEND_URL", "http://localhost:8000")
GENERATE_DOCS_ENDPOINT = f"{BASE_URL}/walker/generate_docs"
STATUS_ENDPOINT = f"{BASE_URL}/walker/get_status"

# Initialize session state
if 'generated_docs' not in st.session_state:
    st.session_state.generated_docs = None
if 'current_repo' not in st.session_state:
    st.session_state.current_repo = None
if 'processing' not in st.session_state:
    st.session_state.processing = False
if 'repo_input' not in st.session_state:
    st.session_state.repo_input = ""

# Sidebar
with st.sidebar:
    st.header("About")
    st.markdown("""
    **Codebase Genius** is an AI-powered documentation generator that analyzes GitHub repositories 
    and creates comprehensive documentation.
    """)
    
    st.subheader("Features")
    st.markdown("""
    - Code structure analysis
    - Function and class extraction
    - Architecture insights
    - Dependency visualization
    - Professional markdown output
    """)
    
    st.subheader("How to Use")
    st.markdown("""
    1. Enter a GitHub repository URL
    2. Click "Generate Documentation"
    3. Wait for AI analysis to complete
    4. Download the generated documentation
    """)
    
    st.divider()
    st.subheader("About This Tool")
    st.markdown("Built with Streamlit, Jac, and Google Gemini AI")

# Main content
st.markdown('<div class="main-header">Codebase Genius</div>', unsafe_allow_html=True)
st.markdown('<div class="subtitle">AI-Powered Repository Documentation Generator</div>', unsafe_allow_html=True)

col1, col2 = st.columns([2, 1], gap="large")

with col1:
    st.markdown('<div class="section-header">Repository Analysis</div>', unsafe_allow_html=True)
    
    # Input section
    repo_url = st.text_input(
        "GitHub Repository URL",
        value=st.session_state.repo_input,
        placeholder="https://github.com/username/repository",
        help="Enter the full URL of a public GitHub repository"
    )

    # Generate button
    if st.button("Generate Documentation", type="primary", use_container_width=True, key="generate_btn"):
        if repo_url:
            # Strip whitespace from repo_url
            repo_url = repo_url.strip()
            
            # Clean URL by removing query parameters and fragments
            if '?' in repo_url:
                repo_url = repo_url.split('?')[0]
            if '#' in repo_url:
                repo_url = repo_url.split('#')[0]
            
            # Validate GitHub URL
            if not repo_url.startswith("https://github.com/"):
                st.error("Please enter a valid GitHub repository URL starting with https://github.com/")
                st.stop()
            
            st.session_state.processing = True
            st.session_state.current_repo = repo_url
            st.session_state.repo_input = repo_url

            # Create a container for progress updates
            progress_container = st.empty()
            status_container = st.empty()

            with progress_container.container():
                progress_bar = st.progress(0)
                status_text = st.empty()

            # Progress phases
            phases = [
                ("Initializing", 0.1, "Setting up analysis environment"),
                ("Cloning Repository", 0.3, "Downloading repository files"),
                ("Analyzing Code Structure", 0.5, "Parsing functions, classes, and relationships"),
                ("Generating AI Insights", 0.7, "Using Google Gemini for intelligent analysis"),
                ("Creating Documentation", 0.9, "Compiling professional markdown documentation"),
                ("Finalizing", 1.0, "Preparing download")
            ]

            try:
                # Simulate progress through phases
                for phase_name, progress_value, description in phases[:-1]:
                    progress_bar.progress(progress_value)
                    status_text.markdown(f"**{phase_name}**\n{description}")
                    time.sleep(0.5)

                # Make the actual API call
                payload = {"repo_url": repo_url, "session_id": ""}
                progress_bar.progress(0.95)
                status_text.markdown("**Processing with AI**\nThis may take 1-3 minutes for larger repositories.")

                response = requests.post(GENERATE_DOCS_ENDPOINT, json=payload, timeout=300)

                # Complete progress
                progress_bar.progress(1.0)
                status_text.markdown("**Processing Complete**")

                if response.status_code == 200:
                    data = response.json()
                    reports = data.get("reports", [])

                    if reports:
                        report = reports[0]
                        if report.get("status") == "success":
                            docs = report.get("docs", "")
                            st.session_state.generated_docs = docs
                            st.success("Documentation generated successfully!")

                            # Show preview
                            with st.expander("Preview Documentation", expanded=True):
                                st.markdown(docs)
                        else:
                            st.error(f"Generation failed: {report.get('docs', 'Unknown error')}")
                    else:
                        st.error("No response received from server")
                else:
                    st.error(f"Server error: {response.status_code} - {response.text}")

            except requests.exceptions.Timeout:
                st.warning("Processing is taking longer than expected. Large repositories can take up to 5 minutes. Please wait or try a smaller repository.")
            except requests.exceptions.ConnectionError:
                st.error("Cannot connect to backend server. Please ensure the backend is running.")
            except Exception as e:
                st.error(f"Unexpected error: {str(e)}")
            finally:
                st.session_state.processing = False
                progress_container.empty()
        else:
            st.error("Please enter a repository URL")

    # Status check button
    col_status_a, col_status_b = st.columns(2)
    with col_status_a:
        if st.button("Check Server Status", use_container_width=True):
            try:
                response = requests.post(STATUS_ENDPOINT, timeout=10)
                if response.status_code == 200:
                    st.success("Server is responding")
                else:
                    st.error(f"Status check failed: {response.status_code}")
            except Exception as e:
                st.error(f"Cannot connect to server: {str(e)}")

with col2:
    st.markdown('<div class="section-header">Documentation</div>', unsafe_allow_html=True)

    # Show current documentation if available
    if st.session_state.generated_docs:
        repo_name = st.session_state.current_repo.split('/')[-1] if st.session_state.current_repo else "repository"
        st.markdown(f'<div class="success-box">Documentation ready for <strong>{repo_name}</strong></div>', unsafe_allow_html=True)

        # Download button
        st.download_button(
            label="Download Markdown",
            data=st.session_state.generated_docs,
            file_name=f"{repo_name}_documentation.md",
            mime="text/markdown",
            use_container_width=True
        )

        # Show stats
        doc_content = st.session_state.generated_docs
        lines = len(doc_content.split('\n'))
        words = len(doc_content.split())
        
        st.markdown("""
        <div class="stat-card">
            <div class="stat-value">""" + str(lines) + """</div>
            <div class="stat-label">Lines</div>
        </div>
        """, unsafe_allow_html=True)
        
        st.markdown("""
        <div class="stat-card">
            <div class="stat-value">""" + str(words) + """</div>
            <div class="stat-label">Words</div>
        </div>
        """, unsafe_allow_html=True)

    else:
        st.markdown("""
        <div class="info-box">
            Generate documentation to see results here
        </div>
        """, unsafe_allow_html=True)

        # Example section
        st.divider()
        st.subheader("Example Repositories")
        examples = [
            ("Hello-World", "https://github.com/octocat/Hello-World"),
            ("VSCode", "https://github.com/microsoft/vscode"),
            ("Jaseci", "https://github.com/rayklanderman/jaseci-proj")
        ]

        for name, example in examples:
            if st.button(f"Try: {name}", key=f"example_{example}", use_container_width=True):
                st.session_state.repo_input = example
                st.session_state.generated_docs = None
                st.session_state.current_repo = None
                st.rerun()

# Footer
st.divider()
st.markdown("""
<div style="text-align: center; color: #888; padding: 2rem 0;">
    <p>Codebase Genius - AI Documentation Generator</p>
    <p style="font-size: 0.85rem;">Built with Streamlit, Jac, and Google Gemini</p>
</div>
""", unsafe_allow_html=True)

# Processing indicator
if st.session_state.processing:
    st.info("Processing in progress. Please wait...")

