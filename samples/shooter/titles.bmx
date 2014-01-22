'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'==============================================================================
' Titles
'==============================================================================

Function ShowTitlePage()
	Local title, i#, a#, s#
	Local state, quit, time
	
	title=LoadImage ("gfx/titlepage.png",MASKEDIMAGE|FILTEREDIMAGE)
	a#=0.01
	s=1.0
	state=0
	time=100

	SetBlend ALPHABLEND

	Repeat
		Cls
	
		Select state
		
			Case 0 ' Fade in
				a#:+0.01
				time:-1
				If time<0 Then state=1	
		
			Case 1 ' Static, wait for quit				
				
			Case 2 ' Fade Out
				a#:-0.02
				s:+0.2
				time:-1
				If time<0 Then state=-1
		
		End Select
		
		If JoyDown(Joy_Fire1) Or KeyHit(KEY_SPACE) Then 
			State=2
			time=100
		EndIf

		SetAlpha a#
		SetScale s,s

		DrawImage title,400,300
		Flip		
	Until state=-1

End Function