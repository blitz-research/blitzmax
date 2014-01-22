'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' main
'===============================================================================
' A little shooty thing! Needs a lot of work as I only hacked it together in
' about three hours one night and it's a right mix of both procedural and OO
' but it may inspire someone to do something..
'===============================================================================

Include "globals.bmx"
Include "player.bmx"
Include "playershots.bmx"
Include "enemies.bmx"
Include "background.bmx"
Include "particles.bmx"
Include "sound.bmx"
Include "init.bmx"
Include "titles.bmx"
Include "gfont.bmx"

' -----------------------------------------------------------------------------

Global tm, ms, old

AppTitle$="Choose Screen Mode"
Graphics 320,240,0,60
DrawText "(W)indowed or (F)ullscreen?",0,120 ; Flip

Repeat
Until (KeyDown(KEY_F) Or KeyDown(KEY_W)) Or JoyDown(2)

AppTitle$="Little Shooty Test by RiK (ESC To quit)"

If KeyDown(KEY_W) Or JoyDown(2) Then
	Graphics WIDTH, HEIGHT,0,60
Else
	Graphics WIDTH, HEIGHT,32,60
EndIf

AutoMidHandle True
SeedRnd(MilliSecs())

' -----------------------------------------------------------------------------
' init
' -----------------------------------------------------------------------------

init()
Gfont.Init()
HideMouse()
ShowTitlePage()

' -----------------------------------------------------------------------------
' Main game loop
' -----------------------------------------------------------------------------

' Just stick an OGG called "music.ogg" in the sounds dir
' PlaySound(music,musicchannel)  

'SetChannelVolume SoundChannel,1
SetChannelVolume MusicChannel,0.75

While Not KeyHit(KEY_ESCAPE)
	While JoyDown(5)
	Wend

	Cls
	ResetCollisions
	
	' -------------------------------------------------------------------------
	' Spawn a random spikey thing, joypad/keyboard check are for testing.
	' -------------------------------------------------------------------------
		
	If Spawntimer<=0 Or JoyDown(3) Or KeyDown(key_e) Then 
		Local nx=Rand(0,800)
		If Abs(player.x-nx)<200 Then nx=nx+400 ' dont spawn on top of player!
		Local ny=Rand(0,600)
		TEnemy.CreateEnemy (nx,ny)
		Spawntimer=60
	EndIf
	
	spawntimer:-1

	' -------------------------------------------------------------------------
	' Update Everything
	' -------------------------------------------------------------------------

	UpdateEntities()

	' -------------------------------------------------------------------------
	' HUD/Score/whatever
	' -------------------------------------------------------------------------
		
	SetColor 255,255,255;	SetRotation 0;	SetAlpha 1

	DrawText player.invincible,0,0 ' just for debug purposes
	DrawText "Little Shooty Test by RiK (ESC to quit)",20,0
		
	GFont.DrawString 800,16,score,-1,0

	If player.state=2 Then GFont.Drawstring 400,300,"YOU SUCK!",1,1

	Flip
Wend

ShowMouse()

' -----------------------------------------------------------------------------
' Update/draw everything 
'
' I've only stuck in out here as I like to keep the main loop small for clarity
' 
' -----------------------------------------------------------------------------

Function UpdateEntities(  )

	MoveBG()
	RenderBackGround(0,player.y)

	SetScale 1,1
	For Local b:TBullet =EachIn bullets
		b.Update
	Next
	
	SetScale 1,1
	For Local e:TEnemy =EachIn enemies
		e.Update
	Next

	For Local p:TParticle =EachIn particles
		p.Update
	Next
	
	player.update()

	' Reset everything
	SetBlend ALPHABLEND
	SetScale 1,1
	SetAlpha 1
	SetRotation 0

End Function

' -----------------------------------------------------------------------------
' End
' -----------------------------------------------------------------------------

