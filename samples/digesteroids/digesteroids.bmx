' *******************************************************************
' Digesteroids - V1.0
' --------------------------------------------------------
' An evil biscuit corporation are using their army of
' sweet snack food to take over the world. Use your ship
' to take down the evil invading corporation before 
' they infest the world with dunkables sweetmeal biscuits.
' REQUIRES 1024x768x32! @75Hz
' --------------------------------------------------------
' Author: Rob Hutchinson 2004
' Email: rob@proteanide.co.uk
' Written entirely in Protean IDE: 
' WWW: http://www.proteanide.co.uk/
' --------------------------------------------------------
' Yep, there's stuff in here, I didnt get time to implement
' Pickups, Weapons and Vortexes.
' *******************************************************************
	
Strict

' Import various utilities.
Import "simplephysics.bmx"
Import "dynamicgame.bmx"
Import "MathUtil.bmx"

' Screen settings.
Const WIDTH       = 1024    ' Width of the screen.
Const HEIGHT      = 768     ' Height of the screen.
Const DEPTH       = 32      ' Depth of the screen.
Const REFRESHRATE = 75      ' How often to update the screen (Per second).

' Game Settings
Const DYNAMICTIMING = True  ' If true then the game will try to keep up with
Const DESIREDFPS    = 75    ' The Desired FPS of the game, can be independant of Refresh Rate.

Function ScreenPan(OffsetX:Float, OffsetY:Float)
	Local Width,Height,Depth,Hz
	Width=GraphicsWidth()
	Height=GraphicsHeight()
	Depth=GraphicsDepth()
	Hz=GraphicsHertz()
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    glOrtho 0,Width,Height,0,-1,1
    glTranslatef OffsetX, OffsetY,0
    glMatrixMode GL_MODELVIEW
EndFunction

Function QFlushKeys()
	' Quick implementation of flushkeys as BMX doesnt have one at time of writing, sure it
	' will be added though.
	For Local Key:Int = 0 To 255
		KeyHit(Key)
		KeyDown(Key)
	Next
End Function

'#Region Scene: MainMenu
	' The main menu scene.
	Type MainMenuScene Extends T2DDynamicGameScene

'#Region DrawTextCentered
	Function DrawTextCentered:Int(Text:String,Y:Int)
		Local Out:Int = (WIDTH / 2) - (TextWidth(Text) / 2)
		DrawText(Text, Out, Y)
		Return Out
	End Function
'#End Region

'#Region Declarations
		Const STARS_PER_SECOND = 6
		Field BackColor:Float
		Field Direction:Float = 0.01
		Field ExitGame:Int = False
		Field Music:TSound
		Field MusicChannel:TChannel
		Field Title:TImage
		Field LowerTitle:TImage
		Field Options:TImage
		Field Craft:TImage
		Field EnteredText:String = ""
		Field LastHighScore:Int
		Field ShowCredits:Int = False

		Field Viewing:Int = VIEW_MENU
		Field HoverOver:Int = VIEW_START

		Const VIEW_MENU         = 0
		Const VIEW_START        = 0
		Const VIEW_INSTRUCTIONS = 1
		Const VIEW_HIGHSCORES   = 2
		Const VIEW_QUIT         = 3
		Const VIEW_ENTERHIGH    = 4

		Field Stars:TPhysicsProviderCollection = New TPhysicsProviderCollection
		Field World:TWorldPhysicsProvider = TWorldPhysicsProvider.Create(0.0, 0.0, 0.0, True)
'#End Region

'#Region Method: FinishScoreEntry
		Method FinishScoreEntry()
			Self.ViewMenu(VIEW_HIGHSCORES)
			Scores.Add(Self.LastHighScore, Self.EnteredText)

			' Add this to the high scores..
			Self.LastHighScore = 0
			Self.EnteredText = ""
		End Method
'#End Region
'#Region Method: ViewMenu
		Method ViewMenu(Menu:Int)
			Self.Viewing = Menu
			Self.HoverOver = Menu
			QFlushKeys()
		End Method
'#End Region

'#Region Method: Update
		Method Update()
			Self.Stars.ApplyPhysics()

			' Add new stars..
			For Local CountStars:Int = 0 To STARS_PER_SECOND
				Local Star:TMenuStar = TMenuStar.Create(World, Self, 10.0)
				Self.Stars.AddLast(Star)
			Next

			' Do enter key checking..
			Select Self.Viewing
				Case VIEW_MENU
					If KeyHit(KEY_ENTER) Then 
						Select Self.HoverOver
							Case VIEW_START
								Self.TerminateMainLoop = True
		
							Case VIEW_INSTRUCTIONS
								Self.ViewMenu(VIEW_INSTRUCTIONS)
		
							Case VIEW_HIGHSCORES
								Self.ViewMenu(VIEW_HIGHSCORES)
		
							Case VIEW_QUIT
								Self.TerminateMainLoop = True
								Self.ExitGame = True
		
						End Select
					EndIf

					If KeyHit(KEY_UP)
						Self.HoverOver :- 1
						If Self.HoverOver < VIEW_START Then Self.HoverOver = VIEW_START
					EndIf
					If KeyHit(KEY_DOWN)
						Self.HoverOver :+ 1
						If Self.HoverOver > VIEW_QUIT Then Self.HoverOver = VIEW_QUIT
					EndIf

					If KeyHit(KEY_ESCAPE) Then 
						Self.TerminateMainLoop = True
						Self.ExitGame = True
					Else
						If KeyHit(KEY_C)
							Self.TerminateMainLoop = True
							Self.ShowCredits = True
						EndIf
					EndIf

				Case VIEW_INSTRUCTIONS, VIEW_HIGHSCORES
					If KeyHit(KEY_ENTER) Or KeyHit(KEY_ESCAPE)
						Self.Viewing = VIEW_MENU
					EndIf

				Case VIEW_ENTERHIGH
					' Check for alpha keys.
					For Local Count:Int = KEY_A To KEY_Z
						If KeyHit(Count) Then Self.EnteredText = Self.EnteredText + Chr(Count)
					Next
					' Check for number key hits
					For Local Count:Int = KEY_0 To KEY_9
						If KeyHit(Count) Then Self.EnteredText = Self.EnteredText + Chr(Count)
					Next
					' Special case, check for space bar
					If KeyHit(KEY_SPACE)
						Self.EnteredText = Self.EnteredText + " "
					EndIf
					' Remove a character when user hits backspace.
					If KeyHit(KEY_BACKSPACE)
						If Len(Self.EnteredText) > 0
							Self.EnteredText = Mid(Self.EnteredText,0,Len(Self.EnteredText))
						EndIf
					EndIf
					' If 5 characters are entered, end high score entry.
					If Len(Self.EnteredText) = 5 Then Self.FinishScoreEntry()
			
					If KeyHit(KEY_ENTER)
						Self.FinishScoreEntry()
					EndIf

			End Select

		End Method
'#End Region
'#Region Method: Render
		Method Render()
			Cls

			ScreenPan(0,0)

			SetTransform
			SetAlpha 1.0
			SetBlend(SOLIDBLEND)
			Self.Stars.Draw()

			SetColor 255,255,255
			SetBlend(ALPHABLEND)
			DrawImage(Self.Title,0,40)
			DrawImage(Self.LowerTitle,0,660)

			Local StartPosX:Int = 150
			Local StartPosY:Int = 245

			Select Self.Viewing
				Case VIEW_MENU
					' Showing main menu
					DrawImage(Self.Options,450,330)
					SetRotation -90
					Select Self.HoverOver
						Case VIEW_START
							DrawImage(Self.Craft,416,352)
							
						Case VIEW_INSTRUCTIONS
							DrawImage(Self.Craft,416,352 + 37)
		
						Case VIEW_HIGHSCORES  
							DrawImage(Self.Craft,416,352 + 74)
		
						Case VIEW_QUIT        
							DrawImage(Self.Craft,416,352 + 145)
		
					End Select

				Case VIEW_HIGHSCORES
					Scores.Render(385,310)

				Case VIEW_ENTERHIGH
					DrawTextCentered("CONGRATULATIONS!",StartPosY)
					DrawTextCentered("You have a new high score!",StartPosY+50)
					DrawTextCentered("Please enter your name (5 characters)",StartPosY+65)
					Local TextX:Int = DrawTextCentered(Self.EnteredText,StartPosY+250)
					DrawRect(TextX + TextWidth(Self.EnteredText), StartPosY+250, 12, 15)

				Case VIEW_INSTRUCTIONS
					DrawText("Welcome to Digesteroids!",StartPosX,StartPosY)
					DrawText("------------------------",StartPosX,StartPosY+20)
					DrawText("An evil biscuit corporation are using their army of sweet snack food to take over the world.",StartPosX,StartPosY+50)
					DrawText("Fortunately, the ingredients the evil corporation used are vulnerable to big sweaty laser",StartPosX,StartPosY+70)
					DrawText("blasts. Use your ship's cannon to take out the corporation before they infest the world with",StartPosX,StartPosY+90)
					DrawText("sweetmeal dunkables biscuits. But be careful, space is small (just big enough to fit inside",StartPosX,StartPosY+110)
					DrawText("your screen), it is also cyclical, so beware of incoming oval shaped objects.",StartPosX,StartPosY+130)

					DrawText("Keys:",StartPosX,StartPosY+180)
					DrawText(" - UP CURSOR ARROW     = Thrust",StartPosX,StartPosY+200)
					DrawText(" - DOWN CURSOR ARROW   = Teleport",StartPosX,StartPosY+220)
					DrawText(" - LEFT CURSOR ARROW   = Rotate Ship Left",StartPosX,StartPosY+240)
					DrawText(" - RIGHT CURSOR ARROW  = Rotate Ship Right",StartPosX,StartPosY+260)
					DrawText(" - ESCAPE              = QUIT",StartPosX,StartPosY+280)

					DrawText("Yes, that's right, it's a glorified asteroids game!",StartPosX,StartPosY+320)
					SetColor 255,0,0
					DrawText("Note: Your score is based on the speed at which your ship is travelling when it fired.",StartPosX,StartPosY+340)

			End Select
		End Method
'#End Region
'#Region Method: Start
		Method Start()
			Self.MusicChannel = AllocChannel()
			If Self.Music = Null Then Self.Music = LoadSound("sounds\menu.ogg",True)
			PlaySound(Self.Music,Self.MusicChannel)
			SetChannelVolume MusicChannel,1.0

			' Load GFX..
			If Self.Title = Null Then Self.Title = LoadImage("graphics\title.png")
			If Self.LowerTitle = Null Then Self.LowerTitle = LoadImage("graphics\lower.png")
			If Self.Options = Null Then Self.Options = LoadImage("graphics\options.png")
			If Self.Craft = Null Then Self.Craft = LoadImage("graphics\ship.png")

			' Add a screen full of stars.
			For Local CountStars:Int = 0 To 1000
				Local Star:TMenuStar = TMenuStar.Create(World, Self, 10.0)
				Star.X = Rnd(WIDTH)
				Self.Stars.AddLast(Star)
			Next
		End Method
'#End Region
'#Region Method: Finish
		Method Finish()
			Self.Stars.Clear()
			Self.MusicChannel.Stop()
			Self.MusicChannel = Null
		End Method
'#End Region
	
	End Type
'#End Region
'#Region Scene: MainGame
	' Main Game scene
	Type MainGameScene Extends T2DDynamicGameScene

'#Region Declarations
		Const STARS_PER_SECOND = 3
		Const FINISH_AT_LEVEL = 6
		Field Level:Int = 1
		Field Completed:Int = False
		
		Field DigestiveImage:TImage
		Field ShipImage:TImage
		Field StarsImage:TImage

		Field LargeImpactSound:TSound

		Field World:TWorldPhysicsProvider = TWorldPhysicsProvider.Create(0.0, 0.0, 0.0, True)

		Field Digestives:TPhysicsProviderCollection = New TPhysicsProviderCollection
		Field Bullets:TPhysicsProviderCollection = New TPhysicsProviderCollection
		Field Stars:TPhysicsProviderCollection = New TPhysicsProviderCollection

		Field Chunks:TFountain
		Const CHUNK_COUNT = 2
		Field ChunkImages:TImage[CHUNK_COUNT + 1]

		Field Player:TPlayer
		Field Shake:Float

		Field Pickups:TList = New TList
'#End Region

'#Region Method: Update
		Method Update()
			If KeyHit(KEY_ESCAPE) Then Self.TerminateMainLoop = True

			CheckEndOfLevel()  ' Check if we need to move to the next level (IE, all digestives gone)

			' Add new stars..
			For Local CountStars:Int = 0 To STARS_PER_SECOND
				Local Speed:Float = Self.Player.Speed()
				If Speed < 1.0 Then Speed = 1.0
				Local Star:TStar = TStar.Create(World, Self, Speed)
				Self.Stars.AddLast(Star)
			Next

			' Update screenshake...
			Self.Shake :/ 1.02
			If Self.Shake < 0.0 Then Self.Shake = 0.0
			If Self.Shake > 6.0 Then Self.Shake = 6.0

			' Update all the stars.
			Self.Stars.ApplyPhysics()

			' Update the chunks
			Self.Chunks.UpdateWithFriction(TPhysicsProvider.AxisX | TPhysicsProvider.AxisY)

			' Update all the digestives.
			Self.Digestives.ApplyPhysics()

			' Update all the bullets.
			Self.Bullets.ApplyPhysics()

			' Update the player.	
			Self.Player.Update()
			Self.Player.ApplyFriction(TPhysicsProvider.AxisX | TPhysicsProvider.AxisY)
			Self.Player.ApplyPhysics()
		End Method
'#End Region
'#Region Method: Render
		Method Render()
			SetClsColor 0,0,0
			Cls
		
			If Self.Shake > 0.0 Then
				ScreenPan(Rnd(Shake),Rnd(Shake))
			EndIf

			' Draw the spazzy psychodelic effect if it is enabled.
			Self.DrawPsychodelic()
	
			SetAlpha 1
			SetTransform
			' Draw all the stars.	
			Self.Stars.Draw()

			Self.Chunks.Draw()

			' Draw the digestives.
			SetColor 255,255,255
			SetBlend(ALPHABLEND)
			Digestives.Draw()

			' Draw the bullets
			SetBlend(LIGHTBLEND)
			Bullets.Draw()
		
			' Draw the player.
			SetBlend(ALPHABLEND)
			Player.Draw()

			' Draw the hud		
			DrawHUD()
		End Method
'#End Region
'#Region Method: Start
		Method Start()
			AutoMidHandle True

			Self.Shake = 0		
			Self.Chunks = TFountain.Create(Self.World,TRectangle.Create(0,0,WIDTH,HEIGHT))

			' Load in the required Images...		
			If Self.DigestiveImage = Null Then Self.DigestiveImage = LoadImage("graphics\digestive.png")
			If Self.ShipImage = Null Then Self.ShipImage = LoadImage("graphics\ship.png")
			If Self.StarsImage = Null Then Self.StarsImage = LoadImage("graphics\stars.png")

			For Local LoadCount:Int = 0 To CHUNK_COUNT
				Self.ChunkImages[LoadCount] = LoadImage("graphics\piece" + String(LoadCount + 1) + ".png")
			Next

			' Set up the player
			Self.Player = TPlayer.Create(Self.World, Self.ShipImage,Self)
			Self.Player.LoadAssets()

			' Load up the sounds.
			If Self.LargeImpactSound = Null Then Self.LargeImpactSound = LoadSound("Sounds\ImpactLarge.wav")

			' Reset the game..
			Self.ResetGame()

			' Create all the weapons..
			Self.Pickups.Clear()
			Local Bullet1Image:TImage = LoadImage("graphics\bullet1.png")
			Local Fire1Sound:TSound = LoadSound("sounds\fire.wav")

'			Local Blaster:TWeapon = TWeapon.Create(Speed,Graphic,Size,Radius,Veer,FireRate,MainGame,Sound)
			Local Blaster:TWeapon = TWeapon.Create(10, Bullet1Image, 0.65, 4.0, 0,30, Self, Fire1Sound, Bullet1Image, "Blaster")
			Local FastBlaster:TWeapon = TWeapon.Create(9, Bullet1Image, 0.3, 4.0, 0.0, 15, Self, Fire1Sound, Bullet1Image, "Blaster Mk2")
			Local SprayBlaster:TWeapon = TWeapon.Create(8, Bullet1Image, 0.35, 4.0, 5.0, 1, Self, Fire1Sound, Bullet1Image, "Blaster Mk3")

			Local BlasterPickup:TPickup = TPickup.Create(TPickup.MODIFIER_WEAPON,0,0,True,Blaster,Bullet1Image,0.01,Bullet1Image)
			Local FastBlasterPickup:TPickup = TPickup.Create(TPickup.MODIFIER_WEAPON,0,0,True,FastBlaster,Bullet1Image,0.01,Bullet1Image)
			Local SprayBlasterPickup:TPickup = TPickup.Create(TPickup.MODIFIER_WEAPON,0,0,True,SprayBlaster,Bullet1Image,0.008,Bullet1Image)

			Local Score1000Pickup:TPickup = TPickup.Create(TPickup.MODIFIER_SCORE,1000,0,True,Null,Null,0.02,Bullet1Image)
			Local Score500Pickup:TPickup = TPickup.Create(TPickup.MODIFIER_SCORE,500,0,True,Null,Null,0.03,Bullet1Image)

			Local RotationPickup:TPickup = TPickup.Create(TPickup.MODIFIER_ROTATION,1.1,0,True,Null,Null,0.01,Bullet1Image)
			Local PsychodelicPickup:TPickup = TPickup.Create(TPickup.MODIFIER_PSYCHODELIC,0,1000,False,Null,Null,0.04,Bullet1Image)

			Local LivesPickup:TPickup = TPickup.Create(TPickup.MODIFIER_LIVES,1,0,True,Null,Null,0.001,Bullet1Image)

			Self.Player.Weapon = Blaster

		End Method
'#End Region
'#Region Method: Finish
		Method Finish()
			Self.Player.ThrusterChannel.Stop
			Self.Player.ThrusterChannel = Null
		End Method
'#End Region
	
'#Region Method: CheckEndOfLevel
	Method CheckEndOfLevel()
		If Digestives.IsEmpty() = True
			' No more digestives..
			Level :+ 1
			If Level = FINISH_AT_LEVEL Then	
				' This was the last level.
				Self.Completed = True
				Self.TerminateMainLoop = True
			Else
				' Move to the next level
				GotoLevel(Level)
			EndIf
		EndIf
	End Method
'#End Region
'#Region Method: DrawHUD
	Method DrawHUD()
		SetColor 255,255,255
		SetAlpha 1.0
		SetRotation 0
		DrawText "Level: " + Level,0,0
		Local Lives:String = "Lives: " + Player.Lives
		Local Score:String = "Score: " + Player.Score
		DrawText Score,(WIDTH / 2) - (TextWidth(Score) / 2) ,0
		DrawText Lives,(WIDTH - TextWidth(Lives)) ,0
		
		Local fr$="000"+Int(Self.Player.Speed()*1000) Mod 1000
		Local sp$=Int(Self.Player.Speed()*1000)/1000+"."+fr[fr.length-3..]
		
		DrawText "Speed: " + sp,0,15
		DrawText "Teleports: " + Self.Player.Teleports,0,30
	End Method
'#End Region
'#Region Method: ResetGame
	Method ResetGame()
		Digestives.Clear()
		Bullets.Clear()
		Stars.Clear()
		Chunks.Particles.Clear()
		Player.Lives = 5
		Player.Reset()
		GotoLevel(1)
	End Method
'#End Region
'#Region Method: GotoLevel
	Method GotoLevel(ToLevel:Int)
		Level = ToLevel
		For Local Count:Int = 1 To ToLevel
			Local Digestive:TDigestive = TDigestive.Create(World, DigestiveImage,Self)
			Digestive.X = Rnd(0,WIDTH)
			Digestive.Y = Rnd(0,HEIGHT)
			Digestive.Rotation = Rnd(360)
			Digestive.Weight = 5
			Digestive.SetVelocityFromAngle(Rnd(360.0),Rnd(0.5,1.5))
			Digestive.HitSound = Self.LargeImpactSound
			Digestives.AddLast(Digestive)
		Next
	End Method
'#End Region
'#Region Method: DrawPsychodelic
	Field PsychoAngle:Float = 0
	Field Psycho:Int = False
	
	Method DrawPsychodelic()
		If Psycho = True
			SetColor Rnd(0.0,255),Rnd(0.0,255),Rnd(0.0,255)
			PsychoAngle :+ 8
			SetBlend(SOLIDBLEND)
			TileImage(StarsImage,Sin(PsychoAngle) * 200,Cos(PsychoAngle) * 200)
		Else
			SetColor 255,255,255
		EndIf
	End Method
'#End Region
'#Region Method: FindSafeLocation
	Method FindSafeLocation:TPointD(Radius:Float)
		While True
			Local X:Int = Rnd(0,WIDTH)
			Local Y:Int = Rnd(0,HEIGHT)
			If Self.IsLocationSafe(X,Y,Radius)
				Local Out:TPointD = New TPointD
				Out.X = X
				Out.Y = Y
				Return Out
			EndIf
		Wend
	End Method
'#End Region
'#Region Method: IsLocationSafe
	Method IsLocationSafe:Int(X:Int,Y:Int,Radius:Float)
		Local TryCircle:TCircle = New TCircle
		TryCircle.X = X
		TryCircle.Y = Y
		TryCircle.Radius = Radius
		For Local Item:TDigestive = EachIn Self.Digestives
			If Item.Circle.CollidesWith(TryCircle)
				Return False
			EndIf
		Next
		Return True
	End Method
'#End Region

	End Type
'#End Region
'#Region Scene: Ending
	' The ending scene.
	Type EndingScene Extends T2DDynamicGameScene
	
'#Region Declarations
		Const STARS_PER_SECOND = 0
		Const MAGNET_COUNT = 5
		Field ScrollPoint:Float
		Field Music:TSound
		Field MusicChannel:TChannel
		Field Title:TImage
		Field Time:Int = 1000000

		Field TEXTS_COUNT = 23
		Field Texts:String[TEXTS_COUNT]

		Field Stars:TPhysicsProviderCollection = New TPhysicsProviderCollection
		Field World:TWorldPhysicsProvider = TWorldPhysicsProvider.Create(0.2, 0.0, 0.0, True)
'#End Region

'#Region Method: Update
		Method Update()
			Self.Stars.ApplyPhysics()

			If KeyHit(KEY_ESCAPE) Then 
				Self.TerminateMainLoop = True
			EndIf

			Self.Time :+ 1
			If Self.Time > 100 Then
				Self.Time = 0
				' Add a new magnet
				Local ThisMagnet:TEndMagnet = New TEndMagnet
				ThisMagnet.X = Rnd(WIDTH)
				ThisMagnet.Y = Rnd(HEIGHT)
				ThisMagnet.Radius = Rnd(200,500)
				ThisMagnet.Polarity = TMagnet.PositivePolarity
				ThisMagnet.Strength = Rnd(0.1,0.5)
				Self.World.Magnets.AddLast(ThisMagnet)
				Self.World.ApplyMagnets = True
			EndIf


			Local X:Int = WIDTH/2
			Local Y:Int = HEIGHT/2
			For Local Magnet:TEndMagnet = EachIn Self.World.Magnets
				For Local Count:Int = 0 To STARS_PER_SECOND
					Local ThisStar:TEndingStar = TEndingStar.Create(Self.World, Self, Rnd(1.0,5.0), Magnet.X + (Sin(Rnd(360.0)) * 5.0), Magnet.Y + (Cos(Rnd(360.0)) * 5.0))
					ThisStar.SetVelocityFromAngle(Rnd(360),Rnd(1.0,5.0))
					Self.Stars.AddLast(ThisStar)
					Magnet.Stars :+ 1
				Next
				If Magnet.Stars > 500 Then
					Self.World.Magnets.Remove(Magnet)
				EndIf
			Next

			' Update the scoller
			Self.ScrollPoint :- 0.5
			If Self.Scrollpoint	< -((TEXTS_COUNT * 25) + 100)
				Self.ScrollPoint = HEIGHT + 20
			EndIf
			
		End Method
'#End Region
'#Region Method: Render
		Method Render()
			Cls

			Self.Stars.Draw()

			SetColor 255,255,255
			For Local Count:Int = 0 To TEXTS_COUNT - 1
				MainMenuScene.DrawTextCentered(Self.Texts[Count],Self.ScrollPoint + (25 * Count))
			Next
		End Method
'#End Region
'#Region Method: Start
		Method Start()
			Self.MusicChannel = AllocChannel()
			If Self.Music = Null Then Self.Music = LoadSound("sounds\ending.ogg",True)
			If Self.MusicChannel <> Null
				PlaySound(Self.Music,Self.MusicChannel)
			EndIf

			Self.Texts[0] = "Cast of Characters"
			Self.Texts[1] = "------------------"
			Self.Texts[2] = ""
			Self.Texts[3] = "Space Craft.......................Intrepid"
			Self.Texts[4] = "Digestive...............Sweet Meal Biscuit"
			Self.Texts[5] = "Star...............................Himself"
			Self.Texts[6] = ""
			Self.Texts[7] = "Written by Rob Hutchinson in roughly 5 days."
			Self.Texts[8] = "Email: rob@proteanide.co.uk"
			Self.Texts[9] = "Web: http://www.proteanide.co.uk/"
			Self.Texts[10] = ""
			Self.Texts[11] = "Special Thanks To"
			Self.Texts[12] = "-----------------"
			Self.Texts[13] = "Richard Makepeace.............Inspiration"
			Self.Texts[14] = "James Readman.................Inspiration"
			Self.Texts[15] = ""
			Self.Texts[16] = "Greets"
			Self.Texts[17] = "------"
			Self.Texts[18] = "Pickup, Cabsy, Peters, ZanaX, Compona, Helen, + all other family and friends."
			Self.Texts[19] = ""
			Self.Texts[20] = ""
			Self.Texts[21] = ""
			Self.Texts[22] = "Thank you for playing."

			Self.ScrollPoint = HEIGHT + 20
		End Method
'#End Region
'#Region Method: Finish
		Method Finish()
			Self.Stars.Clear()
			If Self.MusicChannel <> Null Then
				Self.MusicChannel.Stop()
				Self.MusicChannel = Null
			EndIf
		End Method
'#End Region

	End Type
'#End Region

Type TCircle
	
	Field X:Int
	Field Y:Int
	Field Radius:Float
	
	Method CollidesWith:Int(Circle:TCircle) 
		Local Distance:Double = TPhysicsUtility.DistanceBetweenPoints(Self.X,Self.Y,Circle.X,Circle.Y)
		If Distance < (Self.Radius + Circle.Radius) Then Return True
		Return False
	End Method

	Method Draw()
		SetBlend(ALPHABLEND)
		SetAlpha(0.5)
		SetRotation 0
		DrawCircle(X,Y,Int(Radius))
	End Method

	Function DrawCircle(X,Y,Radius)
		DrawOval(X - Radius,Y - Radius,Radius * 2,Radius * 2)
	End Function

End Type
Type TDigestive Extends TPhysicsProvider
	Field Image:TImage
	Field Alpha:Float = 1.0
	Field Rotation:Float = 0
	Field Scale:Float = 1.0
	Field Circle:TCircle = New TCircle
	Field GameScene:MainGameScene
	Const InitialRadius:Float = 70.0
	Field HitSound:TSound

	Method SplitIntoChunks(X:Int,Y:Int,Multiplier:Float)
		GameScene.Digestives.Remove(Self)

		Local Channel:TChannel = AllocChannel()
		If Channel <> Null
			Channel.SetVolume(Self.Scale)
			PlaySound(Self.HitSound, Channel)
		EndIf

		Self.GameScene.Chunks.X = X
		Self.GameScene.Chunks.Y = Y
		
		Self.GameScene.Player.Score :+ Int(((Self.Scale * 100.0) + 4.0) * Multiplier)

		Self.GameScene.Shake :+ (Self.Scale * 3.5)
		

		If Self.Scale > 0.2
			For Local Count:Int = 0 To Int(Self.Scale * 5)
				Local Digestive:TDigestive = TDigestive.Create(Self.World, Self.Image, Self.GameScene)
				Digestive.X = Self.X
				Digestive.Y = Self.Y
				Digestive.Rotation = Rnd(360)
				Digestive.Weight = 5
				Digestive.SetVelocityFromAngle(Rnd(360.0),Rnd(0.5,1.5))
				Digestive.SetDrawScale(Self.Scale / 2)
				Digestive.HitSound = Self.HitSound
				GameScene.Digestives.AddLast(Digestive)
			Next

			For Local ChunkCount:Int = 0 To 4 * (Self.Scale * 10)
				Local Particle:TStaticParticle = Self.GameScene.Chunks.AddStaticParticle(Self.GameScene.ChunkImages[(Int(Rnd(0,MainGameScene.CHUNK_COUNT)))], Rnd(360.0), Rnd(0.5,10.0), 0, 0.01, [255,255,255])
				Particle.Friction = 0.97
				Particle.Size = Rnd(0.5,1.0)
				Particle.Rotation = Rnd(-5.0,5.0)
			Next
		Else
			For Local ChunkCount2:Int = 0 To Rnd(3,8)
				Local Particle:TStaticParticle = Self.GameScene.Chunks.AddStaticParticle(Self.GameScene.ChunkImages[(Int(Rnd(0,MainGameScene.CHUNK_COUNT)))], Rnd(360.0), Rnd(0.5,10.0), 0, 0.01, [255,255,255])
				Particle.Friction = 0.97
				Particle.Size = Rnd(0.2,0.5)
				Particle.Rotation = Rnd(-5.0,5.0)
			Next
		End If
	End Method

	Method Draw()
		SetAlpha Self.ALPHA
		SetRotation Self.Rotation
		SetScale Self.Scale,Self.Scale
		DrawImage(Self.Image, Self.X, Self.Y)
		SetScale 1,1
	End Method

	Method SetDrawScale(Scale:Float)
		Self.Scale = Scale
		Self.Circle.Radius = Self.InitialRadius * Self.Scale
	End Method

	Method PhysicsApplied()
		Rotation:+2
		Local HalfWidth:Int = ((Image.Width * Self.Scale) / 2)
		Local HalfHeight:Int = ((Image.Height * Self.Scale) / 2)
		If X < -HalfWidth Then X = WIDTH + HalfWidth
		If Y < -HalfHeight Then Y = HEIGHT + HalfHeight
		If X > WIDTH + HalfWidth Then X = -HalfWidth
		If Y > HEIGHT + HalfHeight Then Y = -HalfHeight
		Self.Circle.X = Self.X
		Self.Circle.Y = Self.Y
	End Method

	Function Create:TDigestive(World:TWorldPhysicsProvider,Image:TImage,GameScene:MainGameScene)
		Local Out:TDigestive = New TDigestive
		Out.GameScene = GameScene
		Out.Circle.Radius = InitialRadius
		Out.World = World
		Out.Image = Image
		Return Out
	End Function

End Type
Type TPlayer Extends TPhysicsProvider

	Field Lives:Int
	Field Score:Int
	Field Weapon:TWeapon
	Field Dead:Int = True
	Field Teleports:Int = 2

	Field Image:TImage
	Field Rotation:Float
	Field Acceleration:Float
	Field MaxAcceleration:Float = 4.0
	Field Motion:Float = 0.001
	Field AccelerationDropMultiplier:Float = 8
	Field Circle:TCircle = New TCircle
	Field GameScene:MainGameScene

	Field FireRateCount:Float = 0

	Field Thruster:TFountain
	Field Death:TFountain

	Field ThrusterImage:TImage
	Field DeathImage:TImage
	Field SparkleImage:TImage
	Field ThrusterSound:TSound
	Field CrashSound:TSound
	Field ThrusterChannel:TChannel
	Field TeleportSound:TSound

	Method Draw()
		SetTransform
		' Render the thruster...
		SetBlend LIGHTBLEND
		SetScale 0.6, 0.6
		SetAlpha 1.0
		Self.Thruster.Draw()
		Self.Death.Draw()

		If Not Self.Dead Then
			' Render the player.
			SetBlend ALPHABLEND
			SetAlpha 1.0
			SetScale 1.0,1.0
			SetColor 255,255,255
			SetRotation 360 - Self.Rotation
			DrawImage(Self.Image, Self.X, Self.Y)
		EndIf
	End Method

	Method PhysicsApplied()
		Local HalfWidth:Int = (Image.Width / 2)
		Local HalfHeight:Int = (Image.Height / 2)
		If X < -HalfWidth Then X = WIDTH + HalfWidth
		If Y < -HalfHeight Then Y = HEIGHT + HalfHeight
		If X > WIDTH + HalfWidth Then X = -HalfWidth
		If Y > HEIGHT + HalfHeight Then Y = -HalfHeight
		Self.Circle.X = Self.X
		Self.Circle.Y = Self.Y
	End Method

	Method Update()
		' Update thruster and death particles.
		Local Particle:TStaticParticle = Self.Thruster.AddStaticParticle(Self.ThrusterImage, Self.Rotation + 180 + Rnd(-5.0,5.0), 1.0, 1, 0.04, [255,255,255])
	
		Local ActualRotation:Float = Self.Rotation + 180

		Self.Thruster.X = Self.X + (Sin(ActualRotation) * 10) 
		Self.Thruster.Y = Self.Y + (Cos(ActualRotation) * 10) 

		Local ThisSpeed:Float = Self.Speed()
		
		If ThisSpeed < 0 Then ThisSpeed = 0 
		If ThisSpeed > 10.0 Then ThisSpeed = 10.0
		
		' Add particles to the thruster..
		Particle.Size = (ThisSpeed / 10)
		Self.ThrusterChannel.SetVolume(ThisSpeed / 10)
		Self.ThrusterChannel.SetPan(Float(Self.X / Float(WIDTH / 2.0) - 1.0))
		Self.GameScene.Shake:+ 0.10 * (ThisSpeed / 10.0)

		Self.Thruster.Update()
		Self.Death.UpdateWithFriction(TPhysicsProvider.AxisX | TPhysicsProvider.AxisY)
	
		If Self.Dead
			' Player is currently dead, wait for a nice chance to put them back down.
			If Self.Lives < 1 Then
				' Wait for the death particles to become zeroed.
				If Self.Death.Particles.IsEmpty() Then
					Self.GameScene.TerminateMainLoop = True
				EndIf
			Else
				' Check to see if the center spot is safe to plop the ship on.
				If Self.GameScene.IsLocationSafe(WIDTH/2, HEIGHT/2, 70)
					Self.Dead = False
					For Local Pops:Int = 0 To 200
						Local Particle:TStaticParticle = Self.Death.AddStaticParticle(Self.SparkleImage, Rnd(360.0), Rnd(0.5,2.0), 0, Rnd(0.01, 0.03), [255,255,255])
						Particle.X = Self.X
						Particle.Y = Self.Y
						Particle.Rotation = Rnd(-1.0,1.0)
						Particle.Friction = 0.97
						Particle.Size = Rnd(0.1,0.2)
					Next
				EndIf
			EndIf
		Else
			' Update fire rate counter...
			Self.FireRateCount :- 1
			
			If KeyDown(KEY_UP)
				' Thrust
				Self.Acceleration :+ Self.Motion
				' Clamp the acceleration
				If Self.Acceleration > Self.MaxAcceleration Then Self.Acceleration = Self.MaxAcceleration
				' Add acceleration.
				Self.IncreaseVelocityFromAngle(Self.Rotation,Self.Acceleration)
			Else
				Self.Acceleration :- (Self.Motion * Self.AccelerationDropMultiplier)
				If Self.Acceleration < 0.0 Then Self.Acceleration = 0
			EndIf
	
			If KeyDown(KEY_LEFT)
				' RotateLeft
				Self.Rotation :+ 3
			EndIf
	
			If KeyDown(KEY_RIGHT)
				' RotateLeft
				Self.Rotation :- 3
			EndIf
	
			If KeyDown(KEY_SPACE)
				' FIRE! 
				If Self.FireRateCount <= 0 Then
					Self.FireRateCount = Self.Weapon.FireRate
					Self.Weapon.Fire(Self)
				End If
			EndIf
	
			If KeyHit(KEY_DOWN)
				' TELEPORT
				If Self.Teleports > 0 Then
					Self.Teleports :- 1
					Local Location:TPointD = Self.GameScene.FindSafeLocation(20)

					PlaySound(Self.TeleportSound)
					Self.Death.X = Self.X
					Self.Death.Y = Self.Y

					For Local Pops:Int = 0 To 50
						Local Particle:TStaticParticle = Self.Death.AddStaticParticle(Self.SparkleImage, Rnd(360.0), Rnd(0.5,10.0), 0, 0.02, [255,255,255])
						Particle.X = Self.X
						Particle.Y = Self.Y
						Particle.Rotation = Rnd(-1.0,1.0)
						Particle.Friction = 0.97
						Particle.Size = Rnd(0.1,0.2)
					Next

					Self.X = Int(Location.X)
					Self.Y = Int(Location.Y)
					Self.Death.X = Self.X
					Self.Death.Y = Self.Y

					For Local Pops:Int = 0 To 20
						Local Particle:TStaticParticle = Self.Death.AddStaticParticle(Self.SparkleImage, Rnd(360.0), Rnd(0.5,2.0), 0, 0.02, [255,255,255])
						Particle.X = Self.X
						Particle.Y = Self.Y
						Particle.Rotation = Rnd(-1.0,1.0)
						Particle.Friction = 0.97
						Particle.Size = Rnd(0.1,0.2)
					Next

				EndIf
			EndIf
	
			' COLLISION DETECT AGAINST DIGESTIVES!
			' ---------------------------------------------------------
			For Local Item:TDigestive = EachIn Self.GameScene.Digestives
				If Item.Circle.CollidesWith(Self.Circle)
					Self.Lives :- 1
					Self.Dead = True
					PlaySound(Self.CrashSound)
	
					Local PlayerSpeed:Double = Self.Speed()

					Self.GameScene.Shake :+ PlayerSpeed / 1.5
					If PlayerSpeed > 10.0
						Item.SplitIntoChunks(Self.X,Self.Y,Self.Speed())
					EndIf

					Self.Death.X = Self.X
					Self.Death.Y = Self.Y
					For Local Pops:Int = 0 To 100
						If PlayerSpeed > 10 Then PlayerSpeed = 10
						Local Angle:Double = Self.Angle() + Rnd(-(80 - (8.0 * PlayerSpeed)), 80 - (8.0 * PlayerSpeed))
						Local Particle:TStaticParticle = Self.Death.AddStaticParticle(Self.DeathImage, Angle, Rnd(0.1, Self.Speed()), 0, 0.03, [255,255,255])
						Particle.Friction = 0.98
						Particle.Size = Rnd(0.1,0.7)
						Particle.Color = [Rand(80,255),24,Rand(24,128)]
					Next

					For Local Pops:Int = 0 To 300
						Local Particle:TStaticParticle = Self.Death.AddStaticParticle(Self.DeathImage, Rnd(360.0), Rnd(0.1, 7.0), 0, Rnd(0.01,0.04), [255,255,255])
						Particle.Friction = 0.99
						Particle.Size = Rnd(0.1,0.4)
						Particle.Color = [Rand(80,255),24,Rand(24,200)]
					Next

					Self.Reset()
				EndIf
			Next
		EndIf

	End Method

	Method Reset()
		Self.X = WIDTH / 2
		Self.Y = HEIGHT / 2
		Self.Acceleration = 0
		Self.VelocityX = 0
		Self.VelocityY = 0
		Self.Teleports = 2
		Self.Dead = 2
	End Method

	Method LoadAssets()
		If Self.ThrusterImage = Null Then Self.ThrusterImage = LoadImage("graphics\bullet1.png")
		If Self.DeathImage = Null Then Self.DeathImage = LoadImage("graphics\pop.png")
		If Self.SparkleImage = Null Then Self.SparkleImage = LoadImage("graphics\sparkle.png")

		' Load in the sounds...
		If Self.ThrusterSound = Null Then Self.ThrusterSound = LoadSound("sounds\thrust.wav",True)
		If Self.CrashSound = Null Then Self.CrashSound = LoadSound("sounds\crash.wav",False)
		If Self.TeleportSound = Null Then Self.TeleportSound = LoadSound("sounds\teleport.wav",False)
		
		Self.ThrusterChannel = AllocChannel()
		Self.ThrusterChannel.SetVolume(0)
		PlaySound(Self.ThrusterSound,Self.ThrusterChannel)
	End Method

	Function Create:TPlayer(World:TWorldPhysicsProvider, Image:TImage, GameScene:MainGameScene)
		Local Out:TPlayer = New TPlayer
		Out.Thruster = TFountain.Create(World, TRectangle.Create(0,0,WIDTH,HEIGHT))
		Out.Death = TFountain.Create(World, TRectangle.Create(0,0,WIDTH,HEIGHT))
		Out.GameScene = GameScene
		Out.Circle.Radius = 10
		Out.World = World
		Out.Image = Image
		Out.Friction = 0.985
		Out.Reset()
		Return Out
	End Function

End Type
Type TBullet Extends TPhysicsProvider

	Field Image:TImage
	Field Circle:TCircle = New TCircle
	Field GameScene:MainGameScene
	Field Size:Float = 1.0
	Field ScoreMultiplier:Float = 1
	Field TTL:Int
	Field Fading:Float = 1.0

	Const TIME_TO_LIVE = 100

	Method Draw()
		SetScale(Self.Size,Self.Size)
		SetAlpha(Self.Fading)
		DrawImage(Self.Image, Self.X, Self.Y)
	End Method

	Method PhysicsApplied()
		Local HalfWidth:Int = (Image.Width / 2)
		Local HalfHeight:Int = (Image.Height / 2)
		If X < -HalfWidth Then X = WIDTH + HalfWidth
		If Y < -HalfHeight Then Y = HEIGHT + HalfHeight
		If X > WIDTH + HalfWidth Then X = -HalfWidth
		If Y > HEIGHT + HalfHeight Then Y = -HalfHeight

		' Shall we kill it off?
		Self.TTL :+ 1
		If Self.TTL > TIME_TO_LIVE Then
			Self.Fading :- 0.015
			If Self.Fading < 0.05
				Self.GameScene.Bullets.Remove(Self)
			EndIf
		EndIf
		
'		If X < -HalfWidth Or Y < -HalfHeight Or X > WIDTH + HalfWidth Or Y > HEIGHT + HalfHeight Then 
	'		' Bullet went off't screen
		'	Self.GameScene.Bullets.Remove(Self)
	'	EndIf

		Self.Circle.X = Self.X
		Self.Circle.Y = Self.Y

		' COLLISION DETECT AGAINST DIGESTIVES!
		' ---------------------------------------------------------
		For Local Item:TDigestive = EachIn Self.GameScene.Digestives
			If Item.Circle.CollidesWith(Self.Circle)
				If Self.Fading > 0.5
					Self.GameScene.Bullets.Remove(Self)
					Item.SplitIntoChunks(Self.Circle.X,Self.Circle.Y,Self.ScoreMultiplier)
					Exit
				EndIf
			EndIf
		Next
	End Method

	Function Create:TBullet(World:TWorldPhysicsProvider, Image:TImage, Player:TPlayer, Speed:Float, GameScene:MainGameScene, Size:Float, Radius:Float, Veer:Float)
		Local Out:TBullet = New TBullet
		Out.GameScene = GameScene
		Out.SetVelocityFromAngle(Player.Rotation + Rnd(-Veer,Veer),Speed)
		Out.Size = Size
		Out.Circle.Radius = Radius * Size
		Out.X = Player.X
		Out.Y = Player.Y
		Out.World = World
		Out.Image = Image
		Return Out
	End Function

End Type
Type TStar Extends TPhysicsProvider

	Field Color[]
	Field GameScene:MainGameScene
	
	Method Draw()
		SetColor Self.Color[0],Self.Color[1],Self.Color[2]
		DrawRect(X,Y,1,1)
	End Method

	Method PhysicsApplied()
		Self.VelocityX :* 1.01
		Self.VelocityY :* 1.01
	
		Local HalfWidth:Int = 5
		Local HalfHeight:Int = 5
		If X < -HalfWidth Or Y < -HalfHeight Or X > WIDTH + HalfWidth Or Y > HEIGHT + HalfHeight Then 
			' Bullet went off't screen
			Self.GameScene.Stars.Remove(Self)
		EndIf
	End Method

	Function Create:TStar(World:TWorldPhysicsProvider,GameScene:MainGameScene, Speed:Float)
		Local Out:TStar = New TStar
		Local Pigment = Rand(24,255)
		Out.GameScene = GameScene
		Out.Color = [Pigment,Pigment,Pigment]
		Out.SetVelocityFromAngle(Rnd(360),Rnd(0.2,0.9) * Speed)
		Out.X = WIDTH / 2
		Out.Y = HEIGHT / 2
		Out.World = World
		Return Out
	End Function

End Type
Type TMenuStar Extends TPhysicsProvider

	Field Color[]
	Field MenuScene:MainMenuScene
	
	Method Draw()
		SetColor Self.Color[0],Self.Color[1],Self.Color[2]
		DrawRect(X,Y,1,1)
	End Method

	Method PhysicsApplied()
'		Self.VelocityX :* 1.01
'		Self.VelocityY :* 1.01
	
		Local HalfWidth:Int = 5
		Local HalfHeight:Int = 5
		If X < -HalfWidth Or Y < -HalfHeight Or X > WIDTH + HalfWidth Or Y > HEIGHT + HalfHeight Then 
			' Bullet went off't screen
			Self.MenuScene.Stars.Remove(Self)
		EndIf
	End Method

	Function Create:TMenuStar(World:TWorldPhysicsProvider,MenuScene:MainMenuScene, Speed:Float)
		Local Out:TMenuStar = New TMenuStar
		Local Pigment = Rand(24,255)
		Out.MenuScene = MenuScene
		Out.Color = [Pigment,Pigment,Pigment]
		Out.SetVelocityFromAngle(90,Rnd(0.2,0.9) * Speed)
		Out.X = 0
		Out.Y = Rnd(HEIGHT)
		Out.World = World
		Return Out
	End Function

End Type
Type TEndingStar Extends TPhysicsProvider

	Field Color[]
	Field EndScene:EndingScene
	
	Method Draw()
		SetColor Self.Color[0],Self.Color[1],Self.Color[2]
		DrawRect(X,Y,1,1)
	End Method

	Method PhysicsApplied()
'		Self.VelocityX :* 1.01
'		Self.VelocityY :* 1.01
	
		Local HalfWidth:Int = 5
		Local HalfHeight:Int = 5
		If X < -HalfWidth Or Y < -HalfHeight Or X > WIDTH + HalfWidth Or Y > HEIGHT + HalfHeight Then 
			' Bullet went off't screen
			Self.EndScene.Stars.Remove(Self)
		EndIf
	End Method

	Function Create:TEndingStar(World:TWorldPhysicsProvider, EndScene:EndingScene, Speed:Float, X:Int, Y:Int)
		Local Out:TEndingStar = New TEndingStar
		Local Pigment = Rand(24,255)
		Out.EndScene = EndScene
		Out.Color = [Pigment,Pigment,Pigment]
		Out.X = X
		Out.Y = Y
		Out.World = World
		Return Out
	End Function

End Type
Type TPickup Extends TLink

	Const MODIFIER_SCORE = 0
	Const MODIFIER_LIVES = 1 
	Const MODIFIER_ROTATION = 2 
	Const MODIFIER_PSYCHODELIC = 3
	Const MODIFIER_WEAPON = 4

	Field Modifies:Int = MODIFIER_SCORE
	Field ByValue:Float
	Field LastsFor:Int
	Field Time:Int
	Field IsPermanent:Int = False
	Field Weapon:TWeapon
	Field Icon:TImage
	Field Probability:Double
	Field OwnedIcon:TImage

	Method Clone:TPickup()
		Local Out:TPickup = New TPickup
		Out.Modifies = Self.Modifies
		Out.ByValue = Self.ByValue
		Out.LastsFor = Self.LastsFor
		Out.IsPermanent = Self.IsPermanent
		Out.Weapon = Self.Weapon
		Out.Icon = Self.Icon
		Out.Probability = Self.Probability
		Out.OwnedIcon = Out.OwnedIcon
		Return Out
	End Method

	Function Create:TPickup(Modifies:Int,ByValue:Float,LastsFor:Int,IsPermanent:Int,Weapon:TWeapon,Icon:TImage,Probability:Double,OwnedIcon:TImage)
		Local Out:TPickup = New TPickup
		Out.Modifies = Modifies
		Out.ByValue = ByValue
		Out.LastsFor = LastsFor
		Out.IsPermanent = IsPermanent
		Out.Weapon = Weapon
		Out.Icon = Icon
		Out.Probability = Probability
		Out.OwnedIcon = OwnedIcon
		Return Out
	End Function

End Type
Type TWeapon Extends TLink

	Field Speed:Float
	Field Graphic:TImage
	Field Size:Float
	Field Radius:Float
	Field Veer:Float
	Field FireRate:Int
	Field MainGame:MainGameScene
	Field Sound:TSound
	Field Name:String
	Field Icon:TImage

	Method Fire(Player:TPlayer)
		Local Shot:TBullet = TBullet.Create(MainGame.World, Self.Graphic, Player, Self.Speed + Player.Speed(), Self.MainGame, Self.Size, Self.Radius, Self.Veer)
		Shot.ScoreMultiplier = (Player.Speed() * 4.0)
		If Shot.ScoreMultiplier < 1.0 Then Shot.ScoreMultiplier = 1.0
		Self.MainGame.Bullets.AddLast(Shot)
		PlaySound(Self.Sound)
	End Method

	Function Create:TWeapon(Speed:Float,Graphic:TImage,Size:Float,Radius:Float,Veer:Float,FireRate:Int,MainGame:MainGameScene,Sound:TSound,Icon:TImage,Name:String)
		Local Out:TWeapon = New TWeapon
		Out.Speed = Speed
		Out.Graphic = Graphic
		Out.Size = Size
		Out.Radius = Radius
		Out.Veer = Veer
		Out.FireRate = FireRate
		Out.MainGame = MainGame
		Out.Sound = Sound
		Out.Icon = Icon
		Out.Name = Name
		Return Out
	End Function

End Type
Type TEndMagnet Extends TMagnet
	
	Field Stars:Int
	
End Type
Type THighScores

	Const SCORE_COUNT = 10
	Field Scores:Int[SCORE_COUNT]
	Field Names:String[SCORE_COUNT]

	Method Render(X:Int, Y:Int)
		For Local Count:Int = 0 To SCORE_COUNT - 1
			DrawText(Self.Names[Count], X,Y + (Count * 20))
		Next

		For Local Count2:Int = 0 To SCORE_COUNT - 1
			DrawText(Self.Scores[Count2], X + 200,Y + (Count2 * 20))
		Next
	End Method

	Method IsHighScore:Int(Score:Int)
		For Local Count:Int = 0 To SCORE_COUNT - 1
			If Score > Self.Scores[Count] Then
				Return True
			EndIf
		Next
		Return False
	End Method
	
	Method Add(Score:Int,Name:String)
		' Find out where we should put the score..
		Local PlaceAt:Int = SCORE_COUNT - 1
		For Local Count:Int = SCORE_COUNT - 1 To 0 Step -1
			If Score > Self.Scores[Count] Then
				PlaceAt = Count
			EndIf
		Next

		' Shuffle them all down..
		For Local Shuffle:Int = SCORE_COUNT - 2 To PlaceAt Step -1
			Self.Scores[Shuffle + 1] = Self.Scores[Shuffle]
			Self.Names[Shuffle + 1] = Self.Names[Shuffle]
		Next

		Self.Scores[PlaceAt] = Score
		Self.Names[PlaceAt] = Name
	End Method

	Method Save(File:String)
		Local Out:TStream = OpenStream(File,False,True)
		If Out <> Null
			For Local Count:Int = 0 To SCORE_COUNT - 1
				WriteInt(Out,Self.Scores[Count])
				WriteLine(Out,Self.Names[Count])
			Next
			CloseStream(Out)
		EndIf
	End Method

	Function Load:THighScores(File:String)
		Local In:TStream = OpenStream(File,True,False)
		Local Out:THighScores = New THighScores
		If In = Null
			' Fill it full of high scores..
			Out.Names[0] = "Loki"
			Out.Names[1] = "Booty"
			Out.Names[2] = "Rix"
			Out.Names[3] = "Jamez"
			Out.Names[4] = "Pies"
			Out.Names[5] = "Bobny"
			Out.Names[6] = "Berty"
			Out.Names[7] = "Billy"
			Out.Names[8] = "Bonny"
			Out.Names[9] = "Boxer"

			Out.Scores[0] = 100000
			Out.Scores[1] = 80000
			Out.Scores[2] = 50000
			Out.Scores[3] = 40000
			Out.Scores[4] = 30000
			Out.Scores[5] = 20000
			Out.Scores[6] = 10000
			Out.Scores[7] = 5000
			Out.Scores[8] = 4000
			Out.Scores[9] = 1000
		Else
			For Local Count:Int = 0 To SCORE_COUNT - 1
				Out.Scores[Count] = ReadInt(In)
				Out.Names[Count] = ReadLine(In)
			Next
			CloseStream(In)
		EndIf
		Return Out
	End Function

End Type

' Main game setup.
' ------------------------
Local Game:T2DDynamicGame = T2DDynamicGame.Create(WIDTH, HEIGHT, DEPTH, REFRESHRATE)
Global Scores:THighScores = THighScores.Load("hi.dat")
Game.DynamicTiming = DYNAMICTIMING
Game.DesiredFPS = DESIREDFPS
Game.Initialize()	' Go into graphics mode.

HideMouse

' Create the main game scene.
Local MenuScene:MainMenuScene = New MainMenuScene
Local GameScene:MainGameScene = New MainGameScene
Local EndScene:EndingScene = New EndingScene

Local QuitFlag:Int = False

While Not QuitFlag
	' Attach The Game Scene To The Dynamic Game.
	Game.Setscene(Menuscene)
	
	' Start The Main Loop.
	Game.Mainloop()

	If Not MenuScene.Exitgame
		If MenuScene.ShowCredits
			MenuScene.ShowCredits = False
			Game.SetScene(EndScene)
			Game.Mainloop()
		Else
			Game.Setscene(GameScene)
			Game.Mainloop()

			QFlushKeys()

			If GameScene.Completed
				GameScene.Completed = False
				Game.SetScene(EndScene)
				Game.Mainloop()
			EndIf

			QFlushKeys()

			' Check for high score.
			If Scores.IsHighScore(GameScene.Player.Score) Then
				' We got a high score.
				MenuScene.ViewMenu(MenuScene.VIEW_ENTERHIGH)
				MenuScene.LastHighScore = GameScene.Player.Score
				MenuScene.EnteredText = ""
			EndIf

		EndIf
	Else
		QuitFlag = True
	EndIf
Wend

Scores.Save("hi.dat")

' Clean up after we shut down.
Game.ShutDown()

' Fin

Const DEBUG = True
Function DebugLog(Text:String)
	If DEBUG Then Print Text
End Function






