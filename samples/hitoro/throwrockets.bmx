Const PARTICLE_GRAVITY# = 0.05

Global ParticleCounter
Global ParticleList:TList = New TList

' Core abstract type...

Type Atom

	Field image
	Field x#
	Field y#
	Field xs#
	Field ys#
	Field ALPHA# = 1
	Field size#
	
	Method Update () Abstract

End Type

' Generic particle type that holds creation/update functions, based
' on abstract type Atom...

Type Particle Extends Atom

	Function Create:Particle (image, x#, y#, xs#, ys#)
		p:Rocket = New Rocket
		p.image = image
		p.x = x
		p.y = y
		p.xs = xs
		p.ys = ys
		ParticleList.AddLast p
		ParticleCounter = ParticleCounter + 1
		Return p
	End Function

	Function UpdateAll ()
		Local p:Atom
		For p=EachIn ParticleList
	      	p.Update ()
		Next
	End Function

End Type

' Types based on Particle, all to be created using EXTENDED_TYPE.Create ()...

Type Rocket Extends Particle

	Method Update ()
		If ALPHA > 0.01
			ALPHA = ALPHA - 0.005
			SetAlpha ALPHA
			ys = ys + PARTICLE_GRAVITY
			x = x + xs
			y = y + ys
			ang# = ATan2 (xs, -ys)
			SetRotation ang
			DrawImage image, x, y
			If x < 0 Or x > GraphicsWidth () Or y > GraphicsHeight ()
				ParticleList.Remove Self
				ParticleCounter = ParticleCounter - 1
			EndIf
		Else
			ParticleList.Remove Self
			ParticleCounter = ParticleCounter - 1
		EndIf
	End Method

End Type

' --------------------------------------------------------------------------------

Incbin "gfx/boing.png"

Const GAME_WIDTH = 640
Const GAME_HEIGHT = 480

Const GRAPHICS_WIDTH = 1024
Const GRAPHICS_HEIGHT = 768

Graphics GRAPHICS_WIDTH,GRAPHICS_HEIGHT,32

SetVirtualResolution GAME_WIDTH,GAME_HEIGHT

SetClsColor 64, 96, 180

SetMaskColor 255, 0, 255
AutoImageFlags MASKEDIMAGE ' Disable for filtered rockets...

image = LoadImage ("incbin::gfx/boing.png")
MidHandleImage image

lastmousex = VirtualMouseX ()
lastmousey = VirtualMouseY ()

Repeat

	x = VirtualMouseX ()
	y = VirtualMouseY ()

	mxs# = VirtualMouseXSpeed ()'# = x - lastmousex
	mys# = VirtualMouseYSpeed ()'# = y - lastmousey

	Cls

	xs# = mxs / 10 + Rnd (-0.1, 0.1)
	ys# = mys / 10 + Rnd (-0.1, 0.1)

	If MouseDown (1) And (mxs Or mys)
		Rocket.Create (image, x, y, xs, ys)
	EndIf

        SetScale 0.2, 0.2
	SetBlend ALPHABLEND
	Particle.UpdateAll ()

        SetScale 1, 1
        SetRotation 0

	DrawText "Click and drag mouse to throw rockets!", 10, 10
	DrawText "Rockets: " + ParticleCounter, 10, 25

	Flip

	lastmousex = x
	lastmousey = y

Until KeyHit (KEY_ESCAPE)

End
