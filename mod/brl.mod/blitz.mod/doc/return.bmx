Rem
Return exits a BlitzMax function or method with an optional value.
The type of return value is dictated by the type of the function.
End Rem

Function CrossProduct#(x0#,y0#,z0#,x1#,y1#,z1#)
	Return x0*x1+y0*y1+z0*z1
End Function

Print "(0,1,2)x(2,3,4)="+CrossProduct(0,1,2,2,3,4)

Function LongRand:long()
	Return (rand($80000000,$7fffffff) shl 32)|(rand($80000000,$7fffffff))
End Function

Print "LongRand()="+LongRand()
Print "LongRand()="+LongRand()
