' createslider.bmx

Import MaxGui.Drivers

Strict 

Local window:TGadget=CreateWindow("My Window",0,0,240,240,,WINDOW_TITLEBAR)

Local slider:TGadget[3]

' standard vertical and horizontal scroll bars

slider[0]=CreateSlider(10,10,16,100,window,SLIDER_VERTICAL)
slider[1]=CreateSlider(30,10,100,16,window,SLIDER_HORIZONTAL)

' a horizontal trackbar

slider[2]=CreateSlider(30,30,100,24,window,SLIDER_HORIZONTAL|SLIDER_TRACKBAR)

' a row of vertical trackbars

Local trackbar:TGadget[5]

For Local i=0 To 4
	trackbar[i]=CreateSlider(30+i*20,50,16,60,window,SLIDER_VERTICAL|SLIDER_TRACKBAR)
Next

' a single stepper

Local stepper:TGadget
stepper=CreateSlider(10,120,24,24,window,SLIDER_STEPPER)

SetSliderValue stepper,4
Print SliderValue(stepper)

While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
	End Select
Wend
