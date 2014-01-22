' createwindow.bmx

Import MaxGui.Drivers

Strict 

AppTitle = "CreateWindow() Example"

Global FLAGS:Int

' Comment/uncomment any of the following lines to experiment with the different styles.

FLAGS:| WINDOW_TITLEBAR
FLAGS:| WINDOW_RESIZABLE
FLAGS:| WINDOW_MENU
FLAGS:| WINDOW_STATUS
FLAGS:| WINDOW_CLIENTCOORDS
'FLAGS:| WINDOW_HIDDEN
FLAGS:| WINDOW_ACCEPTFILES
'FLAGS:| WINDOW_TOOL
'FLAGS:| WINDOW_CENTER

Local window:TGadget = CreateWindow( AppTitle, 100, 100, 320, 240, Null, FLAGS )

If (FLAGS & WINDOW_STATUS) Then
	SetStatusText( window, "Left aligned~tCenter aligned~tRight aligned" )
EndIf

Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End
	End Select
Forever