"""
Code Analyzer Agent - Parses source code and builds Code Context Graph (CCG)
Responsible for:
1. Parsing Python and Jac source files
2. Extracting functions, classes, and relationships
3. Building the Code Context Graph
4. Analyzing dependencies and call relationships
"""

import ast;
import os;
import re;
import from datetime {datetime};

# ==================== CODE ANALYZER WALKER ====================

walker CodeAnalyzer {
    """
    Walker that analyzes source code files and builds the Code Context Graph.
    Focuses on Python and Jac files.
    """
    has target_languages: list[str] = ["python", "jac"];
    has max_files_to_analyze: int = 100;
    has analyzed_count: int = 0;
    has result: dict = {};
    
    """Start analysis from repository"""
    can start_analysis with Repository entry {
        """Begin code analysis on repository files"""
        print(f"\n{'='*60}");
        print("🔍 CODE ANALYZER: Starting code analysis");
        print(f"{'='*60}");
        print(f"Repository: {here.name}");
        print(f"Total files: {here.total_files}");
        
        # Get all file nodes
        file_nodes = [-->](`?FileNode);
        
        # Filter for code files
        code_files = [
            f for f in file_nodes 
            if f.language in self.target_languages
        ];
        
        print(f"✅ Found {len(code_files)} code files to analyze");
        
        # Prioritize entry points and important files
        prioritized_files = FilePrioritizer.prioritize_files(code_files);
        
        # Limit number of files if necessary
        files_to_analyze = prioritized_files[:self.max_files_to_analyze];
        
        print(f"📊 Analyzing {len(files_to_analyze)} files...\n");
        
        # Analyze each file
        for file_node in files_to_analyze {
            visit file_node;
        }
        
        # Update repository status
        here.analyzed_files = self.analyzed_count;
        here.status = "analyzed";
        
        self.result = {
            "success": True,
            "analyzed_files": self.analyzed_count,
            "total_code_files": len(code_files),
            "stage": "completed"
        };
        
        print(f"\n{'='*60}");
        print(f"✅ CODE ANALYZER: Analyzed {self.analyzed_count} files");
        print(f"{'='*60}\n");
        
        report self.result;
    }
    
    """Analyze individual file"""
    can analyze_file with FileNode entry {
        """Parse and analyze a single source file"""
        if here.is_analyzed {
            return;  # Skip already analyzed files
        }
        
        # Get repository node
        repo = (<--[0]?Repository);
        if not repo {
            return;
        }
        
        # Construct full file path
        full_path = os.path.join(repo.local_path, here.file_path);
        
        if not os.path.exists(full_path) {
            return;
        }
        
        print(f"  📄 Analyzing: {here.file_name}");
        
        # Read file content
        content = FileSystemHelper.read_file_content(full_path);
        
        if not content {
            print(f"     ⚠️  Could not read file");
            return;
        }
        
        # Count lines of code
        here.lines_of_code = len(content.split("\n"));
        
        # Parse based on language
        if here.language == "python" {
            self.parse_python_file(here, content, repo);
        } elif here.language == "jac" {
            self.parse_jac_file(here, content, repo);
        }
        
        here.is_analyzed = True;
        self.analyzed_count += 1;
    }
    
    """Parse Python file using AST"""
    can parse_python_file(file_node: FileNode, content: str, repo: Repository) -> None {
        """Use Python AST to extract structure"""
        try {
            tree = ast.parse(content);
            
            # Extract module-level information
            module_node = file_node ++> ModuleNode(
                module_name=file_node.file_name.replace(".py", ""),
                module_path=file_node.file_path,
                docstring=ast.get_docstring(tree) or ""
            );
            
            # Traverse AST
            for node in ast.walk(tree) {
                # Extract classes
                if isinstance(node, ast.ClassDef) {
                    class_node = self.extract_class(node, file_node);
                    if class_node {
                        print(f"     ✓ Found class: {class_node.class_name}");
                    }
                }
                
                # Extract functions (not in classes)
                elif isinstance(node, ast.FunctionDef) or isinstance(node, ast.AsyncFunctionDef) {
                    # Check if it's a top-level function
                    func_node = self.extract_function(node, file_node, False);
                    if func_node {
                        print(f"     ✓ Found function: {func_node.function_name}");
                    }
                }
                
                # Extract imports
                elif isinstance(node, ast.Import) or isinstance(node, ast.ImportFrom) {
                    self.extract_imports(node, module_node);
                }
            }
        } except SyntaxError as e {
            print(f"     ⚠️  Syntax error: {e}");
        } except Exception as e {
            print(f"     ⚠️  Parse error: {e}");
        }
    }
    
    """Extract class information"""
    can extract_class(node: ast.ClassDef, file_node: FileNode) -> ClassNode {
        """Extract class details from AST node"""
        # Get base classes
        bases = [];
        for base in node.bases {
            if hasattr(base, "id") {
                bases.append(base.id);
            } elif hasattr(base, "attr") {
                bases.append(base.attr);
            }
        }
        
        # Get decorators
        decorators = [];
        for dec in node.decorator_list {
            if hasattr(dec, "id") {
                decorators.append(dec.id);
            } elif hasattr(dec, "attr") {
                decorators.append(dec.attr);
            }
        }
        
        # Create class node
        class_node = file_node ++> ClassNode(
            class_name=node.name,
            docstring=ast.get_docstring(node) or "",
            line_start=node.lineno,
            line_end=node.end_lineno or node.lineno,
            base_classes=bases,
            decorators=decorators
        );
        
        # Extract methods
        methods = [];
        for item in node.body {
            if isinstance(item, ast.FunctionDef) or isinstance(item, ast.AsyncFunctionDef) {
                method_node = self.extract_function(item, file_node, True);
                if method_node {
                    # Connect method to class
                    class_node ++>:Defines:scope="class":++> method_node;
                    methods.append(item.name);
                }
            }
        }
        
        class_node.methods = methods;
        
        return class_node;
    }
    
    """Extract function information"""
    can extract_function(node, file_node: FileNode, is_method: bool) -> FunctionNode {
        """Extract function details from AST node"""
        # Get parameters
        params = [];
        for arg in node.args.args {
            param_type = "";
            if arg.annotation {
                param_type = ast.unparse(arg.annotation) if hasattr(ast, "unparse") else "";
            }
            
            params.append({
                "name": arg.arg,
                "type": param_type,
                "default": ""
            });
        }
        
        # Get return type
        return_type = "";
        if node.returns {
            return_type = ast.unparse(node.returns) if hasattr(ast, "unparse") else "";
        }
        
        # Get decorators
        decorators = [];
        for dec in node.decorator_list {
            if hasattr(dec, "id") {
                decorators.append(dec.id);
            } elif hasattr(dec, "attr") {
                decorators.append(dec.attr);
            }
        }
        
        # Create function node
        func_node = file_node ++> FunctionNode(
            function_name=node.name,
            docstring=ast.get_docstring(node) or "",
            line_start=node.lineno,
            line_end=node.end_lineno or node.lineno,
            parameters=params,
            return_type=return_type,
            is_async=isinstance(node, ast.AsyncFunctionDef),
            is_method=is_method,
            decorators=decorators
        );
        
        return func_node;
    }
    
    """Extract import statements"""
    can extract_imports(node, module_node: ModuleNode) -> None {
        """Extract import information"""
        if isinstance(node, ast.Import) {
            for alias in node.names {
                module_node.imports.append(alias.name);
            }
        } elif isinstance(node, ast.ImportFrom) {
            if node.module {
                module_node.imports.append(node.module);
            }
        }
    }
    
    """Parse Jac file (simplified)"""
    can parse_jac_file(file_node: FileNode, content: str, repo: Repository) -> None {
        """
        Parse Jac files using regex patterns
        TODO: Use proper Jac parser when available
        """
        # Create module node
        module_node = file_node ++> ModuleNode(
            module_name=file_node.file_name.replace(".jac", ""),
            module_path=file_node.file_path,
            docstring=""
        );
        
        # Extract node definitions
        node_pattern = r"node\s+(\w+)\s*\{";
        for match in re.finditer(node_pattern, content) {
            print(f"     ✓ Found node: {match.group(1)}");
        }
        
        # Extract walker definitions  
        walker_pattern = r"walker\s+(\w+)\s*\{";
        for match in re.finditer(walker_pattern, content) {
            print(f"     ✓ Found walker: {match.group(1)}");
        }
        
        # Extract ability definitions (can statements)
        ability_pattern = r"can\s+(\w+)\s+with";
        for match in re.finditer(ability_pattern, content) {
            func_node = file_node ++> FunctionNode(
                function_name=match.group(1),
                docstring="",
                line_start=content[:match.start()].count("\n") + 1,
                line_end=content[:match.start()].count("\n") + 1,
                is_method=False
            );
            print(f"     ✓ Found ability: {match.group(1)}");
        }
    }
}

# ==================== DEPENDENCY ANALYZER ====================

walker DependencyAnalyzer {
    """Analyzes dependencies between modules and functions"""
    has dependency_map: dict = {};
    
    can analyze_dependencies with Repository entry {
        """Build dependency graph"""
        print(f"\n🔗 Analyzing dependencies...");
        
        # Get all module nodes
        modules = [-->](`?ModuleNode);
        
        for module in modules {
            # Analyze imports
            for import_name in module.imports {
                # Find the imported module
                imported = [m for m in modules if m.module_name == import_name];
                if imported {
                    # Create dependency edge
                    module ++>:DependsOn:dependency_type="import":++> imported[0];
                }
            }
        }
        
        print(f"✅ Dependency analysis complete");
    }
}
