
Strict

Const SKIPEXES=1

Global bmx_dir$=RealPath( "../.." )

CopyReleaseFiles

End

Function BlitzMaxPath$()
	Return bmx_dir
End Function

Function Config$()
?Win32x86
	Return "win32_x86"
?Macosx86
	Return "macos_x86"
?Macosppc
	Return "macos_ppc"
?Linuxx86
	Return "linux_x86"
?
	Throw "ERROR!"
End Function

Function Sys( t$ )
	Local i=t.find( " " )
	If i=-1 i=t.length
	Local cmd$=t[..i]
	If cmd="bmk" Or cmd=".bmk" 
		cmd=BlitzMaxPath()+"/bin/"+cmd
?Win32
		cmd:+".exe"
?
	EndIf
	t="~q"+cmd+"~q"+t[i..]
	Print "Sys:"+t
	Local r=system_( t )
	If r Print "***** Return code: "+r
End Function

Function BackupBmk()
	Local src$,dst$
?Win32
	src=BlitzMaxPath()+"/bin/bmk.exe"
	dst=BlitzMaxPath()+"/bin/.bmk.exe"
?Not Win32
	src=BlitzMaxPath()+"/bin/bmk"
	dst=BlitzMaxPath()+"/bin/.bmk"
?
	If FileType( dst )<>FILETYPE_NONE Return
?Win32
	CopyFile src,dst
?Not Win32	
	Sys "cp ~q"+src+"~q ~q"+dst+"~q"
?
End Function

Function Copy( path$,exts$[]=Null,flags=0 )

	If StripDir( path )="Thumbs.db" Return
	If StripDir( path ).StartsWith( "." ) Return
	
	Local ext$=ExtractExt( path )
	If ext="bak" Or ext="bat" Return
	
	If exts.length
		Local i
		For i=0 Until exts.length
			If ext=exts[i] Exit
		Next
		If i=exts.length Return
	EndIf

	Local src$=BlitzMaxPath()+"/"+path
	
	Select FileType( src )
	Case FILETYPE_DIR

		If flags & SKIPEXES
?MacOS
			If ext="app" Return
?
		EndIf

		Local dir$=path
		If FileType( dir )=FILETYPE_NONE CreateDir dir,True
		If FileType( dir )<>FILETYPE_DIR Return
		Print "Copying dir:"+path
		For Local file$=EachIn LoadDir( src )
			Copy path+"/"+file,exts,flags
		Next
	Case FILETYPE_FILE
		If flags & SKIPEXES
?Win32
			If ext="exe" Return
?Not Win32
			If FileMode( src ) & (64+8+1) Return
?		
		EndIf
		Local dir$=ExtractDir( path )
		If dir
			If FileType( dir )=FILETYPE_NONE CreateDir dir,True
			If FileType( dir )<>FILETYPE_DIR Return
		EndIf
?Win32
		CopyFile src,path
?Not Win32
		Sys "cp ~q"+src+"~q ~q"+path+"~q"
?
	End Select
End Function

Function SetDir( dir$ )
?Win32
	ChangeDir dir
?Not Win32
	Sys "cd ~q"+dir+"~q"
?
End Function

Function CopyDemoFiles()
	Local cd$=CurrentDir()
	Local dst$="BlitzMaxDemo"
	DeleteDir dst,True
	CreateDir dst
	ChangeDir dst
	
?Win32
	Copy "bin/bcc.exe"
	Copy "bin/bmk.exe"
	Copy "bin/ld.exe"
	Copy "bin/FASM.EXE"
	Copy "MaxIDE.exe"
?Macos
	Copy "bin/bcc"
	Copy "bin/bmk"
	Copy "MaxIDE.app"
?Macosx86
	Copy "bin/fasm2as"
?Linux
	Copy "bin/bcc"
	Copy "bin/bmk"
	Copy "bin/fasm"
	Copy "MaxIDE"
?
	Copy "lib"
	Copy "samples",Null,SKIPEXES
	Copy "docs/html"
	Copy "mod/brl.mod",["mod","i","a"]
	Copy "mod/pub.mod",["mod","i","a"]
	Copy "mod/maxgui.mod",["mod","i","a"]
?Win32
	Copy "mod/maxgui.mod/win32maxguiex.mod/xpmanifest.o"
?
	ChangeDir cd
End Function

Function CopyReleaseFiles()

	Local cd$=CurrentDir()
	Local dst$="BlitzMax"
	DeleteDir dst,true
	CreateDir dst
	ChangeDir dst
	
	Copy "bin"
	Copy "lib"
	Copy "samples",Null,SKIPEXES
	Copy "doc/bmxstyle.css"
	Copy "docs/src"
	Copy "src/bmk"
	Copy "src/docmods"
	Copy "src/fasm2as"
	Copy "src/makedocs"
	Copy "mod/brl.mod",Null,SKIPEXES
	Copy "mod/pub.mod",Null,SKIPEXES
	Copy "mod/maxgui.mod",Null,SKIPEXES
	
?Win32
	Copy "MaxIDE.exe"
?Macos
	Copy "MaxIDE.app"
?Linux
	Copy "MaxIDE"
?
	Copy "versions.txt"
End Function

Function Exec( cmd$ )
	Select cmd.ToLower()
	Case "rebuilddocs"
		Sys "makedocs"
	Case "updatemods"
		Sys "bmk makemods"
		Sys "bmk makemods -h"
	Case "rebuildmods"
		Sys "bmk makemods -a"
		Sys "bmk makemods -a -h"
	Case "updateide"
		Sys "bmk makeapp -r -t gui -o ~q"+BlitzMaxPath()+"/MaxIDE~q ~q"+BlitzMaxPath()+"/src/maxide/maxide~q"
?Macos
		Sys "cp ~q"+BlitzMaxPath()+"/src/maxide/Info.plist~q ~q"+BlitzMaxPath()+"/MaxIDE.app/Contents~q"
?
	Case "rebuildide"
		Sys "bmk makeapp -a -r -t gui -o ~q"+BlitzMaxPath()+"/MaxIDE~q ~q"+BlitzMaxPath()+"/src/maxide/maxide~q"
?Macos
		Sys "cp ~q"+BlitzMaxPath()+"/src/maxide/Info.plist~q ~q"+BlitzMaxPath()+"/MaxIDE.app/Contents~q"
?
	Case "updatebmk"
		BackupBmk
		Sys ".bmk makeapp -r -t console -o ~q"+BlitzMaxPath()+"/bin/bmk~q ~q"+BlitzMaxPath()+"/src/bmk/bmk~q"
	Case "rebuildbmk"
		BackupBmk
		Sys ".bmk makeapp -a -r -t console -o ~q"+BlitzMaxPath()+"/bin/bmk~q ~q"+BlitzMaxPath()+"/src/bmk/bmk~q"
	Case "updatetools"
		Sys "bmk makeapp -r -t console -o ~q"+BlitzMaxPath()+"/bin/docmods~q ~q"+BlitzMaxPath()+"/src/docmods/docmods~q"
		Sys "bmk makeapp -r -t console -o ~q"+BlitzMaxPath()+"/bin/makedocs~q ~q"+BlitzMaxPath()+"/src/makedocs/makedocs~q"
	Case "rebuildtools"
		Sys "bmk makeapp -a -r -t console -o ~q"+BlitzMaxPath()+"/bin/docmods~q ~q"+BlitzMaxPath()+"/src/docmods/docmods~q"
		Sys "bmk makeapp -a -r -t console -o ~q"+BlitzMaxPath()+"/bin/makedocs~q ~q"+BlitzMaxPath()+"/src/makedocs/makedocs~q"
	Case "updatebcc"
		Sys "bmk makeapp -r -z -t console -o ~q"+BlitzMaxPath()+"/bin/bcc~q ~q"+BlitzMaxPath()+"/_src/compiler/bcc.cpp~q"
	Case "rebuildbcc"
		Sys "bmk makeapp -a -r -z -t console -o ~q"+BlitzMaxPath()+"/bin/bcc~q ~q"+BlitzMaxPath()+"/_src/compiler/bcc.cpp~q"
	Case "updatebmx"
		Sys "svn update ~q"+BlitzMaxPath()+"~q"
		Sys "svn update ~q"+BlitzMaxPath()+"/bin~q"
		Exec "updatebcc"
		Exec "updatemods"
		Exec "updatebmk"
		Exec "updatetools"
		Exec "updateide"
	Case "rebuildbmx"
		Exec "rebuildbcc"
		Exec "rebuildmods"
		Exec "rebuildbmk"
		Exec "rebuildtools"
		Exec "rebuildide"
	Case "checkoutbmx"
		Sys "svn checkout svn://192.168.1.110/bmx_repos/blitzmax ~q"+BlitzMaxPath()+"~q"
		Sys "svn checkout svn://192.168.1.110/bmx_repos/"+Config()+"/bin ~q"+BlitzMaxPath()+"/bin~q"
		Sys "svn checkout svn://192.168.1.110/bmx_repos/"+Config()+"/lib ~q"+BlitzMaxPath()+"/lib~q"

		Sys "svn checkout https://maxgui.svn.sourceforge.net/svnroot/maxgui/skid/maxgui.mod ~q"+BlitzMaxPath()+"/mod/maxgui.mod~q"
		
'		Sys "svn checkout https://svn2.sliksvn.com/maxgui/trunk/maxgui.mod ~q"+BlitzMaxPath()+"/mod/maxgui.mod~q"
'		Sys "svn checkout https://svn2.sliksvn.com/maxgui/trunk/maxide ~q"+BlitzMaxPath()+"/src/maxide~q"

		Exec "rebuildbmx"
	Case "commitbmx"
		Sys "svn commit -m ~qlazy commit~q ~q"+BlitzMaxPath()+"~q"
		Sys "svn commit -m ~qlazy commit~q ~q"+BlitzMaxPath()+"/bin~q"
	Case "updatemaxgui"
		Sys "svn update ~q"+BlitzMaxPath()+"/mod/maxgui.mod~q"
		Sys "svn update ~q"+BlitzMaxpath()+"/src/maxide~q"
		Exec "updatemods"
		Exec "updateide"
	Case "createdemo"
		Local dir$="BlitzMaxDemo"
		Local cd$=CurrentDir()
		Exec "rebuilddocs"
		ChangeDir BlitzMaxPath()+"/_src/setup"
		DeleteDir dir,True
		CreateDir dir
		ChangeDir dir
?Win32
		Copy "bin/bcc.exe"
		Copy "bin/bmk.exe"
		Copy "bin/ld.exe"
		Copy "bin/FASM.EXE"
		Copy "MaxIDE.exe"
?Macos
		Copy "bin/bcc"
		Copy "bin/bmk"
		Copy "MaxIDE.app"
?Macosx86
		Copy "bin/fasm2as"
?Linux
		Copy "bin/bcc"
		Copy "bin/bmk"
		Copy "bin/fasm"
		Copy "MaxIDE"
?
		Copy "lib"
		Copy "samples",Null,SKIPEXES
		Copy "docs/html"
		Copy "mod/brl.mod",["mod","i","a"]
		Copy "mod/pub.mod",["mod","i","a"]
		Copy "mod/maxgui.mod",["mod","i","a"]
?Win32
		Copy "mod/maxgui.mod/win32maxguiex.mod/xpmanifest.o"
?
		ChangeDir cd
	Case "createrelease"
		Local dir$="BlitzMax"
		Local cd$=CurrentDir()
		ChangeDir BlitzMaxPath()+"/_src/setup"
		DeleteDir dir,True
		CreateDir dir
		ChangeDir dir
		
		Copy "bin"
		
		Copy "lib"
		
		Copy "samples",Null,SKIPEXES
		
		Copy "doc/bmxstyle.css"
		
		Copy "docs/src"
		
		Copy "src/bmk"
		Copy "src/docmods"
		Copy "src/fasm2as"
		Copy "src/makedocs"
		
		Copy "mod/brl.mod",Null,SKIPEXES
		Copy "mod/pub.mod",Null,SKIPEXES
		Copy "mod/maxgui.mod",Null,SKIPEXES
		
?Win32
		Copy "MaxIDE.exe"
?Macos
		Copy "MaxIDE.app"
?Linux
		Copy "MaxIDE"
?
		Copy "versions.txt"
		ChangeDir cd
	Case "createmaxgui"
		ChangeDir BlitzMaxPath()+"/_src/setup"
		DeleteDir "mod",True
		Copy "mod/maxgui.mod"
		CopyDir "mod/maxgui.mod","maxgui.mod"
		DeleteDir "mod",True
	Default
		Print "Unrecognized cmd: "+cmd
	End Select
End Function

If AppArgs.length>1
	For Local i=1 Until AppArgs.length
		Exec AppArgs[i]
	Next
Else
	Repeat
		Local cmd$=Input( "BMX:" )
		If Not cmd Exit
		Exec cmd
	Forever
EndIf
