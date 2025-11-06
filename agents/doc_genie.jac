"""
DocGenie Agent - Generates comprehensive markdown documentation
Responsible for:
1. Synthesizing analysis results into markdown
2. Creating API reference documentation
3. Generating diagrams (mermaid format)
4. Organizing documentation sections
"""

import os;
import from datetime {datetime};

# ==================== DOC GENIE WALKER ====================

walker DocGenie {
    """
    Walker that generates comprehensive documentation from the Code Context Graph.
    Produces well-structured markdown with diagrams.
    """
    has output_dir: str = "./outputs";
    has include_diagrams: bool = True;
    has doc_content: str = "";
    has result: dict = {};
    
    """Start documentation generation"""
    can generate_documentation with Repository entry {
        """Generate complete documentation for repository"""
        print(f"\n{'='*60}");
        print("📝 DOC GENIE: Generating documentation");
        print(f"{'='*60}");
        print(f"Repository: {here.name}");
        
        # Initialize documentation structure
        self.doc_content = "";
        
        # Generate each section
        self.add_header(here);
        self.add_overview(here);
        self.add_file_structure(here);
        self.add_installation_guide(here);
        self.add_api_reference(here);
        
        if self.include_diagrams {
            self.add_architecture_diagram(here);
            self.add_dependency_diagram(here);
        }
        
        self.add_code_examples(here);
        self.add_footer();
        
        # Save documentation
        output_path = self.save_documentation(here);
        
        # Create documentation node in graph
        doc_node = here ++> DocumentationNode(
            doc_content=self.doc_content,
            generated_at=str(datetime.now()),
            sections=self.get_section_list()
        );
        
        self.result = {
            "success": True,
            "output_path": output_path,
            "doc_length": len(self.doc_content),
            "sections": len(self.get_section_list())
        };
        
        print(f"\n✅ Documentation generated: {output_path}");
        print(f"   Length: {len(self.doc_content)} characters");
        print(f"{'='*60}\n");
        
        report self.result;
    }
    
    """Add main header"""
    can add_header(repo: Repository) -> None {
        """Generate documentation header"""
        self.doc_content += f"# {repo.name}\n\n";
        self.doc_content += f"**Repository:** {repo.url}\n\n";
        self.doc_content += f"**Documentation Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n";
        self.doc_content += f"---\n\n";
    }
    
    """Add project overview"""
    can add_overview(repo: Repository) -> None {
        """Generate project overview section"""
        self.doc_content += "## 📋 Project Overview\n\n";
        
        if repo.readme_summary {
            self.doc_content += repo.readme_summary + "\n\n";
        } else {
            self.doc_content += f"Repository: {repo.name}\n\n";
            self.doc_content += "No README summary available.\n\n";
        }
        
        # Add statistics
        self.doc_content += "### 📊 Statistics\n\n";
        self.doc_content += f"- **Total Files:** {repo.total_files}\n";
        self.doc_content += f"- **Analyzed Files:** {repo.analyzed_files}\n";
        self.doc_content += f"- **Default Branch:** {repo.default_branch}\n\n";
    }
    
    """Add file structure"""
    can add_file_structure(repo: Repository) -> None {
        """Generate file structure section"""
        self.doc_content += "## 📁 File Structure\n\n";
        self.doc_content += "```\n";
        self.doc_content += f"{repo.name}/\n";
        
        # Get all file nodes
        file_nodes = [repo-->](`?FileNode);
        
        # Group files by directory
        dir_structure = {};
        for file_node in file_nodes {
            parts = file_node.file_path.split("/");
            if len(parts) > 1 {
                dir_name = "/".join(parts[:-1]);
                if dir_name not in dir_structure {
                    dir_structure[dir_name] = [];
                }
                dir_structure[dir_name].append(file_node);
            } else {
                if "." not in dir_structure {
                    dir_structure["."] = [];
                }
                dir_structure["."].append(file_node);
            }
        }
        
        # Format structure
        for dir_name in sorted(dir_structure.keys()) {
            if dir_name != "." {
                self.doc_content += f"├── {dir_name}/\n";
            }
            for file_node in sorted(dir_structure[dir_name], key=lambda x: x.file_name) {
                marker = "⭐" if file_node.is_entry_point else "  ";
                indent = "│   " if dir_name != "." else "";
                self.doc_content += f"{indent}    {marker} {file_node.file_name}\n";
            }
        }
        
        self.doc_content += "```\n\n";
        self.doc_content += "⭐ = Entry point file\n\n";
    }
    
    """Add installation guide"""
    can add_installation_guide(repo: Repository) -> None {
        """Generate installation instructions"""
        self.doc_content += "## 🚀 Installation\n\n";
        self.doc_content += "### Prerequisites\n\n";
        self.doc_content += "- Python 3.8 or higher\n";
        self.doc_content += "- Git\n\n";
        
        self.doc_content += "### Clone Repository\n\n";
        self.doc_content += "```bash\n";
        self.doc_content += f"git clone {repo.url}\n";
        self.doc_content += f"cd {repo.name}\n";
        self.doc_content += "```\n\n";
        
        self.doc_content += "### Install Dependencies\n\n";
        self.doc_content += "```bash\n";
        self.doc_content += "pip install -r requirements.txt\n";
        self.doc_content += "```\n\n";
    }
    
    """Add API reference"""
    can add_api_reference(repo: Repository) -> None {
        """Generate API reference section"""
        self.doc_content += "## 📚 API Reference\n\n";
        
        # Get all modules
        modules = [repo-->](`?ModuleNode);
        
        if not modules {
            self.doc_content += "*No modules analyzed yet.*\n\n";
            return;
        }
        
        for module in modules {
            self.doc_content += f"### Module: `{module.module_name}`\n\n";
            
            if module.docstring {
                self.doc_content += f"{module.docstring}\n\n";
            }
            
            # Get classes in this module
            classes = [module-->](`?ClassNode);
            if classes {
                self.doc_content += "#### Classes\n\n";
                for cls in classes {
                    self.add_class_documentation(cls);
                }
            }
            
            # Get functions in this module
            functions = [module-->](`?FunctionNode);
            module_functions = [f for f in functions if not f.is_method];
            
            if module_functions {
                self.doc_content += "#### Functions\n\n";
                for func in module_functions {
                    self.add_function_documentation(func);
                }
            }
        }
    }
    
    """Add class documentation"""
    can add_class_documentation(cls: ClassNode) -> None {
        """Document a single class"""
        self.doc_content += f"##### `{cls.class_name}`\n\n";
        
        if cls.docstring {
            self.doc_content += f"{cls.docstring}\n\n";
        }
        
        # Base classes
        if cls.base_classes {
            bases = ", ".join(cls.base_classes);
            self.doc_content += f"**Inherits from:** `{bases}`\n\n";
        }
        
        # Methods
        if cls.methods {
            self.doc_content += "**Methods:**\n\n";
            methods = [cls-->:Defines:->](`?FunctionNode);
            for method in methods {
                params = ", ".join([p["name"] for p in method.parameters]);
                self.doc_content += f"- `{method.function_name}({params})` - ";
                if method.docstring {
                    # Get first line of docstring
                    first_line = method.docstring.split("\n")[0];
                    self.doc_content += first_line;
                }
                self.doc_content += "\n";
            }
            self.doc_content += "\n";
        }
        
        self.doc_content += f"*Defined at lines {cls.line_start}-{cls.line_end}*\n\n";
    }
    
    """Add function documentation"""
    can add_function_documentation(func: FunctionNode) -> None {
        """Document a single function"""
        # Build signature
        params = [];
        for param in func.parameters {
            param_str = param["name"];
            if param["type"] {
                param_str += f": {param['type']}";
            }
            params.append(param_str);
        }
        
        signature = f"{func.function_name}({', '.join(params)})";
        if func.return_type {
            signature += f" -> {func.return_type}";
        }
        
        self.doc_content += f"##### `{signature}`\n\n";
        
        if func.docstring {
            self.doc_content += f"{func.docstring}\n\n";
        }
        
        # Additional info
        if func.is_async {
            self.doc_content += "*This is an async function*\n\n";
        }
        
        if func.decorators {
            self.doc_content += f"**Decorators:** `{'`, `'.join(func.decorators)}`\n\n";
        }
        
        self.doc_content += f"*Defined at lines {func.line_start}-{func.line_end}*\n\n";
    }
    
    """Add architecture diagram"""
    can add_architecture_diagram(repo: Repository) -> None {
        """Generate mermaid architecture diagram"""
        self.doc_content += "## 🏗️ Architecture Diagram\n\n";
        self.doc_content += "```mermaid\n";
        self.doc_content += "graph TD\n";
        
        # Get modules and their relationships
        modules = [repo-->](`?ModuleNode);
        
        for i, module in enumerate(modules[:10]) {  # Limit to 10 for readability
            node_id = f"M{i}";
            self.doc_content += f"    {node_id}[{module.module_name}]\n";
            
            # Add import relationships
            for j, other_module in enumerate(modules) {
                if other_module.module_name in module.imports {
                    other_id = f"M{j}";
                    self.doc_content += f"    {node_id} --> {other_id}\n";
                }
            }
        }
        
        self.doc_content += "```\n\n";
    }
    
    """Add dependency diagram"""
    can add_dependency_diagram(repo: Repository) -> None {
        """Generate dependency visualization"""
        self.doc_content += "## 🔗 Dependencies\n\n";
        
        # Get all modules with imports
        modules = [repo-->](`?ModuleNode);
        
        if not modules {
            return;
        }
        
        self.doc_content += "| Module | Imports |\n";
        self.doc_content += "|--------|--------|\n";
        
        for module in modules[:20] {  # Limit for readability
            imports = ", ".join(module.imports[:5]) if module.imports else "None";
            if len(module.imports) > 5 {
                imports += f" (+ {len(module.imports) - 5} more)";
            }
            self.doc_content += f"| `{module.module_name}` | {imports} |\n";
        }
        
        self.doc_content += "\n";
    }
    
    """Add code examples"""
    can add_code_examples(repo: Repository) -> None {
        """Generate usage examples section"""
        self.doc_content += "## 💡 Usage Examples\n\n";
        self.doc_content += "*Auto-generated usage examples based on entry points*\n\n";
        
        # Find entry point files
        entry_files = [repo-->](`?FileNode:is_entry_point==True:);
        
        if entry_files {
            for entry_file in entry_files {
                self.doc_content += f"### Running `{entry_file.file_name}`\n\n";
                
                if entry_file.language == "python" {
                    self.doc_content += "```bash\n";
                    self.doc_content += f"python {entry_file.file_path}\n";
                    self.doc_content += "```\n\n";
                } elif entry_file.language == "jac" {
                    self.doc_content += "```bash\n";
                    self.doc_content += f"jac run {entry_file.file_path}\n";
                    self.doc_content += "```\n\n";
                }
            }
        } else {
            self.doc_content += "*No entry points identified*\n\n";
        }
    }
    
    """Add footer"""
    can add_footer() -> None {
        """Add documentation footer"""
        self.doc_content += "---\n\n";
        self.doc_content += "*This documentation was automatically generated by Codebase Genius*\n\n";
        self.doc_content += f"*Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n";
    }
    
    """Save documentation to file"""
    can save_documentation(repo: Repository) -> str {
        """Write documentation to markdown file"""
        # Ensure output directory exists
        repo_output_dir = os.path.join(self.output_dir, repo.name);
        os.makedirs(repo_output_dir, exist_ok=True);
        
        # Create filename with timestamp
        filename = "documentation.md";
        output_path = os.path.join(repo_output_dir, filename);
        
        # Write file
        with open(output_path, "w", encoding="utf-8") as f {
            f.write(self.doc_content);
        }
        
        return output_path;
    }
    
    """Get list of sections"""
    can get_section_list() -> list[str] {
        """Return list of documentation sections"""
        return [
            "Project Overview",
            "File Structure",
            "Installation",
            "API Reference",
            "Architecture Diagram",
            "Dependencies",
            "Usage Examples"
        ];
    }
}
