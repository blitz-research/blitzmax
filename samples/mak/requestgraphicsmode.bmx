
Strict

Import MaxGui.Drivers

Repeat

	Local w,h,d,r

	If Not RequestGraphicsMode( w,h,d,r ) End

	Graphics w,h,d,r

	DrawText "Graphics Mode:"+w+","+h+","+d+" "+r+"Hz",0,0
	DrawText "Hit any key",0,16

	Flip

	WaitKey
	
	EndGraphics

Forever

Function ListModes( list:TGadget )
	ClearGadgetItems list
	For Local t:TGraphicsMode=EachIn GraphicsModes()
		AddGadgetItem list,t.ToString()
	Next
	SelectGadgetItem list,0
End Function

Function RequestGraphicsMode( width Var,height Var,depth Var,hertz Var )

	Local w=ClientWidth( Desktop() ),h=ClientHeight( Desktop() )

	Local window:TGadget=CreateWindow( "Select graphics Mode",w/2-160,h/2-160,320,320,Null,WINDOW_TITLEBAR )
	
	Local panel:TGadget=CreatePanel( 0,0,ClientWidth(window),ClientHeight(window),window )

	w=ClientWidth(panel) ; h=ClientHeight(panel)
	
	Local okay:TGadget=CreateButton( "Okay",w-104,h-32,96,24,panel,BUTTON_OK )
	
	CreateLabel "Graphics Mode:",8,16,w-16,16,panel
	Local list1:TGadget=CreateListBox( 8,32,w-16,h-128,panel )

	CreateLabel "Graphics Driver:",8,h-80,w-16,16,panel
	Local combo1:TGadget=CreateComboBox( 8,h-64,w-16,24,panel )
	DisableGadget combo1
	AddGadgetItem combo1,"OpenGL"
	SelectGadgetItem combo1,0
	SetGraphicsDriver GLMax2DDriver()
?Win32
	EnableGadget combo1
	AddGadgetItem combo1,"Direct3D7"
	SelectGadgetItem combo1,1
	SetGraphicsDriver D3D7Max2DDriver()
?
	Local cancel:TGadget=CreateButton( "Cancel",8,h-32,96,24,panel,BUTTON_CANCEL )

	ListModes list1
	ActivateGadget list1

	Local ret=False	
		
	While WaitEvent()<>EVENT_WINDOWCLOSE
		Select EventID()
		Case EVENT_GADGETACTION
			Select EventSource()
			Case okay
				Local t:TGraphicsMode=GraphicsModes()[ SelectedGadgetItem( list1 ) ]
				width=t.width
				height=t.height
				depth=t.depth
				hertz=t.hertz
				ret=True
				Exit
			Case cancel
				Exit
			Case combo1
				Select SelectedGadgetItem( combo1 )
				Case 0
					SetGraphicsDriver GLMax2DDriver()
?Win32
				Case 1
					SetGraphicsDriver D3D7Max2DDriver()
?
				End Select
				ListModes list1
			End Select
		Case EVENT_WINDOWCLOSE
			Exit
		End Select
	Wend
	
	FreeGadget window
	
	Return ret
	
End Function

