
Rem
bbdoc: Miscellaneous/ZLib compression
End Rem
Module Pub.ZLib

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Jean-loup Gailly, Mark Adler"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Modserver: BRL"
ModuleInfo "Credit: Adapted for BlitzMax by Mark Sibly"

ModuleInfo "History: 1.02"
ModuleInfo "History: Updated zlib to 1.2.3"

Import "adler32.c"
Import "compress.c"
Import "crc32.c"
Import "deflate.c"
Import "gzio.c"
Import "infback.c"
'Import "infcodes.c"
Import "inffast.c"
Import "inflate.c"
Import "inftrees.c"
'Import "infutil.c"
Import "trees.c"
Import "uncompr.c"
Import "zutil.c"

Extern

Rem
bbdoc: Compress a block of data at default compression level
end rem
Function compress( dest:Byte Ptr,dest_len Var,source:Byte Ptr,source_len )

Rem
bbdoc: Compress a block of data at specified compression level
end rem
Function compress2( dest:Byte Ptr,dest_len Var,source:Byte Ptr,source_len,level )

Rem
bbdoc: Uncompress a block of data
end rem
Function uncompress( dest:Byte Ptr,dest_len Var,source:Byte Ptr,source_len )

End Extern
