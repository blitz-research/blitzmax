' writefile.bmx

file=writefile("test.txt")

if not file runtimeerror "failed to open test.txt file" 

writeline file,"hello world"

closestream file
