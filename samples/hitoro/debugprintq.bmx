
' Debug Print Queue...

' Copy and paste the DebugQ type and the PrintQ/UpdateQ functions. Use
' PrintQ to add a debug message to your game, and UpdateQ in your main
' loop to display/update messages...

Type DebugQ

     Global DebugQList:TList

     Field message$
     Field alpha# = 1

     Function Print (message$)
              If DebugQList = Null Then DebugQList= New TList
              p:DebugQ = New DebugQ
              p.message = message$
              DebugQList.AddLast p
     End Function

     Function Update (alphacut# = 0.01)
              If DebugQList = Null Then Return
                 y = 0
        	 For p:DebugQ = EachIn DebugQList
        	     SetBlend ALPHABLEND
        	     SetAlpha p.alpha
        	     DrawText p.message$, 0, y
        	     y = y + TextHeight("")
        	     p.alpha = p.alpha - alphacut; If p.alpha < 0 Then DebugQList.Remove p
        	 Next
                 SetBlend SOLID ' Need to get old values!
        	 SetAlpha 1 ' Need to get old values!
     End Function

End Type

' Functional interfaces for non-OO'ers...

Function PrintQ (message$)
         DebugQ.Print message$
End Function

Function UpdateQ ()
         DebugQ.Update
End Function

' D E M O . . .

Graphics 640, 480

Repeat

      Cls

      x = MouseX ()
      y = MouseY ()

      DrawRect x, y, 32, 32

      ' Add items to debug print queue...

      If MouseHit (1) Then PrintQ "Left mouse button hit!"
      If MouseHit (2) Then PrintQ "Right mouse button hit!"

      ' Print/remove all debug items...

      UpdateQ

      DrawText "Click mouse...", 0, GraphicsHeight () - 20

      Flip

Until KeyHit (KEY_ESCAPE)

End


