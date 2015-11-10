Name "Deus ex Machina"
OutFile "dm351.exe"
Icon "dm-16.ico"
WindowIcon on
SetDateSave on ; to have files restored to their orginal date
InstallDir "C:\Diskmags\DM"
InstallDirRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Deus ex Machina" ""
DirShow show ; (make this hide to not let the user change it)
DirText "If you install Machina into C:\Diskmags\DM, any older or newer Machina run from CD finds your preferences there and won't ask you again for language etc."
BGGradient

; Some default compiler settings (uncomment and change at will):
; SetCompress auto ; (can be off or force)
; SetDatablockOptimize on ; (can be off)
; CRCCheck on ; (can be off)
; AutoCloseWindow false ; (can be true for the window go away automatically at end)
; ShowInstDetails hide ; (can be show to have them shown, or nevershow to disable)

Function .onInit
 ; do $0 da doporucenej instaldir
 ReadEnvStr $0 DM
 StrCmp $0 "" label_defaultdir
 StrCpy $INSTDIR $0
 label_defaultdir:

 ; pokud uz je nainstalovanej, do inputlajny da onen dir
 ReadRegStr $1 HKEY_LOCAL_MACHINE "SOFTWARE\Deus ex Machina" ""
 StrCmp $1 "" label_notinstalled
; IfFileExists "$INSTDIR\dm.exe" label_installed label_notinstalled
; label_installed:
 StrCpy $INSTDIR $1
; GetFileTimeLocal "dm.exe" $r0 $r1 ; to co muzu instalovat
; GetFileTime "$INSTDIR\dm.exe" $r2 $r3 ; to co tam uz je
; IntCmpU $r0 $r2 label_chk2 label_
; je tam novejsi -> doporucit neinstalovat
; je tam starsi -> doporucit prepsat
 MessageBox MB_OK|MB_ICONINFORMATION "Machina seems already installed in $1.$\nYou can overwrite it or install elsewhere."
 label_notinstalled:
FunctionEnd

Section "" ; (default section)
 SetOutPath "$INSTDIR"
 File readme.txt
 File dm.dm
 File dm.exe
 File dm.com
 File rain.exe
 File rain.le
 File _dm.pif
 File _editor.pif
 File _console.pif
 File rtm.exe
 File dpmi16bi.ovl
 File dos4gw.exe
 CreateShortCut "$INSTDIR\DM.pif" "$INSTDIR\_dm.pif" "" $INSTDIR\rain.exe 1
 CreateShortCut "$INSTDIR\Editor.pif" "$INSTDIR\_editor.pif" "e" $INSTDIR\rain.exe 2
 CreateShortCut "$INSTDIR\Console.pif" "$INSTDIR\_console.pif" "" $INSTDIR\rain.exe 3
 CreateDirectory "$SMPROGRAMS\Deus ex Machina"
 CreateShortCut "$SMPROGRAMS\Deus ex Machina\Deus ex Machina.pif" "$INSTDIR\DM.pif"
 CreateShortCut "$SMPROGRAMS\Deus ex Machina\Editor.pif" "$INSTDIR\Editor.pif"
 CreateShortCut "$SMPROGRAMS\Deus ex Machina\Console.pif" "$INSTDIR\Console.pif"
 Delete "$INSTDIR\_dm.pif"
 Delete "$INSTDIR\_editor.pif"
 Delete "$INSTDIR\_console.pif"
 ;CreateShortCut "$SMPROGRAMS\Deus ex Machina\Sound Setup.lnk" "$INSTDIR\rain.exe" "-c" $INSTDIR\rain.exe 4 ;dsound je buggy
 WriteRegStr HKEY_LOCAL_MACHINE "SOFTWARE\Deus ex Machina" "" "$INSTDIR"
 WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\Deus ex Machina" "DisplayName" "Deus ex Machina (remove only)"
 WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\Deus ex Machina" "UninstallString" '"$INSTDIR\uninst.exe"'
 WriteUninstaller "$INSTDIR\uninst.exe"
 CreateShortCut "$SMPROGRAMS\Deus ex Machina\Uninstall.lnk" "$INSTDIR\uninst.exe"
 Exec '$WINDIR\EXPLORER.EXE "$SMPROGRAMS\Deus ex Machina"'
SectionEnd ; end of default section


; begin uninstall settings/section
UninstallText "This will uninstall Deus ex Machina from your system"

Section Uninstall
 DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Deus ex Machina"
 DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Deus ex Machina"
 Delete /REBOOTOK "$SMPROGRAMS\Deus ex Machina\Deus ex Machina.pif"
 Delete /REBOOTOK "$SMPROGRAMS\Deus ex Machina\Editor.pif"
 Delete /REBOOTOK "$SMPROGRAMS\Deus ex Machina\Console.pif"
 ;Delete /REBOOTOK "$SMPROGRAMS\Deus ex Machina\Sound Setup.lnk"
 Delete /REBOOTOK "$SMPROGRAMS\Deus ex Machina\Uninstall.lnk"
 RMDir "$SMPROGRAMS\Deus ex Machina"
 Delete /REBOOTOK "$INSTDIR\DM.pif"
 Delete /REBOOTOK "$INSTDIR\Editor.pif"
 Delete /REBOOTOK "$INSTDIR\Console.pif"
 Delete /REBOOTOK "$INSTDIR\readme.txt"
 Delete /REBOOTOK "$INSTDIR\dm.dm"
 Delete /REBOOTOK "$INSTDIR\dm.exe"
 Delete /REBOOTOK "$INSTDIR\dm.com"
 Delete /REBOOTOK "$INSTDIR\rain.exe"
 Delete /REBOOTOK "$INSTDIR\rain.le"
 Delete /REBOOTOK "$INSTDIR\rtm.exe"
 Delete /REBOOTOK "$INSTDIR\dpmi16bi.ovl"
 Delete /REBOOTOK "$INSTDIR\dos4gw.exe"
 Delete /REBOOTOK "$INSTDIR\uninst.exe"
 ClearErrors
 RMDir "$INSTDIR"
 IfErrors label_filesleft label_done
label_filesleft:
 MessageBox MB_YESNO|MB_ICONQUESTION "Configuration files and possibly files you created in editor left. Remove all?" IDNO label_done
 RMDir /r "$INSTDIR"
label_done:
SectionEnd ; end of uninstall section
