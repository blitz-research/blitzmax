
Incbin "gfx/bg.png"
Incbin "gfx/boing.png"

Graphics 640, 480 , 32

AutoImageFlags MASKEDIMAGE|FILTEREDIMAGE

SetMaskColor 255, 0, 255

bg = LoadImage ("incbin::gfx/bg.png")
bgw# = GraphicsWidth () / Float (ImageWidth (bg))
bgh# = GraphicsHeight () / Float (ImageHeight (bg))

image = LoadImage ("incbin::gfx/boing.png") ' My example is 256 x 256
MidHandleImage image

rotstep# = 1

Repeat

	mx = MouseX (); my = MouseY ()
	
	SetViewport 0, 0, GraphicsWidth (), GraphicsHeight ()
	Cls
	
	SetViewport mx - 200, my - 150, 400, 300
	Cls
	
	' ---------------------------------------------------------------
	' Draw background...
	' ---------------------------------------------------------------
	
	SetAlpha 1
	SetBlend MASKBLEND
	
	SetRotation 0; SetScale bgw, bgh
	DrawImage bg, 0, 0
	
	' ---------------------------------------------------------------
	' Draw image...
	' ---------------------------------------------------------------
	
	rot# = rot + rotstep; If rot > 360 - rotstep Then rot = 0
	SetRotation rot
	
	scale# = 0.1 + Sin (rot / 2); If scale < 0 Then scale = -scale
	SetScale scale, scale
	
	SetBlend ALPHABLEND
	SetAlpha scale
	
	DrawImage image, mx, my
	
	Flip
	
Until KeyHit (KEY_ESCAPE)

End






