# Install Dashdot as Windows Startup Service
# This script creates a scheduled task to run dashdot at Windows startup

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Dashdot - Windows Startup Installer" -ForegroundColor Cyan
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

# Get the current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbsScriptPath = Join-Path $scriptDir "start-dashdot-silent.vbs"

# Check if the VBS script exists
if (-not (Test-Path $vbsScriptPath)) {
    Write-Host "ERROR: start-dashdot-silent.vbs not found!" -ForegroundColor Red
    Write-Host "Expected location: $vbsScriptPath" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Script directory: $scriptDir" -ForegroundColor Gray
Write-Host ""

# Task name
$taskName = "DashdotService"

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "WARNING: Task '$taskName' already exists!" -ForegroundColor Yellow
    $response = Read-Host "Do you want to replace it? (Y/N)"
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Host "Removing existing task..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Existing task removed." -ForegroundColor Green
    } else {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 0
    }
}

Write-Host "Creating scheduled task..." -ForegroundColor Cyan

# Create the action - run wscript with the VBS file
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$vbsScriptPath`""

# Create the trigger - at startup with 30 second delay
$trigger = New-ScheduledTaskTrigger -AtStartup
$trigger.Delay = "PT30S"

# Create settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Get current user
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Register the task
try {
    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Automatically starts Dashdot server dashboard at Windows startup" `
        -ErrorAction Stop | Out-Null
    
    Write-Host ""
    Write-Host "SUCCESS! Dashdot has been installed as a startup service." -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Cyan
    Write-Host "  - Task Name: $taskName" -ForegroundColor White
    Write-Host "  - Runs at: Windows Startup (30 second delay)" -ForegroundColor White
    Write-Host "  - Script: $vbsScriptPath" -ForegroundColor White
    Write-Host "  - Auto-restart: Yes (3 attempts, 1 minute interval)" -ForegroundColor White
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart your computer to test, OR" -ForegroundColor White
    Write-Host "  2. Run this to start manually:" -ForegroundColor White
    Write-Host "     Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To uninstall, run: .\uninstall-startup.ps1" -ForegroundColor Gray
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to create scheduled task." -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit"
