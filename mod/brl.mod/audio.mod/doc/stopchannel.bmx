Rem
StopChannel example
End Rem

sound=LoadSound("shoot.wav",true)
channel=PlaySound(sound)

print "channel="+channel

Input "Press return key to stop sound"

StopChannel channel

Input "Press return key to quit"
