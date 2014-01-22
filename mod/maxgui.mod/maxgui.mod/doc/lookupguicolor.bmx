' lookupguicolor.bmx

Strict

Import MaxGUI.Drivers

AppTitle = "LookupGuiColor() Example"

Global wndMain:TGadget = CreateWindow( AppTitle, 100, 100, 300, 200, Null, WINDOW_TITLEBAR|WINDOW_STATUS )

	Global pnlMain:TGadget = CreatePanel( 0, 0, ClientWidth(wndMain), ClientHeight(wndMain), wndMain )
	
		Global cmbColors:TGadget = CreateComboBox( 5, 5, ClientWidth(wndMain) - 10, 28, pnlMain )
		
		' Populate combo-box with the available color constants
		
		AddGadgetItem cmbColors, "GUICOLOR_WINDOWBG", GADGETITEM_DEFAULT, GUICOLOR_WINDOWBG
		AddGadgetItem cmbColors, "GUICOLOR_GADGETBG", 0, GUICOLOR_GADGETBG
		AddGadgetItem cmbColors, "GUICOLOR_GADGETFG", 0, GUICOLOR_GADGETFG
		AddGadgetItem cmbColors, "GUICOLOR_SELECTIONBG", 0, GUICOLOR_SELECTIONBG
		AddGadgetItem cmbColors, "GUICOLOR_LINKFG", 0, GUICOLOR_LINKFG

ActivateGadget cmbColors

Repeat
	Select WaitEvent()
		
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End
			
		Case EVENT_GADGETACTION
			Local red:Byte, green:Byte, blue:Byte
			LookupGuiColor( GadgetItemIcon( cmbColors, EventData() ), red, green, blue )
			SetGadgetColor( pnlMain, red, green, blue )
			SetStatusText( wndMain, "RGB( " + red + ", " + green + ", " + blue + " )" )
			
	EndSelect
Forever
