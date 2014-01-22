'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' Initialisation
'===============================================================================

Function Init()

	HideMouse()
	JoyCount()

	TPlayer.CreatePlayer()
	Tbullet.image=LoadImage("gfx/player_shot.png", MASKEDIMAGE)

	CreateBG()
	TParticle.Init()
	TEnemy.Init()
	InitSound()

EndFunction
