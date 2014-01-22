
Strict

Import "bmk_modutil.bmx"
Import "bmk_util.bmx"

Type TInfo
	Field info:TList=New TList
	
	Method Find$( key$ )
		key=key.ToLower()+":"
		For Local t$=EachIn info
			If t.ToLower()[..Len(key)]=key Return t[Len(key)..].Trim()
		Next
	End Method
	
	Method ReadFromStream:TModInfo( stream:TStream )
		While Not stream.Eof()
			Local t$=stream.ReadLine()
			If Not t Return
			info.AddLast t
		Wend
	End Method
End Type

Type TModInfo Extends TInfo

	Field name$
	Field version#
	Field modprivs$
	Field modserver$
	Field serverinfo:Object

	Function CreateFromModule:TModInfo( name$ )
		Local path$=ModuleInterface( name,"release."+cfg_platform+"."+opt_arch )
		If FileType(path)<>FILETYPE_FILE Return
		Local src:TSourceFile=ParseSourceFile( path )
		If Not src Return
		Local modinfo:TModInfo=New TModInfo
		modinfo.name=name
		modinfo.info=src.info
		modinfo.info.AddFirst "Module: "+name
		modinfo.version=Float( modinfo.Find( "Version" ) )
		modinfo.modserver=modinfo.Find( "ModServer" )
		Return modinfo
	End Function
	
	Function CreateFromStream:TModInfo( stream:TStream )
		Local modinfo:TModInfo=New TModInfo
		modinfo.ReadFromStream stream
		modinfo.name=modinfo.Find( "Module" )
		If Not modinfo.name Return
		modinfo.version=Float( modinfo.Find( "Version" ) )
		modinfo.modprivs=modinfo.Find( "ModPrivs" )
		modinfo.modserver=modinfo.Find( "ModServer" )
		Return modinfo
	End Function

End Type

