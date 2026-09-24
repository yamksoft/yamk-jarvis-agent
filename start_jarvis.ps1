Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Jarvis AI Assistant - Windows Launcher" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

Write-Host "Choose Jarvis Operating Mode:" -ForegroundColor Yellow
Write-Host "[1] Local Mode (Starts Local LiveKit Server, Frontend, and Backend)"
Write-Host "[2] Cloud Mode (Starts Frontend and Backend ONLY)"
Write-Host ""

$choice = Read-Host "Enter your choice (1 or 2)"

if ($choice -eq "1") {
    Write-Host "Starting Local Mode..." -ForegroundColor Green
    
    $LivekitPath = "$PSScriptRoot\livekit-server-win\livekit-server.exe"
    if (!(Test-Path $LivekitPath)) {
        # Fallback for earlier setup script bug
        $LivekitPath = "$PSScriptRoot\jarvis\livekit-server-win\livekit-server.exe"
    }

    if (Test-Path $LivekitPath) {
        $LivekitDir = Split-Path $LivekitPath -Parent
        Write-Host "Launching LiveKit Server in a new window..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit -Command `"`$title='LiveKit Server'; [System.Console]::Title=`$title; cd `'$LivekitDir`'; .\livekit-server.exe --dev --bind 0.0.0.0`""
    } else {
        Write-Host "Error: LiveKit Server not found. Please run setup_windows.ps1 first to download it." -ForegroundColor Red
        pause
        exit
    }
} elseif ($choice -eq "2") {
    Write-Host "Starting Cloud Mode..." -ForegroundColor Green
} else {
    Write-Host "Invalid choice. Exiting..." -ForegroundColor Red
    pause
    exit
}

Write-Host "Launching Frontend in a new window..." -ForegroundColor Yellow
# Bypassing 'npm run dev' to avoid Windows CMD path bugs with the '&' character
Start-Process powershell -ArgumentList "-NoExit -Command `"`$title='Jarvis Frontend'; [System.Console]::Title=`$title; cd `'$PSScriptRoot\jarvis\frontend`'; node node_modules/next/dist/bin/next dev`""

Write-Host "Launching Backend in a new window..." -ForegroundColor Yellow
# Using uv to run the backend natively in dev mode (avoids port 8081 conflicts)
Start-Process powershell -ArgumentList "-NoExit -Command `"`$title='Jarvis Backend'; [System.Console]::Title=`$title; cd `'$PSScriptRoot\jarvis`'; uv run src/agent.py dev`""

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " All services have been launched in separate windows!" -ForegroundColor Green
Write-Host " Opening your web browser to http://localhost:3000..." -ForegroundColor Yellow
Start-Process "http://localhost:3000"
Write-Host " You can monitor their logs there, and simply close those windows to stop them." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
pause
