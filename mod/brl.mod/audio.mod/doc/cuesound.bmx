Rem
CueSound example
End Rem

sound=LoadSound("shoot.wav")
channel=CueSound(sound)

Input "Press return key to play cued sound"

ResumeChannel channel

Input "Press return key to quit"
