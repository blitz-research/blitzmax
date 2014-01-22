




' -----------------------------------------------------------------------------
' MAKE SURE "Threaded Build" IS CHECKED IN THE Program -> Build Options menu!
' -----------------------------------------------------------------------------


' You may have to tell your firewall to let this program through...



' -----------------------------------------------------------------------------
' Global mutex and abort 'signal' checked in thread...
' -----------------------------------------------------------------------------
Global abortmutex:TMutex = CreateMutex ()
Global abort = 0

' -----------------------------------------------------------------------------
Global Bail = 3 ' How many times to attempt download of each image...
' -----------------------------------------------------------------------------

' Number of image URLs in array below...

Const PicNum = 7
Global Pic$ [PicNum]

Pic [0] = ConvURL ("http://www.blitzbasic.com/img/platypus.jpg")
Pic [1] = ConvURL ("http://www.blitzbasic.com/img/auto_cross_racing.jpg")
Pic [2] = ConvURL ("http://www.blitzbasic.com/img/super_gerball.jpg")
Pic [3] = ConvURL ("http://www.blitzbasic.com/img/tank_universal.jpg")
Pic [4] = ConvURL ("http://www.blitzbasic.com/img/tecno.jpg")
Pic [5] = ConvURL ("http://www.blitzbasic.com/img/master_of_defence.jpg")
Pic [6] = ConvURL ("http://www.blitzbasic.com/img/kingdom_elemental_tactics.jpg")

' -----------------------------------------------------------------------------
' D E M O . . .
' -----------------------------------------------------------------------------

AppTitle = "Threaded image downloader..."

Graphics 640, 480
SetClsColor 64, 96, 128
AutoMidHandle True

' -----------------------------------------------------------------------------
' Player type stores downloaded images and their co-ords...
' -----------------------------------------------------------------------------

Type Player

	Field x:Float = Rnd (GraphicsWidth ())
	Field y:Float = Rnd (GraphicsHeight ())

	Field xs:Float = Rnd (10)
	Field ys:Float = Rnd (10)

	Field ang:Float = Rnd (360)
	Field angspeed:Float = Rnd (-5, 5)
	
	Field scale:Float = Rnd (1.0, 3.0)
	
	Field image:TImage

End Type

' -----------------------------------------------------------------------------
' List of Player objects...
' -----------------------------------------------------------------------------

PlayerList:TList = CreateList ()

' -----------------------------------------------------------------------------
' Spawn first thread...
' -----------------------------------------------------------------------------

index = 0 ' Picture index in Pic [] array...

Print ""; Print "Downloading " + Pic [index]

pixthread:TThread = CreateThread (DownloadPixmap, Pic [index])

alldone = 0

Repeat

	' This variable is set when all images have been downloaded:
		
	If Not alldone

		If Not ThreadRunning (pixthread)

			' WaitThread contains the result of the last thread (now finished)...
			
			pix:TPixmap = TPixmap (WaitThread (pixthread))
	
			' If a valid pixmap was returned, create a new 'Player' object
			' and load the pixmap as an image...
			
			If pix
				p:Player = New Player
				p.image = LoadImage (pix)
				ListAddLast PlayerList, p
			EndIf

			' Check we still have more images to load...
				
			If index < PicNum - 1
			
				' OK... next!
				
				index = index + 1
				
				Print ""; Print "Downloading " + Pic [index]
				
				' Last image thread is done/processed, so create a new one!
				
				pixthread = CreateThread (DownloadPixmap, Pic [index])
				
			Else
				Print ""; Print "All images loaded!"
				alldone = 1 ' All images in array loaded!
			EndIf

		EndIf

	EndIf

	Cls

	' Draw all loaded images...
	
	For p:Player = EachIn PlayerList

		p.x = p.x + p.xs
		If p.x < 0 Or p.x > GraphicsWidth () - 1
			p.xs = -p.xs
		EndIf

		p.y = p.y + p.ys
		If p.y < 0 Or p.y > GraphicsHeight () - 1
			p.ys = -p.ys
		EndIf

		SetScale p.scale, p.scale

		p.ang = p.ang + p.angspeed
		SetRotation p.ang

		DrawImage p.image, p.x, p.y
	
		SetScale 1, 1
		SetRotation 0
		
		If alldone
			txt$ = "All images loaded!"
		Else
			txt$ = "Loading images in background..."
		EndIf
		
		SetColor 0, 0, 0
		DrawText txt$, 20, 20
		SetColor 255, 255, 255
		DrawText txt$, 18, 18
		
	Next
	
	Flip

Until KeyHit (KEY_ESCAPE)

' Lock the abort mutex so we can safely modify the global abort variable, which
' is then checked by the thread to allow a safe exit...

LockMutex abortmutex
	abort = True
UnlockMutex abortmutex

' The mutex is unlocked by the DownloadPixmap thread before returning,
' but it may already have exited. I think, hence the UnlockMutex above,
' just in case...

' Now wait to make sure the thread has finished...

WaitThread pixthread

' Done!

End

' -----------------------------------------------------------------------------
' Threaded pixmap downloader...
' -----------------------------------------------------------------------------

Function DownloadPixmap:TPixmap (data:Object)

	img$ = String (data)
	
	Local pix:TPixmap		' Downloaded pixmap...
	
	Local url:TStream		' Download stream...
	Local copy:TStream		' Local copy of download...
	
	Local count:Int		' Byte count during download...
	
	Local retry:Int		' If download fails, retry 'Bail' times...
	Local quit:Int			' Too many fails, exit...
	
	Repeat

		Print ""
		Print "Attempting new download..."
		Print ""
		
		url = ReadStream (img$)

		If url

			' Create local copy...
			
			copy = WriteStream ("local.jpg")
			
			If copy
			
				' Reset byte count...
				
				count = 0

				Repeat

					' Try to lock mutex, to check global abort variable, which
					' is set to True before exiting program...
					
					LockMutex abortmutex
					
					If abort
						
						' Aaaaaaahhhh!!! We're going down!!!

						UnlockMutex abortmutex
						
						' Close all streams! Batten down the hatches!
						
						CloseStream url
						CloseStream copy
						
						' Abandon ship!
						
						Return Null

					Else

						' Not aborting, so unlock the mutex...
						
						UnlockMutex abortmutex
						
						' Not every efficient (one byte at a time), but works as a demo...
						
						WriteByte copy, ReadByte (url)

						' Count bytes downloaded...
						
						count = count + 1
						If count Mod 1024 = 0 Then Print count + " bytes downloaded in background"

					EndIf

				Until Eof (url)

				CloseStream copy

				' Try to load pixmap...
				
				pix = LoadPixmap ("local.jpg")
				
			EndIf
						
			CloseStream url

		EndIf

		' Download failed? Retry 'Bail' times...
		
		If pix = Null

			retry = retry + 1

			If retry = Bail
			
				quit = True
				Print "Failed to download after " + Bail + " attempts..."
			
			Else
			
				Print "Retrying..."
				
			EndIf

		EndIf
				
	Until pix Or quit

	If pix = Null
		DebugLog "Oops... problem loading " + img$
	EndIf
	
	Return pix ' May still be Null after 'Bail' failed attempts...
	
End Function

' Convert real URL to BlitzMax stream-friendly URL...

Function ConvURL$ (url$)
	Return Replace (url$, "://", "::")
End Function
