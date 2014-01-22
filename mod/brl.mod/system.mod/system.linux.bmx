
Strict

Import "driver.bmx"
Import "system.linux.c"

Import "-lXxf86vm"

Import pub.stdc

Extern

Function bbSystemStartup()
Function bbSystemPoll()
Function bbSystemWait()

Function bbSetMouseVisible(visible)
Function bbMoveMouse(x,y)
Function bbSystemDisplay()
Function bbSystemEventHandler( callback(xevent:Byte Ptr) )

Function bbSystemPostSyncOp( syncOp( syncInfo:Object,asyncRet ),syncInfo:Object,asyncRet )
Function bbSystemStartAsyncOp( asyncOp( asyncInfo ),asyncInfo,syncOp( syncInfo:Object,asyncRet ),syncInfo:Object )

Function bbSystemAsyncFD()
Function bbSystemFlushAsyncOps()

End Extern

Const XKeyPress=2
Const XKeyRelease=3

Function XKeyHandler(keyevent,key,mask)
	WriteStdout "XKeyHandler "+keyevent+","+key+","+mask+"~n"
End Function

Type TLinuxSystemDriver Extends TSystemDriver

	Method New()
		bbSystemStartup
	End Method

	Method Poll()
		bbSystemPoll()
	End Method
	
	Method Wait()
		bbSystemWait()
	End Method

	Method Emit( osevent:Byte Ptr,source:Object )
		Throw "simon come here"
	End Method

	Method SetMouseVisible( visible )
		bbSetMouseVisible(visible)
	End Method

	Method MoveMouse( x,y )
		bbMoveMouse x,y
	End Method

	Method Notify( text$,serious )
		WriteStdout text+"~r~n"
	End Method
	
	Method Confirm( text$,serious )
		WriteStdout text+" (Yes/No)?"
		Local t$=ReadStdin().ToLower()
		If t[..1]="y" Return 1
		Return 0
	End Method
	
	Method Proceed( text$,serious )
		WriteStdout text+" (Yes/No/Cancel)?"
		Local t$=ReadStdin().ToLower()
		If t[..1]="y" Return 1
		If t[..1]="n" Return 0
		Return -1
	End Method

	Method RequestFile$( text$,exts$,save,file$ )
		WriteStdout "Enter a filename:"
		Return ReadStdin()
	End Method
	
	Method RequestDir$( text$,path$ )
		WriteStdout "Enter a directory name:"
		Return ReadStdin()
	End Method

	Method OpenURL( url$ )
		If getenv_("KDE_FULL_DESKTOP")
			system_ "kfmclient exec ~q"+url+"~q"
		ElseIf getenv_("GNOME_DESKTOP_SESSION_ID")
			system_ "gnome-open ~q"+url+"~q"
		EndIf
	End Method

End Type
