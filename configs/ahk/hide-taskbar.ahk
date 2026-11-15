#Requires AutoHotkey 2.0+
#SingleInstance Force

; Taskbar Windows disembunyikan PERMANEN (tanpa toggle).
; Bar YASB menggantikan taskbar: jam, tray, volume, dsb.

Rehide() {
    if WinExist("ahk_class Shell_TrayWnd")
        WinHide("ahk_class Shell_TrayWnd")
    if WinExist("ahk_class Shell_SecondaryTrayWnd")
        WinHide("ahk_class Shell_SecondaryTrayWnd")
}
SetTimer(Rehide, 1000)
