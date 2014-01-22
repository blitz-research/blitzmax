Strict

Import MaxGui.Drivers

Local menu:TGadget
Local window:TGadget
Local panel:TGadget

menu=CreateMenu("popup",0,Null)
CreateMenu("Load",101,menu)
CreateMenu("Save",102,menu)

window=CreateWindow("Test PopupWindowMenu",20,20,200,200)

' create a panel to capture some mouse events

panel=CreatePanel(0,0,ClientWidth(window),ClientHeight(window),window,PANEL_ACTIVE)

While True
	WaitEvent
	Select EventID()
		Case EVENT_MOUSEDOWN
			If EventData()=2 PopupWindowMenu window,menu
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_MENUACTION
			Print "EVENT_MENUACTION: eventdata()="+EventData()
	End Select
Wend

