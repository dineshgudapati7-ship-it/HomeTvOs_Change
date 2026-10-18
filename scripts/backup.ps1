# Backs up the TV's app list, settings and user-installed APKs into backup/<timestamp>/
param(
    [string]$Device = "192.168.31.170:5555",
    [string]$Adb = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root ("backup\" + (Get-Date -Format "yyyy-MM-dd_HHmmss"))
New-Item -ItemType Directory -Force "$out\apks" | Out-Null

function Sh([string]$cmd) { & $Adb -s $Device shell $cmd }
function Save([string]$name, [string]$cmd) { Sh $cmd | Out-File -Encoding utf8 (Join-Path $out $name) }

& $Adb connect $Device | Out-Null
if ((& $Adb -s $Device get-state) -ne "device") { throw "TV not connected/authorized" }

# Device info
Save "getprop.txt"         "getprop"
Save "build.txt"           "getprop ro.build.fingerprint; getprop ro.build.version.release; getprop ro.product.model"
Save "storage.txt"         "df -h"
Save "meminfo.txt"         "cat /proc/meminfo"

# Package state (needed to undo debloating)
Save "packages_all.txt"      "pm list packages -f -u"
Save "packages_system.txt"   "pm list packages -s"
Save "packages_user.txt"     "pm list packages -3"
Save "packages_enabled.txt"  "pm list packages -e"
Save "packages_disabled.txt" "pm list packages -d"
Save "packages_versions.txt" "dumpsys package packages | grep -E 'Package \[|versionName'"

# Settings
Save "settings_global.txt" "settings list global"
Save "settings_system.txt" "settings list system"
Save "settings_secure.txt" "settings list secure"

# Default launcher / home activity
Save "home_activity.txt" "cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME"

# APKs of user-installed apps (system apps stay on /system and can be restored with install-existing)
foreach ($line in (Sh "pm list packages -3 -f")) {
    if ($line -match '^package:(.+)=(.+)$') {
        $pkg = $Matches[2].Trim()
        $dir = Split-Path ($Matches[1] -replace '/', '\') -Parent
        $paths = Sh "pm path $pkg" | ForEach-Object { $_ -replace '^package:', '' }
        New-Item -ItemType Directory -Force "$out\apks\$pkg" | Out-Null
        foreach ($p in $paths) { & $Adb -s $Device pull $p.Trim() "$out\apks\$pkg\" | Out-Null }
    }
}

Write-Host "Backup written to $out"
