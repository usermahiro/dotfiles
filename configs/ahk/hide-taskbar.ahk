#Requires AutoHotkey 2.0+
#SingleInstance Force

; Hilangkan taskbar Windows sepenuhnya (bar YASB menggantikannya).
; Win + Alt + T untuk tampilkan/sembunyikan sementara.
hidden := true

Rehide() {
    global hidden
    if hidden {
        if WinExist("ahk_class Shell_TrayWnd")
            WinHide("ahk_class Shell_TrayWnd")
        if WinExist("ahk_class Shell_SecondaryTrayWnd")
            WinHide("ahk_class Shell_SecondaryTrayWnd")
    }
}
SetTimer(Rehide, 1000)

#!t:: {
    global hidden
    hidden := !hidden
    if !hidden
        WinShow("ahk_class Shell_TrayWnd")
}
