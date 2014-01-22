' *******************************************************************
' Source: Mini Timer 
' Version: 1.00
' Author: Rob Hutchinson 2004
' Email: rob@proteanide.co.uk
' WWW: http://www.proteanide.co.uk/
' -------------------------------------------------------------------
' This include provides a class for a timer object. The class works
' in milliseconds. First of all the object can be enabled and 
' disabled at will by setting the Enabled field
' to true or false. The Interval field can be set
' to mark a milliseconds interval that, when reached, IntervalReached
' will become true. You can use the Reset() method to reset the timer
' and MiillisecondsElapsed() will tell you the number of milliseconds
' that have passed since you called Reset. Enabled field only has
' any effect on the IntervalReached function of the timer. If false
' then the method will always return false.
' Ported directly from my .NET Framework game library: Lita.
' -------------------------------------------------------------------
' Required:
'  - Nothing.
' *******************************************************************

Type MiniTimer

'#Region Declarations
        Field TimeStarted:Int
        Field Interval:Int
        Field Enabled:Int = True
'#End Region

'#Region Method: Reset
        '''-----------------------------------------------------------------------------
        ''' <summary>
        ''' Resets the timer.
        ''' </summary>
        '''-----------------------------------------------------------------------------
        Method Reset()
            Self.TimeStarted = MilliSecs()
        End Method
'#End Region
'#Region Method: MiillisecondsElapsed
        '''-----------------------------------------------------------------------------
        ''' <summary>
        ''' Gets the number of milliseconds that have passed since a call to Reset.
        ''' </summary>
        '''-----------------------------------------------------------------------------
        Method MiillisecondsElapsed:Int()
            If Self.TimeStarted = 0 Then Return 0
            Local TimeNow:Int = MilliSecs()
            Return TimeNow - Self.TimeStarted
        End Method
'#End Region
'#Region Method: IntervalReached
        '''-----------------------------------------------------------------------------
        ''' <summary>
        ''' Returns true if the given interval has been reached.
        ''' </summary>
        '''-----------------------------------------------------------------------------
        Method IntervalReached:Int()
            If Self.Enabled Then Return (Self.MiillisecondsElapsed() > Self.Interval)
        End Method
'#End Region

End Type







