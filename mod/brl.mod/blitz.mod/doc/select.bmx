Rem
Select begins a block featuring a sequence of multiple comparisons with a single value.
End Rem

a=Int( Input("Enter Your Country Code ") )

Select a
	Case 1
		Print "You are from America"
	Case 44
		Print "You are from the United Kingdom"
	Case 62
		Print "You are from Australia"
	Case 64
		Print "You are from New Zealand"
	Default
		Print "I cannot tell which country you are from"
End Select
