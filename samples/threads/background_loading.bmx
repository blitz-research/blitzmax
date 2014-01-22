




' -----------------------------------------------------------------------------
' MAKE SURE "Threaded Build" IS CHECKED IN THE Program -> Build Options menu!
' -----------------------------------------------------------------------------





' -----------------------------------------------------------------------------
' Loading screen...
' -----------------------------------------------------------------------------

AppTitle = "Multi-threaded loading screen demo..."

' How to display an animated loading screen while loading images...

' Because only the main program thread can interact with DirectX/OpenGL,
' we have to use BlitzMax TPixmaps in the threaded loading routine.

' That's because BlitzMax's TImage is tied to the DirectX/OpenGL 'context',
' while pixmaps are just blocks of memory that the CPU can manipulate.

' After loading from disk, they can be 'loaded' from the in-memory TPixmap
' into proper images via LoadImage.

' You could just use DrawPixmap to skip this step, but you then can't use'
' realtime scaling, rotation, etc.

' The threaded function LoadPixmaps is at the bottom of this code...

' -----------------------------------------------------------------------------
' This is used to simulate slower loading in the LoadPixmaps thread...
' -----------------------------------------------------------------------------

Global TestDelay = 1000 ' Simulating more/larger images, 3D models, etc...

' -----------------------------------------------------------------------------
' Set up global TMap...
' -----------------------------------------------------------------------------

Global Pixmaps:TMap = CreateMap ()

' -----------------------------------------------------------------------------
' Add list of pixmap filenames to be added to the Pixmaps TMap...
' -----------------------------------------------------------------------------

AddPixmap ("bluboing.png")
AddPixmap ("bluegem.png")
AddPixmap ("boing.png")
AddPixmap ("dead.png")
AddPixmap ("greengem.png")
AddPixmap ("redgem.png")

' -----------------------------------------------------------------------------
' Set up display...
' -----------------------------------------------------------------------------

Graphics 640, 480
SetClsColor 32, 96, 128
SetMaskColor 255, 0, 255
AutoMidHandle True

' -----------------------------------------------------------------------------
' Start the LoadPixmaps thread...
' -----------------------------------------------------------------------------

thread:TThread = CreateThread (LoadPixmaps, Null)

' -----------------------------------------------------------------------------
' This is the loading screen! Some movement and colours while pixmaps load...
' -----------------------------------------------------------------------------

r = 0; g = 255; b = 127

' -----------------------------------------------------------------------------
' Do this routine until the thread has finished its work...
' -----------------------------------------------------------------------------

While ThreadRunning (thread) ' Important!

	Cls

	r = r + 8; If r > 255 Then r = 0
	g = g - 4; If g > 255 Then g = 0
	b = b + 2; If b > 255 Then b = 0

	SetColor 0, 0, 0	
	DrawRect MouseX (), MouseY (), 32, 32

	SetColor r, g, b
	DrawRect MouseX (), MouseY (), 30, 30

	SetColor 0, 0, 0
	DrawText "Slow-ding, please wait...", 20, 20
	SetColor 255, 255, 255
	DrawText "Slow-ding, please wait...", 18, 18

	Flip

Wend

' -----------------------------------------------------------------------------
' Right, the thread has finished. Should have a nice TMap filled with pixmaps!
' -----------------------------------------------------------------------------

' Just re-setting colours, 'scuse me...

r = 255; g = 255; b = 255
SetColor r, g, b

' -----------------------------------------------------------------------------
' Create a list of TImage objects and load the pixmaps into them...
' -----------------------------------------------------------------------------

images:TList = CreateList ()

For p$ = EachIn MapKeys (Pixmaps)
	ListAddLast images, LoadImage (TPixmap (MapValueForKey (Pixmaps, p$)))
Next

' In reality, you would probably load each image based on the filename in the
' map. You could just pass each filename you passed to AddPixmap at the start,
' for example (untested)...

' rocket:TImage = LoadImage (TPixmap (MapValueForKey (Pixmaps, "boing.png")))

' -----------------------------------------------------------------------------
' Free the map and all TPixmap objects it holds...
' -----------------------------------------------------------------------------

ClearMap Pixmaps

' -----------------------------------------------------------------------------
' Yay... into the main game! Woo! Fun!
' -----------------------------------------------------------------------------

Repeat

	Cls
	
	x = 0
	y = 0

	SetRotation ang#; ang = ang + 1; If ang > 360 Then ang = 0
	
	' Draw all images...
	
	For i:TImage = EachIn images
	
		DrawImage i, x, y
		x = x + 96
		y = y + 96
	Next

	SetRotation 0

	SetColor 0, 0, 0	
	DrawRect MouseX (), MouseY (), 32, 32
	SetColor 255, 255, 255
	DrawRect MouseX (), MouseY (), 30, 30
	
	SetColor 0, 0, 0	
	DrawText "All done! We're in-game now! Fun, fun, fun...", 20, 20
	SetColor 255, 255, 255
	DrawText "All done! We're in-game now! Fun, fun, fun...", 18, 18

	Flip
	
Until KeyHit (KEY_ESCAPE)

End

' -----------------------------------------------------------------------------
' Helper function for anyone scared of maps...
' -----------------------------------------------------------------------------

Function AddPixmap (p$)

	' Maps are similar to lists, but associated two values with each other;
	' in this case, a filename and a TPixmap pointer, which is Null here.
	
	' The LoadPixmaps function will load the pixmap for each filename in the
	' map, and associated the resulting TPixmap with that filename.
	
	MapInsert (Pixmaps, p$, New TPixmap)
	
End Function

' -----------------------------------------------------------------------------
' The threaded pixmap loading function...
' -----------------------------------------------------------------------------

' No mutexes are needed here since the global Pixmaps:TMap is only accessed by
' the main program after this thread is finished...

Function LoadPixmaps:Object (data:Object)

	' Iterate through the global Map...
	
	For p$ = EachIn MapKeys (Pixmaps)
	
		' Load pixmaps into the existing [Null] TPixmap slots for each
		' filename...

		pix:TPixmap = LoadPixmap (p$)
		MapInsert (Pixmaps, p$, pix)
		
		' Fake delay to simulate loading bigger images for this demo!
		
		Delay TestDelay
		
	Next

End Function

