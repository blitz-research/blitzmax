' createtoolbar.bmx

Strict

Import MaxGui.Drivers

AppTitle = "ToolBar Example"

Global window:TGadget = CreateWindow( AppTitle, 100, 100, 400, 32, Null, WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_RESIZABLE|WINDOW_CLIENTCOORDS )

	Global toolbar:TGadget = CreateToolBar( "toolbar.png", 0, 0, 0, 0, window )
	DisableGadgetItem toolbar, 2
	
	SetToolBarTips toolbar, ["New", "Open", "Save should be disabled."] 
	
	AddGadgetItem toolbar, "", 0, GADGETICON_SEPARATOR	'Add a separator.
	AddGadgetItem toolbar, "Toggle", GADGETITEM_TOGGLE, 2, "This toggle button should change to a light bulb when clicked."
	
	Global button:TGadget = CreateButton( "Show/Hide Toolbar", 2, 2, 180, 28, window )
	SetGadgetLayout button, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_CENTERED
	
While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
		'ToolBar Event(s)
		'EventData() holds the index of the toolbar item clicked.
		Case EVENT_GADGETACTION
			Select EventSource()
				Case button
					If GadgetHidden(toolbar) Then ShowGadget(toolbar) Else HideGadget(toolbar)
				Case toolbar 
					SetStatusText window, "Toolbar Item Clicked: " + EventData()
			EndSelect
	End Select
Wend
