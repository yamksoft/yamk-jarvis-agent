param (
    [switch]$SkipElevate
)

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Jarvis AI Assistant - Windows Automated Setup Script" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Check for Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and -not $SkipElevate) {
    Write-Host "Requesting Administrator privileges to install system dependencies..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -SkipElevate" -Verb RunAs
    exit
}

# Move to script directory
Set-Location $PSScriptRoot

Write-Host "Checking for winget..." -ForegroundColor Green
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Error: winget is not installed. Please install App Installer from the Microsoft Store." -ForegroundColor Red
    pause
    exit
}

# Install Git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Git is already installed." -ForegroundColor Green
}

# Install Python 3
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Python..." -ForegroundColor Yellow
    winget install --id Python.Python.3.11 -e --source winget --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Python is already installed." -ForegroundColor Green
}

# Install Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Node.js..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --source winget --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Node.js is already installed." -ForegroundColor Green
}

# Refresh environment variables for the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if we are inside the project folder, if not, clone it.
if (!(Test-Path "$PSScriptRoot\jarvis\src\agent.py")) {
    Write-Host "Repository not found in current directory. Cloning from GitHub..." -ForegroundColor Yellow
    git clone https://github.com/yamksoft/livekit-jarvis-server.git
    if (Test-Path "$PSScriptRoot\livekit-jarvis-server") {
        Set-Location "$PSScriptRoot\livekit-jarvis-server"
    } else {
        Write-Host "Error: Failed to clone repository." -ForegroundColor Red
        pause
        exit
    }
} else {
    Write-Host "Repository files found." -ForegroundColor Green
}

# Install uv (Python Package Manager)
if (!(Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing 'uv' Python package manager..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri https://astral.sh/uv/install.ps1 -UseBasicParsing | Invoke-Expression
    $env:Path += ";$HOME\.cargo\bin"
} else {
    Write-Host "uv is already installed." -ForegroundColor Green
}

# Setup Backend
Write-Host "Setting up Python Backend..." -ForegroundColor Yellow
Set-Location "$PSScriptRoot\jarvis"
uv sync
Write-Host "Installing Playwright browsers..." -ForegroundColor Yellow
uv run playwright install chromium

# Setup Frontend
Write-Host "Setting up Next.js Frontend..." -ForegroundColor Yellow
Set-Location "$PSScriptRoot\jarvis\frontend"
npm install
Set-Location $PSScriptRoot

# Download LiveKit Server for Windows
Write-Host "Downloading latest LiveKit Server for Windows..." -ForegroundColor Yellow
$LivekitApi = "https://api.github.com/repos/livekit/livekit/releases/latest"
$Release = Invoke-RestMethod -Uri $LivekitApi
$Asset = $Release.assets | Where-Object { $_.name -match "windows_amd64.zip" }

if ($Asset) {
    $ZipPath = "$PSScriptRoot\livekit-server.zip"
    $ExtractPath = "$PSScriptRoot\livekit-server-win"
    if (!(Test-Path "$ExtractPath\livekit-server.exe")) {
        Write-Host "Downloading $($Asset.name)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $ZipPath
        Write-Host "Extracting LiveKit Server..." -ForegroundColor Yellow
        Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force
        Remove-Item $ZipPath
        Write-Host "LiveKit Server installed successfully in $ExtractPath." -ForegroundColor Green
    } else {
        Write-Host "LiveKit Server is already installed." -ForegroundColor Green
    }
} else {
    Write-Host "Error finding LiveKit Windows release." -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Setup Complete! Everything is ready." -ForegroundColor Green
Write-Host " You can now double-click 'start_jarvis.ps1' to run it." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
pause
