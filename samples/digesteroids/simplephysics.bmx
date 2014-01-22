' Simple Physics Engine - V1.0
' --------------------------------------------------------
' Written By: Rob Hutchinson 2004

Strict

Type TRectangle

'#Region Declarations
	Field X:Int,Y:Int,Width:Int,Height:Int
'#End Region

'#Region Method: Bottom
	Method Bottom:Int()
		Return Y + Height
	End Method
'#End Region
'#Region Method: Right
	Method Right:Int()
		Return X + Width
	End Method
'#End Region
'#Region Method: Create
	Function Create:TRectangle(X:Int,Y:Int,Width:Int,Height:Int)
		Local Out:TRectangle = New TRectangle
		Out.X = X
		Out.Y = Y
		Out.Width = Width
		Out.Height = Height
		Return Out
	End Function
'#End Region

'#Region Method: IntersectsWith
	Method IntersectsWith:Int(Rectangle:TRectangle)
		If (((Rectangle.X < (Self.X + Self.Width)) And (Self.X < (Rectangle.X + Rectangle.Width))) And (Rectangle.Y < (Self.Y + Self.Height))) Then
 			Return (Self.Y < (Rectangle.Y + Rectangle.Height)) 
		End If
		Return False
	End Method
'#End Region

End Type

Type TPhysicsUtility

'#Region Method: DistanceBetweenPoints
    Function DistanceBetweenPoints:Double(X1:Int, Y1:Int, X2:Int, Y2:Int)
        Local DeltaX:Int = X2 - X1
        Local DeltaY:Int = Y2 - Y1
        Local Calculation:Int = ((DeltaX * DeltaX) + (DeltaY * DeltaY))
        Return Sqr(Double(Calculation))
    End Function
'#End Region

    Function DegreesBetweenPoints(X1:Double, Y1:Double, X2:Double, Y2:Double)
		Local Out:Double = ATan2(X2 - X1,-(Y2 - Y1))
        Return 180.0 - Out
    End Function

End Type

Type TPointD
	
'#Region Declarations
	Field X:Double = 0
	Field Y:Double = 0
'#End Region

End Type

Type TMagnetCollection Extends TList

'#Region Method: Draw
	Method Draw()
		Local Item:TMagnet
		For Item=EachIn Self
			Item.Draw()
		Next
	End Method	
'#End Region

End Type

Type TPhysicsProviderCollection Extends TList

'#Region Method: Draw
	Method Draw()
		Local Item:TPhysicsProvider
		For Item=EachIn Self
			Item.Draw()
		Next
End Method
'#End Region
'#Region Method: ApplyPhysics
	Method ApplyPhysics:Int()
		Local Item:TPhysicsProvider
		Local Count:Int
		For Item=EachIn Self
			Item.ApplyPhysics()
			Count:+1
		Next
		Return Count
	End Method
'#End Region
'#Region Method: ApplyPhysicsAndFriction
	Method ApplyPhysicsAndFriction:Int(Axis:Int)
		Local Item:TPhysicsProvider
		Local Count:Int
		For Item=EachIn Self
            Item.ApplyFriction(Axis)
			Item.ApplyPhysics()
			Item.Draw()
			Count:+1
		Next
		Return Count
	End Method
'#End Region
'#Region Method: ApplyPhysicsAndDraw
	Method ApplyPhysicsAndDraw()
		Local Item:TPhysicsProvider
		For Item=EachIn Self
			Item.ApplyPhysics()
			Item.Draw()
		Next
End Method
'#End Region

End Type

Type TMagnet
'#Region Declarations
	Field X:Int, Y:Int
	Field Radius:Double

	Const NegativePolarity = -1
	Const PositivePolarity = 1

	Field Strength:Double
	Field Polarity:Int = 1
'#End Region



'#Region Method: GetStrengthOfPull
	Method GetStrengthOfPull:Double(Orbit:Double)
        If Orbit > Self.Radius Then Return 0

        ' First work out the percentage...
        Local PercentOfPull:Double = (Orbit / Self.Radius) * 100
        Return Self.Strength - ((PercentOfPull / 100) * Self.Strength)
	End Method
'#End Region
'#Region Method: GetForces
	Method GetForces:TPointD(X:Int, Y:Int)
        Local Out:TPointD=New TPointD
		Out.X = 0
		Out.Y = 0

		' Get Distance Between Points...
		Local Distance:Double = TPhysicsUtility.DistanceBetweenPoints(X, Y, Self.X, Self.Y)
		Local Strength:Double = Self.GetStrengthOfPull(Distance)
        If Strength = 0 Then Return Out

		' Get the degrees between points..
		Local Angle:Double = TPhysicsUtility.DegreesBetweenPoints(X, Y,Self.X, Self.Y)

		' Reverse strength if using negative polarity.        
        If Self.Polarity = NegativePolarity Then Strength = -Strength

		Out.X = Sin(Angle) * Strength
        Out.Y = Cos(Angle) * Strength

        Return Out
	End Method
'#End Region
'#Region Method: Draw
    Method Draw()
		Local Degrees
		SetColor 255,255,255
		For Degrees = 0 To 360
			DrawRect Self.X + (Sin(Degrees) * Self.Radius), Self.Y + (Cos(Degrees) * Self.Radius),1,1
		Next
    End Method
'#End Region
'#Region Method: Create
	Function Create:TMagnet(X:Int,Y:Int,Radius:Double,Polarity:Int,Strength:Double)
		Local Out:TMagnet = New TMagnet
		Out.X = X
		Out.Y = Y
		Out.Radius = Radius
		Out.Polarity = Polarity
		Out.Strength = Strength
		Return Out
	End Function
'#End Region
'#Region Method: SetPosition
	Method SetPosition(X:Int,Y:Int)
		Self.X = X
		Self.Y = Y
	End Method
'#End Region

End Type

Type TWorldPhysicsProvider 

	Field Loc = 0

'#Region Declarations
	Field Gravity:Double
	Field Wind:Double
	Field Drag:Double
	Field ApplyMagnets:Int = True
	Field Magnets:TMagnetCollection = New TMagnetCollection
'#End Region

'#Region Method: Initialize
	Method Initialize(Gravity:Double, Wind:Double = 0.0, Drag:Double = 0.0, ApplyMagnets:Int = False)
		Self.Gravity = Gravity
		Self.Wind = Wind
		Self.Drag = Drag
		Self.ApplyMagnets = ApplyMagnets
	End Method
'#End Region
'#Region Method: Create
	Function Create:TWorldPhysicsProvider(Gravity:Double, Wind:Double = 0.0, Drag:Double = 0.0, ApplyMagnets:Int = False)
		Local Out:TWorldPhysicsProvider = New TWorldPhysicsProvider
		Out.Gravity = Gravity
		Out.Wind = Wind
		Out.Drag = Drag
		Out.ApplyMagnets = ApplyMagnets
		Return Out
	End Function
'#End Region

End Type

Type TPhysicsProvider Extends TLink
'#Region Declarations
	' Location.
	Field X:Double, Y:Double
	Field World:TWorldPhysicsProvider = New TWorldPhysicsProvider

	' Terminal Velocity
	Field TerminalVelocityX:Double = 40.0, TerminalVelocityY:Double = 40.0

	' Velocity
	Field VelocityX:Double, VelocityY:Double

	' Weight
	Field Weight:Double = 10.0
	Field SurfaceArea:Double = 10.0

	' Bounce Values.
    Field BounceCoefficientX:Double = 1.0
    Field BounceCoefficientY:Double = 0.75

	' The friction being applied to this object.
    Field Friction:Double = 1.0

	' Whether or not to apply magnets to the individual object.
	Field ApplyMagnets:Int = True

	Const AxisX:Int = 1
	Const AxisY:Int = 2

	Const VerticalPlane = 1
	Const HorizontalPlane = 2
'#End Region

'	Method remove()
'		World.remove Self
'	End Method

'#Region Method: Double
	Method Speed:Double()
		Return Sqr((Self.VelocityX * Self.VelocityX) + (Self.VelocityY * Self.VelocityY))
	End Method
'#End Region
'#Region Method: Momentum
	Method Momentum:Double()
		Return Self.Speed() * Self.Weight
	End Method
'#End Region
'#Region Method: ReverseVelocityX
	Method ReverseVelocityX()
		Self.VelocityX = -Self.VelocityX
	End Method
'#End Region
'#Region Method: ReverseVelocityY
	Method ReverseVelocityY()
		Self.VelocityY = -Self.VelocityY
	End Method
'#End Region
'#Region Method: SnapWithinRectangle
	Method SnapWithinRectangle(Area:TRectangle)
        If Self.X < Area.X Then Self.X = Area.X
        If Self.Y < Area.Y Then Self.Y = Area.Y
		Local Right:Int  = Area.X + Area.Width
		Local Bottom:Int = Area.Y + Area.Height
        If Self.X > Right Then Self.X = Right
        If Self.Y > Bottom Then Self.Y = Bottom
	End Method
'#End Region
'#Region Method: SnapWithinRectangleAndReverseVelocity
	Method SnapWithinRectangleAndReverseVelocity:Int(Area:TRectangle)
		Local Out:Int = False
        If Self.X < Area.X Then
            Self.X = Area.X
            Self.ReverseVelocityX()
            Out = True
        End If
        If Self.Y < Area.Y Then
            Self.Y = Area.Y
            Self.ReverseVelocityY()
            Out = True
        End If
		Local Right:Int  = Area.X + Area.Width
		Local Bottom:Int = Area.Y + Area.Height
        If Self.X > Right Then
            Self.X = Right
            Self.VelocityX = -Self.VelocityX
            Out = True
        End If
        If Self.Y > Bottom Then
            Self.Y = Bottom
            Self.VelocityY = -Self.VelocityY
            Out = True
        End If
        Return Out
	End Method
'#End Region
'#Region Method: ApplyFriction
	Method ApplyFriction(Axis:Int)
        If ((Axis & AxisX) = AxisX) Then Self.VelocityX:*Self.Friction
        If ((Axis & AxisY) = AxisY) Then Self.VelocityY:*Self.Friction
	End Method
'#End Region
'#Region Method: ApplyFrictionX
	Method ApplyFrictionX()
		Self.VelocityX:*Self.Friction
	End Method
'#End Region
'#Region Method: ApplyFrictionY
	Method ApplyFrictionY()
		Self.VelocityY:*Self.Friction
	End Method
'#End Region
'#Region Method: Bounce
	Method Bounce(Planes:Int)
        If ((Planes & HorizontalPlane) = HorizontalPlane)
            Self.VelocityY = -Self.VelocityY
            Self.VelocityY:*Self.BounceCoefficientY
        End If

        If ((Planes & VerticalPlane) = VerticalPlane)
            Self.VelocityX = -Self.VelocityX
            Self.VelocityX:*Self.BounceCoefficientX
        End If
	End Method
'#End Region
'#Region Method: Draw
	Method Draw() Abstract
'#End Region
'#Region Method: PhysicsApplied
	Method PhysicsApplied() Abstract
'#End Region
'#Region Method: ApplyPhysics
	Method ApplyPhysics()
        ' Gravity
        Self.VelocityY:+Self.World.Gravity - (Self.World.Drag * Self.SurfaceArea)

        ' Wind
        Self.VelocityX:+(Self.World.Wind / Self.Weight) * Self.SurfaceArea

        ' Apply the magnets?
        If (Self.World.ApplyMagnets = True) And (Self.ApplyMagnets = True) Then
			Local Magnet:TMagnet
			For Magnet=EachIn Self.World.Magnets
				Local Pull:TPointD = Magnet.GetForces(Self.X,Self.Y)

				Self.VelocityX = Self.VelocityX + Pull.X
				Self.VelocityY = Self.VelocityY + Pull.Y
			Next
        End If

        ' Terminal Velocity
        If Self.VelocityX > Self.TerminalVelocityX Then Self.VelocityX = Self.TerminalVelocityX
        If Self.VelocityY > Self.TerminalVelocityY Then Self.VelocityY = Self.TerminalVelocityY
        If Self.VelocityX < -Self.TerminalVelocityX Then Self.VelocityX = -Self.TerminalVelocityX
        If Self.VelocityY < -Self.TerminalVelocityY Then Self.VelocityY = -Self.TerminalVelocityY

        ' Update
        Self.Y:+Self.VelocityY
        Self.X:+Self.VelocityX

        ' Raise the event...
        Self.PhysicsApplied()

	End Method
'#End Region
'#Region Method: SetVelocityFromAngle
    Method SetVelocityFromAngle(Angle!, Speed!)
        Self.VelocityX = Sin(Angle) * Speed
        Self.VelocityY = Cos(Angle) * Speed
    End Method
'#End Region
'#Region Method: IncreaseVelocityFromAngle
    Method IncreaseVelocityFromAngle(Angle!, Speed!)
        Self.VelocityX :+ Sin(Angle) * Speed
        Self.VelocityY :+ Cos(Angle) * Speed
    End Method
'#End Region
'#Region Method: Angle
    Method Angle!()
		Return TPhysicsUtility.DegreesBetweenPoints(Self.X, Self.Y, Self.X + Self.VelocityX, Self.Y + Self.VelocityY)
    End Method
'#End Region

End Type

' Particle Engine.
Type TParticleEmitter Extends TLink

'#Region Declarations
    Field World:TWorldPhysicsProvider
    Field X:Int, Y:Int
	Field Particles:TPhysicsProviderCollection = New TPhysicsProviderCollection
'#End Region

'#Region Method: Update
	Method Update()
        Self.Particles.ApplyPhysics()
	End Method
'#End Region
'#Region Method: UpdateWithFriction
    Method UpdateWithFriction(Axis:Int)
        Self.Particles.ApplyPhysicsAndFriction(Axis)
    End Method
'#End Region
'#Region Method: Draw
    Method Draw()
        Self.Particles.Draw()
    End Method
'#End Region
'#Region Method: UpdateAndDraw
    Method UpdateAndDraw()
        Self.Particles.ApplyPhysics()
        Self.Particles.Draw()
    End Method
'#End Region
'#Region Method: AddParticle
	Method AddParticle(Particle:IParticle)
		Self.Particles.AddLast(Particle)
	End Method
'#End Region
'#Region Method: RemoveParticle
	Method RemoveParticle(Particle:IParticle)
		Self.Particles.Remove(Particle)
	End Method
'#End Region

End Type
Type IParticle Extends TPhysicsProvider

	Field Angle:Float
	Field Speed:Float
	Field Region:TRectangle

    Method Initialize() Abstract

End Type
Type TStaticParticle Extends IParticle

'#Region Declarations
    Field LastX:Int
    Field LastY:Int
	Field Emitter:TParticleEmitter

    Field LifeTime:Int = -1
    Field LifeAmount:Int
    Field FadeSpeed:Float = -1.0
    Field Color[] = [255,255,255]
    Field FadeAmount:Float
	Field Size:Float = 1.0
	Field ActualRotation:Float = 0.0
	Field Rotation:Float = 0.0

    Field Graphic:TImage
'#End Region
'#Region Constructor
	Function Create:TStaticParticle(World:TWorldPhysicsProvider, Graphic:TImage, Region:TRectangle)
		Local Out:TStaticParticle = New TStaticParticle
        Out.Graphic = Graphic
        Out.Region = Region
		Return Out
    End Function
'#End Region

'#Region Method: Draw
    Method Draw()
		SetColor(Self.Color[0],Self.Color[1],Self.Color[2])
		SetScale(Self.Size, Self.Size)
		SetAlpha(1.0 - Self.FadeAmount)
		Self.ActualRotation :+ Self.Rotation
		SetRotation(Self.ActualRotation)
		DrawImage(Self.Graphic, Int(Self.X), Int(Self.Y))
    End Method
'#End Region

'#Region Method: Initialize
    Method Initialize()
        Self.SetVelocityFromAngle(Self.Angle, Self.Speed)
    End Method
'#End Region

'#Region Override: PhysicsApplied
    Method PhysicsApplied()
        Local ImageRect:TRectangle = New TRectangle
		ImageRect.Width = Self.Graphic.Width
		ImageRect.Height = Self.Graphic.Height
        ImageRect.X = Int(Self.X - Self.Graphic.handle_x)
        ImageRect.Y = Int(Self.Y - Self.Graphic.handle_y)

		Local RemoveThis:Int = False
        If Not Self.Region.IntersectsWith(ImageRect) Then 
			RemoveThis = True
		Else
	        If Self.LifeTime > -1 Then
	            If Self.LifeAmount >= Self.LifeTime Then
	                ' Start fade out?
	                If Self.FadeSpeed > -1 Then
	                    Self.FadeAmount :+ FadeSpeed
	                    If Self.FadeAmount >= 1.0 Then
							RemoveThis = True
	                    EndIf
	                Else
						RemoveThis = True
	                EndIf
	            Else
	                Self.LifeAmount :+ 1 ' its lived a bit longer now.
		        EndIf
			Else
				RemoveThis = True
	        EndIf
		EndIf	

		If RemoveThis Then
            Self.Emitter.RemoveParticle(Self)
			Self.Emitter = Null
		EndIf
  	End Method
'#End Region
	
End Type
Type TFountain Extends TParticleEmitter

'#Region Declarations
	Field Region:TRectangle
'#End Region
'#Region Constructor
    Function Create:TFountain(World:TWorldPhysicsProvider, Region:TRectangle)
        Local Out:TFountain = New TFountain
		Out.World = World
        Out.Region = Region
		Return Out
    End Function
'#End Region

'#Region Method: AddStaticParticle
    Method AddStaticParticle:TStaticParticle(Image:TImage, Angle:Float, Velocity:Float, LifeTime:Int, FadeSpeed:Float, Color[])
        Local Particle:TStaticParticle = TStaticParticle.Create(Self.World, Image, Self.Region)
        Particle.X = Self.X
        Particle.Y = Self.Y
        Particle.Angle = Angle
        Particle.Speed = Velocity
		Particle.Emitter = Self
		Particle.FadeSpeed = FadeSpeed
		Particle.LifeTime = LifeTime
		Particle.Color = Color
        Particle.Initialize()
        Self.AddParticle(Particle)
        Return Particle
    End Method
'#End Region

End Type





