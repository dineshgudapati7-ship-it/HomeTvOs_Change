# Apple TV-style look: Projectivy Launcher as home + Aerial Views (Apple aerial videos) as screensaver.
# Both apps must already be installed from the Play Store. Undo with restore.ps1.
param(
    [string]$Device = "192.168.31.170:5555",
    [string]$Adb = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe"
)

$launcher = "com.spocky.projengmenu/.ui.home.MainActivity"
$launcherA11y = "com.spocky.projengmenu/.services.ProjectivyAccessibilityService"
$dream = "com.neilturner.aerialviews/.ui.screensaver.DreamActivity"

function Sh([string]$cmd) { & $Adb -s $Device shell $cmd }

& $Adb connect $Device | Out-Null
if ((& $Adb -s $Device get-state) -ne "device") { throw "TV not connected/authorized" }

# Launcher: set as home, and enable Projectivy's accessibility service so it can take over the Home button
Sh "cmd package set-home-activity $launcher"
Sh "settings put secure enabled_accessibility_services $launcherA11y"
Sh "settings put secure accessibility_enabled 1"

# Screensaver
Sh "settings put secure screensaver_components $dream"
Sh "settings put secure screensaver_enabled 1"

Write-Host "Apple TV style applied"
