' setgadgetfilter.bmx

Import MaxGui.Drivers

Strict 

Local window:TGadget
Global textarea:TGadget

window=CreateWindow("My Window",30,20,320,240)

textarea=CreateTextArea(0,24,ClientWidth(window),ClientHeight(window)-24,window)

SetGadgetLayout textarea,1,1,1,1
SetGadgetText textarea,"A textarea gadget that filters out down arrows~nand tab keys."
ActivateGadget textarea

SetGadgetFilter textarea,filter

Print "KEY_TAB="+KEY_TAB

Function filter(event:TEvent,context:Object)
	Select event.id
		Case EVENT_KEYDOWN
			Print "filtering keydown:"+event.data+","+event.mods
			If event.data=KEY_DOWN Return 0
			If event.data=13 Return 0
		Case EVENT_KEYCHAR
			Print "filtering charkey:"+event.data+","+event.mods
			If event.data=KEY_TAB Return 0
	End Select
	Return 1
End Function

While WaitEvent()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
	End Select
Wend
