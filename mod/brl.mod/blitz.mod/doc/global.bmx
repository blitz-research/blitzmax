Rem
Global defines a variable as Global allowing it be accessed from within Methods and Functions.
End Rem

Global a=20

Function TestGlobal()
	print "a="+a
End Function

TestGlobal
print "a="+a
