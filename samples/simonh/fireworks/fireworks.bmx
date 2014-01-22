' Fireworks by simonh (si@si-design.co.uk)

Strict

Global width=800
Global height=600

Graphics width,height,16

' Create a spark type
Type spark
	Field x#,y#,z#,vy#,xd#,yd#,zd#,r#,g#,b#,alpha#
End Type

' Load spark image
Global sparki:TImage=LoadImage("spark.png")

' Set no. of sparks to be created per firework
Global no_sparks=500

' Create spark list
Global spark_list:TList=New TList

' Load and set font
Global font:TImageFont=LoadImageFont("Arial.ttf",1)
SetImageFont font

' Start main loop
While Not KeyHit(KEY_ESCAPE)

	' If space key pressed then create new set of sparks (new firework)

	If KeyHit(KEY_SPACE)

		Local x#=Rand(-100,100)
		Local y#=Rand(-100,100)
		Local z#=200

		Local r#=Rand(255)
		Local g#=Rand(255)
		Local b#=Rand(255)

		For Local i=1 To no_sparks

			Local speed# = 0.1

			Local ang1# = Rnd!(360)
			Local ang2# = Rnd!(360)

			Local sp:spark=New Spark
			spark_list.AddLast sp

			sp.x=x#
			sp.y=y#
			sp.z=z#

			sp.xd=Cos(ang1#)*Cos(ang2#)*speed#
			sp.yd=Cos(ang1#)*Sin(ang2#)*speed#
			sp.zd=Sin(ang1#)*speed#
	
			sp.r=r
			sp.g=g
			sp.b=b
	
			sp.alpha=1
	
		Next

	EndIf

	' Draw all sparks

	For Local sp:spark=EachIn spark_list

		' If spark alpha is above 0 then draw it...

		If sp.alpha>0

			sp.x=sp.x+sp.xd*10.0
			sp.y=sp.y+sp.yd*10.0
			sp.z=sp.z+sp.zd*10.0
			sp.y=sp.y+sp.vy#
			sp.vy=sp.vy+0.02

			' Calculate x and y draw values based on x,y,z co-ordinates
			Local x#=(width/2.0)+((sp.x/sp.z)*500)
			Local y#=(height/2.0)+((sp.y/sp.z)*500)

			sp.alpha=sp.alpha-0.01

			SetColor sp.r#,sp.g#,sp.b#
			SetBlend LIGHTBLEND
			SetAlpha sp.alpha
			SetScale 20/sp.z,20/sp.z
			DrawImage sparki,x#,y#

		'...else remove spark from spark list

		Else

			spark_list.Remove sp

		EndIf

	Next

	SetBlend SOLIDBLEND
	SetScale 1,1
	SetColor 255,255,255
	DrawText "Press space to ignite firework",0,0

	Flip
	Cls

Wend
