' redrawgadget.bmx

' version 3 - fixed to be compatible with virtual resolutions

Import MaxGui.Drivers

Strict

Type TApplet 

	Method OnEvent(Event:TEvent) Abstract

	Method Run()
		AddHook EmitEventHook,eventhook,Self
	End Method

	Function eventhook:Object(id,data:Object,context:Object)
		Local event:TEvent = TEvent(data)
		Local app:TApplet = TApplet(context)
		app.OnEvent( event )
		Return data
	End Function

End Type

Type TSpinningApplet Extends TApplet
	
	Global image:TImage
	
	Field timer:TTimer
	Field window:TGadget, canvas:TGadget
	
	Method Draw()
		
		SetGraphics CanvasGraphics(canvas)
		SetVirtualResolution ClientWidth(canvas),ClientHeight(canvas)
		SetViewport 0,0,ClientWidth(canvas), ClientHeight(canvas)
		
		SetBlend( ALPHABLEND )
		SetRotation( MilliSecs()*.1 )
		SetClsColor( 255, 0, 0 )
		
		Cls()
		DrawImage( image, GraphicsWidth()/2, GraphicsHeight()/2 )
		
		Flip()
		
	End Method
	
	Method OnEvent(event:TEvent)
		If Not event Then Return 
		Select event.id
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				End
			Case EVENT_TIMERTICK
				RedrawGadget( canvas )
			Case EVENT_GADGETPAINT
				If (event.source = canvas) Then Draw()
		End Select
	End Method
	
	Method Create:TSpinningApplet(name$)
		
		If Not image Then image = LoadImage( "fltkwindow.png" )
		
		window = CreateWindow( name, 20, 20, 512, 512 )
		
		Local w = ClientWidth(window)
		Local h = ClientHeight(window)
		
		canvas = CreateCanvas( 0, 0, w, h, window )
		SetGadgetLayout( canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		timer = CreateTimer( 100 )
		Run()
		
		Return Self
		
	End Method
	
End Type

AutoMidHandle True

Local spinner:TSpinningApplet = New TSpinningApplet.Create("Spinning Applet")

Repeat
	WaitSystem()
Forever
