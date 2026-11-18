; Installer Windows pentru TraderNote (Inno Setup 6): https://jrsoftware.org/isinfo.php
; Construire:  python build_exe.py   apoi   iscc installer.iss
#define AppName "TraderNote"
#define AppVersion "5.0.0"

[Setup]
AppId={{B3C7A8E2-5F5A-4D0E-9C57-7B2F6A1D4E10}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=TraderNote
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\TraderNote.exe
SetupIconFile=assets\icon.ico
OutputDir=dist\installer
OutputBaseFilename=TraderNote-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
Name: "autostart"; Description: "Start TraderNote when I sign in to Windows (hidden in the tray, keeps alerts running)"; Flags: unchecked

[Files]
Source: "dist\TraderNote\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\TraderNote.exe"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\TraderNote.exe"; Tasks: desktopicon

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "TraderNote"; \
    ValueData: """{app}\TraderNote.exe"" --background"; Flags: uninsdeletevalue; Tasks: autostart

[Run]
Filename: "{app}\TraderNote.exe"; Description: "Launch TraderNote"; Flags: nowait postinstall skipifsilent

; Datele utilizatorului (%APPDATA%\TraderNote) NU se șterg la dezinstalare.
