Strict

Import BRL.FreeAudioAudio
Import BRL.Wavloader


' sfx
Global ticksfx:TSound
Global bulletsfx:TSound
Global shotsfx:TSound
Global zapsfx:TSound
Global zoominsfx:TSound
Global zoomoutsfx:TSound

Global pulsesfx:TSound

Global killedbybulletsfx:TSound
Global killedbyflippersfx:TSound
Global killedbyspikesfx:TSound
Global killedbypulsarsfx:TSound
Global killedbyfuseballsfx:TSound

Global flippershotsfx:TSound
Global spikeshotsfx:TSound
Global pulsarshotsfx:TSound
Global fuseballshotsfx:TSound
Global tankershotsfx:TSound
Global spinnershotsfx:TSound

Global bonusmansfx:TSound

Incbin "sfx/tick.wav"
Incbin "sfx/bullet.wav"
Incbin "sfx/shot.wav"
Incbin "sfx/zap.wav"
Incbin "sfx/zoomin.wav"
Incbin "sfx/zoomout.wav"
Incbin "sfx/pulse.wav"
Incbin "sfx/killedbybullet.wav"
Incbin "sfx/killedbyflipper.wav"
Incbin "sfx/flippershot.wav"
Incbin "sfx/spikeshot.wav"
Incbin "sfx/bonus.wav"

Function LoadSfx()

	ticksfx = LoadSound("incbin::sfx/tick.wav")
	bulletsfx = LoadSound("incbin::sfx/bullet.wav")
	shotsfx = LoadSound("incbin::sfx/shot.wav")
	zapsfx = LoadSound("incbin::sfx/zap.wav")
	zoominsfx = LoadSound("incbin::sfx/zoomin.wav")
	zoomoutsfx = LoadSound("incbin::sfx/zoomout.wav")

	pulsesfx = LoadSound("incbin::sfx/pulse.wav")

	killedbybulletsfx = LoadSound("incbin::sfx/killedbybullet.wav")
	killedbyflippersfx = LoadSound("incbin::sfx/killedbyflipper.wav")
	killedbyspikesfx = LoadSound("incbin::sfx/killedbyflipper.wav")'*reused
	killedbypulsarsfx = LoadSound("incbin::sfx/killedbyflipper.wav")'*reused
	killedbyfuseballsfx = LoadSound("incbin::sfx/killedbyflipper.wav")'*reused

	flippershotsfx = LoadSound("incbin::sfx/flippershot.wav")
	spikeshotsfx = LoadSound("incbin::sfx/spikeshot.wav")
	pulsarshotsfx = LoadSound("incbin::sfx/flippershot.wav")'*reused
	fuseballshotsfx = LoadSound("incbin::sfx/flippershot.wav")'*reused
	tankershotsfx = LoadSound("incbin::sfx/flippershot.wav")'*reused
	spinnershotsfx = LoadSound("incbin::sfx/flippershot.wav")'*reused
	
	bonusmansfx = LoadSound("incbin::sfx/bonus.wav")

End Function