
[Setup]
AppName=BlitzMax Demo
AppVerName=BlitzMax Demo V1.37
DefaultGroupName=BlitzMax Demo
DefaultDirName={sd}\BlitzMaxDemo
OutputBaseFileName="BlitzMaxDemo137"

SourceDir="BlitzMaxDemo"
OutputDir="..\"
SolidCompression=yes

UsePreviousAppDir=no
UsePreviousGroup=no

[Files]
Source: "*"; DestDir: "{app}"; Flags: recursesubdirs;

[Icons]
Name: "{group}\MaxIDE"; Filename: "{app}\MaxIDE.exe"
Name: "{group}\Uninstall BlitzMax Demo"; Filename: "{uninstallexe}"

