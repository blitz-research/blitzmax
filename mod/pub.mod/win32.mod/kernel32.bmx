
Extern "Win32"

Const FILE_ATTRIBUTE_READONLY=		$0001
Const FILE_ATTRIBUTE_HIDDEN=		$0002
Const FILE_ATTRIBUTE_SYSTEM=		$0004
Const FILE_ATTRIBUTE_DIRECTORY=		$0010
Const FILE_ATTRIBUTE_ARCHIVE=		$0020
Const FILE_ATTRIBUTE_DEVICE=		$0040
Const FILE_ATTRIBUTE_NORMAL=		$0080
Const FILE_ATTRIBUTE_TEMPORARY=		$0100
Const FILE_ATTRIBUTE_SPARSE_FILE=	$0200
Const FILE_ATTRIBUTE_REPARSE_POINT=	$0400
Const FILE_ATTRIBUTE_COMPRESSED=	$0800
Const FILE_ATTRIBUTE_OFFLINE=		$1000
Const FILE_ATTRIBUTE_NOT_CONTENT_INDEXED=$2000
Const FILE_ATTRIBUTE_ENCRYPTED=		$4000
Const FILE_ATTRIBUTE_VALID_FLAGS=	$7fb7
Const FILE_ATTRIBUTE_VALID_SET_FLAGS=$31a7

Const GMEM_FIXED=0
Const GMEM_MOVEABLE=2
Const GMEM_ZEROINT=$40

Function Sleep( dwMilliseconds )
Function Beep( dwFreq,dwDuration )
Function GetModuleHandleA( lpModuleName:Byte Ptr  )
Function GetModuleHandleW( lpModuleName:Short Ptr )
Function SetFileAttributesA( lpFileName$z,dwFileAttributes )
Function SetFileAttributesW( lpFileName$z,dwFileAttributes )
Function GetFileAttributesA( lpFileName$z )
Function GetFileAttributesW( lpFileName$z )

Function GetCurrentThreadId()

Function GlobalAlloc(uFlags,dwBytes)
Function GlobalSize(hMem)
Function GlobalFree(hMem)
Function GlobalLock:Byte Ptr(hMem)
Function GlobalUnlock(hMem)

Const STD_INPUT_HANDLE=-10
Const STD_OUTPUT_HANDLE=-11
Const STD_ERROR_HANDLE=-12

Function GetStdHandle(nStdHandle)

End Extern
