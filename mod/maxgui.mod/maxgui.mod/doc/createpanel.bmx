' createpanel.bmx

Strict

Import MaxGui.Drivers

AppTitle = "Panel Example"

Local window:TGadget = CreateWindow( AppTitle, 100, 100, 440, 240, Null, WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_RESIZABLE )

' create an active panel that occupies entire window client area

Local panel:TGadget = CreatePanel(0,0,ClientWidth(window),ClientHeight(window),window,PANEL_ACTIVE)
SetGadgetLayout panel, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED

' and add to it a smaller green panel with a sunken edge

Local panel2:TGadget = CreatePanel(10,10,200,200,panel,PANEL_ACTIVE|PANEL_SUNKEN)
SetGadgetColor(panel2,160,255,160)

' and finally a group panel with a child button

Local group:TGadget = CreatePanel(220,10,200,200,panel,PANEL_GROUP,"Group Label")
Local button:TGadget = CreateButton("Push Button",0,10,ClientWidth(group)-20,26,group)


Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			End
	End Select
Forever
