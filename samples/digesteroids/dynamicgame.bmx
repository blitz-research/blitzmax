' *******************************************************************
' Source: Dynamic Game 
' Version: 1.00
' Author: Rob Hutchinson 2004
' Email: rob@proteanide.co.uk
' WWW: http://www.proteanide.co.uk/
' -------------------------------------------------------------------
' This include provides an OO approach to game creation. You must
' first instantiate the T2DDynamicGame class with the Create()
' method. This controls the game itself, including the main loop.
' You do not need to inherit T2DDynamicGame. Instead, create types
' and inherit from T2DDynamicGameScene, this class is used to process
' a single game scene, such as the main menu or the game itself. You
' might have types that inherit T2DDynamicGame for the Main Menu,
' Levels of your game, Bonus levels, credits, menu screens, etc. 
' The functionality is built into each type in the Update and Render
' methods. Always perform logic operations in the Update method and
' draw your graphics in the standard way inside Render(). This way
' your game will automatically benefit from dynamic game timing. To
' Swap the scene from say, the Main Menu to the game itself, simply 
' call the SetScene() Method on T2DDynamicGame with your new scene.
' -------------------------------------------------------------------
' Benefits/Features:
'  - The T2DDynamicGame class handles pretty much everything to do
'    with the game loop for you, it has a dynamic timing routine 
'    built into it which will catch up with missing frames.
'  - Allows you to easily run at a specific visual framerate 
'    (DesiredFPS) regardless of the refresh rate.
' -------------------------------------------------------------------
' Required:
'  - minitimer.bmx   - Timer framework.
' *******************************************************************

Import "minitimer.bmx"

Type T2DDynamicGame

	' PRIVATE
	Field Scene:T2DDynamicGameScene
	Field EndMainLoop:Int = False
	Field DesiredFPS:Int = 60
	Field TerminateMainLoop:Int = False
	Field DynamicTiming:Int = True       ' If true dynamic timing is uses, else frame limited timing is used.

	' PUBLIC
	Field Width:Int = 1024
	Field Height:Int = 768
	Field Depth:Int = 32
	Field RefreshRate:Int = 60

'#Region Constructor: Create
	Function Create:T2DDynamicGame(Width:Int,Height:Int,Depth:Int,RefreshRate:Int)
		Local Out:T2DDynamicGame = New T2DDynamicGame
		Out.Width = Width
		Out.Height = Height
		Out.Depth = Depth
		Out.RefreshRate = RefreshRate
		Return Out
	End Function
'#End Region

'#Region Method: Initialize
	Method Initialize()
		' Set up the graphics.
		Graphics(Self.Width, Self.Height, Self.Depth, Self.RefreshRate)
	End Method
'#End Region
'#Region Method: ShutDown
	Method ShutDown()
		' Close down the graphics.
		Self.FlushScene()
		EndGraphics()
	End Method
'#End Region
'#Region Method: SetScene
	Method SetScene(Scene:T2DDynamicGameScene)
		' Set a new scene into the game.
		Self.FlushScene()
		Self.Scene = Scene
		Self.Scene.Start()
	End Method
'#End Region
'#Region Method: MainLoop
	Method MainLoop()
		' Repeat the main loop until termination is required.
		' Taken from my .NET game framework codenamed: Lita, for more info drop me a line! :) </PLUG>
		If Self.DynamicTiming = True
			' Dynamic timing.
	       	Local WaitUntil:Int
			Local Timer:MiniTimer = New MiniTimer
	        Timer.Reset()

			Local Period:Int = 1000 / Self.DesiredFPS
	        Local Gap:Int
	        Local UpdatesUntil:Float
	
	        WaitUntil = MilliSecs() + Period
	        While (Not TerminateMainLoop) And (Not Self.IsTerminated())
	
	            ' Loop until time has passed.
	            Repeat
	            Until MilliSecs() > WaitUntil

	            ' Update for as many times frames were missed.
				' First we need to calculate some stats.
	            Gap = (MilliSecs() - Timer.TimeStarted)
	            UpdatesUntil = Float(Gap) / Float(Period)

				' Perform the updates.
	            If UpdatesUntil > 1.0 Then
	                For Local Count:Int = 1 To Int(UpdatesUntil)
	                    Self.Update()
	                Next
				End If
	
				' Reset our timer to start the next run.
	            Timer.Reset()
	            WaitUntil = MilliSecs() + Period
	            Self.Render()
				Flip()
'				GCCollect
	            'Application.DoEvents()
	        Wend
		Else
			' Frame limited tbiming.
	        While (Not TerminateMainLoop) And (Not Self.IsTerminated())
				Self.Update()
				Self.Render()
				Flip()
'				GCCollect
	        Wend
		EndIf
		Self.TerminateMainLoop = False

	End Method
'#End Region
'#Region Method: FlushScene
	Method FlushScene()
		' If there is a scene then we need to kill it off..
		Self.Finish()
		Self.Scene = Null
	End Method
'#End Region
'#Region Method: Start
	Method Start()
		' Call start on the scene.
		If Self.Scene <> Null Then Self.Scene.Start()
	End Method
'#End Region
'#Region Method: Finish
	Method Finish()
		' Call start on the scene.
		If Self.Scene <> Null Then 
			Self.Scene.Finish()
		EndIf
	End Method
'#End Region
'#Region Method: Update
	Method Update()
		' Call update on the scene.
		If Self.Scene <> Null Then Self.Scene.Update()
	End Method
'#End Region
'#Region Method: Render
	Method Render()
		' Call render on the scene.
		If Self.Scene <> Null Then Self.Scene.Render()
	End Method
'#End Region
'#Region Method: IsTerminated
	Method IsTerminated:Int()
		' Check to see if the scene wants to terminate the main loop.
		If Self.Scene <> Null Then
 			If Self.Scene.TerminateMainLoop Then
				Self.Scene.TerminateMainLoop = False
				Return True
			EndIf
			Return False
		EndIf
		Return True
	End Method
'#End Region

End Type

Type T2DDynamicGameScene

	Field TerminateMainLoop:Int = False	

	Method Update() Abstract
	Method Render() Abstract
	Method Start() Abstract
	Method Finish() Abstract

End Type








