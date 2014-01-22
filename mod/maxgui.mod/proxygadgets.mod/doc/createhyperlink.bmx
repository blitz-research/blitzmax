Strict

Import MaxGUI.Drivers
Import MaxGUI.ProxyGadgets

AppTitle = "Hyperlink Test Window"

Global wndMain:TGadget = CreateWindow( AppTitle, 100, 100, 300, 59, Null, WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_STATUS )
	
	'Standard Hyperlink Gadget
	Global hypLeft:TGadget = CreateHyperlink( "http://www.google.com/", 2, 2, ClientWidth(wndMain)-4, 15, wndMain, LABEL_LEFT )
	
	'Center Aligned Hyperlink Gadget with alternate text
	Global hypCenter:TGadget = CreateHyperlink( "http://www.blitzbasic.com/", 2, 21, ClientWidth(wndMain)-4, 17, wndMain, LABEL_CENTER|LABEL_FRAME, "BlitzBasic" )
	
	'Right Aligned Sunken Hyperlink Gadget with custom rollover colors set
	Global hypRight:TGadget = CreateHyperlink( "http://www.blitzmax.com/", 2, 42, ClientWidth(wndMain)-4, 15, wndMain, LABEL_RIGHT, "Custom Rollover Colors" )
		SetGadgetTextColor(hypRight,128,128,128)	'Set normal text color to grey.
		SetGadgetColor(hypRight,255,128,0)			'Set rollover color to orange.

'Example of how to retrieve a hyperlink gadget's URL
Print "Hyperlink 1 URL: " + String(GadgetExtra(hypLeft))
Print "Hyperlink 2 URL: " + String(GadgetExtra(hypCenter))
Print "Hyperlink 3 URL: " + String(GadgetExtra(hypRight))

'Example of how to set a hyperlink gadget's URL
SetGadgetExtra( hypRight, "http://www.blitzbasic.co.nz" )
'We need to update the tooltip to the new URL
SetGadgetToolTip( hypRight, String(GadgetExtra(hypRight)) )

Repeat
	
	WaitEvent()
	
	SetStatusText wndMain, CurrentEvent.ToString()
	
	Select EventID()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
	EndSelect
	
Forever
