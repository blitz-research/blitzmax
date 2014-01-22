Rem
IncBinPtr returns a byte pointer to the specified embedded binary file.
End Rem

Incbin "incbinptr.bmx"

Local p:Byte Ptr=IncbinPtr("incbinptr.bmx")
Local bytes=IncbinLen("incbinptr.bmx")

Local s$=String.FromBytes(p,bytes)

Print "StringFromBytes(p,bytes)="+s$
