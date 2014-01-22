'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' particles.bmx
'===============================================================================

Global particles:TList=New TList
Global particle_density=8
Global spark1,spark2,spark3,explosion, smoke
Global mult_img, score_decal

Type TParticle 
	Field link:TLink
	Field img	
	Field life
	Field frame
	Field x#,y#,xs#,ys#
	Field scale#, ss#
	Field speed#,gravity#=0
	Field bounce=0
	Field ang#, rs#=0.0;
	Field alpha#=1.0, as#=0.0

	'-------------------------------------------------------------------
	' Move / Draw
	'-------------------------------------------------------------------

	Method Update()
		' Move ---------------------------------------------------------
		x:+xs ; If x<0 Or x>WIDTH  Then kill()
		y:+ys ; If y<0 Or y>HEIGHT Then kill()
		ys:+gravity
		ang:+rs;
		alpha:+as
		scale:+ss

		' Draw ---------------------------------------------------------
		SetScale scale, scale
		SetRotation ang
		SetAlpha alpha
		SetBlend ALPHABLEND
		DrawImage img,x,y,frame
	
		life:-1
		If life<=0 Then particles.remove(Self)
	End Method
	
	Method hit()
		expl=1
		particles.remove(Self)
	End Method
	
	Method kill()
		particles.remove(Self)
	End Method

	'-------------------------------------------------------------------

	Function Init() 
		spark1=LoadImage("gfx/spark1.png", MASKEDIMAGE|FILTEREDIMAGE)
		spark2=LoadImage("gfx/spark2.png", MASKEDIMAGE|FILTEREDIMAGE)
		spark3=LoadImage("gfx/spark3.png", MASKEDIMAGE|FILTEREDIMAGE)		
		explosion=LoadImage("gfx/expl.png", MASKEDIMAGE|FILTEREDIMAGE)
		smoke=LoadImage("gfx/smoke.png", MASKEDIMAGE|FILTEREDIMAGE)
		score_decal	= LoadAnimImage("gfx/bonusdecals.png",128,64,0,5, MASKEDIMAGE|FILTEREDIMAGE)			
		mult_img =    LoadAnimImage("gfx/multdecals.png",128,64,0,10, MASKEDIMAGE|FILTEREDIMAGE)
	End Function

	'-------------------------------------------------------------------

	Function CreateExplosion(x,y)
		For Local s = 0 To particle_density
			TParticle.CreateSpark(explosion,x,y, 0.5 ,0 ,6 ,0.1 , Rand(50,100) ) 
			TParticle.CreateSpark(spark1,	x,y, 0.5 ,0 ,7 ,0.2 , Rand(30,80) ) 
			TParticle.CreateSpark(spark2,	x,y, 0.25,0 ,10 ,0.3, Rand(50,100)) 
		Next
		TParticle.Createspark(explosion, x,y,0.5,0.1,0,0, Rand(50,100))
	EndFunction

	Function PlayerExplosion(x,y)
		For Local s = 0 To particle_density*2
			TParticle.CreateSpark(explosion,x,y, 0.5 ,0 ,10 ,0.1 , Rand(150,200) ) 
			TParticle.CreateSpark(spark1,	x,y, 0.5 ,0 ,12 ,0.2 , Rand(130,180) ) 
			TParticle.CreateSpark(spark2,	x,y, 0.25,0 ,14 ,0.3, Rand(150,200)) 
		Next
		
		For Local i=1 To 6
			TParticle.Createspark(explosion, x+Rand(-64,64),y+Rand(-64,64),Rnd(0.25,1),0.2,Rand(4),0, Rand(150,300))
		Next 
	EndFunction



	Function CreateSpark:Tparticle(img,x#,y#,sc#,si#,sp#,gr#, lf)
		Local particle:Tparticle=New Tparticle
		particle.img=img
		
		particle.x=x
		particle.y=y

		particle.alpha=1
		particle.as=-0.03
		
		particle.scale=sc
		particle.ss=si
		
		particle.speed=sp

		particle.ang = Rnd(360)
		particle.xs = Sin(particle.ang)*sp
		particle.ys = Cos(particle.ang)*sp
										
		particle.rs#=Rnd(0,2)
		particle.life=lf		
		particle.gravity = gr
		
		particles.AddLast particle			
	End Function

	Function ShowBonus:Tparticle( x#,y#,frame )
		Local particle:Tparticle=New Tparticle
		particle.img=score_decal
		particle.frame=frame
		particle.x=x
		particle.y=y
		particle.alpha=1
		particle.as=-0.02
		particle.scale=0.5
		particle.ss=0.01
		particle.ang = 0
		particle.xs = 0
		particle.ys = -1
				
		particle.rs#=0
		particle.life=60
		particle.gravity=0
		
		particles.AddLast particle			
	End Function

	Function ShowMult:Tparticle( x#,y#,frame )
		Local particle:Tparticle=New Tparticle
		particle.img=mult_img
		particle.frame=frame
		particle.x=x
		particle.y=y
		particle.alpha=1
		particle.as=-0.02
		particle.scale=0.1
		particle.ss=0.2
		particle.ang = 0
		particle.xs = Rnd(-4,4)
		particle.ys = Rnd(-4,4)
				
		particle.rs#=Rnd(6)
		particle.life=100
		particle.gravity=0
		
		particles.AddLast particle			
	End Function


End Type

'----------------------------------------------------------------------
' End of file
'---------------------------------------------------------------------