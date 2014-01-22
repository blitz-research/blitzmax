
Strict

Rem
Simple rect packer
Based on lightmap packing code by blackpawn
To remove a rect, set its kind to HOLLOW and optimize the root rect
End Rem

Type TRectNode

	Const NODE=0,SOLID=1,HOLLOW=-1

	Field x,y,width,height,kind
	Field child0:TRectNode,child1:TRectNode
	
	Method Insert:TRectNode( w,h )
		Local r:TRectNode
		If kind=NODE
			r=child0.Insert( w,h )
			If r Return r
			Return child1.Insert( w,h )
		EndIf
		If kind=SOLID Return Null
		If w>width Or h>height Return Null
		If w=width And h=height
			kind=SOLID
			Return Self
		EndIf
		kind=NODE
		Local dw=width-w
		Local dh=height-h
		If dw>dh
			child0=Create( x,y,w,height )
			child1=Create( x+w,y,dw,height )
		Else
			child0=Create( x,y,width,h )
			child1=Create( x,y+h,width,dh )
		EndIf
		Return child0.Insert( w,h )
	End Method
	
	Method Optimize()
		If kind<>NODE Return
		child0.Optimize
		child1.Optimize
		If child0.kind<>HOLLOW Or child1.kind<>HOLLOW Return
		kind=HOLLOW
		child0=Null
		child1=Null
	End Method
	
	Function Create:TRectNode( x,y,w,h )
		Local r:TRectNode=New TRectNode
		r.x=x
		r.y=y
		r.width=w
		r.height=h
		r.kind=HOLLOW
		Return r
	End Function
	
End Type
