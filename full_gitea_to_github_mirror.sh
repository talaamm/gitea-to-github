#!/bin/bash

# === CONFIG ===
GITEA_USER="your-gitea-username"
GITEA_URL="https://your.gitea.server"
GITHUB_USER="your-github-username"
GITHUB_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXX"  # GitHub PAT

REPOS=("repo1" "repo2" "repo3" ...)  # Add your Gitea repo names here

# === START ===
for REPO in "${REPOS[@]}"; do
    echo -e "\n=== Processing $REPO ==="

    # Step 1: Create GitHub repo
    echo "→ Creating $REPO on GitHub..."
    curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_USER:$GITHUB_TOKEN" \
        -X POST "https://api.github.com/user/repos" \
        -d "{\"name\":\"$REPO\", \"private\":false}" | grep -q "201" && echo "✔️ Created" || echo "⚠️ Repo may already exist"

    # Step 2: Mirror clone from Gitea
    echo "→ Cloning $REPO from Gitea..."
    git clone --mirror "$GITEA_URL/$GITEA_USER/$REPO.git"
    cd "$REPO.git" || { echo "❌ Failed to enter $REPO.git"; continue; }

    # Step 3: Push to GitHub
    echo "→ Pushing to GitHub..."
    git push --mirror "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"

    # Cleanup
    cd ..
    rm -rf "$REPO.git"
    echo "✅ Finished $REPO"
done