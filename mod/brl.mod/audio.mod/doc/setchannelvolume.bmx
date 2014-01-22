' setchannelvolume.bmx

timer=CreateTimer(20)

sound = LoadSound ("shoot.wav")

For volume#=.1 To 2 Step .05
	WaitTimer timer
	channel=CueSound(sound)
	SetChannelVolume channel,volume
	ResumeChannel channel
Next
