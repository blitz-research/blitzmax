' loaddir.bmx

' declare a string array

local files$[]

files=loaddir(currentdir())

for t$=eachin files
	print t	
next
