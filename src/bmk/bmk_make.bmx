
Strict

Import "bmk_modutil.bmx"

Rem
Experimental speedup hack by Mark!

Should allow you to modify non-interface affecting code without triggering lots of recompiles.

Works by determining whether blah.bmx's .i file physically changes after blah.bmx is compiled.

If not, then anything importing blah.bmx may not need to be recompiled.

Uses a new '.i2' file which is updated only when actual .i file content changes.
End Rem
Global EXPERIMENTAL_SPEEDUP

Local t$=getenv_( "BMK_SPEEDUP" )
If t EXPERIMENTAL_SPEEDUP=True

Type TFile

	Field path$,time

	Function Create:TFile( path$,files:TList )
		Local f:TFile=New TFile
		f.path=path
		f.time=FileTime(path)
		If files files.AddFirst f
		Return f
	End Function

End Type

Global cc_opts$
Global bcc_opts$
Global app_main$
Global app_type$
Global src_files:TList
Global obj_files:TList
Global lnk_files:TList
Global tmp_stack:TList
Global ext_files:TList

Function Push( o:Object )
	tmp_stack.AddLast o
End Function

Function Pop:Object() 
	Return tmp_stack.RemoveLast()
End Function

Function FindFile:TFile( path$,files:TList )
	path=path.ToLower()
	Local f:TFile
	For f=EachIn files
		If f.path.ToLower()=path Return f
	Next
End Function

Function MaxTime( files:TList )
	Local f:TFile,t
	For f=EachIn files
		If f.time>t t=f.time
	Next
	Return t
End Function

Function FilePaths:TList( files:TList )
	Local f:TFile,p:TList=New TList
	For f=EachIn files
		p.AddLast f.path
	Next
	Return p
End Function

Function AddList( src:TList,dst:TList )
	Local t:Object
	For t=EachIn src
		dst.AddLast t
	Next
End Function

Function BeginMake()
	cc_opts=Null
	bcc_opts=Null
	app_main=Null
	src_files=New TList
	obj_files=New TList
	lnk_files=New TList
	tmp_stack=New TList
	ext_files=New TList
End Function

'returns mod interface file
Function MakeMod:TFile( mod_name$ )

	Local path$=ModulePath(mod_name)
	Local id$=ModuleIdent(mod_name)
	Local src_path$=path+"/"+id+".bmx"
	Local arc_path$=path+"/"+id+opt_configmung+".a"
	Local iface_path$=path+"/"+id+opt_configmung+".i"
	
	mod_opts = New TModOpt ' BaH
	
	Local iface:TFile=FindFile( iface_path,src_files )
	If iface Return iface

	Assert Not FindFile( arc_path,lnk_files )

	Local arc:TFile=TFile.Create( arc_path,Null )

	If (mod_name+".").Find(opt_modfilter)=0 And FileType(src_path)=FILETYPE_FILE

		Push cc_opts
		Push bcc_opts
		Push obj_files

		cc_opts=""
		cc_opts:+" -I"+CQuote(path)
		cc_opts:+" -I"+CQuote(ModulePath(""))

		If opt_release cc_opts:+" -O3 -fno-tree-vrp -DNDEBUG"
'		If opt_release cc_opts:+" -O2 -DNDEBUG"
		If opt_threaded cc_opts:+" -DTHREADED"

		bcc_opts=" -g "+opt_arch
		bcc_opts:+" -m "+mod_name$

		If opt_quiet bcc_opts:+" -q"
		If opt_verbose bcc_opts:+" -v"
		If opt_release bcc_opts:+" -r"
		If opt_threaded bcc_opts:+" -h"

		obj_files=New TList
		
		MakeSrc src_path,True

		If MaxTime( obj_files )>arc.time Or opt_all
			If Not opt_quiet Print "Archiving:"+StripDir(arc_path)
			CreateArc arc_path,FilePaths( obj_files )
			arc.time=FileTime(arc_path)
		EndIf

		obj_files=TList(Pop())
		bcc_opts=String(Pop())
		cc_opts=String(Pop())
	EndIf

	Local src:TFile=MakeSrc( iface_path,False )

	lnk_files.AddFirst arc

	Return src

End Function

'adds to obj_files
'returns input src file
Function MakeSrc:TFile( src_path$,buildit )

	Local src:TFile=FindFile( src_path,src_files )
	If src Return src

	If FileType( src_path )<>FILETYPE_FILE Return

	src=TFile.Create( src_path,src_files )

	Local src_file:TSourceFile=ParseSourceFile( src_path )
	If Not src_file Return
	
	Local main_file=(src_path=app_main)
	
	Local keep_opts:TModOpt = mod_opts ' BaH
	
	If main_file
		If src_file.framewk
			If opt_framework Throw "Framework already specified on commandline"
			opt_framework=src_file.framewk
			bcc_opts:+" -f "+opt_framework
			MakeMod opt_framework
		Else
			If app_type="bmx"
				For Local t$=EachIn EnumModules()
					If t.Find("brl.")=0 Or t.Find("pub.")=0
						If t<>"brl.blitz" And t<>opt_appstub MakeMod t
					EndIf
				Next
			EndIf
		EndIf
	Else If src_file.framewk
		Throw "Framework must appear in main source file"
	EndIf
	
	mod_opts = keep_opts ' BaH
	
	push cc_opts
	Push CurrentDir()
	
	ChangeDir ExtractDir( src_path )
	
	Local src_ext$=ExtractExt( src_path ).ToLower()
	
	If Match( src_ext,"bmx;i" )
		'incbins
		For Local inc$=EachIn src_file.incbins
			Local time=FileTime( inc )
			If time>src.time src.time=time
		Next
		'includes
		For Local inc$=EachIn src_file.includes
			Local inc_ext$=ExtractExt(inc).ToLower()
			If Match(inc_ext,"bmx")
				Local dep:TFile=MakeSrc(RealPath(inc),False)
				If Not dep Continue
				If dep.time>src.time src.time=dep.time
			Else
				Throw "Unrecognized Include file type: "+inc
			EndIf
		Next

		'module imports
		For Local imp$=EachIn src_file.modimports
			Local dep:TFile=MakeMod(imp)
			If Not dep Continue
			cc_opts:+" -I"+CQuote(ExtractDir(dep.path))
			If dep.time>src.time src.time=dep.time
		Next

		mod_opts = keep_opts ' BaH

		For Local imp$=EachIn mod_opts.ld_opts ' BaH
			ext_files.AddLast TModOpt.setPath(imp, ExtractDir(src_path))
		Next

		'quoted imports
		For Local imp$=EachIn src_file.imports
			If imp[0]=Asc("-")
				ext_files.AddLast imp
				Continue
			EndIf
			Local imp_ext$=ExtractExt(imp).ToLower()
			If Match( imp_ext,"h;hpp;hxx;hh" )
				cc_opts:+" -I"+CQuote(RealPath(ExtractDir(imp)))
			Else If Match( imp_ext,"o;a;lib" )
				ext_files.AddLast RealPath(imp)
			Else If Match( imp_ext,ALL_SRC_EXTS )

				Local dep:TFile=MakeSrc(RealPath(imp),True)

				If Not dep Or Not Match( imp_ext,"bmx;i" ) Continue
				
				If EXPERIMENTAL_SPEEDUP And Match( imp_ext,"bmx" )
					Local p$=ExtractDir( dep.path )+"/.bmx"
					Local i_path$=p+"/"+StripDir( dep.path )+opt_configmung+".i2"
					If FileType( i_path )=FILETYPE_FILE
						Local i_time=FileTime( i_path )
						If i_time>src.time src.time=i_time
					Else
						If dep.time>src.time src.time=dep.time
					EndIf
				Else
					If dep.time>src.time src.time=dep.time
				EndIf
				
			Else
				Throw "Unrecognized Import file type: "+imp
			EndIf
		Next
	Else If Match( src_ext,"c;m;cpp;cxx;cc;mm;h;hpp;hxx;hh" )
		For Local inc$=EachIn src_file.includes
			Local inc_ext$=ExtractExt(inc).ToLower()
			If Not Match(inc_ext,"h;hpp;hxx;hh")
				Continue
			EndIf
			Local path$=RealPath(inc)
			Local dep:TFile=MakeSrc(path,False)
			If dep And dep.time>src.time src.time=dep.time
			If Not opt_traceheaders Continue
			Local src$=StripExt(path)+".cpp"
			If FileType(src)<>FILETYPE_FILE
				src=""
			EndIf
			If Not src Continue
			MakeSrc src,True
		Next
	EndIf
	
	If buildit And Match( src_ext,"bmx;c;m;cpp;cxx;cc;mm;s;asm" )
	
		Local p$=ExtractDir( src_path )+"/.bmx"
		
		If opt_dumpbuild Or FileType( p )=FILETYPE_NONE
			CreateDir p
			'Sys "mkdir "+p   'Windows no likey...
		EndIf
		
		If FileType( p )<>FILETYPE_DIR Throw "Unable to create temporary directory"

		Local obj_path$=p+"/"+StripDir( src_path )
		If main_file obj_path:+"."+opt_apptype
		obj_path:+opt_configmung+".o"

		If src.time>FileTime( obj_path ) Or opt_all

			If Not opt_quiet Print "Compiling:"+StripDir(src_path)
			Select src_ext
			Case "bmx"
				Local opts$=bcc_opts
				If main_file opts=" -t "+opt_apptype+opts
			
				CompileBMX src_path,obj_path,opts
						
				If EXPERIMENTAL_SPEEDUP
					Local i_path$=StripExt( obj_path )+".i"

					If FileType( i_path )=FILETYPE_FILE
				
						Local i_path2$=i_path+"2",update=True

						If Not opt_all And FileType( i_path2 )=FILETYPE_FILE And src.time=FileTime( src.path )
							If FileSize( i_path )=FileSize( i_path2 )
								Local i_bytes:Byte[]=LoadByteArray( i_path )
								Local i_bytes2:Byte[]=LoadByteArray( i_path2 )
								If i_bytes.length=i_bytes2.length And memcmp_( i_bytes,i_bytes2,i_bytes.length )=0
									update=False
								EndIf
							EndIf
						EndIf
						If update CopyFile i_path,i_path2
					EndIf
				EndIf

			Case "c","m","cpp","cxx","cc","mm"
				CompileC src_path,obj_path,cc_opts
			Case "s","asm"
				Assemble src_path,obj_path
			End Select
		EndIf
		Local obj:TFile=TFile.Create( obj_path,obj_files )
		lnk_files.AddFirst obj
	EndIf

	ChangeDir String(Pop())
	cc_opts=String(Pop())
	
	Return src
	
End Function

Function MakeApp:TFile( Main$,makelib )

	app_main=Main
	
	cc_opts=""
	cc_opts:+" -I"+CQuote(ModulePath(""))
	
	If opt_release cc_opts:+" -O3 -fno-tree-vrp -DNDEBUG"
'	If opt_release cc_opts:+" -O2 -DNDEBUG"
	If opt_threaded cc_opts:+" -DTHREADED"

	bcc_opts=" -g "+opt_arch

	If opt_quiet bcc_opts:+" -q"
	If opt_verbose bcc_opts:+" -v"
	If opt_release bcc_opts:+" -r"
	If opt_threaded bcc_opts:+" -h"

	If opt_framework bcc_opts:+" -f "+opt_framework
	
	Local app_ext$=ExtractExt( app_main ).ToLower()
	Select app_ext
	Case "bmx"
		app_type="bmx"
		MakeMod "brl.blitz"
		MakeSrc Main,True
		MakeMod opt_appstub
	Case "c","cpp","cxx","cc","mm"
		app_type="c/c++"
		If opt_framework MakeMod opt_framework
		MakeSrc Main,True
	Default
		Throw "Unrecognized app source file extension:"+app_ext
	End Select
	
	If MaxTime( lnk_files )>FileTime( opt_outfile ) Or opt_all
		If Not opt_quiet Print "Linking:"+StripDir( opt_outfile )
		lnk_files=FilePaths( lnk_files )
		AddList ext_files,lnk_files
		LinkApp opt_outfile,lnk_files,makelib
	EndIf
	
	app_main=""

End Function

