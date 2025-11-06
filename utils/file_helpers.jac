"""
File System Helper Utilities for Codebase Genius
Handles file operations, workspace creation, and cleanup
"""

import os;
import shutil;
import tempfile;
import from datetime {datetime};

"""File System Operations Helper"""
obj FileSystemHelper {
    """Create temporary workspace directory"""
    static can create_temp_workspace() -> str {
        """
        Create a temporary directory for cloning repositories
        Returns: Absolute path to the workspace directory
        """
        temp_base = tempfile.gettempdir();
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S");
        workspace_name = f"codebase_genius_{timestamp}";
        workspace_path = os.path.join(temp_base, workspace_name);
        
        os.makedirs(workspace_path, exist_ok=True);
        return workspace_path;
    }
    
    """Cleanup workspace directory"""
    static can cleanup_workspace(workspace_path: str) -> bool {
        """
        Remove temporary workspace directory and all contents
        Returns: True if successful, False otherwise
        """
        try {
            if os.path.exists(workspace_path) {
                shutil.rmtree(workspace_path);
                print(f"🧹 Cleaned up workspace: {workspace_path}");
                return True;
            }
            return True;
        } except Exception as e {
            print(f"⚠️  Failed to cleanup workspace: {e}");
            return False;
        }
    }
    
    """Get file extension"""
    static can get_file_extension(file_path: str) -> str {
        """Extract file extension from path"""
        return os.path.splitext(file_path)[1];
    }
    
    """Check if path is a Python file"""
    static can is_python_file(file_path: str) -> bool {
        """Check if file is a Python source file"""
        return file_path.endswith(".py");
    }
    
    """Check if path is a Jac file"""
    static can is_jac_file(file_path: str) -> bool {
        """Check if file is a Jac source file"""
        return file_path.endswith(".jac");
    }
    
    """Get language from file extension"""
    static can get_language(file_path: str) -> str {
        """
        Determine programming language from file extension
        Returns: language name (python, jac, javascript, etc.) or empty string
        """
        ext = FileSystemHelper.get_file_extension(file_path).lower();
        
        language_map = {
            ".py": "python",
            ".jac": "jac",
            ".js": "javascript",
            ".ts": "typescript",
            ".java": "java",
            ".cpp": "cpp",
            ".c": "c",
            ".go": "go",
            ".rs": "rust",
            ".rb": "ruby",
            ".php": "php"
        };
        
        return language_map.get(ext, "");
    }
    
    """Walk directory and collect files"""
    static can walk_directory(root_path: str, max_files: int = 1000) -> list[str] {
        """
        Recursively walk directory and collect file paths
        Returns: List of relative file paths
        """
        file_list = [];
        count = 0;
        
        for dirpath, dirnames, filenames in os.walk(root_path) {
            # Skip common ignored directories
            dirnames[:] = [d for d in dirnames if d not in ['.git', '__pycache__', 'node_modules', 'venv', '.venv', 'build', 'dist']];
            
            for filename in filenames {
                if count >= max_files {
                    break;
                }
                
                full_path = os.path.join(dirpath, filename);
                rel_path = os.path.relpath(full_path, root_path);
                file_list.append(rel_path);
                count += 1;
            }
            
            if count >= max_files {
                break;
            }
        }
        
        return file_list;
    }
}

"""File Prioritizer - Determines which files to analyze first"""
obj FilePrioritizer {
    """Prioritize files based on importance"""
    static can prioritize_files(files: list) -> list {
        """
        Sort files by priority for analysis
        Priority order:
        1. Entry points (main.py, app.py, __init__.py)
        2. Python/Jac files
        3. Other source files
        """
        entry_points = [];
        python_jac_files = [];
        other_files = [];
        
        for file in files {
            file_name = getattr(file, 'file_name', '');
            file_path = getattr(file, 'file_path', '');
            
            # Check if entry point
            if file_name in ['main.py', 'app.py', '__main__.py', 'main.jac', 'app.jac'] or \
               file_name == '__init__.py' {
                entry_points.append(file);
            } else if FileSystemHelper.is_python_file(file_path) or \
                     FileSystemHelper.is_jac_file(file_path) {
                python_jac_files.append(file);
            } else {
                other_files.append(file);
            }
        }
        
        # Combine in priority order
        return entry_points + python_jac_files + other_files;
    }
}
