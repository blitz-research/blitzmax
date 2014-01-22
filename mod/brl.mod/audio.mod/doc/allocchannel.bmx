'AllocChannel.bmx

timer=createtimer(20)

sound=LoadSound ("shoot.wav")
channel=AllocChannel()

for i=1 to 20
	waittimer timer
	playsound sound,channel
next
