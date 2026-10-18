# Disables Xiaomi telemetry/ads and unused extras, and speeds up animations. Undo with restore.ps1.
param(
    [string]$Device = "192.168.31.170:5555",
    [string]$Adb = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe"
)

$packages = @(
    "com.miui.tv.analytics"           # Xiaomi analytics
    "com.xiaomi.statistic"            # Xiaomi usage statistics
    "com.mitv.tvhome.mitvplus"        # Mi TV+ (ad-supported channels)
    "com.mitv.tvhome.michannel"       # Mi Channel content rows
    "com.xiaomi.mimusic2"             # Mi Music
    "com.xiaomi.mitv.handbook"        # On-screen manual
    "com.mitv.gallery"                # Mi Gallery
    "com.google.android.play.games"   # Play Games
    "com.google.android.videos"       # Play Movies & TV
    "com.google.android.marvin.talkback" # TalkBack screen reader
    "com.google.android.feedback"     # Google feedback reporter
    "com.android.printspooler"        # Printing
    "com.android.dynsystem"           # Dynamic System Updates (dev feature, not OTA)
)

& $Adb connect $Device | Out-Null
if ((& $Adb -s $Device get-state) -ne "device") { throw "TV not connected/authorized" }

foreach ($pkg in $packages) {
    $r = & $Adb -s $Device shell "pm disable-user --user 0 $pkg" 2>&1
    Write-Host "$pkg -> $r"
}

foreach ($key in "window_animation_scale", "transition_animation_scale", "animator_duration_scale") {
    & $Adb -s $Device shell "settings put global $key 0.5"
}
Write-Host "Animations set to 0.5x"
