
'This function will be automagically called every Flip
Function MyHook:Object( id,data:Object,context:Object )
	Global count
	
	count:+1
	If count Mod 10=0 Print "Flips="+count
	
End Function

'Add our hook to the system
AddHook FlipHook,MyHook

'Some simple graphics
Graphics 640,480,0

While Not KeyHit( KEY_ESCAPE )

	Cls
	DrawText MouseX()+","+MouseY(),0,0
	Flip

Wend



