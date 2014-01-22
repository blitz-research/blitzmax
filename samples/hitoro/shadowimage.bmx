
' Rockets rotating and casting alpha-blended, pseudo light-sourced shadows on each other...

MAXNUM = 500

Graphics 640, 480, 32

AutoImageFlags MASKEDIMAGE

SetMaskColor 255, 0, 255

rocket = LoadImage ("gfx/boing.png",MASKEDIMAGE|MIPMAPPEDIMAGE)
grass = LoadImage ("gfx/grass.png")

MidHandleImage rocket

scale# = 0.5
trans# = 0.5

NUM = MAXNUM

Local x [NUM], y [NUM]
Local xs [NUM], ys [NUM]
Local ang# [NUM], angstep# [NUM]

For loop = 0 To NUM - 1
	x [loop] = Rand (0, GraphicsWidth () - 1)
	y [loop] = Rand (0, GraphicsHeight () - 1)
	xs [loop] = Rand (1, 5)
	ys [loop] = Rand (1, 5)
	ang [loop] = Rand (0, 359)
	angstep [loop] = Rnd (1, 5)
Next

NUM = 1

Repeat

	Cls

        If KeyHit (KEY_RIGHT) Or MouseHit (2)
           If NUM < MAXNUM Then NUM = NUM + 1
        Else
            If KeyHit (KEY_LEFT) Or MouseHit (1)
               If NUM > 1 Then NUM = NUM - 1
            EndIf
        EndIf

	mx = MouseX ()
	my = MouseY ()

        SetScale scale, scale
	SetRotation 0
	TileImage grass

	For loop = 0 To NUM - 1

		x [loop] = x [loop] + xs [loop]
		y [loop] = y [loop] + ys [loop]

		If x [loop] < 0 Or x [loop] > GraphicsWidth () - 1
		   xs [loop] = -xs [loop]; x [loop] = x [loop] + xs [loop]
		   angstep [loop] = -angstep [loop]
		EndIf

		If y [loop] < 0 Or y [loop] > GraphicsHeight () - 1
		   ys [loop] = -ys [loop]; y [loop] = y [loop] + ys [loop]
		   angstep [loop] = -angstep [loop]
		EndIf

		ang [loop] = ang [loop] + angstep [loop]
                If ang [loop] > 360 - angstep [loop] Then ang [loop] = 0
		SetRotation ang [loop]

		offx = -(mx - x [loop]) / 8
		offy = -(my - y [loop]) / 8
		DrawShadowedImage rocket, x [loop], y [loop], offx, offy, trans

	Next

        SetScale 1, 1
        DrawShadowText "Use left/right cursors or mouse buttons to add/remove rockets", 20, 20
        DrawShadowText "Move mouse to change light direction", 20, 40
        DrawShadowText "Number of rockets: " + NUM, 20, 80

	Flip

Until KeyHit (KEY_ESCAPE)

End

Function DrawShadowText (t$, x, y)
      SetRotation 0
      SetColor 0, 0, 0
      DrawText t$, x + 1, y + 1
      SetColor 255, 255, 255
      DrawText t$, x, y
End Function

Function DrawShadowedImage (image, x#, y#, xoff#, yoff#, level#)

	SetBlend ALPHABLEND
	SetColor 0, 0, 0
	SetAlpha level
	DrawImage image, x + xoff, y + yoff

	SetBlend MASKBLEND
	SetColor 255, 255, 255
	SetAlpha 1
	DrawImage image, x, y

End Function

