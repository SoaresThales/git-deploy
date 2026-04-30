#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${YELLOW}--- Git Deployment Automation (v1.2.0) ---${NC}\n"

# Check if current directory is a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not inside a Git repository!${NC}"
    read -p "Initialize a new repository in this folder? (y/n): " init_git
    
    if [ "$init_git" == "y" ]; then
        git init
        git branch -M main
        echo -e "${YELLOW}Local repository initialized successfully.${NC}"
        
        read -p "Enter remote repository URL (or press ENTER to skip): " remote_url
        
        if [ ! -z "$remote_url" ]; then
            git remote add origin "$remote_url"
            echo -e "${YELLOW}Remote origin connected.${NC}\n"
        else
            echo -e "${RED}No remote added. Final push will fail if origin is not set.${NC}\n"
        fi
    else
        echo -e "${RED}Operation aborted.${NC}"
        exit 1
    fi
fi

# Pre-deployment Checklist
echo -e "${CYAN}================ PRE-DEPLOY CHECKLIST =================${NC}"
echo -e "Before pushing your code, please verify:"
echo -e " [ ] ${YELLOW}.gitignore${NC} is configured? (node_modules, OS files, etc.)"
echo -e " [ ] The actual ${YELLOW}.env${NC} file is protected and ignored?"
echo -e " [ ] The ${YELLOW}.env.example${NC} file is created and updated?"
echo -e " [ ] ${YELLOW}README.md${NC} is up to date?"
echo -e " [ ] Removed all debug 'console.log' or 'print' statements?"
echo -e "${CYAN}=======================================================${NC}\n"

read -p "Proceed with deployment? Press [ENTER] to continue or [CTRL+C] to abort..."

# Identify repository metadata
REPO_NAME=$(basename "$PWD")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Validate remote repository alignment (Safety Lock)
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
if [ ! -z "$REMOTE_URL" ]; then
    # Extracts repo name from URL (removes .git and path)
    REMOTE_REPO_NAME=$(basename "$REMOTE_URL" .git)
    
    if [ "$REPO_NAME" != "$REMOTE_REPO_NAME" ]; then
        echo -e "${RED}FATAL ERROR: Remote mismatch detected!${NC}"
        echo -e "Local folder: ${YELLOW}$REPO_NAME${NC}"
        echo -e "Remote repository: ${YELLOW}$REMOTE_REPO_NAME${NC}"
        echo -e "${RED}Deployment stopped to prevent pushing to the wrong repository.${NC}"
        exit 1
    fi
fi

echo -e "\nTarget Repository: ${CYAN}$REPO_NAME${NC}"
echo -e "Target Branch: ${CYAN}$BRANCH${NC}\n"

# .env security verification
echo "Performing security checks..."

if [ -f ".env" ]; then
  if [ -f ".gitignore" ] && grep -q "^\.env" .gitignore; then
    echo -e "${GREEN}OK: .env is ignored in .gitignore${NC}"
  else
    echo -e "${RED}WARNING: .env file detected but NOT found in .gitignore!${NC}"
  fi

  if git ls-files --error-unmatch .env > /dev/null 2>&1; then
    echo -e "${RED}FATAL ERROR: .env is currently tracked by Git!${NC}"
    echo -e "${RED}Remove it from cache before deployment:${NC}"
    echo -e "${YELLOW}git rm --cached .env${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}No .env file detected.${NC}"
fi

# Display modified files
echo -e "\n${GREEN}Modified Files:${NC}"
git status -s

# Stage changes
echo -e "\n${YELLOW}Staging all changes...${NC}"
git add .

# Prompt for commit message
read -p "Enter commit message (blank for auto-timestamp): " commit_message

if [ -z "$commit_message" ]; then
    commit_message="Automated update: $(date +'%Y-%m-%d %H:%M:%S')"
fi

# Execute commit with safety check
if ! git commit -m "$commit_message"; then
    echo -e "${RED}Error: Commit failed. Are there any changes to push?${NC}"
    exit 1
fi

echo -e "\n--- Version Management ---"

# Retrieve the latest tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

if [ "$LAST_TAG" == "v0.0.0" ]; then
    echo -e "${YELLOW}No previous tags found.${NC}"
else
    echo -e "Last tag found: ${CYAN}$LAST_TAG${NC}"
fi

# Parse version components
VERSION=${LAST_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

# Calculate next versions
PATCH_VERSION="v$MAJOR.$MINOR.$((PATCH + 1))"
MINOR_VERSION="v$MAJOR.$((MINOR + 1)).0"
MAJOR_VERSION="v$((MAJOR + 1)).0.0"

echo -e "\n${GREEN}Select version bump:${NC}"
echo "1) Patch (Bug fixes)   -> $PATCH_VERSION"
echo "2) Minor (New feature) -> $MINOR_VERSION"
echo "3) Major (Breaking)    -> $MAJOR_VERSION"
echo "4) Skip  (No Tag)"

read -p "Option [1-4]: " VERSION_OPTION

case $VERSION_OPTION in
    1) NEW_TAG=$PATCH_VERSION ;;
    2) NEW_TAG=$MINOR_VERSION ;;
    3) NEW_TAG=$MAJOR_VERSION ;;
    *) NEW_TAG="" ; echo "Skipping tag creation." ;;
esac

if [ ! -z "$NEW_TAG" ]; then
    git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
    echo -e "${YELLOW}Tag $NEW_TAG created locally.${NC}"
    
    push_tag="y" 
else
    push_tag="n"
fi

# Final push to remote
if ! git remote | grep -q "origin"; then
    echo -e "${RED}Error: No remote named 'origin' found. Push aborted.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Pushing changes to origin/${BRANCH}...${NC}"

if ! git push origin "$BRANCH"; then
    echo -e "${RED}CRITICAL: Push failed.${NC}"
    echo -e "${YELLOW}Hint: Run 'git pull --rebase' to sync before trying again.${NC}"
    exit 1
fi

if [ "$push_tag" == "y" ]; then
    echo -e "${YELLOW}Pushing tags to remote...${NC}"
    if ! git push origin --tags; then
        echo -e "${RED}Error: Tags failed to push.${NC}"
        exit 1
    fi
fi

echo -e "\n${GREEN}--- 🎉 Deployment successful ---${NC}"