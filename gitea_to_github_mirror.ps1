# Gitea to GitHub Mirror Script for Windows
# Run this script in PowerShell with administrator privileges

# === CONFIG ===
$GITEA_USER = "username"
$GITEA_URL = "https://DOMAIN/git" #example: https://adam-jerusalem.nd.edu/git
$GITEA_DOMAIN = "DOMAIN" # example: adam-jerusalem.nd.edu
$GITHUB_USER = "username2"
$GITHUB_TOKEN = "ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  # GitHub PAT
$GITEA_TOKEN = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# === START ===
Write-Host "Starting Gitea to GitHub mirror process..." -ForegroundColor Green

# Get repositories from Gitea
Write-Host "Fetching repositories from Gitea..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "token $GITEA_TOKEN"
    }
    
    $response = Invoke-RestMethod -Uri "$GITEA_URL/api/v1/users/$GITEA_USER/repos?limit=1000" -Headers $headers -Method Get
    $repos = $response | ForEach-Object { $_.name }
    
    Write-Host "Found $($repos.Count) repositories" -ForegroundColor Green
} catch {
    Write-Host "Error fetching repositories: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Process each repository
foreach ($repo in $repos) {
    Write-Host "`n=== Processing $repo ===" -ForegroundColor Cyan

    # Create GitHub repo
    Write-Host "→ Creating $repo on GitHub..." -ForegroundColor Yellow
    try {
        $githubBody = @{
            name = $repo
            private = $true
        } | ConvertTo-Json
        
        $githubHeaders = @{
            "Authorization" = "token $GITHUB_TOKEN"
            "Accept" = "application/vnd.github.v3+json"
        }
        
        $githubResponse = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $githubHeaders -Method Post -Body $githubBody
        Write-Host "✔️ Created" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 422) {
            Write-Host "⚠️ Repo may already exist" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Error creating repo: $($_.Exception.Message)" -ForegroundColor Red
            continue
        }
    }

    # Mirror clone from Gitea
    Write-Host "→ Cloning $repo from Gitea..." -ForegroundColor Yellow
    try {
        $cloneUrl = "https://$GITEA_USER`:$GITEA_TOKEN@$GITEA_DOMAIN/git/$GITEA_USER/$repo.git"
        git clone --mirror $cloneUrl
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to clone $repo" -ForegroundColor Red
            continue
        }
    } catch {
        Write-Host "❌ Error cloning $repo: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    # Push to GitHub
    Write-Host "→ Pushing to GitHub..." -ForegroundColor Yellow
    try {
        Set-Location "$repo.git"
        $pushUrl = "https://$GITHUB_USER`:$GITHUB_TOKEN@github.com/$GITHUB_USER/$repo.git"
        git push --mirror $pushUrl
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully pushed $repo" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to push $repo" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error pushing $repo: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Cleanup (delete the local mirror clones after pushing to GitHub)
    Set-Location ..
    try {
        Remove-Item -Recurse -Force "$repo.git" -ErrorAction Stop
        Write-Host "🧹 Cleaned up local clone" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Warning: Could not clean up local clone" -ForegroundColor Yellow
    }
    
    Write-Host "✅ Finished $repo" -ForegroundColor Green
}

Write-Host "`n🎉 Mirror process completed!" -ForegroundColor Green
