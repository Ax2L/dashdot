@echo off
:: Run the PowerShell installation script as Administrator

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running installation script...
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0install-startup.ps1"
) else (
    echo Requesting administrator privileges...
    powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0install-startup.ps1\"' -Verb RunAs"
)
