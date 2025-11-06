"""
Code Genius Supervisor - Orchestrates the entire analysis pipeline (Fixed for Asynchronous operation)
"""

import os;
import from datetime {datetime};
# Assume imports for agents and utils are correct at the top of the file

# ==================== CODE GENIUS SUPERVISOR ====================

walker CodeGeniusSupervisor {
    """
    Main orchestrator walker that coordinates all agents in the pipeline.
    It updates the Repository node status as it progresses.
    """
    # FIX: Use repo_id passed from main.jac
    has repo_id: str;
    has repo_url: str;
      
    has output_dir: str = "./outputs";
    has max_size_mb: int = 500;
    has max_files: int = 100;
    has include_diagrams: bool = True;
    has cleanup_workspace: bool = True;
    
    # Pipeline state
    has current_stage: str = "initialized";
    has workspace_path: str = "";
    
    # No report necessary on finish, the graph is the source of truth
    can orchestrate with `root entry {
        
        # 1. Find the Repository Node to update
        repo = here.get_node(self.repo_id);
        if not repo {
            print(f"❌ SUPERVISOR ERROR: Cannot find Repository node with ID {self.repo_id}");
            disengage;
        }
        
        print(f"🎯 SUPERVISOR: Starting pipeline for {repo.name}");
        
        # Update status to indicate job is running
        repo.status = "analyzing";
        
        # STAGE 1: Repository Mapping
        self.current_stage = "mapping";
        print(f"📍 STAGE 1/3: Repository Mapping\n");
        repo.status = "mapping"; # Update status for user visibility
        mapping_success = self.execute_repo_mapping(repo);
        
        if not mapping_success {
            repo.status = "failed";
            disengage;
        }
        
        # STAGE 2: Code Analysis
        self.current_stage = "analyzing";
        print(f"\n📍 STAGE 2/3: Code Analysis\n");
        repo.status = "analyzing"; # Update status for user visibility
        analysis_success = self.execute_code_analysis(repo); # Pass repo node
        
        if not analysis_success {
            repo.status = "failed";
            disengage;
        }
        
        # STAGE 3: Documentation Generation
        self.current_stage = "documenting";
        print(f"\n📍 STAGE 3/3: Documentation Generation\n");
        repo.status = "documenting"; # Update status for user visibility
        doc_success = self.execute_documentation(repo); # Pass repo node
        
        if not doc_success {
            repo.status = "failed";
            disengage;
        }
        
        # Pipeline completed successfully
        repo.status = "completed";
        self.current_stage = "completed";

        # Cleanup if requested
        if self.cleanup_workspace and self.workspace_path {
            print(f"\n🧹 Cleaning up workspace: {self.workspace_path}");
            FileSystemHelper.cleanup_workspace(self.workspace_path);
        }
        
        print("\n✅ PIPELINE COMPLETED SUCCESSFULLY\n");
    }
    
    """Execute repository mapping stage"""
    # FIX: Removed Python type hint `-> bool`
    can execute_repo_mapping(repo_node) {
        """Run RepoMapper agent"""
        try {
            mapper = RepoMapper(
                repo_url=self.repo_url,
                max_size_mb=self.max_size_mb
            );
            
            # Spawn mapper on the Repository node
            result = repo_node spawn mapper;
            
            # Store workspace path for cleanup
            if mapper.workspace_dir {
                self.workspace_path = mapper.workspace_dir;
            }
            
            # Check result - FIX: mapper.result will be a dict from mapper.report
            if result["success"] {
                print(f"✅ Stage 1 Complete: Repository mapped successfully");
                # Update total files count on the repo node
                repo_node.total_files = result.get("total_files", 0);
                return True;
            } else {
                print(f"❌ Stage 1 Failed: {result.get('error')}");
                repo_node.error_message = result.get("error", "Unknown mapping error");
                return False;
            }
        } except Exception as e {
            print(f"❌ Stage 1 Error: {e}");
            repo_node.error_message = str(e);
            return False;
        }
    }
    
    """Execute code analysis stage"""
    # FIX: Removed Python type hint `-> bool`
    can execute_code_analysis(repo_node) {
        """Run CodeAnalyzer agent"""
        try {
            # CodeAnalyzer should traverse from the repo_node passed to it
            analyzer = CodeAnalyzer(
                max_files_to_analyze=self.max_files
            );
            
            result = repo_node spawn analyzer;
            
            # Check result
            if result["success"] {
                analyzed_count = result.get("analyzed_count", 0);
                print(f"✅ Stage 2 Complete: Analyzed {analyzed_count} files");
                # Update the Repository node with analysis progress
                repo_node.analyzed_files = analyzed_count;
                return True;
            } else {
                print(f"❌ Stage 2 Failed");
                repo_node.error_message = "Code analysis failed";
                return False;
            }
        } except Exception as e {
            print(f"❌ Stage 2 Error: {e}");
            repo_node.error_message = str(e);
            return False;
        }
    }
    
    """Execute documentation generation stage"""
    # FIX: Removed Python type hint `-> bool`
    can execute_documentation(repo_node) {
        """Run DocGenie agent"""
        try {
            doc_gen = DocGenie(
                output_dir=self.output_dir,
                include_diagrams=self.include_diagrams
            );
            
            result = repo_node spawn doc_gen;
            
            # Check result
            if result["success"] {
                print(f"✅ Stage 3 Complete: Documentation saved");
                return True;
            } else {
                print(f"❌ Stage 3 Failed");
                repo_node.error_message = "Documentation generation failed";
                return False;
            }
        } catch Exception as e {
            print(f"❌ Stage 3 Error: {e}");
            repo_node.error_message = str(e);
            return False;
        }
    }
}