' createlabel.bmx

Import MaxGui.Drivers

Strict 

Local window:TGadget

window=CreateWindow("My Window",30,20,320,480)

CreateLabel("A plain label",10,10,280,52,window)
CreateLabel("A label with LABEL_FRAME",10,80,280,60,window,LABEL_FRAME)
CreateLabel("A label with LABEL_SUNKENFRAME",10,150,280,60,window,LABEL_SUNKENFRAME)
CreateLabel("not applicable",10,220,280,54,window,LABEL_SEPARATOR)

While WaitEvent()<>EVENT_WINDOWCLOSE
Wend
