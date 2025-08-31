#!/bin/bash

# === CONFIG ===
GITEA_USER="username"
GITEA_URL="https://DOMAIN/git" #example: https://adam-jerusalem.nd.edu/git
GITEA_DOMAIN="DOMAIN" # example: adam-jerusalem.nd.edu
GITHUB_USER="username2"
GITHUB_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # GitHub PAT
GITEA_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
REPOS=($(curl -s -H "Authorization: token $GITEA_TOKEN" \
     "$GITEA_URL/api/v1/users/$GITEA_USER/repos?limit=1000" | jq -r '.[].name'))
git push
# === START ===
for REPO in "${REPOS[@]}"; do
    echo -e "\n=== Processing $REPO ==="

    # Create GitHub repo
    echo "→ Creating $REPO on GitHub..."
    curl -s -o /dev/null -w "%{http_code}" -u "$GITHUB_USER:$GITHUB_TOKEN" \
        -X POST "https://api.github.com/user/repos" \
        -d "{\"name\":\"$REPO\", \"private\":true}" | grep -q "201" && echo "✔️ Created" || echo "⚠️ Repo may already exist"
####### change the line above \"private\":false if you want to create public repos
    # Mirror clone from Gitea
    echo "→ Cloning $REPO from Gitea..."
    git clone --mirror "https://$GITEA_USER:$GITEA_TOKEN@$GITEA_DOMAIN/git/$GITEA_USER/$REPO.git"
    cd "$REPO.git" || { echo "❌ Failed to enter $REPO.git"; continue; }

    # Push to GitHub
    echo "→ Pushing to GitHub..."
    git push --mirror "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"

    # Cleanup (delete the local mirror clones after pushing to GitHub)
    cd ..
    rm -rf "$REPO.git"
    echo "✅ Finished $REPO"
done
