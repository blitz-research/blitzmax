Rem
:Import specifies the external BlitzMax modules and source files used by the program.
End Rem

Framework BRL.GlMax2D

Import BRL.System

Graphics 640,480,32

While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawText "Minimal 2D App!",0,0
	Flip
Wend
