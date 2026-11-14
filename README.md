# windots-hypr: dotfiles Windows 11 yang meniru hyprdots

Turunan dari `usermahiro/dotfiles` (komorebi + yasb) supaya tampilan dan alur kerjanya
mendekati `elrondforwin/hyprdots` (Hyprland + waybar + matugen).
Yang paling penting: **warna seluruh desktop mengikuti wallpaper** lewat matugen,
sama seperti di hyprdots.

## Pemetaan Hyprland ke Windows

| hyprdots | Di sini | Catatan |
|---|---|---|
| Hyprland (dwindle) | komorebi (BSP) | gaps/border/opacity/animasi disamakan |
| waybar | yasb | pill melayang: workspace, jam, tray, keyboard, media, volume, power |
| matugen | matugen (Windows) | template: yasb, border komorebi, Windows Terminal |
| swww + waypaper | `apply-wallpaper.ps1` + `pick-wallpaper.ps1` | `Win+Ctrl+B` membuka dialog pilih gambar |
| rofi powermenu | power menu yasb | 5 tombol bulat: shutdown, restart, sleep, sign out, cancel |
| kitty | Windows Terminal | skema "Matugen" + font/opacity/padding yang sama |
| pulsemixer | audio menu yasb | klik widget volume |
| hyprlock | `Win+O` | kunci layar bawaan Windows |
| keybind SUPER | whkd | workspace 1-10, fokus, pindah, resize, float, monocle |

Nilai yang diterjemahkan dari Hyprland: `gaps_out 4` = padding workspace 2 + container 2,
`gaps_in 2` = container 2, `border_size 2`, `inactive_opacity 0.95` = alpha 242,
animasi 300 ms dengan kurva decel (EaseOutQuint).

## Pasang

1. Pasang dependensi: komorebi + whkd, yasb, matugen, AutoHotkey v2.
   matugen: unduh rilis dari <https://github.com/InioX/matugen/releases> atau `cargo install matugen`.
   AutoHotkey: pasang via winget (`winget install AutoHotkey.AutoHotkey`) — `install.ps1` otomatis
   memasang `elrond.ahk` (Win+Enter → Windows Terminal, Win+Alt+D → sembunyikan ikon desktop)
   dan membuat shortcut di folder Startup bila AutoHotkey64 ditemukan.
2. Pasang font: **Adwaita Sans** (font bar waybar) dan **JetBrainsMono Nerd Font**.
3. Jalankan:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```
   File lama dicadangkan sebagai `*.bak-pre-hypr` (hanya sekali).
4. `komorebic stop --whkd ; komorebic start --whkd`, lalu restart YASB.
5. Kalau `applications.json` komorebi belum ada: `komorebic fetch-asc`.
6. Windows Terminal: salin isi `defaults` dari `windows-terminal/profile-defaults.json`
   ke `profiles.defaults` di settings.json (hanya bagian `defaults`, bukan seluruh file).
7. Warnai dari wallpaper:
   ```powershell
   & "$HOME\.config\windots-hypr\apply-wallpaper.ps1" C:\path\wallpaper.jpg
   ```
   Opsi: `-Mode light` dan `-Scheme scheme-expressive` (dst.).
   Tanpa langkah ini pun, bar dan border sudah memakai palet biru dari hyprdots.

## Tidak bisa ditiru persis

- **Sudut membulat 16px**: Windows 11 memakai radius tetap (~8px) dan tidak bisa diubah.
  Border komorebi mengikuti radius itu.
- **Blur di belakang jendela** (`blur size 6, passes 2`): tidak ada padanan murni.
- **Pseudotile dan togglesplit**: komorebi tidak punya fitur itu.
- **Folder Papirus berwarna, Nemo, GTK/Qt, Spotify (spicetify), Vesktop**: tidak dicakup.
  Matugen bisa membuat template untuk app lain bila mau ditambah.
- **Win+L** (lock) tidak bisa ditimpa aplikasi mana pun, jadi vim-key `l` untuk fokus tidak dipetakan.
  Catatan: di hyprdots, `j` memindahkan fokus ke kanan dan `l` ke bawah (kemungkinan salah ketik);
  di sini dipakai pemetaan vim standar.

## Belum diuji di Windows: cek ini kalau ada yang aneh

File dibuat di Linux dan sejak itu: opsi widget yasb divalidasi terhadap skema pydantic
yasb versi terbaru (opsi invalid mematikan seluruh bar), glyph Nerd Font kosong diisi ulang,
CSS disesuaikan dengan QSS (`width`/`height` tidak didukung Qt), dan `install.ps1` sudah
dijalankan di PowerShell 5.1. Sisanya tetap perlu diuji di mesin dengan komorebi/yasb aktif.

- Bar kosong atau error: `yasbc log`.
- Tombol power menu (ukuran/posisi ikon) mungkin perlu disetel di bagian `.power-menu-popup`
  pada `matugen/templates/yasb-styles.css`.
- matugen menolak flag: cek `matugen --help`; flag yang dipakai script adalah `image <path> -m -t -c`.
- `komorebic check` untuk memvalidasi `komorebi.json` (khususnya `animation`).
- Windows Terminal belum memuat skema "Matugen": tutup semua jendela WT lalu buka lagi.

## Keamanan

Config yasb lama berisi API key WeatherAPI yang ikut ter-commit di repo publik
(masih ada di riwayat git, commit 5babf5c dan 73c37ca, dan key itu masih aktif).
Widget cuaca sengaja tidak disertakan di sini. Key itu TIDAK bisa dihapus dari riwayat
tanpa rewrite history + force push; minimal, **revoke/buat ulang key di weatherapi.com**.
