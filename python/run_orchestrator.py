#!/usr/bin/env python3
"""
Wrapper script to run orchestrator directly with proper environment setup.
"""
import sys
import os
import json

# Ensure we're using the venv python
script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(script_dir)

# Add current directory to path
sys.path.insert(0, script_dir)

# Add parent directory to path (for relative imports)
sys.path.insert(0, parent_dir)

# Load environment variables from .env file
from dotenv import load_dotenv
env_path = os.path.join(parent_dir, '.env')
load_dotenv(env_path)

# Import and run orchestrator
try:
    from orchestrator import orchestrate_documentation
    
    repo_url = sys.argv[1] if len(sys.argv) > 1 else ""
    
    if not repo_url:
        error_response = {
            "status": "error",
            "error": "repo_url argument is required"
        }
        print(json.dumps(error_response))
        sys.exit(1)
    
    result = orchestrate_documentation(repo_url)
    print(json.dumps(result))
    sys.exit(0)
    
except Exception as e:
    import traceback
    error_response = {
        "status": "error",
        "error": f"Orchestrator failed: {str(e)}",
        "details": traceback.format_exc()
    }
    print(json.dumps(error_response))
    sys.exit(1)
