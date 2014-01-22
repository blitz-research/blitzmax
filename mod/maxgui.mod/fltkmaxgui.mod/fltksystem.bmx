' fltksystem.bmx

Strict

Import BRL.System

Import "fltkimports.bmx"

Private
Include "fltkdecls.bmx"
?Win32	
Const NATIVEREQUESTERS=1
?MacOS
Const NATIVEREQUESTERS=0
?Linux
Const NATIVEREQUESTERS=0
?
Public

Type TFLSystemDriver Extends TSystemDriver

	Field NativeDriver:TSystemDriver

	Method New()
		NativeDriver=brl.System.Driver
	End Method
	
	Method Poll()
		NativeDriver.Poll()
	End Method
		
	Method Wait()
		NativeDriver.Wait()
	End Method
	
	Method Emit( osevent:Byte Ptr,source:Object )
		Throw "simon come here"
	End Method

	Method IsFullScreen()
		Return False
	End Method	

	Method SetMouseVisible(bool)
		NativeDriver.SetMouseVisible bool
	End Method

	Method MoveMouse( x,y )
		NativeDriver.MoveMouse x,y
	End Method

	Method Notify( text$,serious )
		If NATIVEREQUESTERS Return NativeDriver.Notify(text,serious)
		If IsFullScreen() RuntimeError "Notify currently not supported in fullscreen mode."
		If serious serious=1
		flRequest(text,serious)
	End Method
	
	Method Confirm( text$,serious )
		If NATIVEREQUESTERS Return NativeDriver.Confirm(text,serious)
		If IsFullScreen() RuntimeError "Confirm currently not supported in fullscreen mode."
		Return flRequest(text,2)
	End Method
	
	Method Proceed( text$,serious )
		If NATIVEREQUESTERS Return NativeDriver.Proceed(text,serious)
		If IsFullScreen() RuntimeError "Proceed currently not supported in fullscreen mode."
		Return flRequest(text,3)-1	'yes/no/cancel -> 1,0,-1
	End Method

	Method RequestFile$( text$,exts$,save,file$ )
		If NATIVEREQUESTERS Return NativeDriver.RequestFile( text$,exts$,save,file$ )
		If IsFullScreen() RuntimeError "RequestFile currently not supported in fullscreen mode."
		If exts
			If exts.Find(":")<>-1
				exts=exts.Replace(":","(*.{")
				exts=exts.Replace(";","})~t")
				exts:+"})"
				exts=exts.Replace("*.{*}","*")
			Else
				exts="(*.{"+exts+"})"
			EndIf
		EndIf	
		Return flRequestFile(text,exts,file,save)
	End Method
	
	Method RequestDir$( text$,path$ )
		If NATIVEREQUESTERS Return NativeDriver.RequestDir( text$,path$ )
		If IsFullScreen() RuntimeError "RequestFile currently not supported in fullscreen mode."
		Return flRequestDir(text,path,0)
	End Method

	Method OpenURL( url$ )
		Return NativeDriver.OpenURL(url)
	End Method

End Type
