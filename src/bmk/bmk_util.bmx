
Strict

Import "bmk_config.bmx"

'OS X Nasm doesn't work? Used to produce incorrect reloc offsets - haven't checked for a while 
Const USE_NASM=False

Const CC_WARNINGS=False'True

Type TModOpt ' BaH
	Field cc_opts:String = ""
	Field ld_opts:TList = New TList
	
	Method addOption(qval:String)
		If qval.startswith("CC_OPTS") Then
			cc_opts:+ " " + qval[qval.find(":") + 1..].Trim()
		ElseIf qval.startswith("LD_OPTS") Then
			Local opt:String = qval[qval.find(":") + 1..].Trim()
			
			If opt.startsWith("-L") Then
				opt = "-L" + CQuote(opt[2..])
			End If
			
			ld_opts.addLast opt
		End If
	End Method
	
	Method hasCCopt:Int(value:String)
		Return cc_opts.find(value) >= 0
	End Method

	Method hasLDopt:Int(value:String)
		For Local opt:String = EachIn ld_opts
			If opt.find(value) >= 0 Then
				Return True
			End If
		Next
		Return False
	End Method

	Function setPath:String(value:String, path:String)
		Return value.Replace("%PWD%", path)
	End Function
	
End Type

Global mod_opts:TModOpt ' BaH

Function Match( ext$,pat$ )
	Return (";"+pat+";").Find( ";"+ext+";" )<>-1
End Function

Function HTTPEsc$( t$ )
	t=t.Replace( " ","%20" )
	Return t
End Function

Function Sys( cmd$ )
	If opt_verbose
		Print cmd
	Else If opt_dumpbuild
		Local p$=cmd
		p=p.Replace( BlitzMaxPath()+"/","./" )
		WriteStdout p+"~n"
		Local t$="mkdir "
		If cmd.StartsWith( t ) And FileType( cmd[t.length..] ) Return
	EndIf
	Return system_( cmd )
End Function

Function CQuote$( t$ )
	If t And t[0]=Asc("-") Return t
	For Local i=0 Until t.length
		If t[i]=Asc(".") Continue
		If t[i]=Asc("/") Continue
?Win32
		If t[i]=Asc("\") Continue
?
		If t[i]=Asc("_") Or t[i]=Asc("-") Continue
		If t[i]>=Asc("0") And t[i]<=Asc("9") Continue
		If t[i]>=Asc("A") And t[i]<=Asc("Z") Continue
		If t[i]>=Asc("a") And t[i]<=Asc("z") Continue
		Return "~q"+t+"~q"
	Next
	Return t
End Function

Function Ranlib( dir$ )
	'
?MacOS
	If macos_version>=$1040 Return
?
	'
	For Local f$=EachIn LoadDir( dir )
		Local p$=dir+"/"+f
		Select FileType( p )
		Case FILETYPE_DIR
			Ranlib p
		Case FILETYPE_FILE
			If ExtractExt(f).ToLower()="a" Sys "ranlib "+p
		End Select
	Next
End Function

Function Assemble( src$,obj$ )
	DeleteFile obj
	Local cmd$
?MacOS
	If opt_arch="ppc" 
		cmd="as -arch ppc"
	Else
		If USE_NASM
			cmd="nasm -f macho"
		Else
			cmd="as -arch i386"
			cmd:+" -mmacosx-version-min=10.6"
		EndIf
	EndIf
	cmd:+" -W -o "+CQuote(obj)+" "+CQuote(src);
?Win32
	cmd$=CQuote(BlitzMaxPath()+"/bin/fasm")+" "+CQuote(src)+" "+CQuote(obj)
?Linux
	Local opts$=getenv_( "BMK_FASM_OPTS" )
	If opts="" opts="-m1048560"
	cmd$=CQuote(BlitzMaxPath()+"/bin/fasm")+" "+opts+" "+CQuote(src)+" "+CQuote(obj)
?
	If Sys( cmd )
		Throw "Build Error: Failed to assemble "+src
	EndIf
End Function

Function CompileC( src$,obj$,opts$ )
	DeleteFile obj

	Local t$=getenv_( "BMK_CC_OPTS" )
	If t opts:+" "+t

	Local cmd$="gcc"
	If ExtractExt(src)="cpp" Or ExtractExt(src)="cc" Or ExtractExt(src)="cxx" Or ExtractExt(src)="mm"
		cmd="g++"
	Else
		If CC_WARNINGS opts:+" -Wimplicit-function-declaration"
	EndIf

	If Not CC_WARNINGS opts:+" -w"

?MacOS
	If opt_arch="ppc" 
		opts:+" -arch ppc"
	Else
		opts:+" -arch i386"
	EndIf

	opts:+" -mmacosx-version-min=10.6"		'build for Snow Leopard++

'	If macos_version>=$1070					'Lion?
'		opts:+" -mmacosx-version-min=10.4"	'...can build for Tiger++
'	Else If macos_version>=$1040			'Tiger?
'		opts:+" -mmacosx-version-min=10.3"	'...can build for Panther++
'	EndIf

?Win32
	If Not mod_opts Or Not mod_opts.hasCCopt("-march")
		opts:+" -march=pentium"
	EndIf
	opts:+" -ffast-math"
?Linux
	opts:+" -m32 -mfancy-math-387 -fno-strict-aliasing"
?
	If mod_opts
		If Not mod_opts.hasCCopt("-fexceptions")
			opts:+" -fno-exceptions"
		EndIf
		opts:+ " " + mod_opts.cc_opts ' BaH
	Else
		opts:+" -fno-exceptions"
	EndIf

	cmd:+opts+" -c -o "+CQuote(obj)+" "+CQuote(src)

	If Sys( cmd )
		Throw "Build Error: failed to compile "+src
	EndIf
End Function

Function CompileBMX( src$,obj$,opts$ )
	DeleteFile obj

	Local azm$=StripExt(obj)+".s"
?MacOs
	Local cmd$=CQuote(BlitzMaxPath()+"/bin/bcc")+opts+" -o "+CQuote(azm)+" "+CQuote(src)
?Win32
	Local cmd$=CQuote(BlitzMaxPath()+"/bin/bcc")+opts+" -o "+CQuote(azm)+" "+CQuote(src)
?Linux	
	Local cmd$=CQuote(BlitzMaxPath()+"/bin/bcc")+opts+" -o "+CQuote(azm)+" "+CQuote(src)
?
	If Sys( cmd )
		Throw "Build Error: failed to compile "+src
	EndIf
?MacOs
	If opt_arch="x86"
		If Not USE_NASM
			Local cmd$=CQuote(BlitzMaxPath()+"/bin/fasm2as")+" "+CQuote(azm)
			If Sys( cmd ) Throw "Fasm2as failed - please contact BRL!"
		EndIf
	EndIf
?
	Assemble azm,obj

End Function

Function CreateArc( path$ , oobjs:TList )
	DeleteFile path
	Local cmd$,t$
?Win32
	For t$=EachIn oobjs
		If Len(cmd)+Len(t)>1000
			If Sys( cmd )
				DeleteFile path
				Throw "Build Error: Failed to create archive "+path
			EndIf
			cmd=""
		EndIf
		If Not cmd cmd="ar -r "+CQuote(path)
		cmd:+" "+CQuote(t)
	Next
?MacOS
	cmd="libtool -o "+CQuote(path)
	For Local t$=EachIn oobjs
		cmd:+" "+CQuote(t)
	Next
?Linux
	For Local t$=EachIn oobjs
		If Len(cmd)+Len(t)>1000
			If Sys( cmd )
				DeleteFile path
				Throw "Build Error: Failed to create archive "+path
			EndIf
			cmd=""
		EndIf
		If Not cmd cmd="ar -r "+CQuote(path)
		cmd:+" "+CQuote(t)
	Next
?
	If cmd And Sys( cmd )
		DeleteFile path
		Throw "Build Error: Failed to create archive "+path
	EndIf
End Function

Function LinkApp( path$,lnk_files:TList,makelib )
	DeleteFile path

	Local cmd$
	Local files$
	Local tmpfile$=BlitzMaxPath()+"/tmp/ld.tmp"
?MacOS
	cmd="g++"
	
	If opt_arch="ppc" 
		cmd:+" -arch ppc" 
	Else
		cmd:+" -arch i386 -read_only_relocs suppress"
	EndIf
	
	cmd:+" -mmacosx-version-min=10.6"		'build for Snow Leopard++
	
'	If macos_version>=$1070					'Lion?
'		cmd:+" -mmacosx-version-min=10.4"	'...can build for Tiger++
'	Else If macos_version>=$1040			'Tiger?
'		cmd:+" -mmacosx-version-min=10.3"	'...can build for Panther++
'	EndIf

	cmd:+" -o "+CQuote( path )
	cmd:+" "+CQuote( "-L"+CQuote( BlitzMaxPath()+"/lib" ) )

	If Not opt_dumpbuild cmd:+" -filelist "+CQuote( tmpfile )
	
	For Local t$=EachIn lnk_files
		If opt_dumpbuild Or (t[..1]="-")
			cmd:+" "+t 
		Else
			files:+t+Chr(10)
		EndIf
	Next
	cmd:+" -lSystem -framework CoreServices -framework CoreFoundation"
?Win32
	cmd=CQuote(BlitzMaxPath()+"/bin/ld.exe")+" -s -stack 4194304"	'symbol stripping enabled
	If opt_apptype="gui" cmd:+" -subsystem windows"
	If makelib cmd:+" -shared"
	
	cmd:+" -o "+CQuote( path )
	cmd:+" "+CQuote( "-L"+CQuote( BlitzMaxPath()+"/lib" ) )

	If makelib
		Local imp$=StripExt(path)+".a"
		Local def$=StripExt(path)+".def"
		If FileType( def )<>FILETYPE_FILE Throw "Cannot locate .def file"
		cmd:+" "+def
		cmd:+" --out-implib "+imp
		files:+"~n"+CQuote( BlitzMaxPath()+"/lib/dllcrt2.o" )
	Else
		files:+"~n"+CQuote( BlitzMaxPath()+"/lib/crtbegin.o" )
		files:+"~n"+CQuote( BlitzMaxPath()+"/lib/crt2.o" )
	EndIf

	'Unholy!!!!!
	Local xpmanifest$
	For Local f$=EachIn lnk_files
		Local t$=CQuote( f )
		If opt_dumpbuild Or (t[..1]="-" And t[..2]<>"-l")
			cmd:+" "+t
		Else
			If f.EndsWith( "/win32maxguiex.mod/xpmanifest.o" )
				xpmanifest=t
			Else
				files:+"~n"+t
			EndIf
		EndIf
	Next

	If xpmanifest files:+"~n"+xpmanifest
	
	cmd:+" "+CQuote( tmpfile )

	files:+"~n-lgdi32 -lwsock32 -lwinmm -ladvapi32"
	files:+" -lstdc++ -lgcc -lmingwex -lmingw32 -lmoldname -lmsvcrt -luser32 -lkernel32"
	
	If Not makelib
		files:+" "+CQuote( BlitzMaxPath()+"/lib/crtend.o" )
	EndIf
	
	files="INPUT("+files+")"
?Linux

	cmd="g++"
	cmd:+" -m32 -s -Os -pthread"
	cmd:+" -o "+CQuote( path )
	cmd:+" "+CQuote( tmpfile )
	cmd:+" -Wl,-rpath='$ORIGIN'"
	cmd:+" -L/usr/lib32"
	cmd:+" -L/usr/X11R6/lib"
	cmd:+" -L/usr/lib"
	cmd:+" -L"+CQuote( BlitzMaxPath()+"/lib" )

	For Local t$=EachIn lnk_files
		t=CQuote(t)
		If opt_dumpbuild Or (t[..1]="-" And t[..2]<>"-l")
			cmd:+" "+t
		Else
			files:+" "+t
		EndIf
	Next

	files="INPUT("+files+")"
?
	Local t$=getenv_( "BMK_LD_OPTS" )
	If t 
		cmd:+" "+t
	EndIf

	Local stream:TStream=WriteStream( tmpfile )
	stream.WriteBytes files.ToCString(),files.length
	stream.Close
	
	If Sys( cmd ) Throw "Build Error: Failed to link "+path

End Function
