Strict 

'Framework BRL.D3D7Max2D
Import BRL.Retro


Type bbdigit
	Field x1#,y1#,x2#,y2#
End Type

Global letterlen[128]
Global letters:bbdigit[128,8]
SetUpVectorFont()



'Test()
Function Test()

	Graphics 800,600,0

	Local sc# = 3.0
	Local dir = 1

	While Not KeyHit(key_escape) 

	Cls
	sc = sc + .1*dir
	If sc > 10 Or sc < 1 Then dir = -dir
	DrawString(" !"+Chr$(30)+"#$%&'()*+,-./",400-sc*40,200-sc*15,sc)
	DrawString("0123456789:;<=>?",400-sc*40,225-sc*10,sc)
	DrawString("@ABCDEFGHIJKLMNO",400-sc*40,250-sc*5,sc)
	DrawString("PQRSTUVWXYZ[\]^_",400-sc*40,275+sc*5,sc)
	DrawString("`abcdefghijklmno",400-sc*40,300+sc*10,sc)
	DrawString("pqrstuvwxyz{|}~~" ,400-sc*40,325+sc*15,sc)
	Flip
	
	Delay 16+sc*5
	Wend

End Function







Function SetUpVectorFont()

	RestoreData letterdata
	
	Local np,t,s
	
	For t = 0 To 127
		letterlen[t] = -1
	Next
	
	For t = 32 To 127
		ReadData np	'number of lines in letter (max 6)  x1,y1, x2,y2
		letterlen[t] = np-1
		For s = 0 To letterlen[t]
			letters[t,s] = New bbdigit
			ReadData letters[t,s].x1
			ReadData letters[t,s].y1
			ReadData letters[t,s].x2
			ReadData letters[t,s].y2
		Next
	Next
End Function


Function DrawDigit(d,xd,yd,sc#)
	Local t
'	If d > 32 And d < 128
'		If letterlen[d] > -1
			For t = 0 To letterlen[d]
				DrawLine letters[d,t].x1*sc+xd,letters[d,t].y1*sc+yd,letters[d,t].x2*sc+xd,letters[d,t].y2*sc+yd
			Next	
'		EndIf
'	EndIf
End Function


Function DrawString(st$,xd,yd,sc#)
	Local s,d,ln,t
	
	ln = Len(st$)
	For s = 0 To ln-1
		d = Asc(Mid$(st$,s+1,1))
'		If d > 32 And d < 128
'			If letterlen[d] > -1
				For t = 0 To letterlen[d]
					DrawLine letters[d,t].x1*sc+xd+sc*5*s,letters[d,t].y1*sc+yd,letters[d,t].x2*sc+xd+sc*5*s,letters[d,t].y2*sc+yd
				Next	
'			EndIf
'		EndIf
	Next
End Function




' **************************  vector text data  *******************************************
' chars 32-127
' spc!"#$%&'()*+`-,/0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"

#letterdata
' spc
DefData	0
' !
DefData	2,	2,0, 2,4,	2,5, 2,6
' ""
DefData	2,	1,1, 1,3,	3,1, 3,3
' #
DefData	4,	1,0, 1,6,	3,0, 3,6,	0,2, 4,2,	0,4, 4,4
' $
DefData	6,	0,1, 0,3,	0,3, 4,3,	4,3, 4,5,	4,5, 0,5,	0,1, 4,1,	2,0, 2,6
' %
DefData	3,	3,0, 1,6,	1,1, 1,2,	3,4, 3,5
' &
DefData	6,	0,1, 4,5,	0,1, 1,0,	1,0, 2,1,	2,1, 0,4,	0,4, 2,6,	2,6, 4,4
' '
DefData	1,	3,1, 2,2
' (
DefData	3,	3,0, 1,2,	1,2, 1,4,	1,4, 3,6
' )
DefData	3,	1,0, 3,2,	3,2, 3,4,	3,4, 1,6
' *
DefData	3,	1,1, 3,5,	1,5, 3,1,	0,3, 4,3
' +
DefData	2,	2,2, 2,4,	1,3, 3,3
' ,
DefData	1,	2,5, 2,6
' -
DefData	1,	1,3, 3,3
' .
DefData	1,	2,5, 2,5
' /
DefData	1,	4,0, 0,6
' 0
DefData	4,	0,0, 0,6,	0,6, 4,6,	4,6, 4,0,	4,0, 0,0
' 1
DefData	1,	2,0, 2,6
' 2
DefData	5,	0,0, 4,0,	4,0, 4,3,	4,3, 0,3,	0,3, 0,6,	0,6, 4,6
' 3
DefData	4,	0,0, 4,0,	4,0, 4,6,	4,6, 0,6,	2,3, 4,3
' 4
DefData	3,	0,0, 0,3,	0,3, 4,3,	4,0, 4,6
' 5
DefData	5,	0,0, 4,0,	0,0, 0,3,	0,3, 4,3,	4,3, 4,6,	0,6, 4,6
' 6
DefData	4,	0,0, 0,6,	0,3, 4,3,	4,3, 4,6,	0,6, 4,6
' 7
DefData	2,	0,0, 4,0,	4,0, 4,6
' 8
DefData	5,	0,0, 0,6,	0,6, 4,6,	4,6, 4,0,	4,0, 0,0,	0,3, 4,3
' 9
DefData	4,	0,0, 4,0,	4,0, 4,6,	0,0, 0,3,	0,3, 4,3
' :
DefData	2,	2,1, 2,1,	2,5, 2,5
' ;
DefData	2,	2,1, 2,1,	2,5, 2,6
' <
DefData	2,	4,0, 1,3,	1,3, 4,6
' =
DefData	2,	1,2, 3,2,	1,4, 3,4
' >
DefData	2,	0,0, 3,3,	3,3, 0,6
' ?
DefData	6,	1,1, 1,0,	1,0, 3,0,	3,0, 3,2,	3,2, 2,3,	2,3, 2,4,	2,5, 2,6
' @
DefData	6,	2,2, 2,4,	2,4, 4,4,	4,4, 4,0,	4,0, 0,0,	0,0, 0,6,	0,6, 4,6
' A (65)
DefData	5,	2,0, 0,2,	2,0, 4,2,	0,2, 0,6,	4,2, 4,6,	0,3, 4,3
' B
DefData	6,	0,0, 0,6,	0,6, 4,6,	4,6, 4,3,	4,3, 0,3,	0,0, 3,0,	3,0, 3,3
' C
DefData	3,	0,0, 0,6,	0,6, 4,6,	0,0, 4,0
' D
DefData	6,	0,0, 0,6,	0,6, 2,6,	2,6, 4,4,	4,4, 4,2,	4,2, 2,0,	2,0, 0,0
' E
DefData	4,	0,0, 0,6,	0,6, 4,6,	0,0, 4,0,	0,3, 2,3
' F
DefData	3,	0,0, 0,6,	0,0, 4,0,	0,3, 2,3
' G
DefData	5,	0,0, 0,6,	0,6, 4,6,	0,0, 4,0,	4,6, 4,3,	4,3, 2,3
' H
DefData	3,	0,0, 0,6,	0,3, 4,3,	4,0, 4,6
' I
DefData	3,	0,0, 4,0,	0,6, 4,6,	2,0, 2,6
' J
DefData	4,	3,0, 4,0,	4,0, 4,6,	4,6, 2,6,   2,6, 1,4
' K
DefData	4,	0,0, 0,6,	0,3, 2,3,	2,3, 4,0,	2,3, 4,6
' L
DefData	2,	0,0, 0,6,	0,6, 4,6
' M
DefData	4,	0,0, 0,6,	0,0, 2,3,	2,3, 4,0,	4,0, 4,6
' N
DefData	3,	0,0, 0,6,	0,0, 4,6,	4,6, 4,0
' O
DefData	4,	0,0, 0,6,	0,6, 4,6,	4,6, 4,0,	4,0, 0,0
' P
DefData	4,	0,0, 0,6,	0,0, 4,0,	0,3, 4,3,	4,3, 4,0
' Q
DefData	6,	0,0, 0,6,	0,6, 2,6,	2,6, 4,4,	4,4, 4,0,	4,0, 0,0,   4,6, 2,4
' R
DefData	5,	0,0, 0,6,	0,0, 4,0,	0,3, 4,3,	4,0, 4,3,	2,3, 4,6
' S
DefData	5,	0,0, 0,3,	0,3, 4,3,	4,3, 4,6,	4,6, 0,6,	0,0, 4,0
' T
DefData	2,	0,0, 4,0,	2,0, 2,6
' U
DefData	3,	0,0, 0,6,	0,6, 4,6,	4,6, 4,0
' V
DefData	4,	0,0, 0,3,	0,3, 2,6,	2,6, 4,3,	4,3, 4,0
' W
DefData	4,	0,0, 1,6,	1,6, 2,4,	2,4, 3,6,	3,6, 4,0
' X
DefData	2,	0,0, 4,6,	0,6, 4,0
' Y
DefData	3,	0,0, 2,3,	2,3, 4,0,	2,3, 2,6
' Z
DefData	3,	0,0, 4,0,	4,0, 0,6,	0,6, 4,6
' [ 
DefData	3,	3,0, 1,0, 	1,0, 1,6,   1,6, 3,6
' \
DefData	1,	0,0, 4,6
' ]
DefData	3,	1,0, 3,0,	3,0, 3,6,	3,6, 1,6
' ^
DefData	2,	1,2, 2,0,	2,0, 3,2
' _
DefData	1,	0,7, 4,7
' `
DefData	1,	1,1, 2,2
' a  (97)
DefData	5,	0,2, 4,2,	4,2, 4,6,	4,6, 0,6,	0,6, 0,3,	0,3, 4,3
' b
DefData	4,	0,0, 0,6,	0,6, 4,6,	4,6, 4,2,	4,2, 0,2
' c
DefData	3,	0,2, 0,6,	0,6, 4,6,	0,2, 4,2
' d
DefData	4,	4,0, 4,6,	4,6, 0,6,	0,6, 0,2,	0,2, 4,2
' e
DefData	5,	4,6, 0,6,	0,6, 0,2,	0,2, 4,2,	4,2, 4,3,   4,3, 1,3
' f
DefData	3,	4,0, 2,0,	2,0, 2,6,	1,2, 3,2
' g
DefData	5,	0,7, 4,7,	4,7, 4,2,	4,2, 0,2,	0,2, 0,6,	0,6, 4,6
' h
DefData	3,	0,0, 0,6,	0,2, 4,2,	4,2, 4,6
' i
DefData	2,	2,2, 2,6,	2,1, 2,1
' j
DefData	4,	3,1, 3,1,	3,2, 3,7,	3,7, 0,7,   0,7, 0,5
' k
DefData	3,	0,0, 0,6,	0,4, 3,2,	0,4, 3,6
' l
DefData	1,	2,0, 2,6
' m
DefData	4,	0,6, 0,2,	0,2, 4,2,	2,2, 2,4,	4,2, 4,6
' n
DefData	4,	0,2, 0,6,	0,3, 1,2,	1,2, 4,2,   4,2, 4,6
' o
DefData	4,	0,2, 0,6,	0,6, 4,6,	4,6, 4,2,	4,2, 0,2
' p
DefData	4,	0,2, 0,7,	0,2, 4,2,	0,6, 4,6,	4,2, 4,6
' q
DefData	4,	0,2, 0,6,	0,6, 4,6,	4,2, 4,7,	0,2, 4,2
' r
DefData	3,	0,2, 0,6,	0,3, 1,2,	1,2, 4,2
' s
DefData	5,	4,2, 0,2,	0,2, 0,4,	0,4, 4,4,	4,4, 4,6,	4,6, 0,6
' t
DefData	2,	0,2, 4,2,	2,0, 2,6
' u
DefData	3,	0,2, 0,6,	0,6, 4,6,	4,6, 4,2
' v
DefData	2,	0,2, 2,6,	2,6, 4,2
' w
DefData	4,	0,2, 1,6,	1,6, 2,4,	2,4, 3,6,	3,6, 4,2
' x
DefData	2,	0,2, 4,6,	0,6, 4,2
' y
DefData	2,	0,2, 2,5,	4,2, 1,7
' z
DefData	3,	0,2, 4,2,	4,2, 0,6,	0,6, 4,6
' {
DefData	4,	3,0, 2,0, 	2,0, 2,6,   2,6, 3,6,   1,3, 2,3
' |
DefData	1,	2,0, 2,6
' }
DefData	4,	1,0, 2,0,	2,0, 2,6,	2,6, 1,6,   2,3, 3,3
' ~  (126) 
DefData	5,	0,3, 0,1,	0,1, 2,1,	2,1, 2,3,   2,3, 4,3,   4,3, 4,1

' <-
DefData	3,	3,1, 0,3,	0,3, 3,5,	0,3, 4,3
' checkmark
DefData	2,	0,4, 2,6,	2,6, 4,0
' ->
DefData	3,	1,1, 4,3,	4,3, 1,5,	0,3, 4,3

