Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Change to the script directory and run the PowerShell script hidden
strCommand = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & strScriptPath & "\start-dashdot.ps1"""

objShell.Run strCommand, 0, False

Set objShell = Nothing
Set objFSO = Nothing
