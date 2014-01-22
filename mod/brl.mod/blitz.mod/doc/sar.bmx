Rem
Sar is a binary operator that performs the arithmetic shift to right function.
End Rem

b=$f0f0f0f0
for i=1 to 32
	print bin(b)
	b=b sar 1
next
