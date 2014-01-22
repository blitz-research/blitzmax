Rem

Another Oldskool demo thingy, by FlameDuck and Razorien of Binary Therapy

It started as a simple circle scroller example but got somewhat out of hand. :o>

End Rem

Strict

Incbin "circlefont.png"
Incbin "oldskool.png"
Incbin "bouncy.ogg"
Incbin "binarytherapy.png"

Global scrollSpeed:Double = .6
Global rotangl:Double = 0
Global osLogo:TImage = LoadImage( "incbin::oldskool.png" )
Global myFont:TImage = LoadAnimImage( "incbin::circlefont.png",32,32,0,90 )
Global myBT:TImage = LoadImage( "incbin::binarytherapy.png" )

MidHandleImage myFont

Global scrollytext$ = " In 2004       Binary Therapy       Proudly Presents       Oldskool 2       Programmed by: FlameDuck       Logo by: Razorien ( http://www.razorien.se/ )       Font courtesy of FONText by: Beaker ( http://www.playerfactory.co.uk/ )       Music by:  Dr Av ( http://www.mentalillusion.co.uk/ )       This demo was written in the beta phase of BlitzMAX development, the source code is 237 lines total including empty lines and comments ....."
Global sp = 0; 'The scrollytext pointer.
Global ld = 0; 'The letter delay counter.
Global muzak:TSound = LoadSound( "incbin::bouncy.ogg",True )

Type scrollyLetter

	Field rad:Double, angl:Double, letter:Byte, rados:Double
	Field myList:TList

	Function createScrollyLetter:scrollyLetter(myChar:Byte)
		Local myLetter:scrollyLetter = New scrollyLetter
		myLetter.rad = 170
		myLetter.angl = -90
		myLetter.letter = myChar
		Return myLetter
	End Function

	Method setList(aList:TList)
		myList = aList
	End Method

	Method moveScrollyLetter()
		angl :+ scrollSpeed
		rados = Cos(angl*3 + rotangl) * 40
		If angl > 270
			myList.remove(Self)
		End If

	End Method

	Method drawLetter()
		Local x = Cos(angl) * (rad + rados)
		Local y = Sin(angl) * (rad + rados)

		SetRotation ATan2 ( y , x )

		Local myAlpha:Double = 1
		If angl < -45
			myAlpha:Double = (90.0+angl)/45.0
		Else If angl > 225
			myAlpha:Double = (270.0-angl)/45.0
		End If

		SetAlpha myAlpha
		DrawImage myFont, x + 400 , -y + 240 , letter

	End Method

End Type

Type circleScroller Extends TList

	Method doScroller()
		rotangl :+ scrollSpeed; rotangl :Mod 360

		ld :+ 1
		If  ld > 20
			If scrollytext[sp]-33 > 0 And scrollytext[sp]-33 < 90
				Local myLetter:scrollyLetter = scrollyLetter.createScrollyLetter( scrollytext[sp]-33 )
				myLetter.setList(Self)
				addLast myLetter
			End If
			sp = (sp+1) Mod Len(scrollytext)
			ld = 0
		End If

		SetBlend ALPHABLEND

		Local cLetter:scrollyLetter
		For cLetter = EachIn Self

			cLetter.moveScrollyLetter
			cLetter.drawLetter


		Next
		SetBlend MASKBLEND

		SetRotation 0
		SetAlpha 1

	End Method

End Type

Type star
	Field x:Double, y:Double, z:Double, angl:Double, anglv:Double, zv:Double

	Function createStar:star()
		Local myStar:star = New star
		myStar.x = Rnd(-240,240)
		myStar.y = Rnd(-240,240)
		myStar.z = 100
		myStar.angl = Rnd(0,360)
		myStar.anglv = Rnd(-5,5)
		myStar.zv = Rnd(0.5,2)
		Return myStar
	End Function

	Method moveStar()
		z :- zv
		Local myx = x / z *100
		Local myy = y / z *100

		If myx < -240 Or myx > 240 Or myy < -240 Or myx > 240 Or z < 1
			x = Rnd(-240,240)
			y = Rnd(-240,240)
			z = 100
			angl = Rnd(0,360)
			anglv = Rnd(-5,5)
			zv = Rnd(0.5,3)
		End If

		angl = angl + anglv
	End Method

	Method drawStar()
		Local myx = x / z *100
		Local myy = y / z *100

		Local cols = 255*(100-z)/100

		SetColor(cols,cols,cols)
		Plot myx+400 , myy+240

	End Method


End Type

Type starField Extends TList

	Method doStarField()

		Local cStar:star
		For cStar = EachIn Self

			cStar.moveStar
			cStar.drawStar

		Next
	 	SetColor 255,255,255

	End Method

End Type

Local myCS:circleScroller = New circleScroller
Local mySF:starField = New starField

Local ba = 0
Local intro = 0
Local i = 0
Local term:Double = 0

Local dd=32

Graphics 640,480,dd

HideMouse

Local myChannel:TChannel = PlaySound (muzak)

While term < 1

	If KeyHit( KEY_ENTER )
		dd=32-dd
		Graphics 640,480,dd
		HideMouse
		FlushKeys
	EndIf

	Cls

	mySF.doStarField

	If intro < 80
		intro :+2
	Else
		myCS.doScroller
		If i < 400
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			mySF.addLast star.createStar()
			i :+ 1
		End If
	End If

	SetBlend SOLIDBLEND
	DrawImage osLogo,-160+intro*2,0

	SetBlend MASKBLEND
	DrawImage myBT, 640-myBT.width * intro/80.0, 480-myBT.height - Sin(ba)*20

	SetBlend ALPHABLEND
	SetAlpha term
	SetChannelVolume myChannel,1-term
	SetColor 0,0,0
	DrawRect 0,0,640,480
	SetAlpha 1
	SetColor 255,255,255

	If KeyHit(KEY_ESCAPE) Or term > 0
		term :+ 0.01
	End If

	ba :+6; ba :Mod 180
	Flip

Wend
