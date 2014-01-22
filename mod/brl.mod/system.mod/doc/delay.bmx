Rem
The following BlitzMax program prints a new line to the console 10 times a second.
End Rem

' testtimer.bmx

for i=1 to 10
	print frame
	frame:+1
	delay 100
next
