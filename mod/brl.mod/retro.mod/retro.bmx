
Strict

Rem
bbdoc: BASIC/BASIC compatibility
End Rem
Module BRL.Retro

ModuleInfo "Version: 1.09"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Cleaned up Mid$"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Deleted network stuff"

Import BRL.Basic

Rem
bbdoc: Extract substring from a string
returns: A sequence of characters from @str starting at position @pos and of length @size
about:
The Mid$ command returns a substring of a String.

Given an existing string, a @position from the start of the string and
an optional @size, #Mid creates a new string equal to the section specified.
If no size if given, #Mid returns the characters in the existing string from
@position to the end of the string.

For compatibility with classic BASIC, the @pos parameter is 'one based'.
End Rem
Function Mid$( str$,pos,size=-1 )
	If pos>Len( str ) Return Null
	pos:-1
	If( size<0 ) Return str[pos..]
	If pos<0 size=size+pos;pos=0
	If pos+size>Len( str ) size=Len( str )-pos
	Return str[pos..pos+size]
End Function

Rem
bbdoc: Find a string within a string
returns: The position within @str of the first matching occurance of @sub
about:
The @start parameter allows you to specifying a starting index for the search.

For compatiblity with classic BASIC, the @start parameter and returned position
are both 'one based'.
End Rem
Function Instr( str$,sub$,start=1 )
	Return str.Find( sub,start-1 )+1
End Function

Rem
bbdoc: Extract characters from the beginning of a string
returns: @size leftmost characers of @str
about:
The Left$ command returns a substring of a String.
Given an existing String and a @size, Left$ returns the first @size
characters from the start of the String in a new String.
End Rem
Function Left$( str$,n )
	If n>Len(str) n=Len(str)
	Return str[..n]
End Function

Rem
bbdoc: Extract characters from the end of a string
returns: @size rightmost characters of @str
about:
The Right$ command returns a substring of a String.
Given an existing String and a @size, Right$ returns the last @size
characters from the end of the String.
End Rem
Function Right$( str$,n )
	If n>Len(str) n=Len(str)
	Return str[Len(str)-n..]
End Function

Rem
bbdoc: Left justify string
returns: A string of length @n, padded with spaces
endrem
Function LSet$( str$,n )
	Return str[..n]
End Function

Rem
bbdoc: Right justify string
returns: A string of length @n, padded with spaces
endrem
Function RSet$( str$,n )
	Return str[Len(str)-n..]
End Function

Rem
bbdoc: Performs a search and replace function
returns: A string with all instances of @sub$ replaced by @replace$
about:
The Replace$ command replaces all instances of one string with another.
End Rem
Function Replace$( str$,sub$,replaceWith$ )
	Return str.Replace( sub,replaceWith )
End Function

Rem
bbdoc: Remove unprintable characters from ends a string
returns: @str with leading and trailing unprintable characters removed
End Rem
Function Trim$( str$ )
	Return str.Trim()
End Function

Rem
bbdoc: Convert string to lowercase
returns: Lowercase equivalent of @str
End Rem
Function Lower$( str$ )
	Return str.ToLower()
End Function

Rem
bbdoc: Convert string to uppercase
returns: Uppercase equivalent of @str
End Rem
Function Upper$( str$ )
	Return str.ToUpper()
End Function

Rem
bbdoc: Convert an integer value to a hexadecimal string
returns: The hexadecimal string representation of @val
End Rem
Function Hex$( val )
	Local buf:Short[8]
	For Local k=7 To 0 Step -1
		Local n=(val&15)+Asc("0")
		If n>Asc("9") n=n+(Asc("A")-Asc("9")-1)
		buf[k]=n
		val:Shr 4
	Next
	Return String.FromShorts( buf,8 )
End Function

Rem
bbdoc: Convert an integer value to a binary string
returns: The binary string representation of @val
End Rem
Function Bin$( val )
	Local buf:Short[32]
	For Local k=31 To 0 Step -1
		buf[k]=(val&1)+Asc("0")
		val:Shr 1
	Next
	Return String.FromShorts( buf,32 )
End Function

Rem 
bbdoc: Convert a 64 bit long integer value to a hexadecimal string 
returns: The hexadecimal string representation of @val 
End Rem 
Function LongHex$( val:Long ) 
	Return Hex$( val Shr 32 )+Hex$( val ) 
End Function 

Rem 
bbdoc: Convert a 64 bit long integer value to a binary string 
returns: The binary string representation of @val 
End Rem 
Function LongBin$( val:Long ) 
	Return Bin$( val Shr 32 )+Bin$( val ) 
End Function 
