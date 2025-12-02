# PowerShell script to run both Flutter app and Admin Panel

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VOGUE AI - Run Flutter App + Admin Panel" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Start Flutter App in new window
Write-Host "Starting Flutter App..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$scriptDir'; flutter pub get; flutter run"

# Wait a bit
Start-Sleep -Seconds 3

# Start Admin Panel in new window
Write-Host "Starting Admin Panel..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$scriptDir\admin-panel'; npm install; npm start"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Both applications are starting..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter App will open in a new window" -ForegroundColor Yellow
Write-Host "Admin Panel will open at http://localhost:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit this window (apps will keep running)" -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

