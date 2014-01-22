' setpointer.bmx

Import MaxGui.Drivers

Strict 

Local window:TGadget
Local combo:TGadget

window=CreateWindow("SetPointer",40,40,320,240,,WINDOW_TITLEBAR)

CreateLabel "Select a pointer shape:",10,10,200,20,window

combo=CreateComboBox(10,30,200,24,window)
AddGadgetItem combo,"POINTER_DEFAULT"
AddGadgetItem combo,"POINTER_ARROW"
AddGadgetItem combo,"POINTER_IBEAM" 
AddGadgetItem combo,"POINTER_WAIT" 
AddGadgetItem combo,"POINTER_CROSS"
AddGadgetItem combo,"POINTER_UPARROW" 
AddGadgetItem combo,"POINTER_SIZENWSE" 
AddGadgetItem combo,"POINTER_SIZENESW" 
AddGadgetItem combo,"POINTER_SIZEWE" 
AddGadgetItem combo,"POINTER_SIZENS" 
AddGadgetItem combo,"POINTER_SIZEALL" 
AddGadgetItem combo,"POINTER_NO" 
AddGadgetItem combo,"POINTER_HAND"
AddGadgetItem combo,"POINTER_APPSTARTING"
AddGadgetItem combo,"POINTER_HELP"

SelectGadgetItem combo,0

While True
	WaitEvent 
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_GADGETACTION
			SetPointer EventData()
	End Select
Wend
