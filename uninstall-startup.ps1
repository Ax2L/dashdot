# Uninstall Dashdot Windows Startup Service
# This script removes the scheduled task that runs dashdot at startup

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Dashdot - Windows Startup Uninstaller" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Please right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Task name
$taskName = "DashdotService"

# Check if task exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if (-not $existingTask) {
    Write-Host "Task '$taskName' not found." -ForegroundColor Yellow
    Write-Host "Dashdot startup service is not installed." -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Found task: $taskName" -ForegroundColor Cyan
Write-Host ""

# Confirm removal
$response = Read-Host "Do you want to remove Dashdot from Windows startup? (Y/N)"

if ($response -ne 'Y' -and $response -ne 'y') {
    Write-Host "Uninstallation cancelled." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

# Stop the task if it's running
Write-Host ""
Write-Host "Stopping task if running..." -ForegroundColor Cyan
try {
    Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
} catch {
    # Task might not be running, that's okay
}

# Remove the task
Write-Host "Removing scheduled task..." -ForegroundColor Cyan
try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
    
    Write-Host ""
    Write-Host "SUCCESS! Dashdot has been removed from Windows startup." -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: If dashdot is currently running, you may want to stop it:" -ForegroundColor Cyan
    Write-Host "  1. Open Task Manager (Ctrl+Shift+Esc)" -ForegroundColor White
    Write-Host "  2. Find 'Node.js: Server-side JavaScript'" -ForegroundColor White
    Write-Host "  3. Right-click and select 'End Task'" -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to remove scheduled task." -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit"
