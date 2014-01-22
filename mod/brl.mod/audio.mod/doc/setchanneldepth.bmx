' setchanneldepth.bmx

Graphics 640, 480

channel = AllocChannel ()
sound = LoadSound ("shoot.wav") ' Use a short sample...

Repeat
	If MouseHit(1) PlaySound sound,channel
	
	pan# = MouseX () / (640 / 2.0) - 1
	depth# = MouseY () / (480 /2.0) -1
	
	SetChannelPan channel,pan
	SetChannelDepth channel,depth

	Cls
	DrawText "Click to play...", 240, 200
	DrawText "Pan   : " + pan, 240, 220
	DrawText "Depth : " + depth, 240, 240

	Flip
Until KeyHit (KEY_ESCAPE)

End
