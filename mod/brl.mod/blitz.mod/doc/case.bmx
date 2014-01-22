' case.bmx

' Case performs a comparison with the preceeding value(s) and that
' listed in the enclosing Select statement:

a=Int( Input("Enter a number between 1 and 5 ") )

Select a
	Case 1 Print "You think small"
	Case 2 Print "You are even tempered"
	Case 3,4 Print "You are middle of the road"	
	Case 5 Print "You think big"
	Default Print "You are unable to follow instructions"
End Select		
