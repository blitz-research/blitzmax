
Strict

Import BRL.MaxUtil

Import Pub.MacOS

Const ALL_SRC_EXTS$="bmx;i;c;m;cpp;cxx;cc;mm;h;hpp;hxx;hh;s;asm"

Global opt_arch$
Global opt_server$
Global opt_outfile$
Global opt_framework$
Global opt_apptype$="console"
Global opt_debug=False
Global opt_threaded=False
Global opt_release=False
Global opt_configmung$=""
Global opt_kill=False
Global opt_username$="nobody"
Global opt_password$="anonymous"
Global opt_modfilter$="."
Global opt_all=False
Global opt_quiet=False
Global opt_verbose=False
Global opt_execute=False
Global opt_proxy$
Global opt_proxyport
Global opt_traceheaders
Global opt_appstub$="brl.appstub" ' BaH 28/9/2007

Global opt_dumpbuild

Global cfg_platform$

?MacOS

cfg_platform="macos"
Global macos_version
Gestalt Asc("s")Shl 24|Asc("y")Shl 16|Asc("s")Shl 8|Asc("v"),macos_version

?MacOsPPC
If is_pid_native(0) opt_arch="ppc" Else opt_arch="x86"

?MacOsX86
If is_pid_native(0) opt_arch="x86" Else opt_arch="ppc"

?Win32

opt_arch="x86"
cfg_platform="win32"

'Fudge PATH so exec sees our MinGW first!
Local mingw$=getenv_( "MINGW" )
If mingw
	Local path$=getenv_( "PATH" )
	If path
		path=mingw+"\bin;"+path
		putenv_ "PATH="+path
	EndIf
EndIf

?Linux

opt_arch="x86"
cfg_platform="linux"

?

ChangeDir LaunchDir

Function CmdError()
	Throw "Command line error"
End Function

Function ParseConfigArgs$[]( args$[] )

	Local n
	
	If getenv_( "BMKDUMPBUILD" )
		opt_dumpbuild=1
		opt_quiet=True
	EndIf
	
	For n=0 Until args.length
		Local arg$=args[n]
		If arg[..1]<>"-" Exit
		Select arg[1..]
		Case "a"
			opt_all=True
		Case "q"
			opt_quiet=True
		Case "v"
			opt_verbose=True
		Case "x"
			opt_execute=True
		Case "d"
			opt_debug=True
			opt_release=False
		Case "r"
			opt_debug=False
			opt_release=True
		Case "h"
			opt_threaded=True
		Case "k"
			opt_kill=True
		Case "z"
			opt_traceheaders=True
		Case "y"
			n:+1
			If n=args.length CmdError
			opt_proxy=args[n]
			Local i=opt_proxy.Find(":")
			If i<>-1
				opt_proxyport=Int( opt_proxy[i+1..] )
				opt_proxy=opt_proxy[..i]
			EndIf
		Case "g"
			n:+1
			If n=args.length CmdError
			opt_arch=args[n].ToLower()
		Case "t"
			n:+1
			If n=args.length CmdError
			opt_apptype=args[n].ToLower()
		Case "o"
			n:+1
			If n=args.length CmdError
			opt_outfile=args[n]
		Case "f"
			n:+1
			If n=args.length CmdError
			opt_framework=args[n]
		Case "s"
			n:+1
			If n=args.length CmdError
			opt_server=args[n]
		Case "u"
			n:+1
			If n=args.length CmdError
			opt_username=args[n]
		Case "p"
			n:+1
			If n=args.length CmdError
			opt_password=args[n]
		Case "b"
			n:+1
			If n=args.length CmdError
			opt_appstub=args[n]
		Default
			CmdError
		End Select
	Next
	
	Return args[n..]

End Function


