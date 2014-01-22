Strict

Import MaxGUI.Drivers

AppTitle = "GadgetClass() Example"
Global wndMain:TGadget = CreateWindow(AppTitle,100,100,220,200,Null,WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_STATUS)

	Global btnTest:TGadget = CreateButton("Push Button",10,10,200,30,wndMain,BUTTON_PUSH)
	Global chkTest:TGadget = CreateButton("Check Button",10,40,200,30,wndMain,BUTTON_CHECKBOX)
	
	Global cmbTest:TGadget = CreateComboBox(10,70,200,30,wndMain)
		AddGadgetItem(cmbTest,"Item 1");AddGadgetItem(cmbTest,"Item 2",GADGETITEM_DEFAULT);AddGadgetItem(cmbTest,"Item 3")
	
	Global sldTest:TGadget = CreateSlider(10,100,200,30,wndMain,SLIDER_HORIZONTAL|SLIDER_TRACKBAR)

Repeat

	WaitEvent()
	SetStatusText wndMain, CurrentEvent.ToString()
	
	Select EventID()
		
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
		
		Case EVENT_GADGETACTION, EVENT_GADGETSELECT, EVENT_WINDOWMOVE, EVENT_WINDOWSIZE
			
			Select GadgetClass(TGadget(EventSource()))
				Case GADGET_WINDOW;Print "Window Event"
				Case GADGET_BUTTON;Print "Button Event"
				Case GADGET_COMBOBOX;Print "ComboBox Event"
				Case GADGET_SLIDER;Print "Slider Event"
			EndSelect
			
	EndSelect
	
Forever
	