#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${YELLOW}--- Starting Push/Tag Automation ---${NC}\n"

# 1. Check if inside a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Warning: You are not inside a Git repository!${NC}"
    echo -e "${GREEN}Would you like to initialize a new repository here? (y/n)${NC}"
    read init_git
    
    if [ "$init_git" == "y" ]; then
        git init
        git branch -M main
        echo -e "${YELLOW}Local repository initialized successfully.${NC}"
        
        echo -e "${GREEN}Paste the remote repository URL (e.g., https://github.com/user/repo.git) or press ENTER to skip:${NC}"
        read remote_url
        
        if [ ! -z "$remote_url" ]; then
            git remote add origin "$remote_url"
            echo -e "${YELLOW}Remote repository connected.${NC}\n"
        else
            echo -e "${RED}No remote added. Final push will fail if origin is not set.${NC}\n"
        fi
    else
        echo -e "${RED}Operation aborted.${NC}"
        exit 1
    fi
fi

# 2. Pre-flight Checklist
echo -e "${CYAN}================ PRE-DEPLOY CHECKLIST =================${NC}"
echo -e "Before pushing your code, please verify:"
echo -e " [ ] ${YELLOW}.gitignore${NC} is configured? (node_modules, OS files, etc.)"
echo -e " [ ] The actual ${YELLOW}.env${NC} file is protected and ignored?"
echo -e " [ ] The ${YELLOW}.env.example${NC} file is created and updated?"
echo -e " [ ] ${YELLOW}README.md${NC} is up to date?"
echo -e " [ ] Removed all debug 'console.log' or 'print' statements?"
echo -e "${CYAN}=======================================================${NC}\n"

# User confirmation
read -p "Ready for deploy? Press [ENTER] to continue or [CTRL+C] to abort..."

# Capture current folder name and branch
REPO_NAME=$(basename "$PWD")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

echo -e "\nRepository: ${CYAN}$REPO_NAME${NC}"
echo -e "Branch: ${CYAN}$BRANCH${NC}\n"

# .env Security Verification
echo "Checking .env security..."

if [ -f ".env" ]; then
  if [ -f ".gitignore" ] && grep -q "^\.env" .gitignore; then
    echo -e "${GREEN}OK: .env found and ignored in .gitignore${NC}"
  else
    echo -e "${RED}WARNING: .env file exists but is NOT in .gitignore!${NC}"
  fi

  # Check if .env is already tracked
  if git ls-files --error-unmatch .env > /dev/null 2>&1; then
    echo -e "${RED}FATAL ERROR: .env is already being tracked by Git!${NC}"
    echo -e "${RED}Remove it from cache before proceeding:${NC}"
    echo -e "${YELLOW}git rm --cached .env${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}No .env file detected.${NC}"
fi

# 3. Show current status
echo -e "\n${GREEN}Modified Files:${NC}"
git status -s

# 4. Stage files
echo -e "\n${YELLOW}Staging files (git add .)...${NC}"
git add .

# 5. Commit message
echo -e "${GREEN}Enter commit message (leave blank for automatic timestamp):${NC}"
read commit_message

if [ -z "$commit_message" ]; then
    commit_message="Automated update: $(date +'%Y-%m-%d %H:%M:%S')"
fi

git commit -m "$commit_message"

echo -e "\nVersion Management"

# Get last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
    echo -e "${YELLOW}No previous tags found. Starting at v0.0.0${NC}"
    LAST_TAG="v0.0.0"
else
    echo -e "Last tag found: ${CYAN}$LAST_TAG${NC}"
fi

# Remove "v" prefix
VERSION=${LAST_TAG#v}

# Split version
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# Ensure numeric values
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

# Calculate next versions
PATCH_VERSION="v$MAJOR.$MINOR.$((PATCH+1))"
MINOR_VERSION="v$MAJOR.$((MINOR+1)).0"
MAJOR_VERSION="v$((MAJOR+1)).0.0"

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

# 7. Push to GitHub
if ! git remote | grep -q "origin"; then
    echo -e "${RED}Error: No remote named 'origin' found. Push aborted.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Pushing to GitHub...${NC}"
current_branch=$(git rev-parse --abbrev-ref HEAD)

if ! git push origin "$current_branch"; then
    echo -e "${RED}Failed to push to remote.${NC}"
    exit 1
fi

# Push tags if applicable
if [ "$push_tag" == "y" ]; then
    echo -e "${YELLOW}Pushing tags...${NC}"
    git push origin --tags
fi

echo -e "\n${GREEN}--- Deploy completed successfully ---${NC}"