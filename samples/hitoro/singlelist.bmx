
' Adding objects to an object-specific list...

Type Particle

     Global ParticleList:TList ' The list for all objects of this type...
     Global Gravity# = 0.1

     Field x#
     Field y#
     Field xs#
     Field ys#

     ' The New method is called whenever one of these objects is created. If
     ' the list hasn't yet been created, it's created here. The object is then
     ' added to the list...

     Method New ()
            If ParticleList = Null
               ParticleList = New TList
            EndIf
            ParticleList.AddLast Self
     End Method

     Function Create:Particle (x, y)
              p:Particle = New Particle
              p.x = x
              p.y = y
              p.xs = Rnd (-4, 4)
              p.ys = 0
              Return p
     End Function

     Function UpdateAll ()

            ' Better check the list exists before trying to use it...

            If ParticleList = Null Return

            ' Iterate through list...

            For p:Particle = EachIn ParticleList
                    p.ys = p.ys + Gravity
                    p.x = p.x + p.xs
                    p.y = p.y + p.ys
                    DrawRect p.x, p.y, 8, 8
                    If p.y > GraphicsHeight () p = Null
            Next

     End Function

End Type

' D E M O . . .

Graphics 640, 480

Repeat

      Cls

      ' Create a Particle every now and then...

      If Rand (100) > 50
            p:Particle = Particle.Create (MouseX (), MouseY ())
      EndIf

      ' Update all Particle objects...

      Particle.UpdateAll ()

      Flip

Until KeyHit (KEY_ESCAPE)

End


