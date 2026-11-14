<#
.SYNOPSIS
  Ganti wallpaper lalu warnai ulang desktop dari gambar itu
  (padanan waypaper + matugen di hyprdots).

.EXAMPLE
  .\apply-wallpaper.ps1 C:\Users\me\Pictures\wall.jpg
  .\apply-wallpaper.ps1 wall.png -Mode light -Scheme scheme-expressive
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [ValidateSet('dark', 'light')]
    [string]$Mode = 'dark',

    [ValidateSet('scheme-content', 'scheme-expressive', 'scheme-fidelity', 'scheme-fruit-salad',
                 'scheme-monochrome', 'scheme-neutral', 'scheme-rainbow', 'scheme-tonal-spot')]
    [string]$Scheme = 'scheme-tonal-spot'
)

$ErrorActionPreference = 'Stop'
$Path = (Resolve-Path -LiteralPath $Path).Path
$cfg  = Join-Path $PSScriptRoot 'matugen.toml'

if (-not (Get-Command matugen -ErrorAction SilentlyContinue)) {
    throw 'matugen tidak ditemukan di PATH. Pasang dulu (lihat README.md).'
}
if (-not (Test-Path -LiteralPath $cfg)) {
    throw "matugen.toml tidak ada di $PSScriptRoot. Jalankan install.ps1 dulu."
}

# 1) Pasang wallpaper dengan mode Fill (setara swww "fill")
if (-not ('WinWall' -as [type])) {
    Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public static class WinWall {
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@
}
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10'
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
# SPI_SETDESKWALLPAPER = 0x14, flags = SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
[void][WinWall]::SystemParametersInfo(0x0014, 0, $Path, 0x03)

# 2) Generate warna Material You dan render semua template
& matugen image $Path -m $Mode -t $Scheme --source-color-index 0 -c $cfg
if ($LASTEXITCODE -ne 0) {
    throw "matugen gagal (exit code $LASTEXITCODE). Cek 'matugen --help' untuk versi kamu."
}

# 3) Tempel warna border ke komorebi.json lalu reload
$borderFile = Join-Path $PSScriptRoot 'out\komorebi-border.json'
if ($env:KOMOREBI_CONFIG_HOME) { $komoDir = $env:KOMOREBI_CONFIG_HOME } else { $komoDir = $HOME }
$komoFile = Join-Path $komoDir 'komorebi.json'

if ((Test-Path -LiteralPath $borderFile) -and (Test-Path -LiteralPath $komoFile)) {
    $colours = Get-Content -LiteralPath $borderFile -Raw | ConvertFrom-Json
    $komo    = Get-Content -LiteralPath $komoFile -Raw | ConvertFrom-Json
    $komo | Add-Member -NotePropertyName 'border_colours' -NotePropertyValue $colours -Force
    $json = $komo | ConvertTo-Json -Depth 32
    [IO.File]::WriteAllText($komoFile, $json, (New-Object System.Text.UTF8Encoding($false)))

    if (Get-Command komorebic -ErrorAction SilentlyContinue) {
        & komorebic reload-configuration
    }
}

Write-Host "Selesai: $Path ($Mode, $Scheme)"
Write-Host 'YASB ter-reload otomatis. Windows Terminal: tutup lalu buka lagi untuk memuat skema baru.'
