@echo off
REM Gitea to GitHub Mirror Script for Windows (Batch File)
REM This is an alternative to the PowerShell version for Command Prompt users

REM === CONFIG ===
set GITEA_USER=username
set GITEA_URL=https://DOMAIN/git
set GITEA_DOMAIN=DOMAIN
set GITHUB_USER=username2
set GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
set GITEA_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

REM === START ===
echo Starting Gitea to GitHub mirror process on Windows...
echo.

REM Check if git is available
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH
    echo Please install Git for Windows from: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Check if jq is available (optional for batch file)
jq --version >nul 2>&1
if errorlevel 1 (
    echo WARNING: jq not found. Using alternative JSON parsing method.
    echo For better functionality, install jq from: https://stedolan.github.io/jq/download/
    echo.
)

echo Fetching repositories from Gitea...
echo Note: This batch file version has limited functionality compared to PowerShell
echo Consider using gitea_to_github_mirror.ps1 for full features
echo.

REM For batch file, we'll need to manually specify repositories
REM or use a simpler approach. This is a basic template.
echo Please edit this batch file to add your repository names manually
echo or use the PowerShell version for automatic repository detection.
echo.

REM Example of how to process a single repository manually:
REM set REPO=your-repo-name
REM echo Processing %REPO%...
REM 
REM REM Create GitHub repo
REM echo Creating %REPO% on GitHub...
REM REM Add your GitHub API call here
REM 
REM REM Clone from Gitea
REM echo Cloning %REPO% from Gitea...
REM git clone --mirror "https://%GITEA_USER%:%GITEA_TOKEN%@%GITEA_DOMAIN%/git/%GITEA_USER%/%REPO%.git"
REM 
REM REM Push to GitHub
REM echo Pushing to GitHub...
REM cd "%REPO%.git"
REM git push --mirror "https://%GITHUB_USER%:%GITEA_TOKEN%@github.com/%GITHUB_USER%/%REPO%.git"
REM cd ..
REM 
REM REM Cleanup
REM rmdir /s /q "%REPO%.git"
REM echo Finished %REPO%

echo.
echo Batch file version completed.
echo For full functionality, please use gitea_to_github_mirror.ps1
pause
