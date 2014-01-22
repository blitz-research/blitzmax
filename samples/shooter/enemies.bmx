'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' enemies.bmx
'===============================================================================

Global enemies:TList=New TList
Global num_enemies=0
Global alien_img

Type TEnemy 
	Field link:TLink
	Field x#,y#
	Field xs#,ys#
	Field ang#, rs#;
	Field alpha#,img
	Field expl
	Field frame

	'-------------------------------------------------------------------
	' Move / Draw
	'-------------------------------------------------------------------

	Method Update()
		x:+xs ; If x>WIDTH Or x<0 Then xs:*-1
		y:+ys ; If y>HEIGHT Or y<0 Then ys:*-1
		frame=(frame+1)&63

		'SetRotation ang ; ang:+rs;
		SetAlpha 1
		SetBlend ALPHABLEND
		DrawImage img,x,y, frame/4
		CollideImage img,x,y,frame/4,0,1
	End Method
	
	Method hit()
'		PlaySound explode, SoundChannel
		PlaySound explode
		TParticle.CreateExplosion(x,y)
		TParticle.ShowBonus(x,y,1)
'		TParticle.ShowMult(x,y,Rand(9))
		enemies.remove(Self)
		num_enemies:-1
	End Method

	'-------------------------------------------------------------------

	Function CreateEnemy:TEnemy( x#,y# )
		Local enemy:TEnemy=New TEnemy
		enemy.x=x
		enemy.y=y
		enemy.alpha=0.1
		enemy.ang=0.0
		enemy.rs#=Rnd(0,4)
		enemy.Expl=0
		enemy.img=alien_img
		Repeat 
			enemy.xs=Rnd(-6,6)
		Until enemy.xs<>0

		Repeat 
			enemy.ys=Rnd(-6,6)
		Until enemy.ys<>0
		enemies.AddLast enemy
		num_enemies:+1
	End Function
	
	Function Init()
		SetMaskColor(255,0,255)
		alien_img=LoadAnimImage("gfx/spikeyball.png",64,64,0,16,MASKEDIMAGE)
	EndFunction

End Type

'----------------------------------------------------------------------
' End of file
'---------------------------------------------------------------------