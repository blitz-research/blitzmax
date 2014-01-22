Rem

Another Oldskool demo thingy, by FlameDuck and Razorien of Binary Therapy

End Rem

Strict

Type rasterBar
	Field angle:Double,angleadd:Double,color[],freq:Double

	Function addRasterBar(aSpeed:Double, aFreq:Double, aColor[], aList:TList)
		Local temp:rasterBar = New rasterBar
		temp.angle=0
		temp.angleadd=aSpeed
		temp.freq=aFreq
		temp.color = aColor
		aList.addLast(temp)
	End Function

	Method drawRasterBar(xstart:Int, ycenter:Int, scale:Double)
		SetBlend LIGHTBLEND
		SetColor(color[0],color[1],color[2])
		angle:+angleadd

		For Local i:Int = 0 To 736
			Local temp:Int = i+xstart
			If temp > 0 Or temp < 799
				DrawImage rastaImage, temp, ycenter + Sin((i+angle)*freq)*scale
			End If
		Next
	End Method

End Type

Type polarVector
	Field length:Double, angle:Double

	Function Create:polarVector(aLength:Double, anAngle:Double)
		Local temp:polarVector = New polarVector
		temp.length=aLength;temp.angle=anAngle
		Return temp
	End Function
End Type

Type baseEntity
	Field offset:polarVector, angvel:Double

	Method update(anx:Double, any:Double) Abstract
End Type

Type circleBob
	Field velocity:polarVector
	Field x:Double,y:Double
	Field life:Int

	Function CreateCircleBob:circleBob(anx:Double, any:Double, avelocity:polarVector)
		Local temp:circleBob = New circleBob
		temp.x=anx;temp.y=any;temp.velocity=avelocity
		temp.life=20
		Return temp
	End Function

	Method update()
		x:+Cos(velocity.angle)*velocity.length
		y:+Sin(velocity.angle)*velocity.length*yaspect
		life:-1
		SetAlpha life/40!
		DrawImage cmBob, x, y
	End Method

	Method isDead:Int()
		If life < 1
			Return True
		Else If x < 0 Or x > 799
			Return True
		Else If y < 0 Or y > 599
			Return True
		End If
		Return False
	End Method

End Type

Type spawn Extends baseEntity
	Field cBobs:TList

	Method update(anx:Double,any:Double)
		offset.angle:+ angvel

		anx:+Cos(offset.angle)*offset.length
		any:+Sin(offset.angle)*offset.length*yaspect
		Local temp:circleBob = circleBob.createCircleBob(anx,any, polarVector.Create(Rnd(4,8),ATan2((320-any),(368-anx))))
		cBobs.addlast(temp)

		For Local mycBob:circleBob = EachIn cBobs
			mycBob.update()
			If myCBob.isDead()
				cBobs.remove(mycBob)
			End If
		Next

	End Method

	Function Create:spawn(anAngle:Double, anAngvel:Double, aRadius:Double)
		Local temp:spawn = New spawn
		temp.cBobs = New TList
		temp.offset = polarVector.Create(aRadius, anAngle)
		temp.angvel=anAngvel
		Return temp
	End Function

End Type

Type anchor Extends baseEntity
	Field spawns:TList

	Method update(anx:Double, any:Double)
		offset.angle:-angvel
		For Local mySpawn:spawn = EachIn spawns
			mySpawn.update(anx+Cos(offset.angle)*offset.length, any+Sin(offset.angle)*offset.length*yaspect)
		Next

	End Method

	Function Create:anchor(anAngle:Double, anAngvel:Double, aRadius:Double, numSpawns:Int)

		Local ddeg:Double = 360:Double/numSpawns
		Local myAnchor:anchor = New anchor
		myAnchor.spawns=New TList
		myAnchor.offset = PolarVector.Create(aRadius, anAngle)
		myAnchor.angvel=anAngvel
		For Local i = 1 To numSpawns
			Local temp:spawn = spawn.Create(ddeg*i, anAngvel, aRadius/2)
			myAnchor.spawns.addlast temp
		Next
		Return myAnchor
	End Function
End Type

Type root
	Field anchors:TList

	Method update()
		For Local myAnchor:anchor = EachIn anchors
			myanchor.update(368,320)
		Next
		SetAlpha 1

	End Method

	Function Create:root(anAngvel:Double, aRadius:Double, numAnchors:Int, numSpawns:Int)
		Local ddeg:Double = 360:Double/numSpawns
		Local myRoot:root=New root
		myRoot.anchors = New TList
		For Local i = 1 To numAnchors
			Local temp:anchor = anchor.Create(ddeg*i, anAngvel, aRadius, numSpawns)
			myRoot.anchors.addlast temp
		Next
		Return myRoot
	End Function


End Type

Type imageStrip
	Field effectImages:TImage[16]
	Field counter:Int


	Function loadImages:imageStrip(name:String)
		Local temp:imageStrip = New imageStrip
		For Local i:Int = 0 To 15
			Local fname:String = name+String(i)+".png"
			temp.effectImages[i] = LoadImage(fname)
		Next
		temp.counter = 0
		Return temp
	End Function

	Method update(x:Int,y:Int)
		counter:-1
		If counter < 0
			counter=15
		EndIf

		DrawImage effectImages[counter],x,y
	End Method

End Type

Graphics 800,600,32

Global yaspect:Double = 3/5!
Global rastaImage:TImage = LoadImage("rasta.png")
Global logo:TImage = LoadImage("cmanialogo.png")
Global cmBob:TImage = LoadImage("circlebob.png")
MidHandleImage logo

Global maskEffect:imageStrip = imageStrip.LoadImages("anim")

Local myRBList:TList = New TList
rasterBar.addRasterBar(3!,2!, [255,0,0], myRBList)
rasterBar.addRasterBar(5!,1.5!, [0,255,0], myRBList)
rasterBar.addRasterBar(7!,1!, [0,0,255], myRBList)

Local angle:Double = 0
Local effectRoot:root = root.Create(4, 200, 6, 6)

While Not KeyHit(KEY_ESCAPE)

	Cls

	Local xpos:Int = 124 * Sin(angle)

	For Local i:rasterBar = EachIn myRBList
		i.drawRasterBar(xpos+32 , 28!, 28!)
	Next

	SetBlend ALPHABLEND

	DrawImage logo, 400 + xpos,58
	angle:+4
	angle:Mod 360

	Local temp = 255*Abs((-180+angle)/180!)

	SetColor temp,temp,temp
	DrawLine 0,116,799,116
	SetColor 255,255,255
	effectRoot.update
	Flip

End While

