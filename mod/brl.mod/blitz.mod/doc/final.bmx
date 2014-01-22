Rem
Final stops methods from being redefined in super classes.
End Rem

Type T1
	Method ToString$() Final
		return "T1"
	end method
End Type

Type T2 extends T1
	method ToString$()	'compile time error "Final methods cannot be overridden"
		return "T2"
	end method
End Type
