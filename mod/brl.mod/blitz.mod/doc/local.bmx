Rem
Local defines a variable as local to the Method or Function it is defined meaning it is automatically released when the function returns.
End Rem

Function TestLocal()
	Local	a
	a=20
	print "a="+a
	Return
End Function

TestLocal
print "a="+a	'prints 0 or if in Strict mode is an error as a is only local to the TestLocal function
