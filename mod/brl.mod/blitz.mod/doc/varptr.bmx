Rem
Varptr returns the address of a variable in system memory.
End Rem

Local a:int
Local p:int ptr

a=20
p=varptr a
print p[0]
