
Strict

NoDebug

Module BRL.AppStub

ModuleInfo "Version: 1.20"
ModuleInfo "Authors: Mark Sibly, Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.20 Release"
ModuleInfo "History: Fixed 'invalid typetag' issue"
ModuleInfo "History: 1.19 Release"
ModuleInfo "History: Removed some debug output"
ModuleInfo "History: 1.18 Release"
ModuleInfo "History: Changed debugger.stdio.bmx so it handles deep stacks better"
ModuleInfo "History: 1.17 Release"
ModuleInfo "History: Added Brucey's SIGPIPE fix for GTK"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: Added experimental dll support"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Fixed Const string reporting not being escaped"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Debug output lines now prepended with ~>"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Removed unused debugger sources"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Now manually builds app menu for MacOS Tiger"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Fixed MacOS debug string overflow"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Added kludge for MacOS Menu Quit generating errors"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Fixed MacOS AutoreleasePool problem"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Fixed Tiger build warnings in debugger.macos.m"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Improved Win32 debugger switching"
ModuleInfo "History: Fixed macos debugger dying with extern types"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Tweaked MacOS debugger"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed C Compiler warnings"
ModuleInfo "History: Fixed multidim arrays hanging debugger"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed buffer overflow in debug strings"
ModuleInfo "History: Modified float and double debug output to match compiler precision"

?Debug
'Import "debugger.stdio.bmx"
Import "debugger_mt.stdio.bmx"	'Let's give Otus's new MT friendly debugger a whirl!
?

?MacOS
Import "appstub.macos.m"
Import "-framework Cocoa"
Import "-framework Carbon"
?Win32
Import "appstub.win32.c"
?Linux
Import "appstub.linux.c"
?

Extern
Function _bb_main()
End Extern

_bb_main
