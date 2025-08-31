GITHUB_USER="xx"
GITHUB_TOKEN="xxx"
NEW_NAME="xxx"
NEW_EMAIL="xxx"

echo "Fetching private repositories from GitHub..."
REPOS=($(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/user/repos?per_page=100&visibility=private" | jq -r '.[].name'))

for REPO in "${REPOS[@]}"; do
    git clone "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"
    cd "$REPO"
   # git remote set-url origin "https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git"
    # Only run filter-repo if there are commits
    if [ "$(git rev-parse HEAD 2>/dev/null)" ]; then
            cat > .mailmap <<EOF
$NEW_NAME <$NEW_EMAIL> <150236890+talaamm@users.noreply.github.com>
$NEW_NAME <$NEW_EMAIL> <adam-07-01@adam-07-01s-Mac-mini.local>
$NEW_NAME <$NEW_EMAIL> <taamm@noreply.adam-jerusalem.nd.edu>
$NEW_NAME <$NEW_EMAIL> <github-actions[bot]@users.noreply.github.com>
$NEW_NAME <$NEW_EMAIL> <159125892+gpt-engineer-app[bot]@users.noreply.github.com>
EOF

        git filter-repo --force --mailmap .mailmap
#         git filter-repo --force --mailmap <(echo "$NEW_NAME <$NEW_EMAIL> <150236890+talaamm@users.noreply.github.com>
# $NEW_NAME <$NEW_EMAIL> <adam-07-01@adam-07-01s-Mac-mini.local>
# $NEW_NAME <$NEW_EMAIL> <taamm@noreply.adam-jerusalem.nd.edu>
# $NEW_NAME <$NEW_EMAIL> <github-actions[bot]@users.noreply.github.com>
# $NEW_NAME <$NEW_EMAIL> <159125892+gpt-engineer-app[bot]@users.noreply.github.com>")
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
