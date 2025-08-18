# list contributors

GITHUB_USER="xxx"
GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxx"  # GitHub PAT

REPOS=($(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/users/$GITHUB_USER/repos?per_page=100" | jq -r '.[].name'))

for REPO in "${REPOS[@]}"; do
    git clone "https://github.com/$GITHUB_USER/$REPO.git"
    if [ -d "$REPO/.git" ]; then
        echo "Repository: $REPO"
        git -C "$REPO" log --format='%an <%ae>' | sort -u
        echo ""
    fi
    rm -rf "$REPO"
    echo "✅ Finished $REPO"
    echo ""
done