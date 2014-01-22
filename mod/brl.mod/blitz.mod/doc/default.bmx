Rem
Default is used in a Select block to mark a code section that is executed if all prior Case statements fail.
End Rem

a$=Input("What is your favorite color?")
a$=lower(a$)	'make sure the answer is lower case

Select a$
	case "yellow" Print "You a bright and breezy"
	case "blue" Print "You are a typical boy"
	case "pink" Print "You are a typical girl"
	default Print "You are quite unique!"
End Select
