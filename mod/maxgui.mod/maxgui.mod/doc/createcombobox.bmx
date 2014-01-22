' createcombobox.bmx

Strict

Import MaxGui.Drivers

AppTitle = "ComboBox Style Example"

Global window:TGadget = CreateWindow( AppTitle, 100, 100, 300, 200, Null, WINDOW_TITLEBAR|WINDOW_STATUS )
	
	CreateLabel( "No Style (0): ", 5, 5, ClientWidth(window)-10, 24, window, LABEL_LEFT )
	Global stdComboBox:TGadget = CreateComboBox( 5, 29, ClientWidth(window)-10, 26, window, 0 )
		AddGadgetItem stdComboBox, "Short"
		AddGadgetItem stdComboBox, "Medium"
		AddGadgetItem stdComboBox, "Fat", True
		AddGadgetItem stdComboBox, "Humungous"
		
	CreateLabel( "COMBOBOX_EDITABLE: ", 5, 59, ClientWidth(window)-10, 24, window, LABEL_LEFT )
	Global editcombobox:TGadget = CreateComboBox( 5, 83, ClientWidth(window)-10, 26, window, COMBOBOX_EDITABLE )
		AddGadgetItem editcombobox, "United Kingdom"
		AddGadgetItem editcombobox, "United States", True

Local tmpText$

Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		'Combobox Event(s)
		'EventData() holds the index of the selected item (or -1 if no item is currently selected)
		Case EVENT_GADGETACTION
			Select EventSource()
				Case stdComboBox
					tmpText = ""
					If EventData() > -1 Then
						tmpText = GadgetItemText(TGadget(EventSource()), EventData())
					EndIf
					SetStatusText window, "Weight chosen: " + tmpText
				Case editComboBox
					tmpText = ""
					If EventData() > -1 Then 
						tmpText = GadgetItemText(TGadget(EventSource()), EventData())
					Else 
						tmpText = GadgetText(TGadget(EventSource())) + " [user text]"
					EndIf
					SetStatusText window, "Country chosen: " + tmpText
			EndSelect
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			End
	EndSelect
Forever
