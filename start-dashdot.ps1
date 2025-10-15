# Dashdot Startup Script for Windows
# This script starts the dashdot service

# Set the working directory to the dashdot folder
Set-Location -Path $PSScriptRoot

# Start dashdot using yarn
Write-Host "Starting dashdot..." -ForegroundColor Green
yarn start
