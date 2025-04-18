#!/bin/bash


###
### Load .env configuration file
### 
# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Turn on automatic export
set -a
# Source the .env file
source .env
# Turn off automatic export
set +a


# Check if gh (GitHub CLI) is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo "You're not authenticated with GitHub. Please run 'gh auth login' first."
    exit 1
fi

# Get the user's GitHub username
GH_USERNAME=$(gh api user --jq '.login')
if [ -z "$GH_USERNAME" ]; then
    echo "Failed to get GitHub username. Please check your authentication."
    exit 1
fi

# Confirm before proceeding
echo "WARNING: This script will DELETE the repository '$GH_USERNAME/$REPO_NAME' and create a new one."

# Check if repository exists
if gh repo view "$GH_USERNAME/$REPO_NAME" &> /dev/null; then
    echo "Repository exists and will be deleted."
    
    # Delete the repository using the API
    echo "Deleting repository '$GH_USERNAME/$REPO_NAME'..."
    curl -X DELETE \
         -H "Authorization: token $PAT" \
         -H "Accept: application/vnd.github.v3+json" \
         "https://api.github.com/repos/$GH_USERNAME/$REPO_NAME"
    
    # Check if deletion was successful
    if ! gh repo view "$GH_USERNAME/$REPO_NAME" &> /dev/null; then
        echo "Repository deleted successfully."
    else
        echo "Repository deletion failed. Please check your token permissions."
        exit 1
    fi
    
    # Wait a moment to ensure GitHub has processed the deletion
    echo "Waiting for GitHub to process the deletion..."
    sleep 5
else
    echo "Repository does not exist, skipping deletion."
fi

# Create a new repository
echo "Creating new repository '$REPO_NAME'..."
gh repo create "$REPO_NAME" --description "$DESCRIPTION" --"$VISIBILITY"
echo "Repository created successfully."

# Initialize repository, add files, commit and push (if in a git directory)
if [ -d .git ]; then
  echo "Pushing local code to the new repository..."
  git add .
  git commit -m "Initial commit" --allow-empty
  git push -u 
  echo "Local code pushed successfully."
fi

echo "Operation completed successfully!"