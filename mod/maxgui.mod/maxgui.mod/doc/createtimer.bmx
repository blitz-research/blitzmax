' createtimer.bmx

Import MaxGui.Drivers

Strict 

Local window:TGadget
Local label:TGadget

window=CreateWindow("Timer Test",40,40,160,64,Null,WINDOW_TITLEBAR)
label=CreateLabel("",10,10,200,20,window)

CreateTimer(1)

While True
	WaitEvent 
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_TIMERTICK
			SetGadgetText label,CurrentTime()
	End Select
Wend
