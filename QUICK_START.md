# Codebase Genius - Quick Start Guide

## 🎯 Overview

Codebase Genius is an AI-powered, multi-agent system built with Jac language that automatically generates comprehensive documentation for GitHub repositories.

## ⚡ Quick Start (5 minutes)

### 1. Setup

```powershell
# Run the setup script
.\setup.ps1
```

Or manually:

```powershell
# Create virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Create .env file
Copy-Item .env.example .env
# Edit .env and add your API key
```

### 2. Configure API Key

Edit `.env` file and add your API key:

```bash
# For OpenAI
OPENAI_API_KEY=your_key_here

# OR for Google Gemini
GOOGLE_API_KEY=your_key_here
```

### 3. Start the Backend Server

```powershell
jac serve main.jac
```

The server will start on `http://localhost:8000`

### 4. Start the Frontend (Optional)

In a **new terminal**:

```powershell
cd FE
pip install -r requirements.txt
streamlit run app.py
```

The UI will open at `http://localhost:8501`

## 📚 Usage

### Option 1: Using the Web UI (Recommended)

1. Open `http://localhost:8501` in your browser
2. Navigate to "Analyze Repository"
3. Enter a GitHub URL (e.g., `https://github.com/username/repo`)
4. Click "Analyze Repository"
5. Wait for processing (2-5 minutes)
6. View documentation in "View Documentation" tab

### Option 2: Using API (cURL)

```bash
# Analyze a repository
curl -X POST http://localhost:8000/walker/analyze_repository \
  -H "Content-Type: application/json" \
  -d '{
    "repo_url": "https://github.com/username/repository"
  }'

# Check status
curl -X POST http://localhost:8000/walker/check_status_api \
  -H "Content-Type: application/json" \
  -d '{"repo_name": "repository"}'

# Get documentation
curl -X POST http://localhost:8000/walker/get_documentation \
  -H "Content-Type: application/json" \
  -d '{"repo_name": "repository"}'
```

### Option 3: Using Python

```python
import requests

# Analyze repository
response = requests.post(
    "http://localhost:8000/walker/analyze_repository",
    json={"repo_url": "https://github.com/username/repo"}
)

result = response.json()
print(result)
```

## 🏗️ Architecture

```
Codebase Genius
│
├── Main API (main.jac)
│   └── Exposes walkers as HTTP endpoints
│
├── Code Genius Supervisor
│   └── Orchestrates the 3-stage pipeline
│
├── Stage 1: Repo Mapper
│   ├── Clones repository
│   ├── Generates file tree
│   └── Summarizes README
│
├── Stage 2: Code Analyzer
│   ├── Parses Python/Jac files
│   ├── Extracts functions & classes
│   └── Builds Code Context Graph
│
└── Stage 3: Doc Genie
    ├── Generates markdown docs
    ├── Creates diagrams
    └── Produces API reference
```

## 📊 Example Output

The generated documentation includes:

- **Project Overview**: Summary and statistics
- **File Structure**: Complete directory tree
- **Installation Guide**: Setup instructions
- **API Reference**: Functions and classes with signatures
- **Architecture Diagrams**: Visual representations (Mermaid)
- **Dependencies**: Import relationships
- **Usage Examples**: Code snippets

## 🎯 Supported Languages

- ✅ **Python** (Full support with AST parsing)
- ✅ **Jac** (Pattern-based parsing)
- 🔄 **JavaScript, TypeScript, Java** (Basic support)

## ⚙️ Configuration Options

Edit `.env` to customize:

```bash
# Output directory
OUTPUT_DIR=./outputs

# Maximum repository size in MB
MAX_FILE_SIZE=500

# Maximum files to analyze
MAX_FILES=100

# Temporary directory
TEMP_DIR=./temp
```

## 📝 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/walker/analyze_repository` | POST | Full repository analysis |
| `/walker/quick_analyze_api` | POST | Quick URL validation |
| `/walker/check_status_api` | POST | Check analysis status |
| `/walker/get_documentation` | POST | Retrieve documentation |
| `/walker/list_repositories` | POST | List all repositories |
| `/walker/health_check` | POST | System health check |

## 🐛 Troubleshooting

### "jac: command not found"

```powershell
pip install --upgrade jaclang
```

### "Git not found"

Install Git from https://git-scm.com/download/win

### "API key not found"

Make sure `.env` file exists and contains your API key.

### Port already in use

```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process
taskkill /PID <process_id> /F
```

## 📚 Resources

- [Jac Language Documentation](https://www.jac-lang.org/)
- [Jaseci GitHub](https://github.com/Jaseci-Labs/jaseci)
- [Assignment PDF](../Assignment2%20(1).pdf)

## 🤝 Contributing

This project was built following the assignment requirements. Key features:

- ✅ Multi-agent architecture
- ✅ Repository cloning and mapping
- ✅ Code Context Graph (CCG) construction
- ✅ Markdown documentation generation
- ✅ HTTP API with Jac server
- ✅ Streamlit frontend
- ✅ Error handling and validation

## 📄 License

Part of the Agentic-AI project by Jaseci Labs.

---

Built with ❤️ using [Jac Language](https://www.jac-lang.org/)
