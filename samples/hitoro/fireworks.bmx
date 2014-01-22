
' Global variables tracking number of Firework objects and
' number of Particle objects. These are increased and decreased
' as objects are created/destroyed.

Global Fireworks, Particles

' Force pulling particles down...

Global Gravity# = 0.025

' Global list of Particle objects...

Global ParticleList:TList = New TList

' Particle object definition ('class')...

Type Particle

' Particle properties...

	Field x#              ' x position
	Field y#              ' y position
	Field xs#             ' x speed
	Field ys#             ' y speed
	Field size            ' particle size (size x size)

	Field r#               ' particle colour (red component)
	Field g#               ' particle colour (green component)
	Field b#               ' particle colour (blue component)

	Field ditch

	' Particle actions...

	' The function below is a 'constructor'. Methods work on
	' existing objects, so we can't use a method to create an
	' object. Instead, we use a function belonging to this object
	' type, and call it like so to return a Particle object:
	
	'       p:Particle = Particle.Create (blah blah)...

	Function Create:Particle (x#, y#, xs#, ys#, size, r#, g#, b#)
		Local p:Particle = New Particle
		p.x = x
		p.y = y
		p.xs = xs
		p.ys = ys
		p.size = size
		p.r = r
		p.g = g
		p.b = b
		ParticleList.Addlast p
		Particles = Particles + 1
		Return p
	End Function

	' This function updates all particles by iterating through the
	' global Particle list (ParticleList) and calling the Update
	' method on each one...

	Function UpdateAll ()
                 For p:Particle = EachIn ParticleList
                     p.Update
                 Next
	End Function

	' Updates current particle...

	Method Update ()
		ApplyForces
		Draw
	End Method

	' Apply x and y speeds, apply gravity and apply position limits...

	Method ApplyForces ()
		x = x + xs
		ys = ys + Gravity * size
		y = y + ys
		LimitParticle
	End Method

	' Draws the particle. This has been kept separate so it can be
	' 'over-ridden' in the Firework type below...

	Method Draw ()
		SetColor r, g, b
		DrawRect x, y, size, size
	End Method

	' Apply limits (if the particle goes off the left or right of
	' the screen, we reverse its direction, and if it goes off the
	' bottom (as it must, since gravity is pulling it down), we
	' remove the particle from the global list. We're also fading
	' the particle to black by reducing r, g and b; once they all
	' reach zero, we remove it from the list.

	Method LimitParticle ()
		If x < 0 Or x + size > GraphicsWidth ()
			xs = -xs
			x = x + xs
		EndIf
		If y + size > GraphicsHeight ()
			ParticleList.Remove Self
			Particles = Particles - 1
		Else
			r = r - 2; If r < 0 Then r = 0
   	        g = g - 2; If g < 0 Then g = 0
            b = b - 2; If b < 0 Then b = 0
            If r + b + g = 0 ParticleList.Remove Self; Particles = Particles - 1
		EndIf
	End Method

End Type

' This object definition takes the 'Particle' definition and 'extends' it,
' meaning that it has all of the same fields and methods/functions as the
' Particle type, but you can add new fields and 'over-ride' methods by
' simply redefining them...

Type Firework Extends Particle

	' Here, I've over-ridden the Create function to return a
	' Firework type. Note that the parameters must be the same
	' as for Particle.Create and that it is added to the global
	' list of Particle objects; this is possible because Firework
	' objects are still Particle objects, just more souped-up!

	Function Create:Firework (x#, y#, xs#, ys#, size, r#, g#, b#)
		Local p:Firework = New Firework
		p.x = x
		p.y = y
		p.xs = xs
		p.ys = ys
		p.size = size
		p.r = r
		p.g = g
		p.b = b
		ParticleList.Addlast p
		Fireworks = Fireworks + 1
		Return p
	End Function

	' Here I've over-ridden the Update method so that when a
	' Firework starts to fall (ys > 0.5) it's deleted and spawns
	' a random number of normal Particle objects. Note the use of
	' the ApplyForces and Draw methods that are 'inherited' from
	' the Particle definition (as are the fields such as x, y,
	' xs, ys, etc)...

	Method Update ()

		If ys > 0.5
			ParticleList.Remove Self
			Fireworks = Fireworks - 1
			For p = 1 To Rand (100,1000)'50, 150)
				Particle.Create (x, y, Rnd (-4, 4), Rnd (0, -4), Rnd (1, 2), Rand (120, 255), Rand (120, 255), Rand (120, 255))
			Next
		Else
			ApplyForces
			Draw
		EndIf

	End Method

	' This version of LimitParticle over-rides that defined in the
	' plain Particle type. It's interesting to note that although
	' the Update method above calls the original ApplyForces method
	' defined in the Particle type, that actually calls this over-ridden
	' version of LimitParticle.

	Method LimitParticle ()
		If x < 0 Or x + size > GraphicsWidth ()
			xs = -xs
			x = x + xs
		EndIf
	End Method

End Type

' D E M O . . .

Graphics 640, 480

SetClsColor 1, 1, 10

astep# = 2 ' Used for the positioning of the spawn point, x, below...

Repeat

	Cls

	' This is plotting a circle but only using the x position...

	ang# = ang + astep; If ang > (360 - astep) Then ang = 0
	x# = (GraphicsWidth () / 2) + (GraphicsWidth () / 2) * Sin (ang)

	' No timers in Blitz Max yet!

	If Rand (0, 1000) > 800
		Firework.Create (x, GraphicsHeight (), Rnd (-1, 1), Rnd (-4, -12), 4, 255, 255, 255)
	EndIf

	' Update all particle (both Particle and Firework objects from
	' the global list)...

	Particle.UpdateAll ()

	SetColor 255, 255, 255
	DrawText "Fireworks: " + Fireworks, 20, 20
	DrawText "Particles: " + Particles, 20, 40

	Flip

Until KeyHit(KEY_ESCAPE)

End

