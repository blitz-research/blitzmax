Strict 

' run in 800X600
Const CWidth#=800 
Const CHeight#=600

Global K# = 50

Global CCenterX#=CWidth/2.0
Global CCenterY#=CHeight/3.0

Global YOFFSET = 128
Global XOFFSET = 0
Global ZOFFSET = 5



' Return the dot product AB · BC.
Function DotProduct#( Ax#,Ay#,Bx#,By#,Cx#,Cy#)

	Local BAx#
	Local BAy#
	Local BCx#
	Local BCy#
	
    ' Get the vectors' coordinates.
    BAx = Ax - Bx
    BAy = Ay - By
    BCx = Cx - Bx
    BCy = Cy - By

    ' Calculate the dot product.
    Return (BAx * BCx + BAy * BCy)

End Function




' Return the cross product AB x BC.
Function CrossProductLength#( Ax#,Ay#,Bx#,By#,Cx#,Cy#)

	Local BAx#
	Local BAy#
	Local BCx#
	Local BCy#

    ' Get the vectors' coordinates.
    BAx = Ax - Bx
    BAy = Ay - By
    BCx = Cx - Bx
    BCy = Cy - By

    ' Calculate the Z coordinate of the cross product.
	Return(BAx * BCy - BAy * BCx)
	
End Function



' Return the angle ABC.
Function GetAngle#( Ax#,Ay#,Bx#,By#,Cx#,Cy#)

	Local dot_product#
	Local cross_product#
	Local angle#

    ' Get the dot product and cross product.
    dot_product = DotProduct(Ax, Ay, Bx, By, Cx, Cy)
    cross_product = CrossProductLength(Ax, Ay, Bx, By, Cx, Cy)

    ' Calculate the angle.
    angle = MyATan2(cross_product, dot_product)
	If angle = 0 Then angle = 180

	' ...handle if angle > 180 case
	' find point ax2,ay2 - rotated -90 degrees
	' find new angle2
	' if angle2 is > 90, then angle = 360-angle
	If angle <> 180
		Local px# = ax
		Local py# = ay
		Local rang = -1
		If angle < 90 Then rang = -(179-angle)
		TFormR(bx,by, rang, px#,py#)
		dot_product = DotProduct(px, py, Bx, By, Cx, Cy)
    	cross_product = CrossProductLength(px, py, Bx, By, Cx, Cy)
	    ' Calculate the angle.
    	Local angle2 = MyATan2(cross_product, dot_product)
		If angle2 > 90 Then angle=360-angle
	EndIf
	
	Return Abs(angle Mod 360)

End Function




' Return the angle with tangent opp/hyp.
Function MyATan2#(opp#, adj#)

	Local angle#

    ' Get the basic angle.
    If Abs(adj) < 0.0001 Then
        angle = 90 
    Else
        angle = Abs(ATan(opp / adj))
    End If

    ' See if we are in quadrant 2 or 3.
    If adj < 0 Then
        angle = 180-angle 
    End If

    ' See if we are in quadrant 3 or 4.
    If opp < 0 Then
        angle = -angle
    End If

    ' Return the result.
    Return angle

End Function







'scale 
Function TFormSZ#(x#, z#)
	z:+ZOFFSET '50 
	Return (x/(z/K))
EndFunction


' rotate xr,yr around xc,yc
Function TFormR(xc#,yc#, angle, xr# Var,yr# Var)
	Local x# = (xr-xc)
	Local y# = (yr-yc)
	xr = Cos(angle)*x - Sin(angle)*y
	yr = Sin(angle)*x + Cos(angle)*y
	xr = xc+xr
	yr = yc+yr
End Function


'scale based on z
Function TForm(x#, y#, z#, x2d# Var, y2d# Var )
	z:+ZOFFSET
	y:+YOFFSET
	x:+XOFFSET
	x2d = CCenterX+(x/(z/K)) 
	y2d = CCenterY+(y/(z/K))
EndFunction

