"""
Codebase Genius - Streamlit Frontend
User-friendly interface for repository analysis and documentation viewing
"""

import streamlit as st
import requests
import json
from datetime import datetime
import os

# ==================== CONFIGURATION ====================

API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

# ==================== PAGE CONFIG ====================

st.set_page_config(
    page_title="Codebase Genius",
    page_icon="🧠",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ==================== CUSTOM CSS ====================

st.markdown("""
    <style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        text-align: center;
        margin-bottom: 2rem;
        color: #1f77b4;
    }
    .success-box {
        padding: 1rem;
        background-color: #d4edda;
        border-left: 4px solid #28a745;
        margin: 1rem 0;
    }
    .error-box {
        padding: 1rem;
        background-color: #f8d7da;
        border-left: 4px solid #dc3545;
        margin: 1rem 0;
    }
    .info-box {
        padding: 1rem;
        background-color: #d1ecf1;
        border-left: 4px solid #17a2b8;
        margin: 1rem 0;
    }
    </style>
""", unsafe_allow_html=True)

# ==================== HELPER FUNCTIONS ====================

def call_api(endpoint, method="POST", data=None):
    """Make API request to Jac server"""
    url = f"{API_BASE_URL}/walker/{endpoint}"
    try:
        if method == "POST":
            response = requests.post(
                url,
                json=data,
                headers={"Content-Type": "application/json"},
                timeout=300  # 5 minutes timeout
            )
        else:
            response = requests.get(url, timeout=30)
        
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        return {"success": False, "error": str(e)}

# ==================== SIDEBAR ====================

with st.sidebar:
    st.markdown("## 🧠 Codebase Genius")
    st.markdown("### AI-Powered Documentation Generator")
    st.markdown("---")
    
    page = st.radio(
        "Navigation",
        ["🏠 Home", "🔍 Analyze Repository", "📚 View Documentation", "📊 Status", "⚙️ Settings"]
    )
    
    st.markdown("---")
    st.markdown("### About")
    st.markdown("""
    Codebase Genius automatically generates
    comprehensive documentation for any
    GitHub repository using multi-agent AI.
    """)
    
    # Health Check
    with st.expander("🔧 System Status"):
        if st.button("Check Health"):
            health = call_api("health_check")
            if health.get("success"):
                status = health["health"]["status"]
                if status == "healthy":
                    st.success(f"✅ Status: {status.upper()}")
                else:
                    st.warning(f"⚠️ Status: {status.upper()}")
                
                st.json(health["health"])
            else:
                st.error("Failed to check health")

# ==================== HOME PAGE ====================

if page == "🏠 Home":
    st.markdown('<div class="main-header">🧠 Codebase Genius</div>', unsafe_allow_html=True)
    st.markdown("### Automated Documentation Generation for Code Repositories")
    
    st.markdown("---")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown("#### 🗺️ Repository Mapping")
        st.markdown("""
        - Clone GitHub repositories
        - Generate file tree structure
        - Extract README summary
        """)
    
    with col2:
        st.markdown("#### 🔍 Code Analysis")
        st.markdown("""
        - Parse Python & Jac files
        - Extract functions & classes
        - Build Code Context Graph
        """)
    
    with col3:
        st.markdown("#### 📝 Documentation")
        st.markdown("""
        - Generate markdown docs
        - Create architecture diagrams
        - API reference generation
        """)
    
    st.markdown("---")
    
    st.markdown("### 🚀 Quick Start")
    st.markdown("""
    1. Navigate to **Analyze Repository**
    2. Enter a GitHub repository URL
    3. Click **Analyze** and wait for processing
    4. View the generated documentation in **View Documentation**
    """)
    
    st.markdown("---")
    
    # List recent repositories
    st.markdown("### 📚 Recent Repositories")
    repos_response = call_api("list_repositories")
    
    if repos_response.get("success") and repos_response.get("count", 0) > 0:
        for repo in repos_response["repositories"][-5:]:  # Last 5
            with st.expander(f"📦 {repo['name']}"):
                col1, col2 = st.columns(2)
                with col1:
                    st.markdown(f"**URL:** {repo['url']}")
                    st.markdown(f"**Status:** {repo['status']}")
                with col2:
                    st.markdown(f"**Files:** {repo['analyzed_files']}/{repo['total_files']}")
                    st.markdown(f"**Docs:** {'✅' if repo['has_documentation'] else '❌'}")
    else:
        st.info("No repositories analyzed yet. Start by analyzing your first repository!")

# ==================== ANALYZE REPOSITORY PAGE ====================

elif page == "🔍 Analyze Repository":
    st.markdown("## 🔍 Analyze Repository")
    st.markdown("Enter a GitHub repository URL to analyze and generate documentation.")
    
    st.markdown("---")
    
    with st.form("analyze_form"):
        repo_url = st.text_input(
            "GitHub Repository URL",
            placeholder="https://github.com/username/repository",
            help="Enter the full URL of a public GitHub repository"
        )
        
        st.markdown("### ⚙️ Options")
        col1, col2 = st.columns(2)
        
        with col1:
            max_size = st.number_input("Max Repository Size (MB)", value=500, min_value=10, max_value=5000)
            max_files = st.number_input("Max Files to Analyze", value=100, min_value=10, max_value=1000)
        
        with col2:
            include_diagrams = st.checkbox("Include Diagrams", value=True)
            cleanup = st.checkbox("Cleanup Workspace", value=True, help="Remove temporary files after analysis")
        
        submitted = st.form_submit_button("🚀 Analyze Repository", use_container_width=True)
    
    if submitted:
        if not repo_url:
            st.error("Please enter a repository URL")
        else:
            # Quick validation first
            with st.spinner("Validating repository..."):
                quick_check = call_api("quick_analyze_api", data={"repo_url": repo_url})
            
            if quick_check.get("success"):
                st.success("✅ Repository URL is valid")
                
                # Start full analysis
                st.markdown("---")
                st.markdown("### 📊 Analysis Progress")
                
                progress_bar = st.progress(0)
                status_text = st.empty()
                
                status_text.text("🚀 Starting analysis pipeline...")
                progress_bar.progress(10)
                
                # Make API call
                with st.spinner("Analyzing repository... This may take a few minutes."):
                    result = call_api(
                        "analyze_repository",
                        data={
                            "repo_url": repo_url,
                            "max_size_mb": max_size,
                            "max_files": max_files,
                            "include_diagrams": include_diagrams,
                            "cleanup_workspace": cleanup
                        }
                    )
                
                progress_bar.progress(100)
                
                if result.get("success"):
                    status_text.text("✅ Analysis complete!")
                    st.balloons()
                    
                    st.markdown('<div class="success-box">', unsafe_allow_html=True)
                    st.markdown("### ✅ Analysis Successful!")
                    st.markdown(f"**Repository:** {result['data'].get('repo_url', 'N/A')}")
                    st.markdown('</div>', unsafe_allow_html=True)
                    
                    # Show stages
                    st.markdown("### 📊 Pipeline Stages")
                    for stage_name, stage_data in result["data"]["stages"].items():
                        status_icon = "✅" if stage_data["status"] == "success" else "❌"
                        st.markdown(f"{status_icon} **{stage_name.capitalize()}**: {stage_data['status']}")
                    
                    st.info("📄 Navigate to **View Documentation** to see the generated docs!")
                    
                else:
                    status_text.text("❌ Analysis failed")
                    st.markdown('<div class="error-box">', unsafe_allow_html=True)
                    st.markdown("### ❌ Analysis Failed")
                    st.markdown(f"**Error:** {result.get('error', 'Unknown error')}")
                    st.markdown('</div>', unsafe_allow_html=True)
                    
                    if "data" in result:
                        with st.expander("View Details"):
                            st.json(result["data"])
            else:
                st.error(f"❌ Invalid repository: {quick_check.get('error', 'Unknown error')}")

# ==================== VIEW DOCUMENTATION PAGE ====================

elif page == "📚 View Documentation":
    st.markdown("## 📚 View Documentation")
    st.markdown("Browse and view generated documentation for analyzed repositories.")
    
    st.markdown("---")
    
    # Get list of repositories
    repos_response = call_api("list_repositories")
    
    if repos_response.get("success") and repos_response.get("count", 0) > 0:
        # Filter repos with documentation
        repos_with_docs = [r for r in repos_response["repositories"] if r["has_documentation"]]
        
        if repos_with_docs:
            # Repository selector
            repo_names = [r["name"] for r in repos_with_docs]
            selected_repo = st.selectbox("Select Repository", repo_names)
            
            if selected_repo:
                # Get documentation
                doc_response = call_api("get_documentation", data={"repo_name": selected_repo})
                
                if doc_response.get("success"):
                    # Show metadata
                    with st.expander("📋 Documentation Info"):
                        st.markdown(f"**Repository:** {doc_response['repo_name']}")
                        st.markdown(f"**Generated At:** {doc_response['generated_at']}")
                    
                    # Show documentation
                    st.markdown("---")
                    st.markdown(doc_response["content"])
                    
                    # Download button
                    st.download_button(
                        label="⬇️ Download Documentation",
                        data=doc_response["content"],
                        file_name=f"{selected_repo}_documentation.md",
                        mime="text/markdown"
                    )
                else:
                    st.error(f"Failed to load documentation: {doc_response.get('error')}")
        else:
            st.info("No repositories with documentation found. Analyze a repository first!")
    else:
        st.info("No repositories found. Start by analyzing a repository!")

# ==================== STATUS PAGE ====================

elif page == "📊 Status":
    st.markdown("## 📊 Repository Status")
    st.markdown("View the status of all analyzed repositories.")
    
    st.markdown("---")
    
    if st.button("🔄 Refresh", use_container_width=True):
        st.rerun()
    
    # Get all repositories
    repos_response = call_api("list_repositories")
    
    if repos_response.get("success") and repos_response.get("count", 0) > 0:
        st.markdown(f"### Found {repos_response['count']} repositories")
        
        for repo in repos_response["repositories"]:
            with st.container():
                col1, col2, col3, col4 = st.columns([3, 2, 2, 2])
                
                with col1:
                    st.markdown(f"### 📦 {repo['name']}")
                    st.markdown(f"[{repo['url']}]({repo['url']})")
                
                with col2:
                    status_color = {
                        "completed": "🟢",
                        "analyzed": "🟢",
                        "mapped": "🟡",
                        "cloning": "🟡",
                        "failed": "🔴"
                    }.get(repo['status'], "⚪")
                    st.markdown(f"**Status:** {status_color} {repo['status']}")
                
                with col3:
                    st.metric("Files", f"{repo['analyzed_files']}/{repo['total_files']}")
                
                with col4:
                    doc_status = "✅" if repo['has_documentation'] else "❌"
                    st.markdown(f"**Docs:** {doc_status}")
                
                st.markdown("---")
    else:
        st.info("No repositories found.")

# ==================== SETTINGS PAGE ====================

elif page == "⚙️ Settings":
    st.markdown("## ⚙️ Settings")
    st.markdown("Configure Codebase Genius settings.")
    
    st.markdown("---")
    
    st.markdown("### 🔧 API Configuration")
    
    new_api_url = st.text_input(
        "API Base URL",
        value=API_BASE_URL,
        help="The base URL of the Jac server"
    )
    
    if st.button("Test Connection"):
        health = call_api("health_check")
        if health.get("success"):
            st.success("✅ Connection successful!")
            st.json(health["health"])
        else:
            st.error("❌ Connection failed!")
    
    st.markdown("---")
    
    st.markdown("### 📊 Statistics")
    repos_response = call_api("list_repositories")
    
    if repos_response.get("success"):
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Total Repositories", repos_response.get("count", 0))
        
        with col2:
            repos_with_docs = len([r for r in repos_response.get("repositories", []) if r.get("has_documentation")])
            st.metric("With Documentation", repos_with_docs)
        
        with col3:
            total_files = sum(r.get("total_files", 0) for r in repos_response.get("repositories", []))
            st.metric("Total Files Analyzed", total_files)

# ==================== FOOTER ====================

st.markdown("---")
st.markdown("""
<div style="text-align: center; color: #666;">
    <p>🧠 Codebase Genius - Built with Jac Language & Streamlit</p>
    <p>Jaseci Labs © 2025</p>
</div>
""", unsafe_allow_html=True)
