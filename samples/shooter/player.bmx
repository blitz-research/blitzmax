'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' Player.bmx
'===============================================================================

Global score=0, oldswitch=0
Global mx, mn, damping#
Global player:TPlayer


Type TPlayer 
	Field x#,y#,xs#,ys#
	Field rot#,alpha#,img,frame=2
	Field primary_weapon, secondary_weapon
	Field pshot_timer=0
	Field shield = 0
	Field invincible =0
	Field state=0, lives
	
	'---------------------------------------
	
	Function CreatePlayer()
		player=New TPlayer
		player.x=320; xs#=0
		player.y=240; ys#=0
		player.img=LoadAnimImage:TImage("gfx/playera.png",80,64,0,5, MASKEDIMAGE|FILTEREDIMAGE )
		mx=6
		mn=-6
		damping#=0.8
		player.rot=0
		player.state=1
		player.lives=3
		player.shield=180
		player.invincible=0
		player.primary_weapon=WPN_DEFLASER
	EndFunction

	'---------------------------------------
			
	Method Update()
		shield:-1
		If state=2 Then Goto pskip

		'---------------------------------------------
		' move
		
		If JoyDown(5) Then
			If oldswitch=0 Then
				direction=-direction
				oldswitch=1
			Else
				oldswitch=0
			EndIf
		EndIf
		
			
		If KeyHit(KEY_I) Then invincible=1-invincible
			
		If KeyDown(KEY_RIGHT)Or KeyDown(KEY_D) Then xs:+1
		If KeyDown(KEY_LEFT)Or KeyDown(KEY_A) Then xs:-1	
		If Abs(JoyX(0))>0.2 Then xs:+JoyX(0) 
		If (xs > mx) Then xs=mx
		If (xs < mn) Then xs=mn
		xs:*damping# ; If Abs(pvx)<0.5 Then pvx=0

		If KeyDown(KEY_UP)Or KeyDown(KEY_W) Then ys:-1 
		If KeyDown(KEY_DOWN) Or KeyDown(KEY_S) Then ys:+1				
		If Abs(JoyY(0))>0.2 Then ys:+JoyY(0) 
		
		If ys > mx Then ys=mx
		If ys < mn Then ys=mn
		
		ys:*damping# ; If Abs(pvy)<0.5 Then pvy=0
		frame = 4-(Int(ys/1.5)+2)
				
		x:+xs ; If x>=WIDTH Then x=WIDTH ; If x<=0 Then x=0
		y:+ys ; If y>=HEIGHT Then y=HEIGHT ; If y<=0 Then y=0

		'---------------------------------------------
		' shoot?

		pshot_timer:-1
		If (JoyDown(2) Or KeyDown(KEY_SPACE)) And pshot_timer<0 Then fire()								
																								
#pskip	If state=2 Then
			If rot<60 Then rot=rot+0.25
			ys=ys+0.05
			y=y+ys
			x=x+1
			' img,x#,y#,sc#,si#,sp#,gr#, lf
			If (Int(y)&3)=1 Then TParticle.Createspark(smoke, x,y,0.25,0.02,Rand(-0.5,0.5),0, Rand(125,175) )

			If y>HEIGHT Then 
				StopChannel TempChannel
				PlaySound playerdie
				TParticle.PlayerExplosion(x,y)
				rot=0
				state=1
				y=HEIGHT/2
				ys=0
				shield=180
				lives=lives-1
			EndIf
		EndIf	

		'---------------------------------------------
		' Draw
		
		SetBlend ALPHABLEND
		SetScale 1,1
		SetAlpha 1
		SetRotation rot
		
		If shield>0 Then SetAlpha Rnd(1)

		DrawImage img,x,y,frame

		'---------------------------------------------	
		' Collisions
		If (shield <0) Then
			If CollideImage(img,x,y,frame,1,0) Then hit() ' Player/Alien Collision
'			If CollideImage(img,x,y,frame,2,0) Then hit() ' Player/Ground Collision
		EndIf
		'---------------------------------------------	
		
	End Method
	
	Method fire()

		Select primary_weapon
		
			Case WPN_NORMAL
					TBullet.CreateBullet bull_img,x+24,y+2+(ys*2),(16+spd)*direction		
					pshot_timer=5
					PlaySound player_shot, SoundChannel
								
			Case WPN_DEFLASER
			
				For Local sp=1 To 8
					TBullet.CreateBullet bull_img,x+24,y+2+(ys*2),(16+sp)*direction
				Next
				pshot_timer=5
				PlaySound player_shot, SoundChannel

		End Select

	End Method
	
	
	Method hit()
		If invincible Then Return
		If state=1 Then 
'			TParticle.PlayerExplosion(x,y)
			TParticle.CreateExplosion(x,y)
			TempChannel=AllocChannel()
			PlaySound bombfall, TempChannel
			state=2
		EndIf
	End Method

End Type


'----------------------------------------------------------------------
' End of file
'---------------------------------------------------------------------