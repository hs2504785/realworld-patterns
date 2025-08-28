#!/bin/bash

# GitHub Repository Merger Script
# This script combines multiple GitHub repositories into a single monorepo using Git subtree

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - EDIT THESE VALUES
MAIN_REPO_URL="https://github.com/yourusername/main-repo.git"
MAIN_REPO_NAME="enterprise-monorepo"

# Array of repositories to merge
# Format: "repo_url:target_directory:branch"
declare -a REPOS=(
    "https://github.com/yourusername/admin-app.git:apps/admin:main"
    "https://github.com/yourusername/lab-app.git:apps/lab:main"
    "https://github.com/yourusername/billing-app.git:apps/billing:main"
    "https://github.com/yourusername/shared-lib.git:libs/shared:main"
    "https://github.com/yourusername/core-lib.git:libs/core:main"
)

# Functions
print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}======================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if git is installed
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Git and try again."
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        print_warning "Node.js is not installed. You may need it for Angular/Nx projects."
    fi
    
    print_success "Prerequisites check completed"
}

# Create or clone main repository
setup_main_repo() {
    print_header "Setting Up Main Repository"
    
    if [ -d "$MAIN_REPO_NAME" ]; then
        print_warning "Directory $MAIN_REPO_NAME already exists. Backing up..."
        mv "$MAIN_REPO_NAME" "${MAIN_REPO_NAME}_backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Check if main repo URL is provided and exists
    if [[ "$MAIN_REPO_URL" == *"yourusername"* ]]; then
        print_info "Creating new local repository (update MAIN_REPO_URL in script for existing repo)"
        mkdir "$MAIN_REPO_NAME"
        cd "$MAIN_REPO_NAME"
        git init
        echo "# Enterprise Monorepo" > README.md
        git add README.md
        git commit -m "Initial commit"
    else
        print_info "Cloning main repository: $MAIN_REPO_URL"
        git clone "$MAIN_REPO_URL" "$MAIN_REPO_NAME"
        cd "$MAIN_REPO_NAME"
    fi
    
    print_success "Main repository setup completed"
}

# Add remote and merge repository using subtree
merge_repository() {
    local repo_url="$1"
    local target_dir="$2"
    local branch="$3"
    local remote_name=$(basename "$repo_url" .git | tr '[:upper:]' '[:lower:]' | tr '-' '_')
    
    print_info "Processing: $repo_url -> $target_dir"
    
    # Add remote
    if git remote get-url "$remote_name" &> /dev/null; then
        print_warning "Remote $remote_name already exists, removing..."
        git remote remove "$remote_name"
    fi
    
    git remote add "$remote_name" "$repo_url"
    
    # Fetch remote
    print_info "Fetching from $remote_name..."
    if ! git fetch "$remote_name"; then
        print_error "Failed to fetch from $repo_url"
        git remote remove "$remote_name"
        return 1
    fi
    
    # Check if target directory already exists
    if [ -d "$target_dir" ]; then
        print_warning "Directory $target_dir already exists. Skipping merge."
        git remote remove "$remote_name"
        return 0
    fi
    
    # Create target directory structure if needed
    mkdir -p "$(dirname "$target_dir")"
    
    # Merge using subtree
    print_info "Merging $remote_name into $target_dir..."
    if git subtree add --prefix="$target_dir" "$remote_name" "$branch" --squash; then
        print_success "Successfully merged $repo_url into $target_dir"
    else
        print_error "Failed to merge $repo_url into $target_dir"
        git remote remove "$remote_name"
        return 1
    fi
    
    # Clean up remote
    git remote remove "$remote_name"
    
    return 0
}

# Merge all repositories
merge_all_repositories() {
    print_header "Merging Repositories"
    
    local success_count=0
    local total_count=${#REPOS[@]}
    
    for repo_config in "${REPOS[@]}"; do
        IFS=':' read -r repo_url target_dir branch <<< "$repo_config"
        
        if merge_repository "$repo_url" "$target_dir" "$branch"; then
            ((success_count++))
        fi
        
        echo ""  # Add spacing between operations
    done
    
    print_info "Merged $success_count out of $total_count repositories"
    
    if [ $success_count -eq $total_count ]; then
        print_success "All repositories merged successfully!"
    else
        print_warning "Some repositories failed to merge. Check the output above."
    fi
}

# Create basic Nx workspace structure (optional)
setup_nx_structure() {
    print_header "Setting Up Nx Structure (Optional)"
    
    read -p "Do you want to set up basic Nx structure? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v npx &> /dev/null; then
            print_info "Creating Nx workspace configuration..."
            
            # Create basic nx.json
            cat > nx.json << EOF
{
  "extends": "nx/presets/npm.json",
  "affected": {
    "defaultBase": "main"
  },
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "lint", "test", "e2e"]
      }
    }
  }
}
EOF
            
            # Create basic workspace structure
            mkdir -p libs tools
            
            # Create .gitignore if it doesn't exist
            if [ ! -f .gitignore ]; then
                cat > .gitignore << EOF
# Dependencies
node_modules
npm-debug.log*

# Build outputs
dist
tmp
out-tsc

# Runtime data
*.log
.DS_Store

# IDE
.vscode
.idea

# Nx
.nx

# Environment
.env
.env.local
EOF
            fi
            
            print_success "Basic Nx structure created"
        else
            print_warning "npx not available. Skipping Nx setup."
        fi
    else
        print_info "Skipping Nx setup"
    fi
}

# Post-merge cleanup and instructions
post_merge_instructions() {
    print_header "Post-Merge Instructions"
    
    echo -e "${YELLOW}Next steps to complete your monorepo setup:${NC}"
    echo ""
    echo "1. Update package.json with merged dependencies"
    echo "2. Configure Angular workspace (angular.json or project.json files)"
    echo "3. Update TypeScript configurations"
    echo "4. Set up proper import paths between libraries"
    echo "5. Configure linting rules (especially Nx boundaries)"
    echo "6. Update CI/CD pipelines"
    echo "7. Test all applications and libraries"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "  npm install                    # Install dependencies"
    echo "  nx build <app-name>           # Build specific app"
    echo "  nx test <lib-name>            # Test specific library"
    echo "  nx dep-graph                  # View dependency graph"
    echo "  nx format:check               # Check code formatting"
    echo ""
    echo -e "${GREEN}Your monorepo is ready! 🚀${NC}"
}

# Main execution
main() {
    print_header "GitHub Repository Merger"
    echo "This script will combine multiple repositories into a single monorepo"
    echo ""
    
    # Confirmation
    read -p "Do you want to proceed? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled by user"
        exit 0
    fi
    
    # Check if we're in the right directory
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    read -p "Is this the correct directory to create the monorepo? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Please navigate to the desired directory and run the script again"
        exit 0
    fi
    
    # Execute steps
    check_prerequisites
    setup_main_repo
    merge_all_repositories
    setup_nx_structure
    post_merge_instructions
}

# Help function
show_help() {
    echo "GitHub Repository Merger Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Before running:"
    echo "1. Edit the configuration section in this script"
    echo "2. Update MAIN_REPO_URL and REPOS array with your repository URLs"
    echo "3. Ensure you have proper access to all repositories"
    echo ""
    echo "Example repository configuration:"
    echo '  REPOS=('
    echo '    "https://github.com/user/repo1.git:apps/app1:main"'
    echo '    "https://github.com/user/repo2.git:libs/lib1:develop"'
    echo '  )'
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
