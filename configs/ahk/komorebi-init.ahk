#Requires AutoHotkey 2.0+
#SingleInstance Force

; Float-rules dari komorebi+extraHotkey.ahk (windows-custom-desktop-pack).
; Keybind AHK-nya TIDAK diambil karena bentrok dengan whkdrc (Alt yang sama).

init() {
  Run "komorebic focus-follows-mouse disable", , "Hide"
  ; Selalu float popup IntelliJ, Control Panel, Task Manager, Calculator, dll.
  Run "komorebic float-rule class SunAwtDialog", , "Hide"
  Run "komorebic float-rule title 'Control Panel'", , "Hide"
  Run "komorebic float-rule class TaskManagerWindow", , "Hide"
  Run "komorebic float-rule title Calculator", , "Hide"
  ; Updater BandZip / ScreenToGif
  Run "komorebic float-rule exe Updater.exe", , "Hide"
  Run "komorebic float-rule exe ScreenToGif.exe", , "Hide"
  ; Settings tidak di-tile
  Run "komorebic float-rule title Settings", , "Hide"
  ; Aplikasi tray (Discord, Telegram, dll.)
  Run "komorebic identify-tray-application exe Discord.exe", , "Hide"
  Run "komorebic identify-tray-application exe Telegram.exe", , "Hide"
  Run "komorebic identify-tray-application exe everything.exe", , "Hide"
}

init()
