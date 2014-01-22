
' -----------------------------------------------------------------------------
' An example of listing a type and (just) its sub-types...
' -----------------------------------------------------------------------------

' List to which all objects are added...

Global TestList:TList = New TList

' Base type...

Type Base
     Field x
     Field desc$
End Type

' Example 1...

Type Test1 Extends Base
     Field y
End Type

' Example 2...

Type Test2 Extends Base
     Field z
End Type

' -----------------------------------------------------------------------------
' Create objects of all three types...
' -----------------------------------------------------------------------------

For a = 1 To 10

    t:Base = New Base
    t.desc = "Base Object " + a
    TestList.AddLast t

    t1:Test1 = New Test1
    t1.desc = "Test1 Object " + a
    TestList.AddLast t1

    t2:Test2 = New Test2
    t2.desc = "Test2 Object " + a
    TestList.AddLast t2

Next

' -----------------------------------------------------------------------------
' List all objects of Base AND Base-extended types...
' -----------------------------------------------------------------------------

Print ""
Print "All Base and Base-extended objects..."
Print ""

For all:Base = EachIn TestList
    Print all.desc
Next

' -----------------------------------------------------------------------------
' List only Test1 objects from Base.TestList...
' -----------------------------------------------------------------------------

Print ""
Print "Only Test1 objects..."
Print ""

For onlyt1:Test1 = EachIn TestList
    Print onlyt1.desc
Next

' -----------------------------------------------------------------------------
' List only Test2 objects from Base.TestList...
' -----------------------------------------------------------------------------

Print ""
Print "Only Test2 objects..."
Print ""

For onlyt2:Test2 = EachIn TestList
    Print onlyt2.desc
Next


