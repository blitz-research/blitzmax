'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' Sound & Music
'===============================================================================

Global player_shot, playerdie
Global bombfall
Global explode, SoundChannel, TempChannel
Global music, MusicChannel

Function InitSound()
	player_shot = LoadSound("sound/shot-1.wav", 0)
	playerdie = LoadSound("sound/explosion1.wav", 0)
	explode = LoadSound("sound/explode.wav", 0)
	bombfall = LoadSound("sound/bombfall.wav", 0)
	SoundChannel=0'AllocChannel()
	
	MusicChannel=AllocChannel()
'	music=LoadSound("sound/music.ogg",1)
EndFunction

'===============================================================================
'
'===============================================================================