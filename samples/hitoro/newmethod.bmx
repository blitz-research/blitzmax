
' Here's an example of using the optional New () method. You could just
' set the x field to have a default anyway (Field x = 100) but this shows
' that you can do other things too (in this case, print a message)...

Type Oink

     Field x

     Method New ()
            Print "Setting the value of x..."
            x = 100
     End Method

End Type

' Create an Oink object...

o:Oink = New Oink

' Print out the value of x...

Print o.x

