
Strict

Graphics 1024,768

Local font:TImageFont=LoadImageFont( "blitz.fon",14 )
If Not font End

SetImageFont font

For Local x=0 Until 96
	DrawText Chr(x+32),x*8,0
Next

Local pixmap:TPixmap=GrabPixmap( 0,0,96*8,16 )

Local out:TStream=WriteStream( "blitzfont.bin" )

For Local y=0 Until 16
	For Local x=0 Until 96
		Local b
		For Local n=0 Until 8
			If ReadPixel( pixmap,x*8+n,y ) & $ff 
				b:|(1 Shl n)
			EndIf
		Next
		WriteByte out,b
	Next
Next

CloseStream out


