' channelplaying.bmx

sound = LoadSound ("shoot.wav")

Input "Hit return to begin channelplaying test, use ctrl-C to exit"

channel=playsound (sound)
while true
	print "ChannelPlaying(channel)="+ChannelPlaying(channel)
wend
