Rem
While executes the following section of code repeatedly while a given condition is true.
End Rem

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)	'loop until escape key is pressed
	Cls
	For i=1 to 200
		DrawLine rnd(640),rnd(480),rnd(640),rnd(480)
	Next
	Flip
Wend
	