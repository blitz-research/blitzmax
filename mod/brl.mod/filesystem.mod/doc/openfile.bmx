' openfile.bmx

' the following prints the contents of this source file 

file=openfile("openfile.bmx")

if not file runtimeerror "could not open file openfile.bmx"

while not eof(file)
	print readline(file)
wend
closestream file
