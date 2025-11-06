# Codebase Genius - Setup Script for Windows PowerShell

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  🧠 CODEBASE GENIUS - SETUP SCRIPT" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Check Python installation
Write-Host "🔍 Checking Python installation..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Python not found. Please install Python 3.10 or higher." -ForegroundColor Red
    exit 1
}

# Check Git installation
Write-Host "`n🔍 Checking Git installation..." -ForegroundColor Yellow
$gitVersion = git --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Git found: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Git not found. Please install Git." -ForegroundColor Red
    exit 1
}

# Create virtual environment
Write-Host "`n📦 Creating virtual environment..." -ForegroundColor Yellow
if (Test-Path "venv") {
    Write-Host "⚠️  Virtual environment already exists. Skipping..." -ForegroundColor Yellow
} else {
    python -m venv venv
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
}

# Activate virtual environment
Write-Host "`n🔄 Activating virtual environment..." -ForegroundColor Yellow
.\venv\Scripts\Activate.ps1

# Upgrade pip
Write-Host "`n⬆️  Upgrading pip..." -ForegroundColor Yellow
python -m pip install --upgrade pip

# Install dependencies
Write-Host "`n📥 Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt

Write-Host "`n✅ Dependencies installed successfully!" -ForegroundColor Green

# Create .env file if it doesn't exist
if (!(Test-Path ".env")) {
    Write-Host "`n📝 Creating .env file..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created. Please edit it with your API keys." -ForegroundColor Green
    Write-Host "⚠️  IMPORTANT: Add your OPENAI_API_KEY or GOOGLE_API_KEY to .env" -ForegroundColor Yellow
} else {
    Write-Host "`n⚠️  .env file already exists. Skipping..." -ForegroundColor Yellow
}

# Create output directory
Write-Host "`n📁 Creating output directory..." -ForegroundColor Yellow
if (!(Test-Path "outputs")) {
    New-Item -ItemType Directory -Path "outputs" | Out-Null
    Write-Host "✅ Output directory created" -ForegroundColor Green
} else {
    Write-Host "✅ Output directory already exists" -ForegroundColor Green
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Edit .env file with your API key" -ForegroundColor White
Write-Host "  2. Start the server: jac serve main.jac" -ForegroundColor White
Write-Host "  3. In another terminal, run: streamlit run FE/app.py" -ForegroundColor White
Write-Host "`n" -ForegroundColor White
