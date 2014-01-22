' file drag & drop example

Import MaxGui.Drivers

Strict

Const MENU_EXIT=105
Const MENU_ABOUT=109

'
' A window
Local win:TGadget = CreateWindow("Drag & Drop!",100,100,400,400,Null,WINDOW_TITLEBAR|WINDOW_RESIZABLE|WINDOW_MENU|WINDOW_STATUS|WINDOW_CLIENTCOORDS|WINDOW_ACCEPTFILES)

'
' A simple menu
Local filemenu:TGadget = CreateMenu("&File",0,WindowMenu(win))
CreateMenu"E&xit",MENU_EXIT,filemenu

Local helpmenu:TGadget = CreateMenu("&Help",0,WindowMenu(win))
CreateMenu "&About",MENU_ABOUT,helpmenu

UpdateWindowMenu win

'
' A canvas gadget to display the image
Local can:TGadget = CreateCanvas(0,0,400,400,win,1)
SetGadgetLayout can,1,1,1,1

'
' A few bits and pieces
Local image:Timage
Local file:String = "Drag an image file onto window"
SetStatusText win,file


'
' Main loop
While WaitEvent()
	Select EventID()

		Case EVENT_GADGETPAINT
			Select EventSource()
				Case can
					'
					' Draw to the canvas
					SetGraphics CanvasGraphics(can)
					
					'
					' Make sure it has the correct dimensions
					SetViewport 0,0,GadgetWidth(can),GadgetHeight(can)
					
					'
					' Draw the checker background
					SetBlend SOLIDBLEND
					Local a:Int = 1
					Local b:Int = 1
					For Local x = 0 To GadgetWidth(can) Step 16
						b = Not b
						a = b
						For Local y = 0 To GadgetHeight(can) Step 16
							a = Not a
							SetColor 160-a*20,160-a*20,160-a*20
							DrawRect x,y,16,16
						Next
					Next
						
					'
					' Draw the image
					If image
						SetBlend ALPHABLEND
						SetColor 255,255,255
						
						Local scale:Float = Min(1.0,Min(Float(ClientWidth(can))/ImageWidth(image),Float(ClientHeight(can))/ImageHeight(image)))
		
						Local w = ImageWidth(image)*scale
						Local h = ImageHeight(image)*scale	
						Local x = (ClientWidth(can)-w)/2
						Local y = (ClientHeight(can)-h)/2
		
						SetScale scale,scale
						DrawImage image,x,y
		
						SetScale 1,1
						SetBlend SHADEBLEND
						SetColor 170,170,170			
						DrawRect x-1,0,1,ClientHeight(can)
						DrawRect x+w,0,1,ClientHeight(can)
						DrawRect 0,y-1,ClientWidth(can),1
						DrawRect 0,y+h,ClientWidth(can),1
						
						SetStatusText win,file+" @ "+Int(scale*100)+"%"
					EndIf
					
					Flip
			EndSelect
					
		Case EVENT_WINDOWCLOSE
			'
			' Quit
			End
			
		Case EVENT_WINDOWACCEPT
			'
			' A file has been dragged and dropped on the window
			file = EventExtra().tostring()
			
			'
			' Try loading the file as an image
			image = LoadImage(file)
			If image = Null
				file = "Invalid file format!"
			Else
				file = file+"  ("+(FileSize(file)/1024)+"Kb)  "+ImageWidth(image)+"x"+ImageHeight(image)
			EndIf
			SetStatusText win,file
			RedrawGadget can
		
		Case EVENT_MENUACTION
			'
			' Menu stuff
			Select EventData()
				Case MENU_EXIT
					End
				Case MENU_ABOUT
					Notify "File drag & drop example!~nBy Mikkel Fredborg"
			End Select
		
		Default
			'
			' Uncomment this to show what other events occur
			' Print CurrentEvent.toString()
					
	EndSelect
	
Wend
