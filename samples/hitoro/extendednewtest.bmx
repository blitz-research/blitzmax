
' This just shows that when you create an object of type 'Tester',
' it inherits the New method of 'Test'...

' Base type...

Type Test

     Global Oink

     Field x
     Field y

     Method New ()
            x = 100
            y = 200
            Oink = Oink + 1
     End Method

End Type

' Another type extending the base type above...

Type Tester Extends Test

     Field z = 99

End Type

' Create a 'Tester' object...

t:Tester = New Tester

' As well as the 'z' field of 't', x and y have values, demonstrating
' that they must have been set by the Test.New () method...

Print t.x
Print t.y
Print t.z


