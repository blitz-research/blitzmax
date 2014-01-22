Rem
Catch defines an exception handler following a Try..EndTry Block.
End Rem

Try
	repeat
		a:+1
		print a
		if a>20 throw "chunks"
	forever
Catch a$
	print "caught exception "+a$
EndTry
