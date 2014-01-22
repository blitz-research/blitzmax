
Strict

Type TColor

	Method RGBColor:TRGBColor() Abstract
	Method CMYColor:TCMYColor() Abstract
	Method HSVColor:THSVColor() Abstract

End Type

Type TRGBColor Extends TColor

	Field _red#,_grn#,_blu#

	Method RGBColor:TRGBColor()
		Return Self
	End Method

	Method CMYColor:TCMYColor()
		Return TCMYColor.CreateCMY( 1-_red,1-_grn,1-_blu )
	End Method

	Method HSVColor:THSVColor()
		Local hmin#=_red
		If _grn<hmin hmin=_grn
		If _blu<hmin hmin=_blu
		Local hmax#=_red
		If _grn>hmax hmax=_grn
		If _blu>hmax hmax=_blu
		If hmax-hmin=0 Return THSVColor.CreateHSV( 0,0,hmax )
		Local hue#,delta#=hmax-hmin
		Select hmax
		Case _red hue=(_grn-_blu)/delta
		Case _grn hue=2+(_blu-_red)/delta
		Case _blu hue=4+(_red-_grn)/delta
		End Select
		hue=hue*60
		If hue<0 hue=hue+360
		Return THSVColor.CreateHSV( hue,delta/hmax,hmax )
	End Method

	Method RED#()
		Return _red
	End Method

	Method GREEN#()
		Return _grn
	End Method

	Method BLUE#()
		Return _blu
	End Method
	
	Method Set(r#,g#,b#)
		_red=r
		_grn=g
		_blu=b
	End Method

	Function CreateRGB:TRGBColor( RED#,grn#,blu# )
		Local color:TRGBColor=New TRGBColor
		color._red=RED
		color._grn=grn
		color._blu=blu
		Return color
	End Function

End Type

Type TCMYColor Extends TColor
	
	Field _cyn#,_mag#,_yel#

	Method RGBColor:TRGBColor()
		Return TRGBColor.CreateRGB( 1-_cyn,1-_mag,1-_yel )
	End Method

	Method CMYColor:TCMYColor()
		Return Self
	End Method

	Method HSVColor:THSVColor()
		Return RGBColor().HSVColor()
	End Method

	Method CYAN#()
		Return _cyn
	End Method

	Method MAGENTA#()
		Return _mag
	End Method

	Method YELLOW#()
		Return _yel
	End Method

	Function CreateCMY:TCMYColor( cyn#,mag#,yel# )
		Local color:TCMYColor=New TCMYColor
		color._cyn=cyn
		color._mag=mag
		color._yel=yel
		Return color
	End Function

End Type

Type THSVColor Extends TColor

	Field _hue#,_sat#,_val#

	Method RGBColor:TRGBColor()
		If _sat<=0 Return TRGBColor.CreateRGB( _val,_val,_val )
		Local h#=_hue/60
		Local i#=Floor( h )
		Local f#=h-i
		Local p#=_val*(1-_sat)
		Local q#=_val*(1-(_sat*f))
		Local t#=_val*(1-(_sat*(1-f)))
		Select Int(i)
		Case 0 Return TRGBColor.CreateRGB( _val,t,p )
		Case 1 Return TRGBColor.CreateRGB( q,_val,p )
		Case 2 Return TRGBColor.CreateRGB( p,_val,t )
		Case 3 Return TRGBColor.CreateRGB( p,q,_val )
		Case 4 Return TRGBColor.CreateRGB( t,p,_val )
		Case 5 Return TRGBColor.CreateRGB( _val,p,q )
		End Select
	End Method

	Method CMYColor:TCMYColor()
		Return RGBColor().CMYColor()
	End Method

	Method HSVColor:THSVColor()
		Return Self
	End Method

	Method Hue#()
		Return _hue
	End Method

	Method Saturation#()
		Return _sat
	End Method

	Method Value#()
		Return _val
	End Method

	Function CreateHSV:THSVColor( hue#,sat#,val# )
		If hue<0 hue=hue+360
		If hue>=360 hue=hue-360
		Local color:THSVColor=New THSVColor
		color._hue=hue
		color._sat=sat
		color._val=val
		Return color
	End Function

End Type

Global RED:TColor=RGBColor( 1,0,0 )
Global GREEN:TColor=RGBColor( 0,1,0 )
Global BLUE:TColor=RGBColor( 0,0,1 )

Global ORANGE:TColor=RGBColor( 1,1,0 )

Global CYAN:TColor=CMYColor( 1,0,0 )
Global MAGENTA:TColor=CMYColor( 0,1,0 )
Global YELLOW:TColor=CMYColor( 0,0,1 )

Global BLACK:TColor=HSVColor( 0,0,0 )
Global WHITE:TColor=HSVColor( 0,0,1 )
Global GRAY:TColor=HSVColor( 0,0,.5 )
Global DARKGRAY:TColor=HSVColor( 0,0,.25 )
Global LIGHTGRAY:TColor=HSVColor( 0,0,.75 )

Rem
bbdoc: Create a red, green, blue color
returns: A new color object
about: @red, @grn and @blu should be in the range 0 to 1.
End Rem
Function RGBColor:TRGBColor( RED#,grn#,blu# )
	Return TRGBColor.CreateRGB( RED,grn,blu )
End Function

Rem
bbdoc: Create a cyan, magenta, yellow color
returns: A new color object
about: @cyn, @mag and @yel should be in the range 0 to 1.
End Rem
Function CMYColor:TCMYColor( cyn#,mag#,yel# )
	Return TCMYColor.CreateCMY( cyn,mag,yel )
End Function

Rem
bbdoc: Create a hue, saturation, value color
returns: A new color object
about: @hue should be in the range 0 to 360, @sat and @val should be in the range 0 to 1.
End Rem
Function HSVColor:THSVColor( hue#,sat#,val# )
	Return THSVColor.CreateHSV( hue,sat,val )
End Function

Rem
bbdoc: Get red component of a color
returns: Red component of @color in the range 0 to 1
End Rem
Function ColorRed#( color:TColor )
	Return color.RGBColor().RED()
End Function

Rem
bbdoc: Get green component of a color
returns: Green component of @color in the range 0 to 1
End Rem
Function ColorGreen#( color:TColor )
	Return color.RGBColor().GREEN()
End Function

Rem
bbdoc: Get blue component of a color
returns: Blue component of @color in the range 0 to 1
End Rem
Function ColorBlue#( color:TColor )
	Return color.RGBColor().BLUE()
End Function

Rem
bbdoc: Get cyan component of a color
returns: Cyan component of @color in the range 0 to 1
End Rem
Function ColorCyan#( color:TColor )
	Return color.CMYColor().CYAN()
End Function

Rem
bbdoc: Get magenta component of a color
returns: Magenta component of @color in the range 0 to 1
End Rem
Function ColorMagenta#( color:TColor )
	Return color.CMYColor().MAGENTA()
End Function

Rem
bbdoc: Get yellow component of a color
returns: Yellow component of @color in the range 0 to 1
End Rem
Function ColorYellow#( color:TColor )
	Return color.CMYColor().YELLOW()
End Function

Rem
bbdoc: Get hue component of a color
returns: Hue component of @color in the range 0 to 360
End Rem
Function ColorHue#( color:TColor )
	Return color.HSVColor().Hue()
End Function

Rem
bbdoc: Get saturation component of a color
returns: Saturation component of @color in the range 0 to 1
End Rem
Function ColorSaturation#( color:TColor )
	Return color.HSVColor().Saturation()
End Function

Rem
bbdoc: Get value component of a color
returns: Value component of @color in the range 0 to 1
End Rem
Function ColorValue#( color:TColor )
	Return color.HSVColor().Value()
End Function
