
[Setup]
AppName=BlitzMax
AppVerName=BlitzMax1.50
DefaultGroupName=BlitzMax
DefaultDirName={sd}\BlitzMax
OutputBaseFileName="BlitzMax150_win32x86"

SourceDir="BlitzMax"
OutputDir=".."
SolidCompression=yes
ChangesAssociations=yes

UsePreviousAppDir=no
UsePreviousGroup=no

;InfoBeforeFile=../installinfo.txt

[Files]
Source: "*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\MaxIDE"; Filename: "{app}\MaxIDE.exe"
Name: "{group}\Uninstall BlitzMax"; Filename: "{uninstallexe}"

[Registry]
Root: HKCR; Subkey: ".bmx"; ValueType: string; ValueName: ""; ValueData: "MaxIDE"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "MaxIDE"; ValueType: string; ValueName: ""; ValueData: "BlitzMax IDE"; Flags: uninsdeletekey
Root: HKCR; Subkey: "MaxIDE\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\MaxIDE.exe,0"
Root: HKCR; Subkey: "MaxIDE\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\MaxIDE.exe"" ""%1"""

