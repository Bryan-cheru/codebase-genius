# 🚀 Quick Start Guide

Get Codebase Genius running in 5 minutes!

## Prerequisites

- Python 3.10+
- Git
- Google Gemini API key (free from https://aistudio.google.com/app/apikey)

## Step 1: Setup (2 minutes)

```bash
# Navigate to codebase_genius
cd codebase_genius

# Create virtual environment
python -m venv venv

# Activate it
.\venv\Scripts\Activate.ps1  # Windows
# OR
source venv/bin/activate     # Linux/Mac

# Install backend dependencies
pip install -r requirements.txt
```

## Step 2: Configure (1 minute)

Create `.env` file:
```bash
GEMINI_API_KEY=your_api_key_here
BACKEND_URL=http://localhost:8000
```

## Step 3: Start Backend (1 minute)

```bash
jac serve main.jac
```

Expected output:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

## Step 4: Start Frontend (1 minute)

Open **new terminal** in same folder:

```bash
# Activate venv again if needed
.\venv\Scripts\Activate.ps1  # Windows

# Install frontend deps
cd frontend
pip install -r requirements.txt

# Run Streamlit app
streamlit run app.py
```

Expected output:
```
Local URL: http://localhost:8501
```

## Step 5: Use It!

1. Open http://localhost:8501 in browser
2. Paste a GitHub URL (e.g., https://github.com/octocat/Hello-World)
3. Click "Generate Documentation"
4. Download the markdown file ⬇️

## 📊 What Happens Behind the Scenes

```
┌─────────────────────────┐
│   Frontend (Streamlit)   │  You interact here
└────────────┬────────────┘
             │ HTTP POST
             ▼
┌─────────────────────────┐
│ Backend JAC Server      │  Orchestrates workflow
└────────────┬────────────┘
             │ Subprocess
             ▼
┌─────────────────────────┐
│ Python Orchestrator     │
│ • Clone repo            │
│ • Parse code            │
│ • Call Gemini AI        │
│ • Generate markdown     │
└────────────┬────────────┘
             │ Result
             ▼
┌─────────────────────────┐
│ Frontend Displays Docs   │  You download here
└─────────────────────────┘
```

## 🧪 Test It

Try these example repos:
- `https://github.com/octocat/Hello-World` (Simple, fast)
- `https://github.com/python/cpython` (Complex, slower)

## 🐛 Troubleshooting

### Port Already in Use
```bash
# JAC uses 8000, Streamlit uses 8501
# Kill processes or use different ports:
streamlit run app.py --server.port 8502
```

### API Key Error
- Check GEMINI_API_KEY in .env
- Get free key: https://aistudio.google.com/app/apikey
- Make sure .env file exists in codebase_genius/

### Module Not Found
```bash
# Make sure virtual env is activated
pip list  # Should show streamlit, requests, etc.
```

### Connection Refused
- Check if JAC server is running
- Ensure it's on http://localhost:8000

## 📚 File Descriptions

| File | Purpose |
|------|---------|
| `main.jac` | JAC API server with endpoints |
| `python/orchestrator.py` | Main analysis coordinator |
| `python/repo_parser.py` | Code parsing engine |
| `python/gemini_connector.py` | AI integration |
| `frontend/app.py` | Streamlit web interface |

## 🔌 API Endpoints

**Generate Docs**
```bash
curl -X POST http://localhost:8000/walker/generate_docs \
  -H "Content-Type: application/json" \
  -d '{"repo_url":"https://github.com/user/repo","session_id":""}'
```

**Check Status**
```bash
curl -X POST http://localhost:8000/walker/get_status
```

## 💾 Output

Generated documentation saved to:
```
outputs/
└── repo-name/
    └── docs.md
```

## 🆘 Need Help?

1. Check UPDATE_SUMMARY.md for detailed changes
2. Review README.md for full documentation
3. Check .env.example for configuration options

## 🎉 Done!

You now have a working AI documentation generator!

Next: Deploy to cloud (see working/jaseci-proj for examples)

---

**Questions?** Check the generated docs in `outputs/` folder!

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
