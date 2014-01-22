
Strict

Import "driver.bmx"
Import "system.win32.c"

Import "-lshell32"
Import "-lcomctl32"

Const WM_BBSYNCOP=$7001	'wp=function, lp=arg

Extern

Function bbSystemStartup()
Function bbSystemPoll()
Function bbSystemWait()
Function bbSystemMoveMouse( x,y )
Function bbSystemSetMouseVisible( visible )

Function bbSystemNotify( text$,serious )
Function bbSystemConfirm( text$,serious )
Function bbSystemProceed( text$,serious )
Function bbSystemRequestFile$( text$,exts$,defext,save,file$,dir$ )
Function bbSystemRequestDir$( text$,dir$ )
Function bbOpenURL( url$ )

Function bbSystemEmitOSEvent( hwnd,msg,wparam,lparam,source:Object )

Function bbSystemPostSyncOp( syncOp( syncInfo:Object,asyncRet ),syncInfo:Object,asyncRet )
Function bbSystemStartAsyncOp( asyncOp( asyncInfo ),asyncInfo,syncOp( syncInfo:Object,asyncRet ),syncInfo:Object )

End Extern

Type TWin32SystemDriver Extends TSystemDriver

	Method New()
		bbSystemStartup
	End Method

	Method Poll()
		bbSystemPoll()
	End Method
	
	Method Wait()
		bbSystemWait()
	End Method
	
	Method MoveMouse( x,y )
		bbSystemMoveMouse x,y
	End Method
	
	Method SetMouseVisible( visible )
		bbSystemSetMouseVisible visible
	End Method

	Method Notify( text$,serious )
		bbSystemNotify text,serious
	End Method
	
	Method Confirm( text$,serious )
		Return bbSystemConfirm( text,serious )
	End Method
	
	Method Proceed( text$,serious )
		Return bbSystemProceed( text,serious )
	End Method

	Method RequestFile$( text$,exts$,save,path$ )
		Local file$,dir$
		
		path=path.Replace( "/","\" )
		
		Local i=path.FindLast( "\" )
		If i<>-1
			dir=path[..i]
			file=path[i+1..]
		Else
			file=path
		EndIf

' calculate default index of extension in extension list from path name

		Local ext$,defext,p,q
		p=path.Find(".")
		If (p>-1)
			ext=","+path[p+1..].toLower()+","
			Local exs$=exts.toLower()
			exs=exs.Replace(":",":,")
			exs=exs.Replace(";",",;")
			p=exs.find(ext)
			If p>-1
				Local q=-1
				defext=1
				While True
					q=exs.find(";",q+1)
					If q>p Exit
					If q=-1 defext=0;Exit
					defext:+1
				Wend
			EndIf
		EndIf
	
		If exts
			If exts.Find(":")=-1
				exts="Files~0*."+exts
			Else
				exts=exts.Replace(":","~0*.")
			EndIf
			exts=exts.Replace(";","~0")
			exts=exts.Replace(",",";*.")+"~0"
		EndIf
		
		Return bbSystemRequestFile( text,exts,defext,save,file,dir )

	End Method

	Method RequestDir$( text$,dir$ )
	
		dir=dir.Replace( "/","\" )
		
		Return bbSystemRequestDir( text,dir )
	
	End Method
	
	Method OpenURL( url$ )
		bbOpenURL( url )
	End Method
	
End Type
