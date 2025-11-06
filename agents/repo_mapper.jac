"""
Repo Mapper Agent - Clones and maps repository structure
Responsible for:
1. Cloning GitHub repositories
2. Generating file tree structures
3. Summarizing README files
4. Creating initial graph structure
"""

import os;
import from datetime {datetime};

# ==================== REPO MAPPER WALKER ====================

walker RepoMapper {
    """
    Walker that clones a repository and creates its initial graph structure.
    This is the first agent in the analysis pipeline.
    """
    has repo_url: str;
    has workspace_dir: str = "";
    has max_size_mb: int = 500;
    has result: dict = {};
    
    """Initialize workspace on entry"""
    can setup_workspace with `root entry {
        """Create temporary workspace for cloning"""
        print(f"\n{'='*60}");
        print("🚀 REPO MAPPER: Starting repository analysis");
        print(f"{'='*60}");
        print(f"Repository URL: {self.repo_url}");
        
        # Validate URL
        if not GitHelper.validate_github_url(self.repo_url) {
            self.result = {
                "success": False,
                "error": "Invalid GitHub URL format",
                "stage": "validation"
            };
            report self.result;
            disengage;
        }
        
        # Check if git is installed
        if not GitHelper.is_git_installed() {
            self.result = {
                "success": False,
                "error": "Git is not installed or not in PATH",
                "stage": "validation"
            };
            report self.result;
            disengage;
        }
        
        # Create workspace
        self.workspace_dir = FileSystemHelper.create_temp_workspace();
        print(f"✅ Workspace created: {self.workspace_dir}");
        
        # Continue to clone
        visit [-->](`?Repository) else {
            # Create new repository node if it doesn't exist
            repo_node = here ++> Repository(
                url=self.repo_url,
                name=GitHelper.extract_repo_name(self.repo_url),
                local_path="",
                status="cloning",
                created_at=str(datetime.now())
            );
            visit repo_node;
        }
    }
    
    """Clone and analyze repository"""
    can clone_and_analyze with Repository entry {
        """Clone the repository and perform initial analysis"""
        print(f"\n📥 Cloning repository: {here.name}...");
        
        # Set up target directory
        target_dir = os.path.join(self.workspace_dir, here.name);
        here.local_path = target_dir;
        here.status = "cloning";
        
        # Clone the repository
        clone_result = GitHelper.clone_repository(self.repo_url, target_dir);
        
        if not clone_result["success"] {
            here.status = "failed";
            here.error_message = clone_result["error"];
            self.result = {
                "success": False,
                "error": f"Failed to clone: {clone_result['error']}",
                "stage": "cloning"
            };
            report self.result;
            disengage;
        }
        
        print(f"✅ Repository cloned successfully");
        
        # Get default branch
        here.default_branch = GitHelper.get_default_branch(target_dir);
        
        # Generate file tree
        print(f"\n📊 Generating file tree...");
        file_tree_data = FileSystemHelper.get_file_tree(target_dir);
        
        here.total_files = file_tree_data["file_count"];
        print(f"✅ Found {here.total_files} files");
        
        # Check repository size
        size_check = ValidationHelper.check_repository_size(
            file_tree_data["total_size"],
            self.max_size_mb
        );
        
        if not size_check["valid"] {
            here.status = "failed";
            here.error_message = size_check["message"];
            self.result = {
                "success": False,
                "error": size_check["message"],
                "stage": "size_validation",
                "size_mb": size_check["size_mb"]
            };
            report self.result;
            disengage;
        }
        
        print(f"✅ Repository size: {size_check['size_mb']:.2f}MB (within limits)");
        
        # Create FileNode instances and connect them
        print(f"\n📁 Creating file nodes...");
        created_files = 0;
        
        for file_data in file_tree_data["files"] {
            # Determine file type and language
            file_name = file_data["name"];
            file_path = file_data["path"];
            file_ext = "." + file_name.split(".")[-1] if "." in file_name else "";
            
            # Create file node
            file_node = here ++> FileNode(
                file_path=file_path,
                file_name=file_name,
                file_type=file_ext,
                file_size=file_data["size"],
                is_entry_point=file_name in ["main.py", "app.py", "__init__.py", "main.jac", "server.jac"],
                language=FileTreeBuilder.get_language(file_ext)
            );
            
            created_files += 1;
        }
        
        print(f"✅ Created {created_files} file nodes");
        
        # Find and summarize README
        print(f"\n📄 Looking for README...");
        readme_path = FileSystemHelper.find_readme(target_dir);
        
        if readme_path {
            print(f"✅ Found README: {os.path.basename(readme_path)}");
            readme_content = FileSystemHelper.read_file_content(readme_path);
            
            if readme_content {
                # Summarize README (using byLLM if available, otherwise truncate)
                here.readme_summary = self.summarize_readme(readme_content);
                print(f"✅ README summarized ({len(here.readme_summary)} chars)");
            }
        } else {
            print("⚠️  No README found");
            here.readme_summary = "No README file found in repository.";
        }
        
        # Update repository status
        here.status = "mapped";
        
        # Prepare result
        self.result = {
            "success": True,
            "repo_name": here.name,
            "repo_url": here.url,
            "local_path": here.local_path,
            "total_files": here.total_files,
            "readme_summary": here.readme_summary,
            "size_mb": size_check["size_mb"],
            "stage": "completed"
        };
        
        print(f"\n{'='*60}");
        print("✅ REPO MAPPER: Analysis complete");
        print(f"{'='*60}\n");
        
        report self.result;
    }
    
    """Summarize README content"""
    can summarize_readme(content: str) -> str {
        """
        Create a concise summary of README content
        TODO: Integrate with byLLM for AI-powered summarization
        For now, we'll do a simple truncation with key sections
        """
        # Simple summarization - extract first 500 chars and look for key sections
        lines = content.split("\n");
        summary_lines = [];
        char_count = 0;
        max_chars = 500;
        
        for line in lines {
            line = line.strip();
            if not line {
                continue;
            }
            
            # Include headers and first paragraph
            if line.startswith("#") or len(summary_lines) < 3 {
                summary_lines.append(line);
                char_count += len(line);
                
                if char_count > max_chars {
                    break;
                }
            }
        }
        
        summary = "\n".join(summary_lines);
        if len(content) > max_chars {
            summary += "\n\n[README truncated - full content available in repository]";
        }
        
        return summary;
    }
}

# ==================== FILE TREE FORMATTER ====================

"""Helper walker to format file tree as markdown"""
walker FileTreeFormatter {
    """Generates a markdown-formatted file tree"""
    has tree_content: str = "";
    has depth: int = 0;
    
    can format_tree with Repository entry {
        """Start formatting from repository node"""
        self.tree_content = f"# File Structure: {here.name}\n\n";
        self.tree_content += "```\n";
        self.tree_content += f"{here.name}/\n";
        
        # Visit all file nodes
        visit [-->](`?FileNode);
    }
    
    can add_file with FileNode entry {
        """Add file to tree structure"""
        # Create indentation based on path depth
        path_parts = here.file_path.split("/");
        indent = "  " * (len(path_parts) - 1);
        
        # Add file with size info
        size_str = FileSystemHelper.format_file_size(here.file_size);
        marker = "📄" if not here.is_entry_point else "⭐";
        
        self.tree_content += f"{indent}├── {marker} {here.file_name} ({size_str})\n";
    }
}

# ==================== README SUMMARIZER (byLLM Version) ====================

"""
TODO: Integrate with byLLM for intelligent README summarization
This can be implemented later when byLLM integration is complete
"""

#| can summarize_with_llm(readme_content: str) -> str by llm(
#|     reason="Summarize repository README into 3-5 concise sentences",
#|     model="gemini-1.5-flash"
#| ) {
#|     """AI-powered README summarization"""
#|     return f"Analyze this README and provide a clear, concise summary:\n\n{readme_content[:2000]}";
#| }
