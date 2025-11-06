"""
Git Helper Utilities for Codebase Genius
Handles repository cloning, validation, and Git operations
"""

import subprocess;
import os;
import re;
import tempfile;
import shutil;
import from datetime {datetime};

"""Git Operations Helper"""
obj GitHelper {
    """Validate GitHub URL format"""
    static can validate_github_url(url: str) -> bool {
        """
        Check if URL is a valid GitHub repository URL
        Supports: https://github.com/owner/repo, git@github.com:owner/repo.git
        """
        patterns = [
            r"^https://github\.com/[\w-]+/[\w.-]+/?$",
            r"^git@github\.com:[\w-]+/[\w.-]+\.git$",
            r"^https://github\.com/[\w-]+/[\w.-]+\.git$"
        ];
        
        for pattern in patterns {
            if re.match(pattern, url) {
                return True;
            }
        }
        return False;
    }
    
    """Extract repository name from URL"""
    static can extract_repo_name(url: str) -> str {
        """
        Extract repository name from GitHub URL
        Example: https://github.com/jaseci-labs/jaseci -> jaseci
        """
        # Remove .git suffix if present
        url = url.rstrip("/");
        if url.endswith(".git") {
            url = url[:-4];
        }
        
        # Extract last part of URL
        parts = url.split("/");
        return parts[-1];
    }
    
    """Clone a repository to local directory"""
    static can clone_repository(repo_url: str, target_dir: str) -> dict {
        """
        Clone a GitHub repository using git command
        Returns: {"success": bool, "path": str, "error": str}
        """
        try {
            # Ensure target directory exists
            os.makedirs(os.path.dirname(target_dir), exist_ok=True);
            
            # Remove existing directory if it exists
            if os.path.exists(target_dir) {
                shutil.rmtree(target_dir);
            }
            
            # Clone the repository
            result = subprocess.run(
                ["git", "clone", "--depth", "1", repo_url, target_dir],
                capture_output=True,
                text=True,
                timeout=300  # 5 minutes timeout
            );
            
            if result.returncode == 0 {
                return {
                    "success": True,
                    "path": target_dir,
                    "error": ""
                };
            } else {
                return {
                    "success": False,
                    "path": "",
                    "error": result.stderr
                };
            }
        } except Exception as e {
            return {
                "success": False,
                "path": "",
                "error": str(e)
            };
        }
    }
    
    """Get default branch name"""
    static can get_default_branch(repo_path: str) -> str {
        """Get the default branch name of the repository"""
        try {
            result = subprocess.run(
                ["git", "symbolic-ref", "refs/remotes/origin/HEAD"],
                cwd=repo_path,
                capture_output=True,
                text=True
            );
            
            if result.returncode == 0 {
                # Output format: refs/remotes/origin/main
                branch = result.stdout.strip().split("/")[-1];
                return branch;
            }
        } except Exception {
            pass;
        }
        
        # Default fallback
        return "main";
    }
    
    """Check if git is installed"""
    static can is_git_installed() -> bool {
        """Verify that git command is available"""
        try {
            result = subprocess.run(
                ["git", "--version"],
                capture_output=True,
                timeout=5
            );
            return result.returncode == 0;
        } except Exception {
            return False;
        }
    }
}

"""File System Helper"""
obj FileSystemHelper {
    """Get file tree structure from directory"""
    static can get_file_tree(root_path: str, ignore_dirs: list[str] = None) -> dict {
        """
        Traverse directory and return structured file tree
        Returns: {"files": list[str], "total_size": int, "file_count": int}
        """
        if ignore_dirs is None {
            ignore_dirs = [
                ".git", "node_modules", "__pycache__", ".venv", "venv",
                ".pytest_cache", ".mypy_cache", "dist", "build", ".egg-info",
                "coverage", ".coverage", ".tox", ".idea", ".vscode"
            ];
        }
        
        files = [];
        total_size = 0;
        file_count = 0;
        
        try {
            for root, dirs, filenames in os.walk(root_path) {
                # Remove ignored directories from traversal
                dirs[:] = [d for d in dirs if d not in ignore_dirs];
                
                for filename in filenames {
                    # Skip hidden files and certain extensions
                    if filename.startswith(".") {
                        continue;
                    }
                    
                    full_path = os.path.join(root, filename);
                    relative_path = os.path.relpath(full_path, root_path);
                    
                    # Get file size
                    try {
                        file_size = os.path.getsize(full_path);
                        total_size += file_size;
                        
                        files.append({
                            "path": relative_path.replace("\\", "/"),  # Normalize path
                            "name": filename,
                            "size": file_size
                        });
                        file_count += 1;
                    } except Exception {
                        continue;
                    }
                }
            }
        } except Exception as e {
            print(f"Error traversing directory: {e}");
        }
        
        return {
            "files": files,
            "total_size": total_size,
            "file_count": file_count
        };
    }
    
    """Read file content"""
    static can read_file_content(file_path: str) -> str {
        """Safely read file content with encoding handling"""
        encodings = ["utf-8", "latin-1", "cp1252"];
        
        for encoding in encodings {
            try {
                with open(file_path, "r", encoding=encoding) as f {
                    return f.read();
                }
            } except UnicodeDecodeError {
                continue;
            } except Exception as e {
                print(f"Error reading file {file_path}: {e}");
                return "";
            }
        }
        
        return "";
    }
    
    """Find README file"""
    static can find_readme(repo_path: str) -> str {
        """Find and return path to README file"""
        readme_names = ["README.md", "README.MD", "Readme.md", "readme.md", "README", "README.txt"];
        
        for name in readme_names {
            readme_path = os.path.join(repo_path, name);
            if os.path.exists(readme_path) {
                return readme_path;
            }
        }
        
        return "";
    }
    
    """Create temporary workspace"""
    static can create_temp_workspace() -> str {
        """Create a temporary directory for cloning repositories"""
        temp_base = os.path.join(tempfile.gettempdir(), "codebase_genius");
        os.makedirs(temp_base, exist_ok=True);
        
        # Create unique subdirectory with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S");
        workspace = os.path.join(temp_base, f"repo_{timestamp}");
        os.makedirs(workspace, exist_ok=True);
        
        return workspace;
    }
    
    """Clean up temporary workspace"""
    static can cleanup_workspace(workspace_path: str) -> bool {
        """Remove temporary workspace directory"""
        try {
            if os.path.exists(workspace_path) {
                shutil.rmtree(workspace_path);
                return True;
            }
            return False;
        } except Exception as e {
            print(f"Error cleaning up workspace: {e}");
            return False;
        }
    }
    
    """Format file size"""
    static can format_file_size(size_bytes: int) -> str {
        """Convert bytes to human-readable format"""
        for unit in ["B", "KB", "MB", "GB"] {
            if size_bytes < 1024.0 {
                return f"{size_bytes:.2f} {unit}";
            }
            size_bytes /= 1024.0;
        }
        return f"{size_bytes:.2f} TB";
    }
}

"""Validation Helper"""
obj ValidationHelper {
    """Validate repository structure"""
    static can is_valid_repository(repo_path: str) -> bool {
        """Check if directory is a valid git repository"""
        git_dir = os.path.join(repo_path, ".git");
        return os.path.isdir(git_dir);
    }
    
    """Check if repository is too large"""
    static can check_repository_size(total_size: int, max_size_mb: int = 500) -> dict {
        """
        Verify repository size is within limits
        Returns: {"valid": bool, "size_mb": float, "message": str}
        """
        size_mb = total_size / (1024 * 1024);
        
        if size_mb > max_size_mb {
            return {
                "valid": False,
                "size_mb": size_mb,
                "message": f"Repository too large ({size_mb:.2f}MB). Maximum is {max_size_mb}MB."
            };
        }
        
        return {
            "valid": True,
            "size_mb": size_mb,
            "message": "Repository size is acceptable."
        };
    }
    
    """Filter files by extension"""
    static can filter_by_extension(files: list[dict], extensions: list[str]) -> list[dict] {
        """Filter file list by extensions (e.g., ['.py', '.jac'])"""
        return [f for f in files if any(f["name"].endswith(ext) for ext in extensions)];
    }
}
