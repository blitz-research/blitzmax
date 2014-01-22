Rem
IncBinLen returns the size in bytes of the specified embedded binary file.
End Rem

incbin "incbinlen.bmx"

local p:byte ptr=IncBinPtr("incbinlen.bmx")
local bytes=incbinlen("incbinlen.bmx")

local s$=StringFromBytes(p,bytes)

Print "StringFromBytes(p,bytes)="+s$
