<#
.SYNOPSIS
  Memasang windots-hypr: config komorebi, whkd, yasb, matugen + script wallpaper.
  File lama dicadangkan sekali sebagai <nama>.bak-pre-hypr.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot

# Lokasi target (mengikuti env var bawaan tiap tool bila ada)
if ($env:YASB_CONFIG_HOME)     { $yasbDir = $env:YASB_CONFIG_HOME }     else { $yasbDir = Join-Path $HOME '.config\yasb' }
if ($env:KOMOREBI_CONFIG_HOME) { $komoDir = $env:KOMOREBI_CONFIG_HOME } else { $komoDir = $HOME }
if ($env:WHKD_CONFIG_HOME)     { $whkdDir = $env:WHKD_CONFIG_HOME }     else { $whkdDir = Join-Path $HOME '.config' }
$winDots = Join-Path $HOME '.config\windots-hypr'
$wtFrag  = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\matugen'

function Install-File {
    param([string]$From, [string]$To)
    $dir = Split-Path -Parent $To
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if ((Test-Path -LiteralPath $To) -and -not (Test-Path -LiteralPath "$To.bak-pre-hypr")) {
        Copy-Item -LiteralPath $To -Destination "$To.bak-pre-hypr"
        Write-Host "  cadangan: $To.bak-pre-hypr"
    }
    Copy-Item -LiteralPath $From -Destination $To -Force
    Write-Host "  -> $To"
}

Write-Host '[1/4] komorebi + whkd'
Install-File (Join-Path $src 'komorebi.json') (Join-Path $komoDir 'komorebi.json')
Install-File (Join-Path $src 'whkdrc')        (Join-Path $whkdDir 'whkdrc')

Write-Host '[2/4] yasb'
Install-File (Join-Path $src 'yasb\config.yaml') (Join-Path $yasbDir 'config.yaml')
Install-File (Join-Path $src 'yasb\styles.css')  (Join-Path $yasbDir 'styles.css')

Write-Host '[3/4] matugen + script wallpaper'
New-Item -ItemType Directory -Path (Join-Path $winDots 'out') -Force | Out-Null
New-Item -ItemType Directory -Path $wtFrag -Force | Out-Null
Get-ChildItem -LiteralPath (Join-Path $src 'scripts') -Filter '*.ps1' | ForEach-Object {
    Install-File $_.FullName (Join-Path $winDots $_.Name)
}
Get-ChildItem -LiteralPath (Join-Path $src 'matugen\templates') -File | ForEach-Object {
    Install-File $_.FullName (Join-Path $winDots ('templates\' + $_.Name))
}

# Render config.toml: ganti token @...@ dengan path absolut (garis miring biasa)
$toml = Get-Content -LiteralPath (Join-Path $src 'matugen\config.toml') -Raw
$toml = $toml.Replace('@WINDOTS@',     ($winDots -replace '\\', '/'))
$toml = $toml.Replace('@YASB@',        ($yasbDir -replace '\\', '/'))
$toml = $toml.Replace('@WT_FRAGMENT@', ($wtFrag  -replace '\\', '/'))
$tomlOut = Join-Path $winDots 'matugen.toml'
[IO.File]::WriteAllText($tomlOut, $toml, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  -> $tomlOut"

Write-Host '[4/4] cek dependensi'
foreach ($cmd in 'komorebic', 'whkd', 'yasb', 'matugen') {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Host "  ok      $cmd"
    } else {
        Write-Host "  KURANG  $cmd (lihat README.md)"
    }
}

# AutoHotkey: script elrond.ahk (Win+Enter -> Windows Terminal, Win+Alt+D -> sembunyikan ikon desktop)
Install-File (Join-Path $src 'configs\ahk\elrond.ahk') (Join-Path $winDots 'elrond.ahk')
# AutoHotkey: hilangkan taskbar bawaan Windows sepenuhnya (Win+Alt+T = toggle)
Install-File (Join-Path $src 'configs\ahk\hide-taskbar.ahk') (Join-Path $winDots 'hide-taskbar.ahk')
# AutoHotkey: float-rules komorebi (Task Manager, Settings, tray apps) dari windows-custom-desktop-pack
Install-File (Join-Path $src 'configs\ahk\komorebi-init.ahk') (Join-Path $winDots 'komorebi-init.ahk')
$ahk = Get-Command 'AutoHotkey64' -ErrorAction SilentlyContinue
if (-not $ahk) {
    $ahkExe = Get-ChildItem "$env:ProgramFiles\AutoHotkey" -Filter 'AutoHotkey64.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ahkExe) { $ahk = $ahkExe.FullName }
}
if ($ahk) {
    $startup = [Environment]::GetFolderPath('Startup')
    foreach ($name in 'elrond', 'hide-taskbar', 'komorebi-init') {
        $ahkPath = Join-Path $winDots "$name.ahk"
        if (-not (Test-Path -LiteralPath $ahkPath)) { continue }
        $lnk = Join-Path $startup "$name.lnk"
        $ws = New-Object -ComObject WScript.Shell
        $sc = $ws.CreateShortcut($lnk)
        $sc.TargetPath = if ($ahk -is [string]) { $ahk } else { $ahk.Source }
        $sc.Arguments  = '"' + $ahkPath + '"'
        $sc.Save()
        Write-Host "  -> $lnk"
    }
} else {
    Write-Host '  KURANG  AutoHotkey64 (shortcut startup elrond.ahk tidak dibuat; lihat README.md)'
}

Write-Host ''
Write-Host 'Selesai. Langkah berikutnya:'
Write-Host '  1. komorebic stop --whkd ; komorebic start --whkd'
Write-Host '  2. Restart YASB'
Write-Host "  3. Warnai dari wallpaper:  & '$winDots\apply-wallpaper.ps1' C:\path\wallpaper.jpg"
Write-Host '  4. Windows Terminal: gabungkan windows-terminal\profile-defaults.json ke settings.json'
