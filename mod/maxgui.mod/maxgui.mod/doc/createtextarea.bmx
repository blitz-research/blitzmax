' createtextarea.bmx

Import MaxGui.Drivers

Strict 

Global window:TGadget = CreateWindow( "My Window", 130, 20, 200, 200 )

Global textarea:TGadget = CreateTextArea( 0, 0, ClientWidth(window), ClientHeight(window), window )
	SetGadgetLayout( textarea, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
	SetGadgetText( textarea, "A TextArea gadget. :-)~n~nOne line...~n...and then another!")
	ActivateGadget( textarea )

' Select the entire third (index: 2 [base-0]) line.
SelectTextAreaText( textarea, 2, 1, TEXTAREA_LINES )

' Output the properties of the current text selection (should be 1, 1 as set above).
Print "TextAreaCursor(): " + TextAreaCursor( textarea, TEXTAREA_LINES )
Print "TextAreaSelLen(): " + TextAreaSelLen( textarea, TEXTAREA_LINES )

While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_APPTERMINATE
			End
	End Select
Wend
