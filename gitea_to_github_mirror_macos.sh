#!/bin/bash

# Gitea to GitHub Mirror Script for macOS
# This script is optimized for macOS systems

# === CONFIG ===
GITEA_USER="username"
GITEA_URL="https://DOMAIN/git" #example: https://adam-jerusalem.nd.edu/git
GITEA_DOMAIN="DOMAIN" # example: adam-jerusalem.nd.edu
GITHUB_USER="username2"
GITHUB_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # GitHub PAT
GITEA_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# === START ===
echo "🍎 Starting Gitea to GitHub mirror process on macOS..."

# Check if required tools are installed
check_requirements() {
    echo "🔍 Checking system requirements..."
    
    # Check for Homebrew (recommended package manager for macOS)
    if ! command -v brew &> /dev/null; then
        echo "⚠️  Homebrew not found. Installing required packages manually..."
        echo "   You may need to install jq manually if not already present"
    else
        echo "✅ Homebrew found"
    fi
    
    # Check for jq
    if ! command -v jq &> /dev/null; then
        echo "❌ jq is required but not installed."
        echo "   Install with: brew install jq"
        echo "   Or download from: https://stedolan.github.io/jq/download/"
        exit 1
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        echo "❌ curl is required but not installed."
        echo "   Install with: brew install curl"
        exit 1
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        echo "❌ git is required but not installed."
        echo "   Install with: brew install git"
        exit 1
    fi
    
    echo "✅ All requirements satisfied"
}

# Run requirements check
check_requirements

# Get repositories from Gitea
echo "📥 Fetching repositories from Gitea..."
REPOS=($(curl -s -H "Authorization: token $GITEA_TOKEN" \
     "$GITEA_URL/api/v1/users/$GITEA_USER/repos?limit=1000" | jq -r '.[].name'))

if [ ${#REPOS[@]} -eq 0 ]; then
    echo "❌ No repositories found or error occurred"
    exit 1
fi

echo "✅ Found ${#REPOS[@]} repositories"

# Process each repository
for REPO in "${REPOS[@]}"; do
    echo -e "\n=== Processing $REPO ==="

    # Create GitHub repo
    echo "→ Creating $REPO on GitHub..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_USER:$GITHUB_TOKEN" \
        -X POST "https://api.github.com/user/repos" \
        -d "{\"name\":\"$REPO\", \"private\":true}")
    
    if [ "$HTTP_CODE" = "201" ]; then
        echo "✔️ Created"
    elif [ "$HTTP_CODE" = "422" ]; then
        echo "⚠️ Repo may already exist"
    else
        echo "❌ Error creating repo (HTTP: $HTTP_CODE)"
        continue
    fi

    # Mirror clone from Gitea
    echo "→ Cloning $REPO from Gitea..."
    if git clone --mirror "https://$GITEA_USER:$GITEA_TOKEN@$GITEA_DOMAIN/git/$GITEA_USER/$REPO.git"; then
        echo "✅ Cloned successfully"
    else
        echo "❌ Failed to clone $REPO"
        continue
    fi
    
    cd "$REPO.git" || { echo "❌ Failed to enter $REPO.git"; continue; }

    # Push to GitHub
    echo "→ Pushing to GitHub..."
    if git push --mirror "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"; then
        echo "✅ Pushed successfully"
    else
        echo "❌ Failed to push $REPO"
    fi

    # Cleanup (delete the local mirror clones after pushing to GitHub)
    cd ..
    rm -rf "$REPO.git"
    echo "🧹 Cleaned up local clone"
    echo "✅ Finished $REPO"
done

echo -e "\n🎉 Mirror process completed!"
echo "🍎 macOS version completed successfully!"
