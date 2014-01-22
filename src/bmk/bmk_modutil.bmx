
Strict

Import BRL.MaxUtil
Import BRL.TextStream

Import "bmk_util.bmx"

Type TSourceFile
	Field ext$		'one of: "bmx", "i", "c", "cpp", "m", "s", "h"
	Field path$
	Field modid$
	Field framewk$
	Field info:TList=New TList

	Field modimports:TList=New TList
	
	Field imports:TList=New TList
	Field includes:TList=New TList
	Field incbins:TList=New TList
	
	Field declids:TList=New TList
End Type

Function CharIsDigit( ch )
	Return ch>=Asc("0") And ch<=Asc("9")
End Function

Function CharIsAlpha( ch )
	Return ch=Asc("_") Or (ch>=Asc("a") And ch<=Asc("z")) Or (ch>=Asc("A") And ch<=Asc("Z"))
End Function

Function ValidSourceExt( ext$ )
	Select ext.ToLower()
	Case "bmx","i"
	Case "c","m","h"
	Case "cpp","cxx","mm","hpp","hxx"
	Case "s","asm"
	Default
		Return False
	End Select
	Return True
End Function

Function ParseSourceFile:TSourceFile( path$ )

	If FileType(path)<>FILETYPE_FILE Return

	Local ext$=ExtractExt( path ).ToLower()
	If Not ValidSourceExt( ext ) Return

	Local file:TSourceFile=New TSourceFile
	file.ext=ext
	file.path=path
	
	Local str$=LoadText( path )

	Local pos,in_rem,cc=True

	While pos<Len(str)

		Local eol=str.Find( "~n",pos )
		If eol=-1 eol=Len(str)

		Local line$=str[pos..eol].Trim()
		pos=eol+1

		Select ext
		Case "bmx","i"

			Local n=line.Find( "'" )
			If n<>-1 line=line[..n]
			
			If Not line Continue

			Local lline$=line.Tolower()

			If in_rem
				If lline[..6]="endrem" Or lline[..7]="end rem" 
					in_rem=False
				EndIf
				Continue
			Else If lline[..3]="rem"
				in_rem=True
				Continue
			EndIf

			If lline[..1]="?"
				Local t$=lline[1..].Trim()
				
				Local cNot
				If t.StartsWith( "not " )
					cNot=True
					t=t[4..].Trim()
				EndIf

				Select t
				Case ""
					cc=True
				Case "debug"
					cc=opt_debug
				Case "threaded"
					cc=opt_threaded
?x86
				Case "x86" cc=opt_arch="x86"
?ppc
				Case "ppc" cc=opt_arch="ppc"
?
?Win32
				Case "win32" cc=True
				Case "win32x86" cc=opt_arch="x86"
				Case "win32ppc" cc=opt_arch="ppc"
?Linux
				Case "linux" cc=True
				Case "linuxx86" cc=opt_arch="x86"
				Case "linuxppc" cc=opt_arch="ppc"
?MacOS
				Case "macos" cc=True
				Case "macosx86" cc=opt_arch="x86"
				Case "macosppc" cc=opt_arch="ppc"
?
				Default
					cc=False
				End Select
				If cNot cc=Not cc
				Continue
			EndIf

			If Not cc Continue

			If Not CharIsAlpha( lline[0] ) Continue

			Local i=1
			While i<lline.length And (CharIsAlpha(lline[i]) Or CharIsDigit(lline[i]))
				i:+1
			Wend
			If i=lline.length Continue
			
			Local key$=lline[..i]
			
			Local val$=line[i..].Trim(),qval$,qext$
			If val.length>1 And val[0]=34 And val[val.length-1]=34
				qval=val[1..val.length-1]
			EndIf

			Select key
			Case "module"
				file.modid=val.ToLower()
			Case "framework"
				file.framewk=val.ToLower()
			Case "import"
				If qval
					file.imports.AddLast qval
				Else
					file.modimports.AddLast val.ToLower()
				EndIf
			Case "incbin"
				If qval
					file.incbins.AddLast qval
				EndIf
			Case "include"
				If qval
					file.includes.AddLast qval
				EndIf
			Case "moduleinfo"
				If qval
					file.info.AddLast qval
					If mod_opts mod_opts.addOption(qval) ' BaH
				EndIf
			End Select
		Case "c","m","h","cpp","cxx","hpp","hxx"
			If line[..8]="#include"
				Local val$=line[8..].Trim(),qval$,qext$
				If val.length>1 And val[0]=34 And val[val.length-1]=34
					qval=val[1..val.length-1]
				EndIf
				If qval
					file.includes.AddLast qval
				EndIf
			EndIf
		End Select

	Wend
	
	Return file

End Function
