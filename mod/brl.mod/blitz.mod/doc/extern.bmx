Rem
Extern marks the beginning of an external list of function declarations.
End Rem

Extern 
	Function puts( str$z )
	Function my_puts( str$z )="puts"
End Extern

puts "Using clib's put string!"
my_puts "Also using clib's put string!"
