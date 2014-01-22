' canvasbeginpaint.bmx

Strict

Import MaxGui.Drivers

AppTitle = "Canvas Painter Example"

Local window:TGadget = CreateWindow(AppTitle,50,50,200,200)

	' create a canvas that occupies entire window client area
	
	Local canvas:TGadget = CreateCanvas(0,0,ClientWidth(window),ClientHeight(window),window)
	SetGadgetLayout canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED

' create a timer as our single event source

Local timer:TTimer = CreateTimer(50)

Repeat
	Select WaitEvent()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			End
		Default
			CanvasBeginPaint(canvas)
			SetClsColor( 0, 255*Sin(MilliSecs()/5.0), 0 )
			Cls()
			Flip()
	EndSelect
Forever

Function CanvasBeginPaint(canvas:TGadget)
	SetGraphics CanvasGraphics(canvas)
	SetVirtualResolution ClientWidth(canvas), ClientHeight(canvas)
	SetViewport 0, 0, ClientWidth(canvas), ClientHeight(canvas)
End Function
