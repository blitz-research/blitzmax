'===============================================================================
' Little Shooty Test Thing
' Code & Stuff by Richard Olpin (rik@olpin.net)
'===============================================================================
' Constants
'===============================================================================

Const WIDTH=800,HEIGHT=600
Const DEPTH=16,HERTZ=60

'===============================================================================
' Global Vars
'===============================================================================

Global spawntimer=0
Global sky, ay
Global bg_layer_1
Global bp1
Global bx1
Global sky_pos#=800
Global scroll_speed#=2.0
Const  horizon = 200
Global upd=0

'===============================================================================
' Controls
'===============================================================================

' Default key mappings for PS2 dualshock through USB adaptor
'
' For a full game obviously this stuff would be configurable from an options
' screen, or at the very least read from a text file.
'

Const Joy_L = 15
Const Joy_R = 13
Const Joy_U = 12 
Const Joy_D = 14

Const Joy_Fire1 = 2
Const Joy_Fire2 = 3
Const Joy_Fire3 = 1
Const Joy_Fire4 = 0

Const Joy_Start = 9
Const Joy_Select = 8
