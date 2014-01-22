
Graphics 640,480,0

While Not AppTerminate() Or Not Confirm( "Terminate?" )

	Cls
	DrawText MouseX()+","+MouseY(),0,0
	Flip

Wend
