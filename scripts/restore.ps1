# Restores every package that was present/enabled in a backup (undoes pm disable-user / pm uninstall --user 0)
param(
    [Parameter(Mandatory)][string]$BackupDir,
    [string]$Device = "192.168.31.170:5555",
    [string]$Adb = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe"
)

& $Adb connect $Device | Out-Null
if ((& $Adb -s $Device get-state) -ne "device") { throw "TV not connected/authorized" }

$current = & $Adb -s $Device shell "pm list packages" | ForEach-Object { $_ -replace '^package:', '' }

foreach ($line in Get-Content (Join-Path $BackupDir "packages_enabled.txt")) {
    $pkg = ($line -replace '^package:', '').Trim()
    if (-not $pkg) { continue }
    if ($current -notcontains $pkg) {
        Write-Host "reinstalling $pkg"
        & $Adb -s $Device shell "cmd package install-existing $pkg"
    }
    & $Adb -s $Device shell "pm enable $pkg" | Out-Null
}

# Reinstall user apps that are gone entirely, from the saved APKs
foreach ($dir in Get-ChildItem (Join-Path $BackupDir "apks") -Directory) {
    if ($current -notcontains $dir.Name) {
        Write-Host "installing $($dir.Name) from backup"
        & $Adb -s $Device install-multiple (Get-ChildItem $dir.FullName -Filter *.apk).FullName
    }
}

# Animation scales back to their backed-up values (Android default is 1 when unset)
$global = Get-Content (Join-Path $BackupDir "settings_global.txt")
foreach ($key in "window_animation_scale", "transition_animation_scale", "animator_duration_scale") {
    $saved = ($global | Where-Object { $_ -like "$key=*" }) -replace "^$key=", ''
    if (-not $saved) { $saved = "1" }
    & $Adb -s $Device shell "settings put global $key $saved"
}

Write-Host "Restore complete"
