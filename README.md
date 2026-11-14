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
| rofi powermenu | power menu yasb | 4 tombol bulat: shutdown, restart, sleep, sign out |
| kitty | Windows Terminal | skema "Matugen" + font/opacity/padding yang sama |
| pulsemixer | audio menu yasb | klik widget volume |
| hyprlock | `Win+O` | kunci layar bawaan Windows |
| keybind SUPER | whkd | workspace 1-10, fokus, pindah, resize, float, monocle |

Nilai yang diterjemahkan dari Hyprland: `gaps_out 4` = padding workspace 2 + container 2,
`gaps_in 2` = container 2, `border_size 2`, `inactive_opacity 0.95` = alpha 242,
animasi 300 ms dengan kurva decel (EaseOutQuint).

## Pasang

1. Pasang dependensi: komorebi + whkd, yasb, matugen, AutoHotkey v2 (untuk `Win+Enter`, sudah ada di config lama).
   matugen: unduh rilis dari <https://github.com/InioX/matugen/releases> atau `cargo install matugen`.
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

File dibuat dan divalidasi sintaksnya di Linux (YAML, JSON, TOML, keybind ganda, template matugen
terhadap palet hyprdots). Script `.ps1` belum dijalankan di PowerShell.
Opsi widget yasb dicocokkan dengan dokumentasi, tetapi versi yasb kamu bisa berbeda.

- Bar kosong atau error: `yasbc log`.
- Tombol power menu (ukuran/posisi ikon) mungkin perlu disetel di bagian `.power-menu-popup`
  pada `matugen/templates/yasb-styles.css`.
- matugen menolak flag: cek `matugen --help`; flag yang dipakai script adalah `image <path> -m -t -c`.
- `komorebic check` untuk memvalidasi `komorebi.json` (khususnya `animation`).
- Windows Terminal belum memuat skema "Matugen": tutup semua jendela WT lalu buka lagi.

## Keamanan

Config yasb lama berisi API key WeatherAPI yang ikut ter-commit di repo publik.
Widget cuaca sengaja tidak disertakan di sini. Kalau key itu milikmu, sebaiknya dibuat ulang
dan dihapus dari repo (riwayat git juga masih menyimpannya).
