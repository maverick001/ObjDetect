# PowerShell Script to forcefully stop Gradle Daemons and clean the app build directory

# Get the directory where the script is located
$ScriptPath = $PSScriptRoot

Write-Host "--------------------------------------------------"
Write-Host "Attempting cleanup in: $ScriptPath"
Write-Host "--------------------------------------------------"

# Ensure Android Studio is closed before running this script!

# --- Step 1: Stop Gradle Daemons ---
Write-Host "Attempting to stop Gradle Daemons..."
# Navigate to the script's directory (should be project root)
Push-Location $ScriptPath

# Check if gradlew exists
if (Test-Path .\gradlew.bat) {
    .\gradlew.bat --stop
    Write-Host "Gradle stop command executed."
} else {
    Write-Host ".\gradlew.bat not found. Skipping daemon stop." -ForegroundColor Yellow
}

# Return to the original location (optional, but good practice)
Pop-Location

Write-Host "Gradle daemon stop attempt finished."
Write-Host "Waiting a few seconds for processes to terminate..."
Start-Sleep -Seconds 5

# --- Step 2: Force Delete app/build Directory ---
$BuildFolderPath = Join-Path $ScriptPath "app\build"

if (Test-Path $BuildFolderPath) {
    Write-Host "Attempting to forcefully delete: $BuildFolderPath"
    try {
        Remove-Item -Path $BuildFolderPath -Recurse -Force -ErrorAction Stop
        # Verify deletion
        if (-not (Test-Path $BuildFolderPath)) {
             Write-Host "Successfully deleted $BuildFolderPath" -ForegroundColor Green
        } else {
             Write-Host "Folder might still exist after deletion attempt: $BuildFolderPath" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error deleting $BuildFolderPath : $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "This might indicate a persistent lock. Try running PowerShell as Administrator or check for antivirus interference." -ForegroundColor Yellow
    }
} else {
    Write-Host "Directory does not exist, no need to delete: $BuildFolderPath"
}

Write-Host "--------------------------------------------------"
Write-Host "Cleanup script finished."
Write-Host "You can now try building the project in Android Studio."
Write-Host "--------------------------------------------------"

# Optional: Pause at the end if running by double-clicking
# Read-Host -Prompt "Press Enter to exit"