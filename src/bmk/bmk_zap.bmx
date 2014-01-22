
Strict

Import "bmk_modutil.bmx"
Import "bmk_bank.bmx"
Import "bmk_modinfo.bmx"

Function Zap( path$,stream:TStream )

	If Not path Return False

	Local name$=StripDir( path )
	
	Local skip=False
	
	If name[..1]="."
		skip=True
	Else If name.ToLower().EndsWith( ".bak" )
		skip=True
	EndIf
	
	If skip
		stream.WriteLine ""
		Return True
	EndIf
	
	Local mode=FileMode( path )

	Select FileType(path)
	Case FILETYPE_NONE
		Print "Error zapping file "+path
		Return
	Case FILETYPE_FILE
		Local size=FileSize(path)
		stream.WriteLine name
		stream.WriteLine mode
		stream.WriteLine size
		Local from_stream:TStream=ReadStream(path)
		CopyBytes from_stream,stream,size
		from_stream.Close
	Case FILETYPE_DIR
		Local dir$[]=LoadDir( path )
		Local size=Len( dir )
		stream.WriteLine name
		stream.WriteLine -mode
		stream.WriteLine size
		For Local t$=EachIn dir
			If Not Zap( path+"/"+t,stream ) Return
		Next
	End Select
	
	Return True
	
End Function

Function Unzap( dir$,stream:TStream )

	Local name$=stream.ReadLine()
	If Not name Return True
	
	Local mode=Int( stream.ReadLine() )
	Local size=Int( stream.ReadLine() )

	Local path$=dir+"/"+name
	
	If mode<0
		mode=-mode
		CreateDir path
		For Local k=0 Until size
			If Not Unzap( path,stream ) Return
		Next
	Else
		DeleteFile path
		Local to_stream:TStream=WriteStream(path)
		CopyBytes stream,to_stream,size
		to_stream.Close
	EndIf

	SetFileMode path,mode
	Return True

End Function

Function ZapMod( name$,stream:TStream )

	Local path$=ModuleInterface( name,"release."+cfg_platform+"."+opt_arch )

	If FileType(path)<>FILETYPE_FILE 
		Print "Failed to find module"
		Return
	EndIf
	
	Local src:TSourceFile=ParseSourceFile( path )
	stream.WriteLine "Module: "+name
	For Local t$=EachIn src.info
		stream.WriteLine t
	Next
	stream.WriteLine ""

	Local bank:TBank=TBank.Create(0)
	Local bank_stream:TStream=TBankStream.Create( bank ) 
	If Not Zap( ModulePath(name),bank_stream ) Throw "Failed to publish module"
	bank_stream.Close
	
	bank=CompressBank( bank )
	bank_stream=TBankStream.Create( bank )
	CopyStream bank_stream,stream
	bank_stream.Close

End Function

Function UnzapMod( stream:TStream )

	Local modinfo:TModInfo=TModInfo.CreateFromStream( stream )
	
	Local path$=ModulePath( modinfo.name )
	If Not CreateDir( path,True ) Throw "Unable to create module directory"
	DeleteDir path,True
	
	Local bank:TBank=TBank.Create(0)
	Local bank_stream:TStream=TBankStream.Create( bank )
	CopyStream stream,bank_stream
	bank_stream.Close
	
	bank=UncompressBank( bank )
	bank_stream=TBankStream.Create( bank )
	If Not Unzap( ExtractDir(path),bank_stream )
		Print "Failed to Unzap module"
		Return
	EndIf
	bank_stream.Close
	
?MacOS
	Ranlib path
?
	Return True

End Function
