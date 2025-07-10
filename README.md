# Gitea to GitHub Mirror Script

This repository contains a Bash script (`full_gitea_to_github_mirror.sh`) to automate the process of mirroring **all** repositories from a Gitea instance to GitHub.

## Features

- Automatically fetches all repositories for a given Gitea user
- Creates corresponding private repositories on GitHub (can be changed to public)
- Mirrors all repositories, preserving all branches, tags, and commit history

## Prerequisites

- `jq` installed (for parsing JSON)
- `curl` and `git` installed
- Access tokens for both Gitea and GitHub

## Usage

1. **Clone this repository or copy the script to your machine.**
2. **Edit the configuration section at the top of `full_gitea_to_github_mirror.sh`:**
   - `GITEA_USER`: Your Gitea username
   - `GITEA_URL`: Base URL of your Gitea instance (e.g., `https://yourdomain.com/git`)
   - `GITEA_DOMAIN`: Domain of your Gitea instance (e.g., `yourdomain.com`)
   - `GITHUB_USER`: Your GitHub username
   - `GITHUB_TOKEN`: Your GitHub Personal Access Token (PAT)
   - `GITEA_TOKEN`: Your Gitea API token
3. **Run the script:**

```bash
   chmod +x full_gitea_to_github_mirror.sh
   ./full_gitea_to_github_mirror.sh
```

## How to Get Your Tokens

### GitHub Personal Access Token (PAT)

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Name it something like gitea-sync-token.
4. Select the required scopes
   - ✅ repo → for pushing to repos
   - ✅ admin:repo_hook → for repo creation
5. Set an expiration if you want (e.g. 90 days).
6. Click “Generate token”.
7. Copy and save the generated token (you won't be able to see it again)
![GitHub Token Example](assets/github%20keys.png)

### Gitea API Token

1. Log in to your Gitea account in your browser.
2. Go to "Settings" > "Applications"
3. Under "Manage Access Tokens", click "Generate Token"
4. Enter a name for your token (e.g. github-mirror).
5. Select the scopes/permissions:
   - ✅ repo (for reading repos)
   - ✅ write:repo_hook (if pushing)
   - ✅ admin:repo_hook (optional, if you need advanced repo control)
   - ✅ or simply choose “all” to make it simple.
6. Click "Generate Token"
7. Copy and save the generated token - you will never see it again!

![GitHub Token Example](assets/gitea%20keys.png)

## Notes

- The script creates private repositories on GitHub by default. To create public repositories, change `"private":true` to `"private":false` in the script.
- Make sure your tokens have sufficient permissions to read from Gitea and create/push to GitHub repositories.
