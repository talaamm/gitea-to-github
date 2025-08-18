GITHUB_USER="xxx"
GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
NEW_NAME="xxx"
NEW_EMAIL="xxx.xxxxx@xxx.com"

REPOS=($(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/users/$GITHUB_USER/repos?per_page=100" | jq -r '.[].name'))

for REPO in "${REPOS[@]}"; do
    git clone "https://github.com/$GITHUB_USER/$REPO.git"
    cd "$REPO"
   # git remote set-url origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"
    # Only run filter-repo if there are commits
    if [ "$(git rev-parse HEAD 2>/dev/null)" ]; then
        git filter-repo --force --mailmap <(echo "$NEW_NAME <$NEW_EMAIL> <email1>
$NEW_NAME <$NEW_EMAIL> <email2>
$NEW_NAME <$NEW_EMAIL> <email3>")
       git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git
       git remote -v
       git push --force --tags origin 'refs/heads/*'

        echo "✅ Rewritten and pushed $REPO"
        echo ""
    else
        echo "⚠️ No commits in $REPO, skipping."
        echo ""
    fi
    cd ..
    rm -rf "$REPO"
done