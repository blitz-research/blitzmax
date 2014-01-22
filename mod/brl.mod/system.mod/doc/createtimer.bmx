Rem
The following BlitzMax program prints a new line to the console 5 times a second.
End Rem

' testtimer.bmx

t=createtimer(5)
frame=0

for i=1 to 10
	waittimer(t)
	print frame
	frame:+1
next
