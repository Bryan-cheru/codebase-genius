# Codebase Genius �

An AI-powered documentation system that automatically generates high-quality documentation for any software repository using multi-agent architecture and Google Gemini AI.

## 🌟 Features

- **🤖 AI-Powered Analysis**: Uses Google Gemini AI for intelligent code understanding
- **🔄 Multi-Agent System**: Supervisor, RepoMapper, CodeAnalyzer, and DocGenie agents
- **📊 Code Structure Analysis**: Parses code relationships and dependencies
- **🌐 Graph Visualization**: Builds Code Context Graphs with NetworkX
- **📝 Professional Documentation**: Generates comprehensive markdown docs
- **🎨 Modern Web UI**: Streamlit-based interface with real-time progress
- **☁️ Cloud Ready**: Easily deployable to Render and Streamlit Cloud
- **🔒 Secure**: Environment variable management for API keys

## 🏗️ Architecture

Codebase Genius uses a simplified, production-ready architecture:

- **Backend** (`main.jac`) - Jac API server with walker endpoints
- **Python Orchestrator** - Handles repository analysis and documentation generation
- **Gemini Integration** - AI-powered code analysis and insights
- **Frontend** (`app.py`) - Streamlit web interface

## 📋 Prerequisites

- Python 3.10 or higher
- Git installed
- Google Gemini API key
- Jac language installed

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Bryan-cheru/codebase-genius.git
cd codebase-genius/codebase_genius
```

### 2. Set Up Virtual Environment

```bash
# Create virtual environment
python -m venv venv

# Activate it
# On Windows:
.\venv\Scripts\Activate.ps1

# On Linux/Mac:
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment

Create a `.env` file in the codebase_genius directory:

```bash
# Google Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Backend API Configuration
BACKEND_URL=http://localhost:8000
```

### 5. Run the Backend Server

```bash
jac serve main.jac
```

The server will start on `http://localhost:8000`

### 6. Run the Frontend (in a new terminal)

```bash
cd frontend
pip install -r requirements.txt
streamlit run app.py
```

The frontend will start on `http://localhost:8501`

### 7. Use the Application

Visit `http://localhost:8501` and:
1. Enter a GitHub repository URL
2. Click "Generate Documentation"
3. Download the AI-generated markdown documentation

## 🔌 API Endpoints

**Generate Documentation:**
```bash
POST /walker/generate_docs
```
Request body:
```json
{
  "repo_url": "https://github.com/username/repo-name",
  "session_id": ""
}
```

**Check Status:**
```bash
POST /walker/get_status
```

## 📚 Generated Output
curl http://localhost:8000/walker/get_documentation?repo_name=<repo_name>
```

## 🖥️ Using the Frontend

We also provide a Streamlit frontend for a better user experience:

```bash
cd FE
pip install -r requirements.txt
streamlit run app.py
```

Then open your browser to `http://localhost:8501`

## 📁 Project Structure

```
codebase_genius/
├── main.jac                 # Main API server entry point
├── requirements.txt         # Python dependencies
├── .env                     # Environment variables (create this)
├── README.md               # This file
├── agents/                 # Agent implementations
│   ├── supervisor.jac      # Code Genius orchestrator
│   ├── repo_mapper.jac     # Repository mapping agent
│   ├── code_analyzer.jac   # Code analysis agent
│   └── doc_genie.jac       # Documentation generator
├── models/                 # Data models (nodes & edges)
│   └── nodes.jac          # Graph node definitions
├── utils/                  # Utility functions
│   ├── git_helpers.jac    # Git operations
│   ├── parsers.jac        # Code parsers
│   └── diagram_gen.jac    # Diagram generation
├── outputs/                # Generated documentation
└── FE/                     # Streamlit frontend
    ├── app.py
    └── requirements.txt
```

## 🔧 Configuration

### Supported LLM Providers

- OpenAI (GPT-4, GPT-3.5)
- Google Gemini (gemini-1.5-flash, gemini-1.5-pro)
- Any LiteLLM-compatible provider

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENAI_API_KEY` | OpenAI API key | One of the API keys |
| `GOOGLE_API_KEY` | Google Gemini API key | One of the API keys |
| `OUTPUT_DIR` | Custom output directory | No (default: ./outputs) |
| `MAX_FILE_SIZE` | Max file size to analyze (MB) | No (default: 10) |

## 📊 Example Output

Generated documentation includes:

- **Project Overview**: Summary from README
- **File Structure**: Complete directory tree
- **Code Context Graph**: Visual diagram of relationships
- **API Reference**: Functions and classes with signatures
- **Installation Guide**: Setup instructions
- **Usage Examples**: Code snippets and examples

## 🧪 Testing

Run the test suite:

```bash
jac test tests/
```

Test on a sample repository:

```bash
# Using the CLI
jac run main.jac --repo-url https://github.com/jaseci-labs/jaseci
```

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md).

## 📝 License

This project is part of the Agentic-AI repository by Jaseci Labs.

## 🆘 Troubleshooting

### Common Issues

**Issue**: "jac: command not found"
```bash
pip install --upgrade jaclang
```

**Issue**: "Failed to clone repository"
- Ensure the repository URL is correct and publicly accessible
- Check your internet connection
- Verify Git is installed: `git --version`

**Issue**: "API key not found"
- Make sure you've created a `.env` file
- Ensure the API key variable name matches exactly
- Restart the server after updating `.env`

## 📚 Resources

- [Jac Language Documentation](https://www.jac-lang.org/)
- [Jaseci GitHub](https://github.com/Jaseci-Labs/jaseci)
- [byLLM Documentation](https://www.jac-lang.org/learn/jac-byllm/)

## 🎯 Roadmap

- [ ] Support for more programming languages (JavaScript, Go, Rust)
- [ ] Advanced code metrics (cyclomatic complexity, test coverage)
- [ ] Integration with CI/CD pipelines
- [ ] Real-time collaboration features
- [ ] Export to PDF/HTML formats

---

Built with ❤️ using [Jac Language](https://www.jac-lang.org/) and Jaseci ecosystem
