' Snowfall by simonh (si@si-design.co.uk)

Strict

Global width=800
Global height=600

Graphics width,height,16

' Load snowflake image
Global flakei:TImage=LoadImage("flake.png",MIPMAPPEDIMAGE)

' Set no. of snowflakes to be created
Global no_flakes=1000

' Create a snowflake type
Type flake
	Field x#,y#,size#,speed#,sway#,phase
End Type

' Create snowflake list
Global flake_list:TList=New TList

' Initialise snowflakes

For Local i=1 To no_flakes

	Local fl:flake=New flake
	flake_list.AddLast fl

	fl.size=Rnd!(0.01,0.1)
	fl.speed=Rnd!(1,2)
	fl.sway=Rnd!(1,2)
	fl.phase=Rand(45)
	fl.x=Rand(-10,width+10)
	fl.y=Rand(height)-height-10

Next

' Main loop

While Not KeyHit(KEY_ESCAPE)

	' Begin loop in which we will update values of all snowflakes and draw them

	For Local wind=1 To 360 Step 5

		' Iterate through our snowflake list

		For Local fl:flake=EachIn flake_list

			' Just update the snowflake position values to try and make them move convincingly!
			fl.y=fl.y+fl.speed
			fl.x#=fl.x#+(Sin(wind+(fl.phase)))*fl.sway

			' If snowflake has not yet reached the bottom of screen...
			If fl.y<height+10

				' ...then draw snowflake.
				SetBlend LIGHTBLEND
				SetScale fl.size,fl.size
				DrawImage flakei,fl.x,fl.y

			'...else if snowflake has reached bottom of screen...
			Else

				'...reset snowflake values so it appears as new snowflake at top of screen.
				fl.speed=Rnd!(1,2)
				fl.sway=Rnd!(1,2)
				fl.phase=Rand(45)
				fl.x=Rand(-10,width+10)
				fl.y=-10

			EndIf

		Next

		Flip
		Cls

	Next

Wend
