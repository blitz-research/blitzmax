' requestfont.bmx

Import MaxGui.Drivers

Strict 

AppTitle = "RequestFont() Example"

Const teststring:String = "The quick brown fox jumps over the lazy dog."

Local window:TGadget = CreateWindow(AppTitle,50,50,300,200,Null,WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_RESIZABLE)
	SetMinWindowSize window, GadgetWidth(window), GadgetHeight(window)
	
	Local label:TGadget = CreateLabel(teststring,0,0,ClientWidth(window),ClientHeight(window)-26,window)
		SetGadgetLayout label, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED
	
	Local button:TGadget = CreateButton("Select Font",0,ClientHeight(window)-26,ClientWidth(window),26,window)
		SetGadgetLayout button, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED

Local font:TGUIFont

Repeat
	Select WaitEvent()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			End
		Case EVENT_GADGETACTION
			font = RequestFont(font)
			If font Then
				SetGadgetFont label, font
				SetStatusText window,FontName(font) + ": " + Int(FontSize(font)+0.5) + "pt"
			EndIf
	End Select
Forever
