# PowerShell script to start the Flask backend
Write-Host "Starting Flask Backend Server..." -ForegroundColor Green
Set-Location -Path "$PSScriptRoot\api"
python app.py

