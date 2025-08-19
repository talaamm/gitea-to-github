#!/bin/bash

GITHUB_USER="xx"
GITHUB_TOKEN="xxx"  # GitHub PAT
# GITHUB_TOKEN="your_personal_access_token_here"  # Keep secret

# Fetch private repos (must use /user/repos not /users/)
echo "Fetching private repositories from GitHub..."
REPOS=($(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/user/repos?per_page=100&visibility=private" | jq -r '.[].name'))

if [[ ${#REPOS[@]} -eq 0 ]]; then
    echo "No private repositories found."
    exit 0
fi

echo "Found ${#REPOS[@]} private repositories:"
printf '%s\n' "${REPOS[@]}"
echo

for REPO in "${REPOS[@]}"; do
    echo -e "\n=== Processing PRIVATE repository: $REPO ==="

    # Clone using token authentication
    git clone "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"
    
    if [ -d "$REPO/.git" ]; then
        echo "Repository: $REPO"
        echo "Contributors:"
        git -C "$REPO" log --format='%an <%ae>' | sort -u
        echo ""
    fi

    rm -rf "$REPO"
    echo "✅ Finished $REPO"
    echo ""
done
