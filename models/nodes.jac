"""
Data Models for Codebase Genius (FIXED)
Defines nodes and edges for the Code Context Graph (CCG)
"""

# ==================== REPOSITORY NODE ====================
node Repository {
    """Represents a cloned GitHub repository"""
    has url: str;
    has name: str;
    has local_path: str;
    has default_branch: str = "main";
    has readme_summary: str = "";
    has total_files: int = 0;
    has analyzed_files: int = 0;
    has status: str = "initialized";  # initialized, cloning, analyzing, completed, failed
    has created_at: str;
    has error_message: str = "";
}

# ==================== FILE NODE ====================
node FileNode {
    """Represents a file in the repository"""
    has file_path: str;                 # Relative path from repo root
    has file_name: str;
    has file_type: str;                 # .py, .jac, .js, etc.
    has file_size: int;                 # in bytes
    has is_entry_point: bool = False;   # main.py, app.py, etc.
    has is_analyzed: bool = False;
    has lines_of_code: int = 0;
    has language: str = "";             # python, jac, javascript, etc.
    has content_hash: str = "";         # for change detection
}

# ==================== MODULE NODE ====================
node ModuleNode {
    """Represents a Python/Jac module or package"""
    has module_name: str;
    has module_path: str;
    has docstring: str = "";
    has is_package: bool = False;
    has imports: list = [];        # List of imported modules (Removed Python type hint [str])
}

# ==================== CLASS NODE ====================
node ClassNode {
    """Represents a class definition"""
    has class_name: str;
    has docstring: str = "";
    has line_start: int;
    has line_end: int;
    has is_abstract: bool = False;
    has base_classes: list = [];   # Parent classes (Removed Python type hint [str])
    has decorators: list = [];
    has methods: list = [];        # Method names
}

# ==================== FUNCTION NODE ====================
node FunctionNode {
    """Represents a function or method definition"""
    has function_name: str;
    has docstring: str = "";
    has line_start: int;
    has line_end: int;
    has parameters: list = [];    # [{"name": str, "type": str, "default": str}]
    has return_type: str = "";
    has is_async: bool = False;
    has is_method: bool = False;
    has decorators: list = [];
    has complexity: int = 1;            # Cyclomatic complexity
    has calls_functions: list = []; # Functions called within
}

# ==================== VARIABLE NODE ====================
node VariableNode {
    """Represents a global variable or constant"""
    has var_name: str;
    has var_type: str = "";
    has value: str = "";
    has is_constant: bool = False;
    has line_number: int;
}

# ==================== DOCUMENTATION NODE ====================
node DocumentationNode {
    """Represents generated documentation for a repository"""
    has doc_content: str;               # Markdown content
    has generated_at: str;
    has version: str = "1.0";
    has sections: list = [];       # Section titles
    has diagrams: list = [];      # [{"type": str, "path": str}]
}

# ==================== EDGES (Relationships) ====================

edge Contains {
    """Generic containment relationship"""
    has relationship_type: str = "contains";
}

edge ImportsFrom {
    """Module/file imports another module"""
    has import_type: str = "module";    # module, class, function, variable
    has is_relative: bool = False;
}

edge InheritsFrom {
    """Class inheritance relationship"""
    has inheritance_type: str = "direct"; # direct, multiple
}

edge Calls {
    """Function calls another function"""
    has call_count: int = 1;
    has is_recursive: bool = False;
}

edge Defines {
    """Module/Class defines a function/method"""
    has scope: str = "module";          # module, class, instance
}

edge Uses {
    """Function uses a variable or constant"""
    has usage_type: str = "read";       # read, write, modify
}

edge DocumentedBy {
    """Links code elements to their documentation"""
    has doc_type: str = "generated";    # generated, manual, combined
}

edge DependsOn {
    """General dependency relationship"""
    has dependency_type: str = "import"; # import, call, inheritance
    has strength: int = 1;              # 1-10, higher = stronger dependency
}

# ==================== HELPER FUNCTIONS ====================

"""Helper to create a file tree representation"""
obj FileTreeBuilder {
    # FIX: Removed Python type hints
    can build_tree(root_node, files) {
        """Create FileNode instances from a list of file paths"""
        file_nodes = [];
        for file_path in files {
            # Extract file info
            parts = file_path.split("/");
            file_name = parts[-1];
            
            # Handle files with no extension
            file_type = "";
            if "." in file_name {
                file_type = "." + file_name.split(".")[-1];
            }
            
            # Determine if entry point
            is_entry = file_name in ["main.py", "app.py", "__init__.py", "main.jac", "server.jac"];
            
            # Create file node
            file_node = FileNode(
                file_path=file_path,
                file_name=file_name,
                file_type=file_type,
                file_size=0,  # Will be set later
                is_entry_point=is_entry,
                # FIX: Call sibling ability using the object's name
                language=FileTreeBuilder.get_language(file_type)
            );
            
            file_nodes.append(file_node);
        }
        return file_nodes;
    }
    
    # FIX: Removed Python type hints
    can get_language(file_type) {
        """Map file extension to language name"""
        
        # FIX: Use dict() constructor with '=' for assignment
        lang_map = dict(
            ".py" = "python",
            ".jac" = "jac",
            ".js" = "javascript",
            ".ts" = "typescript",
            ".java" = "java",
            ".go" = "go",
            ".rs" = "rust",
            ".cpp" = "cpp",
            ".c" = "c",
            ".md" = "markdown",
            ".txt" = "text"
        );
        
        # FIX: Use 'if key in map' for safe access
        if file_type in lang_map {
            return lang_map[file_type];
        } else {
            return "unknown";
        }
    }
}

"""Helper to prioritize files for analysis"""
obj FilePrioritizer {
    # FIX: Removed Python type hints
    can prioritize_files(files) {
        """Sort files by priority (entry points first, then by type)"""
        
        # List comprehensions replaced with explicit loops for Jac compliance
        entry_points = [];
        code_files = [];
        other_files = [];
        
        for f in files {
            if f.is_entry_point {
                entry_points.append(f);
            } else if f.language in ["python", "jac"] {
                code_files.append(f);
            } else {
                other_files.append(f);
            }
        }
        
        return entry_points + code_files + other_files;
    }
}