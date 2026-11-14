# Dialog pilih gambar sederhana (padanan waypaper), lalu panggil apply-wallpaper.ps1.
# Harus dijalankan dengan powershell -STA agar dialog Windows Forms bisa tampil.
Add-Type -AssemblyName System.Windows.Forms

$dlg = New-Object System.Windows.Forms.OpenFileDialog
$dlg.Title  = 'Pilih wallpaper'
$dlg.Filter = 'Gambar (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp'

$start = Join-Path $HOME 'Pictures'
if (Test-Path -LiteralPath $start) { $dlg.InitialDirectory = $start }

if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    & (Join-Path $PSScriptRoot 'apply-wallpaper.ps1') -Path $dlg.FileName
}
