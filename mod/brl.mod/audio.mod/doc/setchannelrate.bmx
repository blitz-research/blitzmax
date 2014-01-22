' setchannelrate.bmx

timer=CreateTimer(20)

sound = LoadSound ("shoot.wav",True)
channel=CueSound(sound)
ResumeChannel channel

For rate#=1.0 To 4 Step 0.01
	WaitTimer timer
	SetChannelRate channel,rate
Next
