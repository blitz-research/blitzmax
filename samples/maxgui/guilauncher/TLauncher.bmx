Strict

Import MaxGui.Drivers

Import "PNGHeader.bmx"
Incbin "bmxlogo.png"

Type TAR
	Field width:Int
	Field height:Int
	
	Function Create:TAR( width:Int , height:Int )
		Local temp:TAR = New TAR
		temp.width = width
		temp.height = height
		Return temp
	EndFunction
	Method ToString:String()
	Return width + ":" + height
	EndMethod
EndType

Type TLauncher
	Field angle = 0
	Field sync:TTimer
	Field myWindow:TGadget
	Field myCanvas:TGadget
	Field myLogo:TImage
	Field myLB:TGadget
	Field resMap:TMap
	Field btnLaunch:TGadget
	Field btnAbort:TGadget
	Field terminate = False
	Field selected:TGraphicsMode
	Field isDisposed = True
	Field aspectRatios:TList
	Field pngInfo:PNGHeader

	Method initGUI()
		myWindow = CreateWindow("Arise GUI Launcher - BETA", Desktop().width/2 - 100, Desktop().height/2 - 100, 200, 200, Null, WINDOW_TITLEBAR | WINDOW_CLIENTCOORDS | WINDOW_HIDDEN)
		myCanvas:TGadget = CreateCanvas ( 0 , 0 , 200 , 87 , myWindow)
		pngInfo:PNGHeader = PNGHeader.fromPtr(IncbinPtr( "bmxlogo.png" ))
		If pngInfo.isPNG()
			myLogo:TImage = LoadAnimImage( "incbin::bmxlogo.png",pngInfo.width,1,0,pngInfo.height )
		EndIf
		myLB:TGadget = CreateListBox(0,88,200,93,myWindow)
		For Local i:String = EachIn resMap.Keys()
			AddGadgetItem myLB , i
		Next
		
		'SelectGadgetItem myLB , CountGadgetItems(myLB) -1
		sync = CreateTimer(100)
		btnLaunch = CreateButton ("LAUNCH!" , 0,181,100,20,myWindow)
		btnAbort = CreateButton ("ABORT!" , 100,181,100,20,myWindow)
		isDisposed = False
	EndMethod

	Function Create:TLauncher()
		Local temp:TLauncher = New TLauncher
		temp.addAspectRatio( 4 , 3 )
		temp.populateModes
		Return temp
	End Function

	Method populateModes()
		If aspectRatios = Null
			addAspectRatio( 4 , 3 )
		EndIf
		resMap = New TMap

		For Local i:TGraphicsMode = EachIn GraphicsModes()
			For Local j:TAR = EachIn aspectRatios
				If i.width / j.width = i.height / j.height And i.depth > 8
					Local res:String = i.width + " x " + i.height + " - " + i.depth + " bits @ " + i.hertz + "Hz"
					resMap.insert res , i
					Exit
				EndIf
			Next
		Next
	EndMethod

	Method addAspectRatio( width:Int , height:Int )
		If aspectRatios = Null
			aspectRatios = New TList
		EndIf
		aspectRatios.addLast( TAR.Create( width , height ))
	EndMethod

	Method show()
		If Not isDisposed
			ShowGadget myWindow	
		EndIf
	EndMethod

	Method hide()
		If Not isDisposed
			HideGadget myWindow
		EndIf
	EndMethod
	
	Method dispose()
		FreeGadget myWindow
		FreeGadget myCanvas
		FreeGadget btnLaunch
		FreeGadget btnAbort
		FreeGadget myLB

		myLogo = Null
		resMap = Null
		myWindow = Null
		myCanvas = Null
		btnLaunch = Null
		btnAbort = Null
		myLB = Null
		isDisposed = True
	EndMethod

	Method getSelectedMode:TGraphicsMode()
		Return selected
	EndMethod
	
	Method main()
		If Not isDisposed
			WaitEvent
			If CurrentEvent.id = EVENT_TIMERTICK 
				angle = TimerTicks(sync) Mod 360 
				SetGraphics CanvasGraphics( myCanvas )
				SetClsColor 255 , 255 , 255
				Cls
				For Local i:Int = 0 Until pngInfo.height
					DrawImage myLogo,24 + Sin(angle+i*2) * 48,i,i
				Next
				Flip
			ElseIf CurrentEvent.id = EVENT_APPTERMINATE Or CurrentEvent.id = EVENT_WINDOWCLOSE Or..
				( CurrentEvent.id = EVENT_GADGETACTION And EventSource() = btnAbort )
				terminate = True
			ElseIf ( CurrentEvent.id = EVENT_GADGETACTION And EventSource() = btnLaunch )
				terminate = True
				If SelectedGadgetItem(myLB)<>-1
					selected = TGraphicsMode(resMap.ValueForKey(GadgetItemText(myLB,SelectedGadgetItem(myLB))))
				EndIf
			EndIf
		EndIf
	EndMethod
EndType
