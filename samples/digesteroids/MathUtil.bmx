' *******************************************************************
' Source: Math Util
' Version: 1.00
' Author: Rob Hutchinson 2004
' Email: rob@proteanide.co.uk
' WWW: http://www.proteanide.co.uk/
' -------------------------------------------------------------------
' Some generic functions. Certainly nothing to do with Math. HURRAH!
' -------------------------------------------------------------------
' Required:
'  - Nothing.
' *******************************************************************

Type MathUtil

'#Region Method: QWrapF
	' Wraps only once, if the value is out of the range by twice as much, this function will return incorrect values,
	' However, it is faster than Wrap. Use Wrap for accurate results.
	Function QWrapF:Float(Value:Float,Minimum:Float,Maximum:Float)
		If Value > Maximum
			Return Minimum + (Value Mod Maximum)
		ElseIf Value < Minimum
			Return Maximum - Abs(Minimum - Value)
		EndIf
		Return Value
	End Function
'#End Region
'#Region Method: QWrapDegrees
	Function QWrapDegrees:Double(Value:Double)
		If Value > 359.0
			Return (0.0 + (Value Mod 359.0))
		ElseIf Value < 0.0
			Return (359.0 - Abs(0.0 - Value))
		EndIf
		Return Value
	End Function
'#End Region
'#Region Method: Wrap
	Function Wrap:Float(Value:Float,Minimum:Float,Maximum:Float)
		Local Difference:Float = Maximum - Minimum
		While ((Value < Minimum) Or (Value => Maximum))
			If Value => Maximum
				Value:- Difference
			Else
				If Value < Minimum
					Value:+ Difference
				EndIf
			EndIf
		Wend
		Return value
	End Function
'#End Region
'#Region Method: CurveValue
	Function CurveValue:Float(Current:Float,Destination:Float,Curve:Int)
		Current = Current + ( (Destination - Current) /Curve)
		Return Current
	End Function
'#End Region

End Type
