Rem
Shl is a binary operator that performs the shift to left function.
End Rem

b=1
for i=1 to 32
	print bin(b)
	b=b shl 1
next
