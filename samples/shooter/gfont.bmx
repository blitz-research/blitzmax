'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'==============================================================================
' Graphic Font
'==============================================================================
Type GFont

	Global FontImg, f
	Global TypeStr$

	' ---------------------------------------------------------------------------
	' Init() - Load Font Image
	' ---------------------------------------------------------------------------

	Function Init()
		FontImg = LoadAnimImage("gfx/abduction.png",32,32,0,49, MASKEDIMAGE)	
	End Function

	' ---------------------------------------------------------------------------
	' DrawString(MsgX,MsgY,Message$)
	' ---------------------------------------------------------------------------

	 Function DrawString(MsgX,MsgY,Message$,centrex, centrey)
		Local MsgCount = Len(Message$)
		
		SetBlend MASKBLEND
		SetScale 1,1
		SetAlpha 1
		SetRotation 0

		length =Len(message$)*30	
		x=msgx

		If centrex=1 Then x=msgx-(length/2)
		If centrex=-1 Then x=msgx-length	
					
		If centrey=1
			y=msgy-16
		Else
		y=msgy
		EndIf
		
		For f=0 To MsgCount-1
			FontChar = Asc(Lower$(Mid$(Message$,f+1,1)))
			imgchar= sortchar(fontchar)
			
			DrawImage FontImg,x+(f*30),MsgY,ImgChar
		Next
		
	End Function

	' ---------------------------------------------------------------------------
	' Sortchar
	' ---------------------------------------------------------------------------

	Function sortchar(char)
		' Letters
		If char>=97 And char<=122 Then c=char-97
	
	' Numbers
		If char>=48 And char<=57 Then c=char-22

		' Special characters
		Select Char
			Case 63 c = 36 
			Case 46 c= 37
			Case 44 c= 38 
			Case 39 c= 39
			Case 34 c= 40 
			Case 33 c= 41
			Case 40 c= 42 
			Case 41 c= 43
			Case 45 c= 44 
			Case 58 c= 45
			Case 59 c= 46 
			Case 32 c= 48
		End Select

		Return c
	End Function
	
End Type