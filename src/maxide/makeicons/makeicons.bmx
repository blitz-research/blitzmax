
Strict

Local n
Repeat
	Local t$
	ReadData t$
	If Not t Exit
	n:+1
Forever

Local sz=24

Local p:TPixmap

RestoreData Here
Local x=0

Repeat
	Local t$
	ReadData t
	If Not t Exit
	
	If t<>" "
		Local q:TPixmap=LoadPixmap( t+".png" )
		If Not p
			Local rgb=0'q.readpixel( 0,0 )
			p=TPixmap.Create( n*sz,sz,PF_RGBA8888 )
			For Local y=0 Until sz
				For Local x=0 Until n*sz
					p.WritePixel x,y,rgb
				Next
			Next
		EndIf
		If q.width>sz Or q.height>sz
			q=ResizePixmap( q,sz,sz )
		EndIf
		Local cx=(sz-q.width)/2
		Local cy=(sz-q.height)/2
		p.paste q,x+cx,cy
	EndIf
	x:+sz
Forever

SavePixmapPNG p,"../toolbar.png"

Local i:TImage=LoadImage(p)

Graphics 640,480,0
DrawPixmap p,0,0

DrawImage i,0,100
Flip
WaitKey

#Here
DefData "New","Open","Close","Save"," "
DefData "Cut","Copy","Paste","Find"," "
DefData "Build","Build-Run","Step","Step-In","Step-Out","Stop"," "
DefData "Home","Back","Forward"
DefData "Go",""

