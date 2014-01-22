
Strict

Module Pub.MacOS

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "ModServer: BRL"

ModuleInfo "History: 1.01 Release"

?MacOS
Import "macos.m"

Extern

Function is_pid_native( pid )
Function Gestalt( tag,result Var )
Function bbStringFromNSString$( ns_string )
Function NSStringFromBBString( bb_string$ )

End Extern
?






