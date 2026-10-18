# HomeTvOs_Change
A fun side project to change my OS of my andriod tv. Current one is very slow and buggy.

The stock OS can't be replaced (Xiaomi locks the bootloader and there are no custom ROMs for this model), so instead this repo makes it fast and gives it an Apple TV-style look — all over ADB, all reversible.

## The TV
| | |
|---|---|
| Model | Xiaomi MiTV-AXSO2 (codename `dangalUHD`) |
| OS | Android TV 11 with Xiaomi PatchWall |
| Chip / RAM | Amlogic, 2 GB RAM (the main reason it lagged) |

## What was changed
- **Debloat** — 13 Xiaomi/Google extras disabled (analytics, statistics, Mi TV+, Mi Channel, Mi Music, handbook, Mi Gallery, Play Games, Play Movies, TalkBack, feedback, print spooler, Dynamic System Updates). Disabled with `pm disable-user`, not uninstalled.
- **Animations** set to 0.5x for snappier menus.
- **Apple TV-style look** — [Projectivy Launcher](https://play.google.com/store/apps/details?id=com.spocky.projengmenu) replaces the Google home screen, and [Aerial Views](https://play.google.com/store/apps/details?id=com.neilturner.aerialviews) plays Apple's aerial videos as the screensaver.
- **Wake straight to home** — Xiaomi's power-on "auto play" (`set_auto_play`) opened Live TV on a blank screen when there's no antenna; it's turned off.

## Requirements
- Windows PC on the same Wi-Fi as the TV
- ADB: `winget install Google.PlatformTools`
- On the TV: Settings → Device Preferences → About → click *Build* 7 times, then turn on **USB debugging** in Developer options. Accept the "Allow debugging" prompt the first time a script connects.

All scripts take `-Device <tv-ip>:5555` (default `192.168.31.170:5555`).

## Scripts
Run from the repo root:

```powershell
# 1. Back up app list, settings and user-installed APKs to backup/<timestamp>/
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1

# 2. Disable bloat and speed up animations
powershell -ExecutionPolicy Bypass -File .\scripts\debloat.ps1

# 3. Apple TV style + wake to home (install Projectivy Launcher and Aerial Views from the Play Store first)
powershell -ExecutionPolicy Bypass -File .\scripts\apple-style.ps1

# Undo everything back to a backup
powershell -ExecutionPolicy Bypass -File .\scripts\restore.ps1 -BackupDir .\backup\2026-10-18_192041
```

`restore.ps1` re-enables every app that was enabled in the backup, reinstalls missing user apps from the saved APKs, and resets the animation, auto-play, screensaver and launcher settings.

## Manual steps (done on the TV, not scripted)
Projectivy stores its layout in its own app data, so these were set with the remote:

- **Appearance → Cards:** rounded corners and card size up, ripple effect off, animated icons off, focused card effect *Drop shadow*
- **Appearance → Wallpaper:** *Default wallpaper* (still image), image transition *None*
- **Appearance → Left headers:** off
- **Edit categories:** Inputs and Mobile Apps hidden; TV Apps shown as a **grid**
- **Edit channels:** Watch Next hidden (heavy poster images)
- **App order** (hold OK on an app → Reorder): Netflix, Crunchyroll, JioHotstar, Prime Video, YouTube, Play Store, JioCinema, then the rest
- **Aerial Views:** Apple videos at 1080p (smoother than 4K on 2 GB RAM)

## Notes
- `backup/*/apks/` is git-ignored: it's ~400 MB of third-party apps that shouldn't be published.
- Device identifiers (serial, Android ID, MAC addresses, Xiaomi IDs) in the committed backup files are replaced with `REDACTED`.
