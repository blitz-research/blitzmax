' createlistbox.bmx

Strict

Import MaxGui.Drivers

AppTitle = "ListBox Example"

Global window:TGadget = CreateWindow( AppTitle, 100, 100, 200, 200, Null, WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_RESIZABLE )
	
	Global listbox:TGadget = CreateListBox( 0, 0, ClientWidth(window), ClientHeight(window), window )
	SetGadgetLayout listbox, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED
	
	SetGadgetIconStrip listbox, LoadIconStrip("toolbar.png")
	
	AddGadgetItem listbox, "New", False, 0, "Create something."
	AddGadgetItem listbox, "Open", False, 1, "Open something."
	AddGadgetItem listbox, "Save", False, 2, "Save something.", "Extra Item Object!"
	AddGadgetItem listbox, "No Icon", False, -1, "This should not have an icon set."
	

SelectGadgetItem listbox, 2

While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
		'ListBox Event(s)
		'EventData() holds the index of the corresponding listbox item.
		Case EVENT_GADGETSELECT
			SetStatusText window, "Selected Item Index: " + EventData()
		Case EVENT_GADGETACTION
			SetStatusText window, "Double-Clicked Item Index: " + EventData()
		Case EVENT_GADGETMENU
			SetStatusText window, "Right-Clicked Item Index: " + EventData()
	End Select
Wend
