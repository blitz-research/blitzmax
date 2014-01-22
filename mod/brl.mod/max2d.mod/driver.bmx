
Strict

Import BRL.Pixmap
Import BRL.Graphics

'modes for SetBlend
Const MASKBLEND=1
Const SOLIDBLEND=2
Const ALPHABLEND=3
Const LIGHTBLEND=4
Const SHADEBLEND=5

'flags for frames/images
Const MASKEDIMAGE=		$1
Const FILTEREDIMAGE=	$2
Const MIPMAPPEDIMAGE=	$4
Const DYNAMICIMAGE=		$8

'current driver
Global _max2dDriver:TMax2DDriver

Type TImageFrame

	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# ) Abstract
	
End Type

Type TMax2DDriver Extends TGraphicsDriver

	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags ) Abstract
	
	Method SetBlend( blend ) Abstract
	Method SetAlpha( alpha# ) Abstract
	Method SetColor( red,green,blue ) Abstract
	Method SetClsColor( red,green,blue ) Abstract
	Method SetViewport( x,y,width,height ) Abstract
	Method SetTransform( xx#,xy#,yx#,yy# ) Abstract
	Method SetLineWidth( width# ) Abstract
	
	Method Cls() Abstract
	Method Plot( x#,y# ) Abstract
	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# ) Abstract
	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# ) Abstract
	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# ) Abstract
	Method DrawPoly( xy#[],handlex#,handley#,originx#,originy# ) Abstract
		
	Method DrawPixmap( pixmap:TPixmap,x,y ) Abstract
	Method GrabPixmap:TPixmap( x,y,width,height ) Abstract
	
	Method SetResolution( width#,height# ) Abstract

End Type
