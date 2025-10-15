# Dashdot Windows Startup Guide

This guide helps you set up dashdot to run automatically in the background when Windows starts.

## Files Created

1. **start-dashdot.ps1** - PowerShell script that starts dashdot
2. **start-dashdot-silent.vbs** - VBScript that runs the PowerShell script silently in the background
3. **start-dashdot.bat** - Alternative batch file for manual starting
4. **install-startup.bat** / **install-startup.ps1** - Automated installer for startup service
5. **uninstall-startup.bat** / **uninstall-startup.ps1** - Automated uninstaller for startup service

## Quick Install (Recommended)

**Just double-click `install-startup.bat`** - It will automatically:
- Request administrator privileges
- Create a Windows scheduled task
- Configure dashdot to start at Windows startup
- Set up auto-restart on failure

**To uninstall: double-click `uninstall-startup.bat`**

## Setup Instructions

### Method 1: Using Task Scheduler (Recommended)

This method ensures dashdot runs with proper privileges and restarts if it crashes.

1. **Open Task Scheduler**
   - Press `Win + R`
   - Type `taskschd.msc` and press Enter

2. **Create a New Task**
   - Click "Create Task..." (not "Create Basic Task")
   - Give it a name: `Dashdot Service`
   - Check "Run whether user is logged on or not"
   - Check "Run with highest privileges"
   - Configure for: Windows 10/11

3. **Configure Triggers Tab**
   - Click "New..."
   - Begin the task: "At startup"
   - Delay task for: 30 seconds (optional, to let system services start first)
   - Click OK

4. **Configure Actions Tab**
   - Click "New..."
   - Action: "Start a program"
   - Program/script: `wscript.exe`
   - Add arguments: `"C:\Users\vsewo\Code\apps\dashdot\start-dashdot-silent.vbs"`
     (Replace with your actual path)
   - Click OK

5. **Configure Conditions Tab**
   - Uncheck "Start the task only if the computer is on AC power"

6. **Configure Settings Tab**
   - Check "Allow task to be run on demand"
   - Check "If the task fails, restart every: 1 minute"
   - Attempt to restart up to: 3 times
   - If the running task does not end when requested: "Stop the existing instance"

7. **Save the Task**
   - Click OK
   - Enter your Windows password if prompted

### Method 2: Using Startup Folder (Simple)

This method starts dashdot when you log in to Windows.

1. **Open Startup Folder**
   - Press `Win + R`
   - Type `shell:startup` and press Enter

2. **Create Shortcut**
   - Right-click in the Startup folder
   - Select "New" → "Shortcut"
   - Browse to: `C:\Users\vsewo\Code\apps\dashdot\start-dashdot-silent.vbs`
   - Click Next, name it "Dashdot", and click Finish

## Manual Start/Stop

### Start Manually
- Double-click `start-dashdot-silent.vbs` for background start
- Or double-click `start-dashdot.bat` to see console output

### Stop
- Open Task Manager (`Ctrl + Shift + Esc`)
- Find "Node.js: Server-side JavaScript" process
- Right-click and select "End Task"

## Troubleshooting

### Check if dashdot is running
1. Open PowerShell
2. Run: `Get-Process node -ErrorAction SilentlyContinue`
3. Or check Task Manager for Node.js processes

### View dashdot in browser
Once running, open: http://localhost:3000

### Logs
- For Task Scheduler: Check Task Scheduler Library → Dashdot Service → History tab
- For manual runs with .bat file: Console window will show output

### Common Issues

**Script won't run:**
- Right-click `start-dashdot.ps1` → Properties → Check "Unblock" if present

**Permission denied:**
- Run Task Scheduler as administrator
- Ensure "Run with highest privileges" is checked

**Port already in use:**
- Check if another instance of dashdot is running
- Use Task Manager to end any existing Node.js processes

**Yarn not found:**
- Ensure yarn is installed globally: `npm install -g yarn`
- Or verify the PATH environment variable includes Node.js

## Configuration

If you need to change the port or other settings, create a `.env` file in the dashdot directory or set environment variables in the Task Scheduler action.

## Uninstall

### Automated Method (Easiest):
**Double-click `uninstall-startup.bat`** - It will automatically remove the scheduled task.

### Manual Task Scheduler Method:
1. Open Task Scheduler
2. Find "DashdotService"
3. Right-click → Delete

### Startup Folder Method:
1. Press `Win + R`, type `shell:startup`
2. Delete the "Dashdot" shortcut

## What the Install Script Does

The `install-startup.bat` script:
1. Checks for administrator privileges (requests them if needed)
2. Creates a scheduled task named "DashdotService"
3. Configures it to run at Windows startup (30 second delay)
4. Sets up auto-restart on failure (3 attempts, 1 minute intervals)
5. Configures it to run even on battery power
6. Uses your current Windows user account

## Command Line Usage

You can also use PowerShell directly:

```powershell
# Install (requires admin)
.\install-startup.ps1

# Uninstall (requires admin)
.\uninstall-startup.ps1

# Start the task manually
Start-ScheduledTask -TaskName "DashdotService"

# Stop the task manually
Stop-ScheduledTask -TaskName "DashdotService"

# Check task status
Get-ScheduledTask -TaskName "DashdotService"
```
