Rem
A BlitzMax type that contains Abstract methods becomes abstract itself.
Abstract types are used to define interfaces that extending types must 
implement before they can be used to create new instances.

In the following code TShape is an abstract type in that you can not
create a TShape but anything extending a TShape must implement a Draw()
method.
End Rem

Type TShape
	Field	xpos,ypos
	Method Draw() Abstract
End Type

Type TCircle extends TShape
	Field	radius
	
	Function Create:TCircle(x,y,r)
		local c:TCircle=new TCircle
		c.xpos=x;c.ypos=y;c.radius=r
		return c
	End Function
	
	Method Draw()
		DrawOval xpos,ypos,radius,radius
	End Method
End Type

Type TRect extends TShape
	Field	width,height
	
	Function Create:TRect(x,y,w,h)
		local r:TRect=new TRect
		r.xpos=x;r.ypos=y;r.width=w;r.height=h
		return r
	End Function
	
	Method Draw()
		DrawRect xpos,ypos,width,height
	End Method
End Type

local 	shapelist:TShape[4]
local	shape:TShape

shapelist[0]=TCircle.Create(200,50,50)
shapelist[1]=TRect.Create(300,50,40,40)
shapelist[2]=TCircle.Create(400,50,50)
shapelist[3]=TRect.Create(200,180,250,20)

graphics 640,480
while not keyhit(KEY_ESCAPE)
	cls
	for shape=eachin shapelist
		shape.draw
	next
	flip
wend
end
