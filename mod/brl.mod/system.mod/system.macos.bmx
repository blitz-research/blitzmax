Strict

Import BRL.Event

Import "driver.bmx"
Import "system.macos.m"

Extern

Function bbSystemStartup()
Function bbSystemPoll()
Function bbSystemWait()
Function bbSystemIntr()
Function bbSystemMoveMouse( x,y )
Function bbSystemSetMouseVisible( visible )
Function bbSystemNotify( text$,serious )
Function bbSystemConfirm( text$,serious )
Function bbSystemProceed( text$,serious )
Function bbSystemRequestFile$( text$,exts$,save,file$,dir$ )
Function bbSystemRequestDir$( text$,dir$ )
Function bbOpenURL( url$ )

Function bbSystemPostSyncOp( syncOp( syncInfo:Object,asyncRet ),syncInfo:Object,asyncRet )
Function bbSystemStartAsyncOp( asyncOp( asyncInfo ),asyncInfo,syncOp( syncInfo:Object,asyncRet ),syncInfo:Object )

End Extern

Private

Function Hook:Object( id,data:Object,context:Object )
	bbSystemIntr
	Return data
End Function

AddHook EmitEventHook,Hook,Null,10000

Public

Type TMacOSSystemDriver Extends TSystemDriver

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
		Local file$,dir$,filter$
		
		path=path.Replace( "\","/" )
		Local i=path.FindLast( "/" )
		If i<>-1
			dir=path[..i]
			file=path[i+1..]
		Else
			file=path
		EndIf
		
		exts=exts.Replace( ";","," )
		While exts
			Local p=exts.Find(",")+1
			If p=0 p=exts.length
			Local q=exts.Find(":")+1
			If q=0 Or q>p q=0
			filter:+exts[q..p]
			exts=exts[p..]
		Wend
		If filter.find("*")>-1 filter=""
		
		Return bbSystemRequestFile( text,filter,save,file,dir )
	End Method

	Method RequestDir$( text$,dir$ )
		dir=dir.Replace( "\","/" )
		Return bbSystemRequestDir( text,dir )
	End Method
	
	Method OpenURL( url$ )
'		Return system_( "open "" + url.Replace("~q","") + "~q" )
		bbOpenURL( url )
	End Method
	
End Type

