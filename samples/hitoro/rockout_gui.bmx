
' Hacked-into-GUI version! It's not pretty, but still, it's only meant to
' demonstrate a windowed game with GUI!

' -----------------------------------------------------------------------------
' RockOut -- Rocket BlockOut
' -----------------------------------------------------------------------------
' Public domain source code by James L Boyd (support @ blitzbasic . com)
' -----------------------------------------------------------------------------
' Rocket image © 2004 James L Boyd, with permission granted for freeware/PD use,
' not that anyone'd really want it anyway...!
' -----------------------------------------------------------------------------

' -----------------------------------------------------------------------------
' Constants...
' -----------------------------------------------------------------------------

' Sizes used for blocks...
Import MaxGUI.Drivers

Const BLOCKWIDTH = 32
Const BLOCKHEIGHT = 16

' -----------------------------------------------------------------------------
' Include media...
' -----------------------------------------------------------------------------

' Sounds (all from Yamaha RM1X!)...

Incbin "sounds/shot.ogg"		' Player shot
Incbin "sounds/fall.ogg"		' Block fall
Incbin "sounds/hit.ogg"			' Block/player hit
Incbin "sounds/beep.ogg"		' 'Press space' sound
Incbin "sounds/gameover.ogg"		' Guess...

' Graphics...

Incbin "gfx/boing.png"			' Rocket
Incbin "gfx/land.png"			' Background (used to be land, now a grid)
Incbin "gfx/shot.png"			' Player's shot
Incbin "gfx/block.png"			' Guess...

' -----------------------------------------------------------------------------
' Types (object definitions)...
' -----------------------------------------------------------------------------

' GravityItem: all objects affected by gravity are based upon this...

Type GravityItem

     ' ------------------------------------------------------------------------
     ' Type-specific globals...
     ' ------------------------------------------------------------------------

     ' Why not make these truly global? It's cleaner -- you can just copy and
     ' paste the type definition into a completely different program without
     ' having to remember which globals are related...

     Global GCount                     ' Count of all GravityItems (for debugging)
     Global GravityItemList:TList      ' List used for all GravityItem objects
     Global Gravity# = 0.05            ' Gravity applied to all GravityItems

     ' ------------------------------------------------------------------------
     ' Type fields...
     ' ------------------------------------------------------------------------

     Field x#                          ' x position of object
     Field y#                          ' y position of object
     Field xs#                         ' x speed of object
     Field ys#                         ' y speed of object

     Field width                       ' Width of object
     Field height                      ' Height of object

     Field damage                      ' Damage caused by this item if it hits player
     Field fixed = False               ' Is object fixed in place? Blocks are, at first...

     Field r, g, b

     ' ------------------------------------------------------------------------
     ' Type functions...
     ' ------------------------------------------------------------------------

     Function UpdateAll ()
              If GravityItemList = Null Then Return
              If Shadows_On Then Block.DrawShadows ' Shadows_On is a global...
              For g:GravityItem = EachIn GravityItemList
                  g.Update
                  g.Draw
              Next
     End Function

'	Function DrawAll ()
'              If Shadows_On Then Block.DrawShadows ' Shadows_On is a global...
'              For g:GravityItem = EachIn GravityItemList
'                  g.Draw
'              Next
'	End Function
	
     ' ------------------------------------------------------------------------
     ' Type methods...
     ' ------------------------------------------------------------------------

     ' The New method is special -- Blitz calls it whenever a new object is
     ' created...

     ' Every time a new GravityItem is created -- including objects that extend
     ' GravityItem -- this is called. In this case, it creates the type-global
	' list if it doesn't yet exist (only happens once), and adds the item to it...

     Method New ()
            If GravityItemList = Null Then GravityItemList = New TList
            GravityItemList.AddLast Self
            GCount = GCount + 1
     End Method

     ' Destroy current object and remove from list
     Method Destroy ()
            GravityItemList.Remove Self
            GCount = GCount - 1
     End Method

     ' Rectangle-based collision test of current object and player.
     
     ' 'The multiplier' parameter controls how much of an object's
     ' 'damage' field applies to the player -- in the case of Block
     ' objects, the more they're faded out, the less damage they do...

     ' The 'posyonly' parameter is a hack to stop Shot objects damaging
     ' the player while going up...

     Method PlayerCollide (multiplier# = 1, posyonly = 0)

            ' Offset x/y position of shots (all images' handles are centered)...

            ox = x - width / 2
            oy = y - height / 2

            ' Offset x/y position of player...

            opx = PlayerOne.x - PlayerOne.width / 2
            opy = PlayerOne.y - PlayerOne.height / 2

            ' Hack to stop Shot objects damaging player while going up...

            check = 1

            If posyonly
               If ys < 0
                  check = 0
               EndIf
            EndIf

            ' Test for collision, apply damage and make explosion...

            If check
               If OverLap (ox, oy, ox + width, oy + height, opx, opy, opx + PlayerOne.width, opy + PlayerOne.height)
                  PlayerOne.shields = PlayerOne.shields - damage * multiplier
                  ExplosionParticle.Explode x, y, damage * 5 * multiplier
                  PlayerOne.damaged = MilliSecs ()
                  Return True
               EndIf
            EndIf

     End Method

     ' There is no default Draw method here, as it's different for each extended type
     ' of GravityItem, so I've defined it as Abstract...

     ' Abstract forces every type that extends GravityItem to have a Draw () method defined
     ' or the code simply won't compile...

     ' One practical use for this is that you can call Draw from any random GravityItem,
     ' regardless of which extended type it is, and this will call the correct Draw ()
     ' for the type of object in question...

     Method Draw () Abstract

     ' Abstract Update method for GravityItems. See Draw () explanation...

     Method Update () Abstract

End Type

' Particles created in an explosion. This type extends GravityItem, meaning all
' properties of GravityItem apply, except where methods are over-ridden
' (ie. re-defined) here...

Type ExplosionParticle Extends GravityItem

     ' ------------------------------------------------------------------------
     ' Type fields...
     ' ------------------------------------------------------------------------

     ' No need to define, x, y, xs, ys, etc as they're part of the GravityItem definition...

     Field alph# = 1.0          ' Alpha level of particle (translucency)

     ' ------------------------------------------------------------------------
     ' Type functions...
     ' ------------------------------------------------------------------------

     ' Create explosion of particles, and play sound...

     Function Explode (x#, y#, particles)

              ' NB. GW2 is a global set to half of GraphicsWidth ()...

              If Sounds_On
                 pan# = x / GW2 - 1.0
                 play = CueSound (hit)
                 SetChannelPan play, pan
                 ResumeChannel play
              EndIf

              For loop = 1 To particles
                  ExplosionParticle.Create (x, y)
              Next

     End Function

     ' Create single explosion particle. Note that any items extending GravityItem
     ' will call the New () method from GravityItem upon creation, so these will
     ' be added to the GravityItem list automatically...

     Function Create:ExplosionParticle (x, y)

              e:ExplosionParticle = New ExplosionParticle
              e.x = x
              e.y = y
              e.xs = Rnd (-8, 8)
              e.ys = Rnd (-8, 8)

              ' Random colour...

              Select Rand (0, 3)
                     Case 0
                          e.r = 255
                          e.g = 255
                          e.b = 255
                     Case 1
                          e.r = 255
                          e.g = 127
                          e.b = 0
                     Case 2
                          e.r = 255
                          e.g = 255
                          e.b = 0
                     Case 3
                          e.r = 255
                          e.g = 0
                          e.b = 0
              End Select

              ' Random size...

              size = Rand (1, 8)
              e.width = size
              e.height = size

     End Function

     ' ------------------------------------------------------------------------
     ' Type methods...
     ' ------------------------------------------------------------------------

     ' Update () over-rides the GravityItem Update () method...

     Method Update ()

        ' Reduce alpha level of particle...

        alph = alph - 0.01

        ' Apply Gravity global (see GravityItem) to y speed...

        ys = ys + Gravity

        ' Move particle by current speed...

        x = x + xs
        y = y + ys
        
        ' If off-screen or reduced to invisible, remove from list by
        ' calling the Destroy method (inherited from GravityItem)...

        If y > GraphicsHeight () Or alph = 0 Then Destroy

     End Method

     ' Draw particle...

     Method Draw ()

            SetScale 1, 1

            SetBlend ALPHABLEND

            SetAlpha alph
            SetColor r, g, b
            DrawRect x, y, width, height

     End Method

End Type

' Block definition. Again, Block is a kind of GravityItem...

Type Block Extends GravityItem

     ' ------------------------------------------------------------------------
     ' Type-specific globals...
     ' ------------------------------------------------------------------------

     Global BCount            ' Number of blocks

     ' ------------------------------------------------------------------------
     ' Type-specific fields...
     ' ------------------------------------------------------------------------

     Field alph# = 1.0        ' Alpha level of block
     Field ang#               ' Rotation of block
     Field angspeed#          ' Rotation speed of block
     Field desty#

     ' ------------------------------------------------------------------------
     ' Type-specific function...
     ' ------------------------------------------------------------------------

     ' Create a Block object (added to GravityItem list automatically)...

     Function Create:Block (x, y)
              blk:Block = New Block
              blk.x = x
              blk.y = y
              blk.desty = y
              blk.width = BLOCKWIDTH
              blk.height = BLOCKHEIGHT
              blk.fixed = True
              blk.damage = 20
              BCount = BCount + 1
              Return blk
     End Function

     ' ------------------------------------------------------------------------
     ' Type-specific methods...
     ' ------------------------------------------------------------------------

     ' Update () method for Block objects...

     Method Update ()

            ' Check for collision (passing alpha level of block to apply
            ' appropriate damage), and remove from GravityItem list if hit...

            If PlayerCollide (alph) Then BCount = BCount - 1; Destroy; Return

            ' If the block has been freed (by being hit), make it fall...

            If Not fixed

               alph = alph - 0.0075; If alph < 0 Then alph = 0
               ang = ang + angspeed; If ang > 359 Then ang = 0
               ys = ys + Gravity
               x = x + xs
               y = y + ys

               If y > GraphicsHeight () Or alph = 0 Destroy; BCount = BCount - 1

            Else

                ' When blocks are lowered in main loop, they are just set to 'desty',
                ' their new y-position destination. This moves them towards that...

                ydist# = desty - y
                ys = ydist / 12.0
                y = y + ys

            EndIf

     End Method

     ' Block-specific Draw () method...

     Method Draw ()

            SetBlend ALPHABLEND
            SetRotation ang

            SetColor r, g, b
            SetAlpha alph

            DrawImage BlockImage, x, y

            SetRotation 0

     End Method

     Function DrawShadows ()
              SetBlend ALPHABLEND
              For blk:Block = EachIn GravityItemList
                   SetRotation blk.ang
                   SetColor 0, 0, 0
                   SetAlpha blk.alph * 0.25
                   DrawImage BlockImage, blk.x + 8, blk.y + 8
              Next
     End Function

End Type

' Player object. Only one player possible right now, but this keeps everything
' together for easy reference...

Type Player

     Field damaged    ' Set to MilliSecs () when hit (used for flashing effect)

     ' ------------------------------------------------------------------------
     ' Type-specific fields...
     ' ------------------------------------------------------------------------

	' The shields field is a float so I can reduce by small amounts, but I use
	' Int (PlayerOne.shields) to display/evaluate it...

     Field shields# = 100

     Field x#
     Field y#
     Field xs#
     Field ys#

     Field image      ' Player image...

     Field width
     Field height

     ' ------------------------------------------------------------------------
     ' Type-specific functions...
     ' ------------------------------------------------------------------------

	' Create () is a function that creates & returns a :Player type object...

     Function Create:Player (x, y, image)
              PlayerOne:Player = New Player
              PlayerOne.image = image
              PlayerOne.x = x
              PlayerOne.y = y
              PlayerOne.width = ImageWidth (PlayerOne.image) * 0.2     ' Image is scaled in Draw ()
              PlayerOne.height = ImageHeight (PlayerOne.image) * 0.2
              Return PlayerOne
     End Function

     ' ------------------------------------------------------------------------
     ' Type-specific methods...
     ' ------------------------------------------------------------------------

     ' This is passed the MouseX () and MouseY () positions in the main game
	' loop, and hence moves the player toward the mouse cursor...

     Method Move (destx#, desty#, div#)
            xdist# = destx - x
            ydist# = desty - y
            xs = xdist / div
            ys = ydist / div
            x = x + xs
            y = y + ys
     End Method

     Method Draw (alpha# = 1, r = 255, g = 255, b = 255)

            SetBlend ALPHABLEND
            SetScale 0.2, 0.2

            If Shadows_On
               SetColor 0, 0, 0
               SetAlpha alpha * 0.4
               DrawImage image, x + 8, y + 8
            EndIf

            SetAlpha alpha

		' If player is damaged, rgb will be RED...

            SetColor r, g, b
            DrawImage image, x, y
            SetScale 1, 1

     End Method

End Type

Type Shot Extends GravityItem

     ' ------------------------------------------------------------------------
     ' Type-specific functions...
     ' ------------------------------------------------------------------------

     Function Create:Shot (x#, y#, ys#, xs#, soundpan#)
            If Sounds_On
               play = CueSound (shoot)
               SetChannelPan play, soundpan
               ResumeChannel play
            EndIf
            s:Shot = New Shot
            s.x = x
            s.y = y
            s.xs = xs
            s.ys = ys
            s.width = 6
            s.height = 6
            s.damage = 2
            Return s
     End Function

     ' ------------------------------------------------------------------------
     ' Type-specific methods...
     ' ------------------------------------------------------------------------

     ' Over-ride standard GravityItem Update () method...

     Method Update ()

        ' Hit the player (note 'posyonly', 2nd parameter, of PlayerCollide)...

        If PlayerCollide (1, 1) Then Destroy; Return

        ys = ys + Gravity
        x = x + xs
        y = y + ys

        ' Remove if below bottom of screen...

        If y > GraphicsHeight ()

           Destroy

        Else

            ' Check current Shot against all Blocks...

            ' (Notice that this only checks Block objects in the list!)

            For blk:Block = EachIn GravityItemList

                ' Get x offset (rectangles are mid-handled)...

                ox = x - width / 2
                oy = y - height / 2

                ogx = blk.x - blk.width / 2
                ogy = blk.y - blk.width / 2

                ' Check collision...

                If OverLap (ox, oy, ox + width, oy + height, ogx, ogy, ogx + blk.width, ogy + blk.height)

                   ' If Block is already dead (ie. falling), reflect Shot, otherwise
                   ' un-fix block and create explosion...

                   ' Note: ys is current Shot object's y speed...

                   If blk.fixed = False
                      ys = -ys
                   Else
                      blk.fixed = False
                      blk.ys = ys / Rnd (1, 4)
                      blk.angspeed = Rnd (-4, 4)
                      ExplosionParticle.Explode ogx, ogy, 4
                   EndIf

                EndIf

            Next

        EndIf

     End Method

     Method Draw ()
            SetBlend MASKBLEND
            SetAlpha 1
            SetColor 255, 255, 255
            DrawImage ShotImage, x, y
     End Method

End Type

' The random debris that falls 'down' the screen...

Type DebrisItem

     ' ------------------------------------------------------------------------
     ' Type-specific fields...
     ' ------------------------------------------------------------------------

     Field x# = Rand (0, GraphicsWidth () - 1)
     Field y# = Rand (0, GraphicsHeight () - 1)
     Field ys# = Rnd (0.01, 8)
     Field size = Rand (1, 2)

     ' ------------------------------------------------------------------------
     ' Type-specific methods...
     ' ------------------------------------------------------------------------

     Method Update ()
            If y > GraphicsHeight () y = 0
            y = y + ys
     End Method

	Method Draw ()
            SetColor Rnd (127, 255), Rnd (127, 255), 255
            SetBlend SOLIDBLEND
            DrawRect x, y, size, size
	End Method
	
End Type

' -----------------------------------------------------------------------------
' Functions...
' -----------------------------------------------------------------------------

' Draw simple text with shadow...

Function DrawShadowText (t$, x, y)
      SetColor 0, 0, 0
      DrawText t$, x + 1, y + 1
      SetColor 255, 255, 255
      DrawText t$, x, y
End Function

' Returns "Off" if 'status' is 0, otherwise "On"...

Function OnOff$ (status)
         If status Then Return "On" Else Return "Off"
End Function

' Phew! Thanks, Birdie! Rectangular overlap function. Should have been so easy...

Function OverLap (x0, y0, x1, y1, x2, y2, x3, y3)
	If x0 > x3 Or x1 < x2 Then Return False
 	If y0 > y3 Or y1 < y2 Then Return False
 	Return True
End Function

' Distance between two points...

Function Dist# (x0#, y0#, x1#, y1#)
         Return Sqr (((x1 - x0) * (x1 - x0)) + ((y1 - y0) * (y1 - y0)))
End Function

' -----------------------------------------------------------------------------
' Main game. This is where it all goes pear-shaped!
' -----------------------------------------------------------------------------

' Open display...

'Graphics 640, 480, 32

x = GadgetWidth (Desktop ()) / 2 - 320
y = GadgetHeight (Desktop ()) / 2 - 240

window = CreateWindow ("RockOut GUI", x, y, 640, 480, Null, WINDOW_TITLEBAR)
If Not window Notify "Couldn't open window!"; End

canvas:TGadget = CreateCanvas (0, 0, ClientWidth (window), ClientHeight (window) - 48, window)
If Not canvas Notify "Couldn't create canvas!"; End

SetGraphics CanvasGraphics (canvas)

' Buttons...

y = ClientHeight (window) - 24
width = ClientWidth (window) / 4

tbackground:TGadget	= CreateButton ("Toggle background", 0, y, width, 24, window)
tdebris:TGadget		= CreateButton ("Toggle debris", width, y, width, 24, window)
tshadows:TGadget = CreateButton ("Toggle shadows", width * 2, y, width, 24, window)
tsounds:TGadget = CreateButton ("Toggle sounds", width * 3, y, width + 2, 24, window)

tslabel:TGadget = CreateLabel ("Shields:", 20, y - 22, 60, 20, window, LABEL_CENTER)' | LABEL_FRAME)
tshields:TGadget = CreateProgBar (100, y - 24, ClientWidth (window) - 100, 20, window)

' Pre-calc half of graphics width...

Global GW2 = GraphicsWidth () / 2
Global GH2 = GraphicsHeight () / 2

' Set Cls colour (used when background turned off)...

SetClsColor 64, 96, 128

' All images' and rectangles' handles should be set to the centre...

AutoMidHandle True
SetHandle 0.5, 0.5

' All images unfiltered...

'AutoImageFlags MASKEDIMAGE

' Mask colour for loaded images (will be transparent)...

SetMaskColor 255, 0, 255

' Mouse position -- used in some type methods and functions, hence global...

Global mx, my

' Player object...

Global PlayerOne:Player

' Draw shadows?

Global Shadows_On = True

' Turn off sound?

Global Sounds_On = True

' Load media -- sounds, from included binaries (see start of code)...

Global shoot = LoadSound ("incbin::sounds/shot.ogg")
Global hit   = LoadSound ("incbin::sounds/hit.ogg")
Global beep  = LoadSound ("incbin::sounds/beep.ogg")
Global over  = LoadSound ("incbin::sounds/gameover.ogg")

' Load media -- images, from included binaries...

' Shots...

Global ShotImage = LoadImage ("incbin::gfx/shot.png")

' Blocks...

' Note there is only one image for all blocks -- they are altered by SetColorRGB before
' drawing (WHITE gives normal image)...

Global BlockImage = LoadImage ("incbin::gfx/block.png")

' Player...

pimage = LoadImage ("incbin::gfx/boing.png",MASKEDIMAGE|MIPMAPPEDIMAGE)

' Background...

' Note that bgscale stores the length of the screen diagonal, and this value is used
' for the image height, so it doesn't get chopped when it rotates...

bg = LoadImage ("incbin::gfx/land.png")
bgscale# = Dist (0, 0, GraphicsWidth () - 1, GraphicsHeight () - 1) / ImageHeight (bg)

' Background angle/speed of rotation...

bgang# = 0
bgangspeed# = 0

' Create an array of 100 debris particles...

Local debris:DebrisItem [100]
For loop = 0 Until 100
    debris [loop] = New DebrisItem
Next

' This should probably read 'rows' -- the number of rows of blocks at startup...

layers = 5

' Toggle variables for drawing background, debris and wireframe mode...

bgtoggle = 1
debristoggle = 1
wftoggle = 0

' Delay before adding another row of blocks (this is decreased as the game progresses)...

rowdelay = 10000 ' 10 seconds (10000 milliseconds)...

' Background colour and first target colour...

backr# = 64
backg# = 96
backb# = 180

backtr# = 128
backtg# = 32
backtb# = 48

' Delay between colour increments...

backstep# = 5000

' Colour increments...

backstepr# = (backtr - backr) / backstep
backstepg# = (backtg - backg) / backstep
backstepb# = (backtb - backb) / backstep

' Direction of increment to target colour...

backsgn = Sgn (backtr - backr)

mx = GraphicsWidth () / 2
my = GraphicsHeight () / 2
MoveMouse mx, my

timer = CreateTimer (60)

' This is the point where the game is re-started from, whenever a level is completed or game ended...

#ResetLevel ' $name signifies a label now...

' Increase level number (level is 0 on startup, so becomes 1 for first level)...

level = level + 1

' Reset the 'new row' delay timer to the current time...

rowtimer = MilliSecs ()

' Set fire rate limiter to current time...

firetimer = MilliSecs ()

' Create rows of blocks...

For y = 0 To layers - 1
    For x = 0 Until GraphicsWidth () Step BLOCKWIDTH
        b:Block = Block.Create (x + BLOCKWIDTH / 2, (y * BLOCKHEIGHT) + BLOCKHEIGHT / 2)
        b.r = Rnd (127, 255)
        b.g = Rnd (127, 255)
        b.b = Rnd (127, 255)
    Next
Next

' Minimum number of blocks left before we *stop* dropping them down (equivalent of 2 rows)...

lowblocks = 2 * (GraphicsWidth () / BLOCKWIDTH)

' When a level is completed, we delete the player object for simplicity of resetting
' all its values. This creates it (same for game startup)...

If PlayerOne = Null Then PlayerOne = Player.Create (mx, my, pimage)

' Game text and precalculated x offsets...

go$ = "G A M E   O V E R   --   H I T   S P A C E   O R   R M B"
wd$ = "W E L L   D O N E   --   H I T   S P A C E   O R   R M B"

gox = (GraphicsWidth () / 2) - (TextWidth (go$) / 2)
wdx = (GraphicsWidth () / 2) - (TextWidth (wd$) / 2)

ActivateGadget canvas

firing = 0
HideMouse

firstgo = 1

Repeat

	' Mac compatibility fix...
	
'	SetGraphics CanvasGraphics (canvas)

		WaitEvent
		
      ' Clear the screen...

      Cls

      ' Store mouse position in these global variables...

		Select EventID ()
		
			Case EVENT_MOUSEENTER
				If EventSource () = canvas Then HideMouse

			Case EVENT_MOUSELEAVE
				If EventSource () = canvas Then ShowMouse
			
			Case EVENT_TIMERTICK
				'Print "Tick!"
				RedrawGadget canvas
				
			Case EVENT_GADGETPAINT
				draw = 1
				
			Case EVENT_MOUSEDOWN
				If EventData () = 1
					firing = 1
				EndIf
				
			Case EVENT_MOUSEUP
				firing = 0
				If EventData () = 2
					spacehit = 1
				EndIf
					
			Case EVENT_MOUSEMOVE
			      mx = EventX ()
	    		  my = EventY ()

			Case EVENT_KEYUP
	
		      ' -----------------------------------------------------------------------
		      ' Toggles...
		      ' -----------------------------------------------------------------------
		
				Select EventData ()
					Case KEY_ESCAPE
						End
					Case KEY_SPACE
						spacehit = 1
				End Select
			
		Case EVENT_GADGETACTION

			Select EventSource ()
				Case tbackground:TGadget	
					bgtoggle = 1 - bgtoggle
				Case tdebris:TGadget
					debristoggle = 1 - debristoggle
				Case tshadows:TGadget
					Shadows_On = 1 - Shadows_On
				Case tsounds:TGadget
					Sounds_On = 1 - Sounds_On
			End Select
			
			ActivateGadget canvas ' Get event focus back!
			
		End Select

      ' -----------------------------------------------------------------------
      ' Background...
      ' -----------------------------------------------------------------------

	If draw ' EVENT_GADGETPAINT received...
	
      ' Update background rotation...

      bgang = bgang + bgangspeed; If bgang > 359 - bgangspeed Then bgang = 0
      bgangspeed = bgangspeed + 0.0001

      ' The bgtoggle variable controls whether the background should be drawn or not...

      If bgtoggle

              ' Change colour by pre-calculated increment...

              backr = backr + backstepr
              backg = backg + backstepg
              backb = backb + backstepb

              ' Reached target colour? Set a new target/increments/increment-direction...

              If backr => backtr * backsgn
                  backtr = Rnd (255)
                  backtg = Rnd (255)
                  backtb = Rnd (255)
                  backstepr# = (backtr - backr) / backstep
                  backstepg# = (backtg - backg) / backstep
                  backstepb# = (backtb - backb) / backstep
                  backsgn = Sgn (backtr - backr)
              EndIf

      EndIf

      ' When the player is hit, the 'damaged' field is set to the current time.
      ' This code checks if a second has passed since 'damaged'. If so, it draws
	' the player normally; if not, the player is drawn in red, with varying
	' transparency...

      If MilliSecs () > PlayerOne.damaged + 1000 ' Damage timeout has passed...

         ' Draw normally...

         PlayerOne.damaged = 0 ' Resetting damage time...
         alpha# = 1
         rcol = 255; gcol = 255; bcol = 255

      Else

          ' Flash player for 1 second if hit...

          alpha# = Sin (MilliSecs ())
          rcol = 255; gcol = 0; bcol = 0

      EndIf

      ' -----------------------------------------------------------------------
      ' If player is alive, do stuff...
      ' -----------------------------------------------------------------------

      If Int (PlayerOne.shields) > 0 ' Shields is a float, so gotta round it...

         ' Player is alive...

         ' If more than 'lowblocks' left on screen, add a row and lower all
         ' blocks. Reset drop-down timer and reduce delay for next drop-down...

         If Block.BCount > lowblocks And MilliSecs () > rowtimer + rowdelay

            ' Add a row of blocks, above top of screen...

            For x = 0 Until GraphicsWidth () Step BLOCKWIDTH
                b:Block = Block.Create (x + BLOCKWIDTH / 2, -BLOCKHEIGHT / 2)
                b.r = Rnd (127, 255)
                b.g = Rnd (127, 255)
                b.b = Rnd (127, 255)
            Next

            ' Set all blocks' target y position down by block height. When blocks
            ' are updated, they get moved towards this new position...

            For b:Block = EachIn GravityItem.GravityItemList
                b.desty = b.desty + BLOCKHEIGHT
            Next

            ' Reset timeout until a new row is added...

            rowtimer = MilliSecs ()

            ' Reduce row-down timeout a bit...

            If rowdelay => 1100 Then rowdelay = rowdelay - 100 ' Minimum 1 sec interval!

         EndIf

         ' --------------------------------------------------------------------
         ' Fire shot (maximum fire rate 75 milliseconds)...
         ' --------------------------------------------------------------------

         If firing 'MouseDown (1)
            If MilliSecs () > firetimer + 75
               pan# = PlayerOne.x / GW2 - 1.0
               s:Shot = Shot.Create (PlayerOne.x, PlayerOne.y - (PlayerOne.height / 2 + 5), -5, PlayerOne.xs / 5.0, pan)
               firetimer = MilliSecs ()
            EndIf
         EndIf

         ' --------------------------------------------------------------------
         ' No blocks left?
         ' --------------------------------------------------------------------

         ' Set 'welldone' flag (text shows "Well done" below if True);

         ' If there are no blocks and Space is hit, delete all GravityItems,
         ' reduce block count, increase number of block rows and reset level...

         If Block.BCount = 0

            ' Will display 'well done' message further down...

            welldone = True

            ' Remove all items (and reduce block count)...

            For g:GravityItem = EachIn GravityItem.GravityItemList
                If Block (g) Then Block.BCount = Block.BCount - 1
                g.Destroy
            Next

            ' If space is hit, add some layers and reset everything (new level)...

            If spacehit'KeyHit (KEY_SPACE) Or MouseHit (2)
               If Sounds_On Then PlaySound beep
               layers = layers + 3
               Goto ResetLevel
            EndIf

         EndIf

      Else

          If gameoverplayed = 0
             If Sounds_On Then PlaySound over
             gameoverplayed = 1
          EndIf

          ' Player is dead...

          PlayerOne.shields = 0 ' Force to zero as can be reduced after game is over...

          gameover = True

          ' Remove all blocks...

          For b:Block = EachIn GravityItem.GravityItemList
              b.Destroy
              Block.BCount = Block.BCount - 1
          Next

          ' -------------------------------------------------------------------
          ' If player is dead and Space hit...
          ' -------------------------------------------------------------------

          ' Space hit... remove everything else and reset to initial settings...

          If spacehit'KeyHit (KEY_SPACE) Or MouseHit (2)

             If Sounds_On Then PlaySound beep

             For g:GravityItem = EachIn GravityItem.GravityItemList
                 g.Destroy
             Next

             ' Delete player (recreated when level is reset)...

             PlayerOne = Null
             layers = 5
             bgang = 0
             bgangspeed = 0
             level = 0
             rowdelay = 10000

             gameoverplayed = 0

             Goto ResetLevel

          EndIf

      EndIf

      If debristoggle
         For loop = 0 Until 100
             debris [loop].Update
         Next
      EndIf


	
		If bgtoggle
		              ' Set colour of background image (applied to the greyscale default)...
		
		              SetColor backr, backg, backb
		
		              ' Set the background's pre-calculated scale...
		
		              SetScale bgscale, bgscale
		              SetRotation bgang
		              SetAlpha 1
		
		              DrawImage bg, GW2, GH2
		
		              ' Reset this stuff so next drawn items don't have to...
		
		              SetRotation 0
		              SetScale 1, 1
		
		              ' Put back to wireframe/non-wireframe mode, depending on value of 'wftoggle'...
		
		'              WireFrame wftoggle
		EndIf
	
	      ' -----------------------------------------------------------------------
	      ' Debris...
	      ' -----------------------------------------------------------------------
	
	      ' Draw debris particles if 'debristoggle' is True...
	
	      If debristoggle
	         For loop = 0 Until 100
	'             debris [loop].Update
				debris [loop].Draw
	         Next
	      EndIf
	
	      ' -----------------------------------------------------------------------
	      ' Cursor...
	      ' -----------------------------------------------------------------------
	
	      SetColor 255, 255, 255
	      DrawLine mx - 8, my, mx + 8, my
	      DrawLine mx, my - 8, mx, my + 8
	
	      ' -----------------------------------------------------------------------
	      ' Move and draw player...
	      ' -----------------------------------------------------------------------
	
	      ' Move the player object based on mouse position (the '20' controls the
	      ' speed at which the player moves toward the mouse -- play with it;
	      ' lower is faster)...
	
	      PlayerOne.Move (mx, my, 12)
	
	      ' Draw the player using the above values...
	
	      PlayerOne.Draw (alpha, rcol, gcol, bcol)
	
	      ' -----------------------------------------------------------------------
	      ' Update everything...
	      ' -----------------------------------------------------------------------
	
	      GravityItem.UpdateAll
	
	      ' -----------------------------------------------------------------------
	      ' Draw text on top of everything...
	      ' -----------------------------------------------------------------------
	
	      SetAlpha 1
	
	      DrawShadowText "Level: " + level, 20, GraphicsHeight () - 40
	' + " | Shields: " + Int (PlayerOne.shields) + "%"
			UpdateProgBar tshields, Int (PlayerOne.Shields) / 100.0
	      ' Draw extra text if appropriate...
	
	      If gameover
	         DrawShadowText go$, gox, GraphicsHeight () / 2
	         gameover = False
	      Else
	         If welldone
	            DrawShadowText wd$, wdx, GraphicsHeight () / 2
	            welldone = False
	         EndIf
	      EndIf
	
	      ' Display everything that's been drawn to the hidden back buffer...
	
	      Flip
	
		spacehit = 0
		draw = 0
		
	EndIf
	
Until EventID () = EVENT_WINDOWCLOSE

End
