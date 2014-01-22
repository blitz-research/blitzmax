' grabimage.bmx

' draws a small graphic then uses grabimage to make an image

' as mask color and cls color both default to black a mask is 
' created for the grabbed where any pixels unset on the backbuffer
' become transparent in the grabbed image

Graphics 640,480

Cls

DrawLine 0,0,32,32
DrawLine 32,0,0,32
DrawOval 0,0,32,32

Local image=CreateImage(640,480,1,DYNAMICIMAGE|MASKEDIMAGE)
GrabImage image,0,0

Cls
For i=1 To 100
	DrawImage image,Rnd(640),Rnd(480)
Next
Flip

WaitKey
 