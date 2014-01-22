'Tempest
'Started by David Bird (Birdie) - BlitzMax 1.10 Samples 

'Completed by Mark Incitti (Mark1nc) - June 2005

' Version 1.5 - July 18
' added 16 more tubes
' tweaked the difficulty and release rates

' Version 1.1 - July 7
' fixed egg hatching to act 7 (non-existant case - disappeared)
' changed fuseballs - only kill when off the edge  w>1 or w<7
' added Tempest Tubes boards

' CTRL - Fire!
' SPACE - Superzapper
' L/R - Move
' ESC - Quit
' T - select tube set

Strict

Import "transformfunctions.bmx"
Import "vectorfont.bmx"
Import "sfx.bmx"

'Setup Graphics mode
Graphics CWidth,CHeight,32    ',0 windowed  ',32 'fullscreen
HideMouse
SeedRnd(MilliSecs())


'defined colours index
Const COL_BULLETS = 0
Const COL_CLAW = 1
Const COL_TANKERS = 2
Const COL_FLIPPERS = 3
Const COL_PULSARS = 4
Const COL_SPIKERS = 5
Const COL_LEVEL = 6
Const COL_INFO = 7

'death types
Const KILLED_BY_BULLET = 0
Const KILLED_BY_PULSAR = 2
Const KILLED_BY_SPIKE = 3
Const KILLED_BY_FLIPPER = 4
Const KILLED_BY_FUSEBALL = 5

'level states
Const LEVEL_BEGIN    = 0
Const LEVEL_COMPLETE = 1
Const LEVEL_READY    = 2
Const LEVEL_PLAYER_DYING = 3
Const LEVEL_ZOOMING = 4
Const LEVEL_START_ZOOM = 5
Const LEVEL_REVERSE_ZOOM = 6
Const LEVEL_INTO_VORTEX = 7

'baddie types
Const BAD_SPIKE = 1
Const BAD_BULLET = -1
Const BAD_SPINNER = 2
Const BAD_FLIPPER = 3
Const BAD_TANKER = 4
Const BAD_PULSAR = 5
Const BAD_FUSEBALL = 6

Const PLAYERSPEED# = 0.25 '5 positions per edge  0,.25,.5,.75,1


' lists of objects
Global POINT_LIST:TList = New TList
Global FUSEPOINT_LIST:TList = New TList
Global EGG_LIST:TList = New TList
Global EXPLOSION_LIST:TList = New TList
Global SHOT_LIST:TList = New TList
Global BADDIE_LIST:TList = New TList


Global theLevel:Level
Global current_level = 0
Global current_color = 0
Global current_board = 0
Global tubes = 0
Global hiscore = 0

Global leveldata[64,3+32]  '  Closed/Open, YCenter, YOFFSET, 16 x,y pairs

Global eggsleft
Global maxeggs
Global enemiesleft
Global hatchingeggs

Global MainPlayer:Player
Global superzapper = 2
Global superzapperdisplay = 0
Global startbonus = 0
Global zapchan:TChannel = AllocChannel()

Global canflip = True
Global flipflipspeed = 15
Global pulseflipspeed = 15
Global fuseclimbspeed = 1
Global tankerclimbspeed = 1

Global pulsecount = 0
Global pulsespeed = 1
Global pulsing = False
Global pulse_zh# 
Global pulsesalive = False

Global fusex#[5,6,7]
Global fusey#[5,6,7]
Global fuseball_count
Global fuseball_frame

Global globalclock
Global enemyreleaserate = 30
Global hatchrate = 1
Global rimit = False
Global onrim = False

Global showdebug

LoadSfx()
ReadFuseballData()
ReadLevelData()

theLevel = Level.Create()
MainPlayer = Player.Create()

Game()

'BoardMaker()



Function BoardMaker()

	Local showcord = False
	Local index = 0
	Local cb = 0
	Local xp[16]
	Local yp[16]
	Local c 
	While Not KeyHit(key_escape)

		c = leveldata[cb,0]
		k = 70
		CCenterY = leveldata[cb,1]
		YOFFSET =  leveldata[cb,2]
	
	
		For Local a = 0 Until 16
			xp[a] = leveldata[cb,3+a*2]+400
			yp[a] = leveldata[cb,3+a*2+1]+300
			If index = a 
				DrawOval xp[a]-4,yp[a]-4,8,8
			Else
				DrawOval xp[a]-2,yp[a]-2,4,4
			EndIf

			If a > 0
				DrawLine xp[a-1],yp[a-1],xp[a],yp[a]
			EndIf
			If showcord Then DrawText "("+(xp[a]-400)+","+(yp[a]-300)+")",xp[a]-30,yp[a]-20
		Next
		If c
			DrawLine xp[15],yp[15],xp[0],yp[0]
		EndIf
		
		If KeyHit(key_c) Then showcord = 1-showcord
		If KeyHit(key_b) Then cb = cb + 1 ; If cb > 47 Then cb = 0
		If KeyHit(key_v) Then cb = cb - 1 ; If cb < 0 Then cb = 47
		
		If KeyHit(key_COMMA) Then index = index - 1;If index < 0 Then index = 15
		If KeyHit(key_PERIOD) Then index = index + 1;If index > 15 Then index = 0	

		If KeyHit(key_left) Then leveldata[cb,3+index*2]:-10
		If KeyHit(key_right) Then leveldata[cb,3+index*2]:+10
		If KeyHit(key_up) Then leveldata[cb,3+index*2+1]:-10
		If KeyHit(key_down) Then leveldata[cb,3+index*2+1]:+10

		DrawText cb,10,10
		
		If KeyHit(key_s)
			DebugLog "'Level "+cb
			Local s$ = "DefData "+c+","+leveldata[cb,1]+","+leveldata[cb,2]+","
			For Local a = 0 Until 16
				s$ = s$ + Int(leveldata[cb,3+a*2]) +","+ Int(leveldata[cb,3+a*2+1])
				If a < 15 Then s$=s$+","
			Next
			DebugLog s$
		EndIf
		Flip
		Delay 30
		Cls
	Wend
		
End Function







Type Player
	Field e_Index        'the edge the player is on
	Field zPos			 ' player height
	Field shottimer = 3	 ' delay between shots timer
	Field score
	Field oldscore
	Field bonusmencnt = 0	' keep track of when bonus man is due
	Field dying				
	Field men = 3
	Field deathcount
	Field deathtype
	Field bonusdisplay
	Field scl#=0.5          ' where on the edge 0.0, 0.25, 0.5, 0.75, 1.0
	Field schan:TChannel = Null ' send all shot audio through this channel

	
	Method SetEdge(index)
		e_index = index
	EndMethod


	Method AddShot()
		Shot.Create(theLevel.edges[e_Index],zPos)
	EndMethod

	Method ShiftLeft()
		PlaySound(ticksfx)
		If e_Index=0
			If theLevel.continuous
				e_Index = theLevel.e_Cnt-1
			EndIf
		Else
			e_Index:-1
		EndIf
	EndMethod

	Method ShiftRight()
		PlaySound(ticksfx)
		If e_Index=theLevel.e_cnt-1
			If theLevel.continuous
				e_Index = 0
			EndIf
		Else
			e_Index:+1
		EndIf
	EndMethod

	Method Update()
	
		' fire!
		If KeyDown(KEY_LCONTROL)
			If shottimer > 2
				If deathcount = 0 ' no control when dying
					If CountList(SHOT_LIST) < 12
						Self.AddShot()
						PlaySound(shotsfx, schan)
						shottimer = 0
					EndIf
				EndIf
			EndIf
		EndIf
		shottimer:+1
		
		' superzapper
		If KeyHit(KEY_SPACE)
			If deathcount = 0
				If superzapper > 0 
					baddies.superZapit(superzapper)
					superzapper:-1
				EndIf
			EndIf
		EndIf
		
		' rotate 
	 	If KeyDown(KEY_LEFT)
			If deathcount = 0
		 		If theLevel.continuous
			 		scl:-PLAYERSPEED
			 		If scl<0 Then
			 			Self.ShiftLeft()
			 			scl = 1
			 		EndIf
				Else
					If e_index > 0
				 		scl:-PLAYERSPEED
				 		If scl<0 Then
				 			Self.ShiftLeft()
				 			scl = 1
				 		EndIf
					Else
				 		scl:-PLAYERSPEED
				 		If scl < 0 Then
				 			scl = 0
				 		EndIf
					EndIf
				EndIf
			EndIf
	 	EndIf
		
		' rotate other direction
	 	If KeyDown(KEY_RIGHT)
			If deathcount = 0
		 		If theLevel.continuous
			 		scl:+PLAYERSPEED
			 		If scl>1 Then
			 			Self.ShiftRight()
			 			scl = 0
			 		EndIf
				Else
					If e_index < theLevel.e_cnt-1
				 		scl:+PLAYERSPEED
				 		If scl > 1 Then
				 			Self.ShiftRight()
				 			scl = 0
				 		EndIf
					Else
				 		scl:+PLAYERSPEED
				 		If scl > 1 Then
				 			scl = 1
				 		EndIf
					EndIf
				EndIf
			EndIf
	 	EndIf
	
		' this edge will be player colour
		theLevel.edges[e_Index].hasplayer = True
		
		'we're dying if deathcount has been set to > 0
		If deathcount > 0
			deathcount:-1
			If deathcount = 0
				men:-1
				deathtype = 0
			EndIf
		EndIf
		
		'check score for bonus
		If score <> oldscore
			If Int(score/10000) > bonusmencnt
				men:+1
				bonusdisplay = 100
				bonusmencnt = score/10000
				PlaySound(bonusmansfx)
			EndIf
			' keep track of high score
			If score > hiscore
				hiscore = score
			EndIf
		EndIf

		'time to show rainbow pattern - for bonus man
		If bonusdisplay > 0
			If theLevel.state <> LEVEL_BEGIN
				bonusdisplay:-1
			EndIf
		EndIf

	EndMethod

	
	Method Draw()
		SetRotation 0
		'Draw it
		Local zz#,zh#
		Local x#[8],y#[8]
		Select theLevel.state
			Case LEVEL_BEGIN
				zPos = theLevel.depth				
				zz = theLevel.position+theLevel.depth-zPos
				zh# = (10.0)*(1.0-zz/1500.0)
			Case LEVEL_READY
				zPos = theLevel.depth				
				zz = theLevel.position+theLevel.depth-zPos
				zh# = 20.0+10-Abs(scl-0.5)*10.0
			Case LEVEL_PLAYER_DYING
				Select deathtype
					Case KILLED_BY_FLIPPER
						zz = theLevel.position+theLevel.depth-zPos' +180-deathcount*3
						zh# = 20.0+10-Abs(scl-0.5)*10.0
						zh = zh * (deathcount*3)/180.0
					Case KILLED_BY_PULSAR
						zz = theLevel.position - Sin(deathcount*1.5)*100 +100
						zh# = 20.0+10-Abs(scl-0.5)*10.0
					Case KILLED_BY_BULLET
						zz = theLevel.position + Sin(deathcount*1.5)*20	-20
						zh# = 20.0+10-Abs(scl-0.5)*10.0
					Default
						zPos = theLevel.depth				
						zz = theLevel.position+theLevel.depth-zPos
						zh# = 2+zPos/10-Abs(scl-0.5)*zPos/40	
				End Select
			Case LEVEL_COMPLETE
				zPos = theLevel.depth				
				zz = theLevel.position+theLevel.depth-zPos
				zh# = 2+zPos/10-Abs(scl-0.5)*zPos/40	
			Case LEVEL_START_ZOOM
				zPos = theLevel.depth				
				zz = theLevel.position+theLevel.depth-zPos
				zh# = 2+zPos/10-Abs(scl-0.5)*zPos/40	
			Case LEVEL_ZOOMING
				'zPos = theLevel.depth				
				zz = theLevel.position+theLevel.depth-zPos
				zh# = 30.0-Abs(scl-0.5)*zPos/40
			Case LEVEL_REVERSE_ZOOM
				zz = theLevel.position+theLevel.depth-zPos
				zh# = 2+zPos/10-Abs(scl-0.5)*zPos/40
		EndSelect
		Local e:Edge = theLevel.edges[e_Index]
		TForm(e.p1.x, e.p1.y,zz,x[0],y[0])
		TForm(e.p2.x, e.p2.y,zz,x[1],y[1])

		Local xn#
		Local yn#
		
		Local xd# = x[1]-x[0]
		Local yd# = y[1]-y[0]
		Local sz# = Sqr(xd*xd + yd*yd)
		' find a perpendicular line to the outside edge of the web
		If sz = 0
			xn# = 0
			yn# = 0
		Else
			xn# = -yd/sz
			yn# = xd/sz
		EndIf
		If scl > 0.0 And scl < 1.0
			x[4] = x[1]-(xd)*scl + xn*zh
			y[4] = y[1]-(yd)*scl + yn*zh
		
			x[2] = x[1]-(xd)*0.3 - xn*zh/2
			y[2] = y[1]-(yd)*0.3 - yn*zh/2
		
			x[3] = x[1]-(xd)*0.6 - xn*zh/2
			y[3] = y[1]-(yd)*0.6 - yn*zh/2
		
			x[5] = x[1]-(xd)*scl + xn*zh/2
			y[5] = y[1]-(yd)*scl + yn*zh/2
		
			x[6] = x[1]-(xd)*0.8
			y[6] = y[1]-(yd)*0.8
		
			x[7] = x[1]-(xd)*0.2
			y[7] = y[1]-(yd)*0.2
			
		Else
			' extreme ends of motion
			If scl >.5
				x[4] = x[1]-(xd)*scl + xn*zh
				y[4] = y[1]-(yd)*scl + yn*zh
			
				x[2] = x[1]-(xd)*0.3 - xn*zh/2
				y[2] = y[1]-(yd)*0.3 - yn*zh/2
			
				x[3] = x[1]-(xd)*0.6 - xn*zh/2
				y[3] = y[1]-(yd)*0.6 - yn*zh/2
			
				x[6] = x[1]-(xd)*0.9' + xn*zh/8
				y[6] = y[1]-(yd)*0.9' + yn*zh/8

				x[5] = x[1]-(xd)*0.9 + xn*zh/2
				y[5] = y[1]-(yd)*0.9 + yn*zh/2
						
				x[7] = x[1]-(xd)*0.8 + xn*zh
				y[7] = y[1]-(yd)*0.8 + yn*zh

				x[1] = x[1]-(xd)*0.7 + xn*zh*1.5
				y[1] = y[1]-(yd)*0.7 + yn*zh*1.5
			Else
				x[4] = x[1]-(xd)*scl + xn*zh
				y[4] = y[1]-(yd)*scl + yn*zh
			
				x[2] = x[1]-(xd)*0.3 - xn*zh/2
				y[2] = y[1]-(yd)*0.3 - yn*zh/2
			
				x[3] = x[1]-(xd)*0.6 - xn*zh/2
				y[3] = y[1]-(yd)*0.6 - yn*zh/2
			
				x[7] = x[1]-(xd)*0.1' + xn*zh/8
				y[7] = y[1]-(yd)*0.1' + yn*zh/8

				x[5] = x[1]-(xd)*0.1 + xn*zh/2
				y[5] = y[1]-(yd)*0.1 + yn*zh/2
			
				x[6] = x[1]-(xd)*0.2 + xn*zh
				y[6] = y[1]-(yd)*0.2 + yn*zh
			
				x[0] = x[1]-(xd)*0.3 + xn*zh*1.5
				y[0] = y[1]-(yd)*0.3 + yn*zh*1.5
			EndIf		
		EndIf		
		Color(COL_CLAW)
		If deathtype <> 5
			' normal claw draw
			DrawLine x[0],y[0],x[4],y[4]
			DrawLine x[1],y[1],x[4],y[4]
			DrawLine x[0],y[0],x[3],y[3]
			DrawLine x[1],y[1],x[2],y[2]
			
			DrawLine x[5],y[5],x[6],y[6]
			DrawLine x[5],y[5],x[7],y[7]		
			DrawLine x[3],y[3],x[6],y[6]
			DrawLine x[2],y[2],x[7],y[7]
		Else
			'death by fuseball
			If (deathcount/4)Mod 4 >1 SetColor 255,255,255
			For Local i = 0 To 7
				Local rv = Rand(0,360)
				Local sr = Rnd(4,40)*(60-deathcount)/60
				DrawRect (x[2]+x[3])/2+Cos(rv)*sr,(y[2]+y[3])/2+Sin(rv)*sr,2,2
			Next		
		EndIf
		
		If showdebug
			DrawText zPos+" "+zh,600,10
		EndIf
		
	EndMethod


	Method DrawMenLeft()
	
		Local zz#,zh#
		Local x#[8],y#[8]
		zh# = 10.0
		x[0] = 30
		y[0] = 60
		x[1] = 0
		y[1] = 60

		Local xn#
		Local yn#
		
		Local xd# = -30
		Local yd# = 0
		Local sz# = 30
		xn# = 0
		yn# = -1
		x[4] = x[1]-(xd)*.5 + xn*zh
		y[4] = y[1]-(yd)*.5 + yn*zh
	
		x[2] = x[1]-(xd)*0.3 - xn*zh/2
		y[2] = y[1]-(yd)*0.3 - yn*zh/2
	
		x[3] = x[1]-(xd)*0.6 - xn*zh/2
		y[3] = y[1]-(yd)*0.6 - yn*zh/2
	
		x[5] = x[1]-(xd)*.5 + xn*zh/2
		y[5] = y[1]-(yd)*.5 + yn*zh/2
	
		x[6] = x[1]-(xd)*0.8' + xn*zh/8
		y[6] = y[1]-(yd)*0.8' + yn*zh/8
	
		x[7] = x[1]-(xd)*0.2' + xn*zh/8
		y[7] = y[1]-(yd)*0.2' + yn*zh/8
		
		Color(COL_CLAW)
		Local m = men;If m > 5 Then m = 5
		For Local t = 1 To m
			DrawLine x[0]+t*40-30,y[0],x[4]+t*40-30,y[4]
			DrawLine x[1]+t*40-30,y[1],x[4]+t*40-30,y[4]
			DrawLine x[0]+t*40-30,y[0],x[3]+t*40-30,y[3]
			DrawLine x[1]+t*40-30,y[1],x[2]+t*40-30,y[2]
		
			DrawLine x[5]+t*40-30,y[5],x[6]+t*40-30,y[6]
			DrawLine x[5]+t*40-30,y[5],x[7]+t*40-30,y[7]		
			DrawLine x[3]+t*40-30,y[3],x[6]+t*40-30,y[6]
			DrawLine x[2]+t*40-30,y[2],x[7]+t*40-30,y[7]
		Next
		If men > 5
			DrawString( men,6*40+5-30,50,2.0)
		EndIf
	EndMethod

	Function Create:Player()
		Local p:Player = New Player	
		p.zPos = 400
		p.schan = AllocChannel()
		Return p
	EndFunction
	
EndType




Type Point
	Field x#,y#,xd#,yd#
	Field xtarget#,ytarget#
	Field xrate#,yrate#
	Field xoriginal#,yoriginal#

	Field e0:edge
	Field e1:edge
	
	Function Create:Point( x#, y# )
		Local p:Point = New Point
		p.x=x
		p.y=y
		p.xoriginal# = x
		p.yoriginal# = y
		p.xtarget# = x
		p.ytarget# = y
		POINT_LIST.AddLast( p )		
		Return p
	EndFunction

	Method SetPointXY( x#, y# )
		x=x
		y=y
		xoriginal# = x
		yoriginal# = y
	EndMethod
	
	Method Update()
		If Abs(xd) > 0.001
			xd = xd - xrate
		Else
			xd = 0
			xtarget = x
			xrate = 0
		EndIf
		x = x + xrate
		If Abs(yd) > 0.001
			yd = yd - yrate
		Else
			yd = 0
			ytarget = y
			xrate = 0
		EndIf
		y = y + yrate
	End Method 
	
	Method ResetPoint()
		x=xoriginal
		y=yoriginal
		xtarget = xoriginal#
		ytarget = yoriginal#
		xrate = 0
		yrate = 0
		xd = 0
		yd = 0		
	End Method 
	
	Method MorphPoint(xt#,yt#,xr#,yr#)
		x = xtarget
		y = ytarget
		xtarget = xt
		ytarget = yt
		xd = xtarget-x
		yd = ytarget-y		
		xrate = Abs(xr)*Sgn(xd)
		yrate = Abs(yr)*Sgn(yd)
	End Method 
		
	Function UpdatePoints()
		Local p:Point
		For p=EachIn POINT_LIST
			p.Update()
		Next
	EndFunction
	
	Function ResetPoints()
		Local p:Point
		For p=EachIn POINT_LIST
			p.ResetPoint()
		Next
	EndFunction
	
EndType









Type Edge
	Field index
	Field p1:point
	Field p2:point
	Field angle
	Field pulsing
	Field haspulser = False
	Field hasplayer = False
	Field bcol
	
	Field spike:Spikes
	
	Field xx#,yy#
	
	Method Draw( zd1#, zd2#, layer )
		If zd1<1 zd1=1
		If zd2<1 zd2=1
		
		'draw the edge at zero position,
		'the depth line and the far point
		Local x#[4],y#[4]
		TForm p1.x,p1.y,zd1, x[0],y[0]
		TForm p1.x,p1.y,zd2, x[1],y[1]
		
		TForm p2.x,p2.y,zd1, x[2],y[2]
		TForm p2.x,p2.y,zd2, x[3],y[3]
		
		If pulsing
			'SetBlend LIGHTBLEND	
	
			SetLineWidth 2
			If (pulsecount) Mod 8 > 3
				Color(COL_PULSARS)
			Else
				Color(COL_BULLETS)
			EndIf
			DrawLine x[0],y[0],x[1],y[1]
			DrawLine x[3],y[3],x[2],y[2]
				
		Else
		
			'SetBlend LIGHTBLEND	
			SetLineWidth 2

			If hasplayer 
				Color(COL_CLAW)
			Else
				If (superzapperdisplay/2) Mod 4 > 1
					Color(COL_TANKERS)
				Else
					Color(COL_LEVEL)
				EndIf
			EndIf
			If layer = 0 And mainPlayer.bonusdisplay > 0
				Color(bcol)
			EndIf
			If layer = 0 Or hasplayer
				DrawLine x[0],y[0],x[1],y[1]
				DrawLine x[3],y[3],x[2],y[2]
			EndIf
			
			If (superzapperdisplay/2) Mod 4 > 1
				Color(COL_TANKERS)
			Else
				Color(COL_LEVEL)
			EndIf
			DrawLine x[1],y[1],x[3],y[3]'bottom
			If haspulser = False
				DrawLine x[0],y[0],x[2],y[2]'top
			EndIf
		EndIf		
		SetLineWidth 1

		If showdebug Then DrawText angle,x[0],y[0]
	EndMethod

	Function Create:Edge(p1:Point, p2:Point)
		Local e:Edge = New edge
		
		'assign the points
		e.p1=p1
		e.p2=p2
		
		'linkem up
		p1.e1=e
		p2.e0=e
		
		'store the midpoint for speeding up
		e.xx =( ( p2.x - p1.x ) / 2.0 ) + p1.x
		e.yy =( ( p2.y - p1.y ) / 2.0 ) + p1.y
			
		Return e
	EndFunction
EndType



Type Level
	Field depth#    = 400
	Field position# = 1500
	Field state     = LEVEL_BEGIN
	Field continuous = True
	Field cnt
	Field hasspikes = False
	Field hasflippers = False
	Field hastankers = False
	Field hastankersp = False
	Field hastankersf = False
	Field hasfuseballs = False
	Field haspulsars = False
	
	'Field points:TList
	Field edges:Edge[20]
	Field e_cnt

	Method AddPoint:Point(x#,y#)
		Local p:Point = Point.Create( x, y )
		'points.AddLast( p )
		Return p
	EndMethod

	Method AddEdge:Edge( p1:Point, p2:point )
		Local e:Edge = Edge.Create( p1, p2 )
		edges[e_cnt] = e
		e_cnt:+1
		e.index = e_cnt
		Return e
	EndMethod

	Method Update()
		Select state
			Case LEVEL_BEGIN
				If cnt = 0 Then PlaySound(zoominsfx)
				cnt = cnt + 1
				If position>50
					position:-10
					CCenterY = -(position-50)/5 + leveldata[current_board+tubes,1]
				Else
					state=LEVEL_READY
					CCenterY = leveldata[current_board+tubes,1]
				EndIf
			Case LEVEL_READY
				ZOFFSET = 5
				mainplayer.zPos = depth
			Case LEVEL_PLAYER_DYING
				ZOFFSET = 5
				If mainplayer.deathcount = 1
					state=LEVEL_INTO_VORTEX
					cnt = 0
				EndIf
			Case LEVEL_INTO_VORTEX
				cnt:+1
				ZOFFSET:+3
				If cnt > 60
					state=LEVEL_READY
					Baddies.ConvertBaddieToEggs()
					cnt = 0
					ZOFFSET=5
				EndIf
			Case LEVEL_START_ZOOM
				k = 70
				ZOFFSET = 5
				mainplayer.zPos = depth
				cnt = cnt + 1
				If cnt > 20 
					state = LEVEL_ZOOMING
					mainPlayer.deathcount = 0
					cnt = 0
					PlaySound(zoomoutsfx)
				EndIf
			Case LEVEL_ZOOMING
				If ZOFFSET < -40
					k = k + 2
					If k > 70+30 Then k = k + 2
					If mainplayer.zPos < 10
						state = LEVEL_COMPLETE
						ZOFFSET = 5
						cnt = 0
					Else
						mainplayer.zPos:-3			
					EndIf
				Else
					ZOFFSET = ZOFFSET - 2
					mainplayer.zPos:-3
				EndIf
			Case LEVEL_REVERSE_ZOOM
				k=k-4
				If k<70 Then k = 70
				ZOFFSET:+1
				If ZOFFSET > 5
					ZOFFSET = 5					
					cnt = cnt + 1
					If cnt > 20
						If CountList(EGG_LIST) = 0
							state = LEVEL_START_ZOOM
						Else
							state = LEVEL_READY
						EndIf
						cnt = 0
						k=70
						mainplayer.deathcount = 0						
					EndIf
					mainplayer.zPos = depth					
				EndIf			
			Case LEVEL_COMPLETE
				cnt = cnt + 1
				If cnt > 60
					If startbonus > 0
						mainplayer.score:+startbonus 
						startbonus = 0
					EndIf

					ZOFFSET = 5
					mainplayer.zPos = depth
					state = LEVEL_BEGIN
					ClearLevel()
					current_level:+1
					If current_level > 16*6-1
						current_level = 0
						tubes = tubes+16
						If tubes > 32 Then tubes = 0
					EndIf
					current_board = current_level Mod 16
					current_color = current_level/16
					SetUpLevel()
					SetUpEnemies()
					superzapper = 2
					MainPlayer.SetEdge( 7 )
					cnt = 0
					position = 1500
					CCenterY = -(position-50)/5 + leveldata[current_board+tubes,1]
					FlushKeys()
				EndIf				
					
		EndSelect
		For Local a=0 Until e_cnt
			edges[a].pulsing = False
			edges[a].haspulser = False
			edges[a].hasplayer = False
			If mainplayer.bonusdisplay Mod 4 = 3
				edges[a].bcol = Rand(0,5)
			EndIf
		Next
		If superzapperdisplay > 0 Then superzapperdisplay:-1
	EndMethod


	Method UpdateAngles()
		Local a
		For a=0 Until e_cnt		
			edges[a].angle = GetAngle#( edges[a].p2.x, edges[a].p2.y, edges[a].p1.x, edges[a].p1.y, edges[(a+1)Mod e_cnt].p1.x, edges[(a+1)Mod e_cnt].p1.y)
		Next
		If theLevel.continuous = False
			edges[14].angle = 0 
		EndIf
	    For a=0 Until e_cnt
		   	edges[a].xx =( ( edges[a].p2.x - edges[a].p1.x ) / 2.0 ) + edges[a].p1.x
    		edges[a].yy =( ( edges[a].p2.y - edges[a].p1.y ) / 2.0 ) + edges[a].p1.y
    	Next
		a=0
		If theLevel.continuous = False
		   	edges[a].xx =( ( edges[a].p2.x - edges[a].p1.x ) / 2.0 ) + edges[a].p1.x
    		edges[a].yy =( ( edges[a].p2.y - edges[a].p1.y ) / 2.0 ) + edges[a].p1.y		
		EndIf
	End Method
	
	
	Method Draw()
		Local a=0
		Local oldz
		Select state
			Case LEVEL_INTO_VORTEX 
				oldz = ZOFFSET	
				ZOFFSET = 5		
		EndSelect
		
		For a=0 Until e_cnt
			edges[a].Draw(position,position+depth,0)
		Next
		For a=0 Until e_cnt
			edges[a].Draw(position,position+depth,1)
		Next
		
		Select state
			Case LEVEL_INTO_VORTEX 
 				ZOFFSET = oldz
		EndSelect
		
	EndMethod

	Function Create:Level()
		Local l:Level = New Level
		'l.points = New TList
		Return l
	EndFunction
	
	Method mutate()
	    Local a=0
	    For a=0 Until e_cnt
			Local xt# = Rnd(-1,1)
			Local yt# = Rnd(-1,1)
			Local xr# = xt/16
			Local yr# = yt/16
			edges[a].p1.Morphpoint(xt+edges[a].p1.x,yt+edges[a].p1.y,xr,yr)
    	Next
		a=0
		If theLevel.continuous = False
			Local xt# = Rnd(-1,1)
			Local yt# = Rnd(-1,1)
			Local xr# = xt/16
			Local yr# = yt/16
			edges[a].p2.Morphpoint(xt+edges[a].p2.x,yt+edges[a].p2.y,xr,yr)			
		EndIf
	EndMethod
	
	Function LevelSelect()

		Local done = False	
		Local lv = -1
		Local index = current_level/2
		If index > 42 Then index = 42
		Local sel = 0

		While lv = -1
			If KeyHit(key_left)
				sel:-1
				If sel < 0
					sel = 0
					index:-1
					If index < 0 Then index = 0
				EndIf
				PlaySound(ticksfx)
			EndIf
			If KeyHit(KEY_RIGHT)
				sel:+1
				If sel > 4
					sel = 4
					index:+1
					If index > 43 Then index = 43
				EndIf
				PlaySound(ticksfx)
			EndIf
			
			Cls 
			SetColor 255,255,0
			DrawString("SELECT STARTING LEVEL",100,10,6.0)
			DrawString("HI SCORE  "+hiscore,180,500,6.0)
			
			For Local br = 0 To 4
				DrawSmallLevel((index+br)*2,190+br*120,300,br=sel)
			Next
			SetColor 0,255,0	
			DrawString("LEVEL",80,300-50,2.0)
	
			SetColor 255,0,0
			DrawString("BONUS",80,300+50,2.0)			
			
			If KeyHit(KEY_LCONTROL)
				lv = (index+sel)*2
				Local col = lv/16
				startbonus = (lv)*(3000+col*1000)+col*7000+((lv)>3)*(lv)*4000				
			EndIf
			
			If KeyHit(key_t) Then tubes:+16; If tubes > 32 Then tubes = 0
			
			If KeyHit(KEY_ESCAPE) Then done = True;lv=-2
			Globalclock:+1
			Flip
			Delay 16		
		Wend
		
		If lv > -1
			current_level = lv
			current_board = lv Mod 16
			current_color = lv/16
			
			SetUpLevel()
			SetUpEnemies()
	
			superzapper = 2		
			MainPlayer.SetEdge(7)
			theLevel.state = LEVEL_BEGIN
		EndIf
		
		Return done
	
	End Function
	

	Function DrawSmallLevel(lv,xoff,yoff,h)
	
		Local col = lv/16
		current_color = col
		Local b = lv Mod 16

		Local sc# = 1.0		
		Local x1,x2,y1,y2
		Local c = leveldata[b+tubes,0]
		CCenterY = leveldata[b+tubes,1]
		YOFFSET =  leveldata[b+tubes,2]
		
		Color(COL_LEVEL)
		If h And (Globalclock Mod 30 < 16) Then Color(Rand(0,7));sc = (Globalclock Mod 30)/20.0

		For Local a = 0 Until 15
			x1 = Float(leveldata[b+tubes,3+a*2])/8*sc
			y1 = Float(leveldata[b+tubes,3+a*2+1])/8*sc
			x2 = Float(leveldata[b+tubes,3+a*2+2])/8*sc
			y2 = Float(leveldata[b+tubes,3+a*2+3])/8*sc
			DrawLine x1+xoff,y1+yoff,x2+xoff,y2+yoff
		Next
		If c
			x1 = Float(leveldata[b+tubes,3])/8*sc
			y1 = Float(leveldata[b+tubes,3+1])/8*sc
			DrawLine x1+xoff,y1+yoff,x2+xoff,y2+yoff
		EndIf
	
		SetColor 0,255,0	
		DrawString(b+1+16*col,xoff-5,yoff-50,2.0)

		SetColor 255,0,0
		Local l$ = (lv)*(3000+col*1000)+col*7000+((lv)>3)*(lv)*4000
		Local ln = Len(l$)*5
		DrawString(l$,xoff-ln,yoff+50,2.0)
		
	End Function


	
EndType



Type Shot
	Field e:edge  ' the edge its on
	Field z#      ' its position
	Field r#      ' rotation
	Field xx#,yy#
	
	Method Draw()
		Color(COL_BULLETS)

		Local zz# = theLevel.depth-z+theLevel.position
		Local sz# = TFormSZ(4,zz)
		Local pxx#,pyy#
		
		xx = e.xx
		yy = e.yy
		
		TForm(xx,yy,zz,pxx,pyy)
		
		For Local a=0 Until 360 Step 45
			SetRotation r+a
			DrawLine pxx+sz,pyy+sz,pxx-sz,pyy-sz
		Next
		r:+15
		SetRotation 0
	EndMethod

	Method Update()
		z:-6
		Local bad:Baddies
		If z<0
			SHOT_LIST.Remove(Self)
			Return
		Else
			'check for collisions
			For bad = EachIn BADDIE_LIST
				If bad.CheckColl(e,z)
					SHOT_LIST.Remove(Self)
					Return
				EndIf
			Next
		EndIf
	EndMethod

	Function Create:Shot(e:Edge, zPos)
		Local ns:Shot = New Shot
		ns.e = e
		ns.xx =e.xx
		ns.yy =e.yy
		ns.z  = zPos '+5
		SHOT_LIST.AddLast( ns )
		Return ns
	EndFunction

	Function UpdateShots()
		Local s:shot
		For s=EachIn SHOT_LIST
			s.Update()
		Next
	EndFunction
	
	Function DrawShots()
		Local s:shot
		For s=EachIn SHOT_LIST
			s.Draw()
		Next
	EndFunction
	
EndType








Type Explosion
	Field x,y
	Field cnt '60
	Field scale#
	
	Method Draw()
		Color(COL_BULLETS)
		For Local t = 0 To 7
			Local xd = Sin(t*45)*Cos(cnt*3)*scale 
			Local yd = Cos(t*45)*Cos(cnt*3)*scale
			DrawLine x-xd,y-yd,x+xd,y+yd
		Next
	EndMethod

	Method Update()
		cnt:-3
		If cnt < 0 Then EXPLOSION_LIST.Remove(Self)
	EndMethod

	Function Create:Explosion(x,y,height)
		Local ex:Explosion = New Explosion 
		ex.x = x
		ex.y =y
		ex.cnt = 30
		ex.scale# = height/20
		EXPLOSION_LIST.AddLast( ex )
		Return ex
	EndFunction

	Function UpdateDrawExplosions()
		Local s:Explosion
		For s=EachIn EXPLOSION_LIST
			s.Update()
		Next
		For s=EachIn EXPLOSION_LIST
			s.Draw()
		Next
	EndFunction

EndType





' points displayed when a fuseball is shot
' 250/500/750/1000
Type fusepoint
	Field x,y
	Field cnt '60
	Field scale#
	Field pts$
	
	Method Draw()
		Color(COL_BULLETS)
		DrawString(pts,x,y,scale)	
	EndMethod

	Method Update()
		cnt:-1
		If cnt < 0 Then FUSEPOINT_LIST.Remove(Self)
	EndMethod

	Function Create:fusepoint(x,y,height,pt)
		Local ex:fusepoint = New fusepoint
		ex.cnt = 30
		ex.pts = pt
		ex.scale# = height/64+.5
		ex.x = x -ex.scale*1.5
		ex.y = y
		FUSEPOINT_LIST.AddLast( ex )
		Return ex
	EndFunction

	Function UpdateDrawFusePoints()
		Local s:fusepoint
		For s=EachIn FUSEPOINT_LIST
			s.Update()
		Next
		For s=EachIn FUSEPOINT_LIST
			s.Draw()
		Next
	EndFunction
	
EndType





' enemies in the vortex!
Type Egg
	Field e_index
	Field height
	Field act
	Field cnt
	Field hdir
	Field dir

	Method DrawStats(x,y)
		DrawText "i= "+e_Index+"  a="+act+" h="+Int(height)+" c="+cnt+" d="+hdir,x,y
	End Method
	
	Method Hatch()
		Local typ = -1
		While typ < 0		
			' turn it into a baddie
			typ = Rand(0,(7-(enemiesleft=0)*3))
			Select typ
				Case 0'flipper
					If theLevel.hasflippers
						flipper.Create(e_Index,0,0)
					Else
						typ = -1
					EndIf
				Case 1'tank
					If theLevel.hastankers
						Local car = -1
						While car < 0
							car = Rand(0,2)
							Select car
								Case 0
									' carry flippers
									If theLevel.hasflippers
										Tanker.Create(e_Index, Rand(1,2),0,0)			
									Else
										car = -1
									EndIf
								Case 1
									' carry fuseballs
									If theLevel.hastankersf
										Tanker.Create(e_Index, 0,0,Rand(1,2))								
									Else
										car = -1
									EndIf
								Case 2
									' carry pulsars
									If theLevel.hastankersp
										Tanker.Create(e_Index, 0,Rand(1,2),0)
									Else
										car = -1
									EndIf
							End Select
						Wend
					Else
						typ = -1
					EndIf
				Case 4,5,6,7'spinner
					If theLevel.hasspikes
						spinner.Create( e_Index ,Rand(2.0,4.0))
					Else
						typ = -1
					EndIf
				Case 2'fuseball
					If theLevel.hasfuseballs
						fuseball.Create(e_Index,0,0)
					Else
						typ = -1
					EndIf
				Case 3'pulsar
					If theLevel.haspulsars
						Pulsar.Create(e_Index,0,0)			
					Else
						typ = -1
					EndIf		
			End Select
		Wend
		EGG_LIST.Remove(Self)
	End Method
		
	Method Update()
	
		Select act
			Case 0 'move from edge to edge
				cnt:+1
				If cnt > 7
					height:+hdir
					If height >= -1 Or height <= -20 Or Rand(0,100) > 95 Then hdir=-hdir 
					cnt = 0
					If dir = 1
						If e_Index=theLevel.e_cnt-1
							If theLevel.continuous
								e_Index = 0
							Else
								dir = 1-dir
							EndIf
						Else
							e_Index:+1
						EndIf
					Else
						If e_Index = 0
							If theLevel.continuous
								e_Index = theLevel.e_Cnt-1
							Else
								dir = 1-dir
							EndIf
						Else
							e_Index:-1
						EndIf
					EndIf
					If theLevel.state=LEVEL_READY
						If Rand(0,100) > 95-hatchrate
							If enemiesleft + hatchingeggs < 12
								act = 1
								hatchingeggs:+1
							EndIf
						EndIf
					EndIf
				EndIf
			Case 1 'move towards web
				cnt:+1
				If cnt > 7
					height:+1
					If height >= 0 Then act = 2
					cnt=0
				EndIf
			Case 2 'hatch
				hatch()
				hatchingeggs:-1
		End Select
	
	End Method
	
	Method Draw()
	
		Local zz# = theLevel.depth-height*20+theLevel.position
		Local pxx#,pyy#
		Local xx# = theLevel.Edges[e_Index].xx
		Local yy# = theLevel.Edges[e_Index].yy
		
		TForm(xx,yy,zz,pxx,pyy)
		Color(COL_FLIPPERS)
		Plot(pxx,pyy)
		
	End Method
	
	Function Create:Egg(index)
		Local e:Egg = New Egg
		e.e_index = index
		e.height = -10
		e.cnt = 0
		e.act = 0
		e.hdir = 1
		e.dir = Rand(0,1)
		EGG_LIST.AddLast( e )
		Return e
	EndFunction

	Function UpdateEggs()
		Local e:egg
		For e = EachIn EGG_LIST
			e.Update()
		Next
	EndFunction
	
	Function DrawEggs()
		Local e:egg
		Local cnt = 0
		For e = EachIn EGG_LIST
			e.Draw()
			If showdebug Then e.DrawStats(400,cnt*12)		
			cnt = cnt + 1
		Next
	EndFunction
	
End Type








Type Baddies
	Field OnEdge:Edge
	Field e_Index  'used to traverse theLevel edgelist
	Field baddietype = 0
	Field dietime = 0
	Field height#
	
	Method Draw() Abstract
	Method DrawStats(x,y) Abstract
	Method Zapit(t) Abstract
	Method Update() Abstract
	Method CheckColl(e:edge,z#) Abstract 'shots->enemy
	Method CheckPlayerColl() Abstract 'enemy->player
	
	Function UpdateBaddies()
		onrim = True
		Local b:Baddies
		For b = EachIn BADDIE_LIST
			If theLevel.state = LEVEL_ZOOMING Or theLevel.state = LEVEL_REVERSE_ZOOM
				If b.baddietype = BAD_SPIKE Then b.Update() ' only spikes
			Else
				b.Update()
				If b.baddietype > BAD_SPIKE 
					If b.height < 400
						onrim = False
					EndIf				
				EndIf		
			EndIf
		Next
		For b = EachIn BADDIE_LIST
			If theLevel.state = LEVEL_ZOOMING Or theLevel.state = LEVEL_REVERSE_ZOOM
				If b.baddietype = BAD_SPIKE Then b.CheckPlayerColl()' only spikes
			Else
				If theLevel.state <> LEVEL_PLAYER_DYING Then b.CheckPlayerColl()	
			EndIf
		Next
	EndFunction
	
	Function DrawBaddies()
		Local b:Baddies
		Local cnt = 0 
		For b = EachIn BADDIE_LIST
			If theLevel.state = LEVEL_ZOOMING Or theLevel.state = LEVEL_REVERSE_ZOOM
				If b.baddietype = BAD_SPIKE ' only spikes kill when zooming
					b.Draw()
					If showdebug Then b.DrawStats(10,cnt*12)
				EndIf
			Else
				b.Draw()
				If showdebug Then b.DrawStats(10,cnt*12)
			EndIf
			cnt:+1
		Next
	EndFunction
	
	Function ConvertBaddieToEggs()
		' player just died - reset the enemies to eggs
		enemiesleft = 0
		Local b:Baddies
		For b = EachIn BADDIE_LIST
			If b.baddietype > BAD_SPIKE  ' non spikes or bullets
				BADDIE_LIST.Remove(b)
				' eggs yet to be created + live eggs
				If eggsleft + CountList(EGG_LIST) < maxeggs
					eggsleft:+1
				EndIf
			Else
				If b.baddietype = BAD_BULLET  'remove bullets, keep spikes
					BADDIE_LIST.Remove(b)
				EndIf
			EndIf
		Next
		' only strat with max 16 eggs
		If CountList(EGG_LIST) > 16
			eggsleft:+(CountList(EGG_LIST)-16)
			Local cnt = 0
			For Local e:egg = EachIn EGG_LIST
				cnt:+1
				If cnt > 16
					EGG_LIST.Remove(e)
				EndIf
			Next
		EndIf
	End Function
	
	Function SuperZapit(strength)
	
		Local b:Baddies
		Local cnt = 4
		If strength = 2
			' zap them all
			superzapperdisplay = 60
			For b = EachIn BADDIE_LIST
				If b.baddietype <> 1
					If b.Zapit(cnt) Then cnt = cnt + 2
				EndIf
			Next
		Else
			' find biggest threat and kill it
			Local i = mainplayer.e_index
			Local b_best:baddies = Null
			Local best_d = 16
			Local best_h = 0
			Local best_b = 0
			For b = EachIn BADDIE_LIST
				If b.baddietype > 1
					Local d
					If theLevel.continuous
						d = -(i - b.e_index) 'how far from player
						If Abs(d) > 8 Then d = -d
					Else
						d = -(i - b.e_index)
					EndIf
					d = Abs(d)
					If d < best_d+2
						If b.height > best_h
							b_best = b
							best_d = d
							best_h = b.height
							best_b = b.baddietype
'							DebugLog("b="+b.baddietype+" i="+b.e_index+" d="+d+" h="+b.height)
						Else
							If d < best_d
								b_best = b
								best_d = d
								best_h = b.height
								best_b = b.baddietype							
'								DebugLog("+ b="+b.baddietype+" i="+b.e_index+" d="+d+" h="+b.height)
							Else
								' same d, pick the meaner one
								If b.baddietype > best_b
									b_best = b
									best_d = d
									best_h = b.height
									best_b = b.baddietype							
'									DebugLog("++ b="+b.baddietype+" i="+b.e_index+" d="+d+" h="+b.height)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next
			If b_best <> Null
'				DebugLog("Zap b="+b_best.baddietype+" i="+b_best.e_index+" d="+best_d+" h="+best_h)			
				b_best.Zapit(4)
				superzapperdisplay = 60			
			EndIf

		EndIf
	
	End Function
	
EndType


Type Bullets Extends Baddies
	Field height# ' its position
	Field r#      ' rotation
	Field xx#,yy#
	
	Method Draw()
		Color(COL_BULLETS)
		Local zz# = theLevel.depth-height+theLevel.position
		Local sz# = TFormSZ(6,zz)
		Local pxx#,pyy#
		
		xx = onEdge.xx
		yy = onEdge.yy
		
		TForm(xx,yy,zz,pxx,pyy)
		
		For Local a=0 Until 360 Step 45
			SetRotation r+a
			DrawLine pxx+sz,pyy,pxx-sz,pyy
		Next
		r:+15
		SetRotation 0
	EndMethod

	Method Update()
		height:+3
		If height > theLevel.depth
			BADDIE_LIST.Remove(Self)
			Return
		EndIf
	EndMethod

	Method CheckColl(e:edge,z#)
		If e = OnEdge
			If z < height
				MainPlayer.Score = MainPlayer.Score+25
				BADDIE_LIST.Remove(Self)
				Return True
			EndIf
		EndIf
		Return False
	EndMethod
	
	Method CheckPlayerColl()
		If MainPlayer.e_Index = e_index
			If theLevel.depth-height < 8
				PlaySound(killedbybulletsfx)
				BADDIE_LIST.Remove(Self)
				KillPlayer(KILLED_BY_BULLET)
				Return
			EndIf
		EndIf
		Return False
	EndMethod

	Method DrawStats(x,y)
	End Method

	Method ZapIt(t)
		Return False
	End Method
	
	Function Create:Bullets(index, depth)
		PlaySound(bulletsfx)
		Local b:Bullets = New Bullets
		b.OnEdge = theLevel.edges[index]
		b.e_Index= index
		b.xx = b.onEdge.xx
		b.yy = b.onEdge.yy
		b.height = depth
		b.baddietype = BAD_BULLET
		BADDIE_LIST.AddLast b
		Return b
	EndFunction
	
EndType




Type Tanker Extends Baddies
	Field cargo_flipper		'flipper,pulsar,fuseball  1 or 2 of them
	Field cargo_pulsar
	Field cargo_fuseball
	Field xx#,yy#
	Field hasbullets
	
	Method Draw()
		Color(COL_TANKERS)
		Local x#[2],y#[2]
		Local zz# = theLevel.depth-height+theLevel.position
		xx = onEdge.xx
		yy = onEdge.yy

		TForm(xx,yy,zz,x[0],y[0])
		Local scale# '= height/theLevel.depth*24.0+1
		scale = TFormSZ(26,zz)+1
		
		Local scale3# = scale/3
		DrawLine x[0],y[0]-scale3,x[0]-scale,y[0]
		DrawLine x[0],y[0]-scale,x[0]+scale3,y[0]
		DrawLine x[0],y[0]+scale,x[0]-scale3,y[0]
		DrawLine x[0],y[0]+scale3,x[0]+scale,y[0]

		DrawLine x[0],y[0]+scale,x[0]+scale,y[0]
		DrawLine x[0],y[0]+scale,x[0]-scale,y[0]
		DrawLine x[0],y[0]-scale,x[0]+scale,y[0]
		DrawLine x[0],y[0]-scale,x[0]-scale,y[0]

		DrawLine x[0],y[0]+scale3,x[0]+scale3,y[0]
		DrawLine x[0],y[0]+scale3,x[0]-scale3,y[0]
		DrawLine x[0],y[0]-scale3,x[0]+scale3,y[0]
		DrawLine x[0],y[0]-scale3,x[0]-scale3,y[0]

		DrawLine x[0],y[0]+scale3,x[0],y[0]+scale
		DrawLine x[0],y[0]-scale3,x[0],y[0]-scale
		DrawLine x[0]+scale3,y[0],x[0]+scale,y[0]
		DrawLine x[0]-scale3,y[0],x[0]-scale,y[0]
		
		If cargo_fuseball
			'draw fuse in the middle
			Color(COL_FLIPPERS)
			DrawLine x[0],y[0],x[0],y[0]+scale3
			Color(COL_SPIKERS)
			DrawLine x[0],y[0],x[0],y[0]-scale3
			Color(COL_PULSARS)
			DrawLine x[0],y[0],x[0]+scale3,y[0]
			Color(COL_CLAW)
			DrawLine x[0],y[0],x[0]-scale3,y[0]			
		Else
			If cargo_pulsar
				'draw pulsar in the middle
				Color(COL_PULSARS)
				DrawLine x[0]-scale3,y[0],x[0],y[0]+scale3/2
				DrawLine x[0],y[0]+scale3/2,x[0],y[0]-scale3/2
				DrawLine x[0],y[0]-scale3/2,x[0]+scale3,y[0]
			EndIf
		EndIf
	EndMethod
	
	Method ReleaseCargo(stillborn)
		If cargo_flipper > 0
			Local dir = 1-Rand(0,1)*2
			For Local d = 1 To cargo_flipper
				Local e = e_index
				If dir = 1
					If e=0
						If theLevel.continuous
							e = theLevel.e_Cnt-1
						EndIf
					Else
						e:-1
					EndIf
				Else
					If e=theLevel.e_cnt-1
						If theLevel.continuous
							e = 0
						EndIf
					Else
						e:+1
					EndIf
				EndIf				
				Local c:flipper = flipper.Create(e,1,height)
				c.dir = -dir
				If stillborn Then c.dietime = 8
				dir = -dir
			Next
		EndIf
		If cargo_fuseball > 0
			Local dir = 1-Rand(0,1)*2
			For Local d = 1 To cargo_fuseball 
				Local e = e_index
				If dir = 1			
					If e=0
						If theLevel.continuous
							e = theLevel.e_Cnt-1
						EndIf
					Else
						e:-1
					EndIf
				Else
					If e=theLevel.e_cnt-1
						If theLevel.continuous
							e = 0
						EndIf
					Else
						e:+1
					EndIf
				EndIf				
				Local c:fuseball= fuseball.Create(e,0,height)
				c.dir = -dir
				If stillborn Then c.dietime = 8				
				dir = -dir
			Next
		EndIf
		If cargo_pulsar > 0
			Local dir = 1-Rand(0,1)*2
			For Local d = 1 To cargo_pulsar 
				Local e = e_index
				If dir = 1			
					If e=0
						If theLevel.continuous
							e = theLevel.e_Cnt-1
						EndIf
					Else
						e:-1
					EndIf
				Else
					If e=theLevel.e_cnt-1
						If theLevel.continuous
							e = 0
						EndIf
					Else
						e:+1
					EndIf
				EndIf				
				Local c:pulsar = pulsar.Create(e,0,height)
				c.dir = -dir
				If stillborn Then c.dietime = 8								
				dir = -dir
			Next
		EndIf
	EndMethod
	
	Method ZapIt(t)
		dietime = t 'die after t tics
		Return True
	End Method
	
	Method Update()
		If dietime > 0
			dietime:-1
			If dietime = 0 'die
				PlaySound(zapsfx,zapchan)
				Local xx#,yy#,zz1#
				MainPlayer.Score = MainPlayer.Score+200
				ReleaseCargo(True) ' it's cargo will die too
				zz1 = theLevel.position + theLevel.depth - height
				TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)
				Explosion.Create(xx,yy,height)				
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1
				Return		
			EndIf
		EndIf
		height:+2
		If height < 380
			If Rand(0,100) > 98 And hasbullets Then bullets.Create(e_index,height);hasbullets:-1
		EndIf
		If height > theLevel.depth-15
			ReleaseCargo(False)
			BADDIE_LIST.Remove(Self)
			enemiesleft:-1
		EndIf
	EndMethod

	Method CheckColl(e:edge,z#)
		If e = OnEdge
			If z < height
				Local xx#,yy#,zz1#
				MainPlayer.Score = MainPlayer.Score+200
				ReleaseCargo(False)
				zz1 = theLevel.position + theLevel.depth - height
				TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)
				Explosion.Create(xx,yy,height)	
				PlaySound(tankershotsfx)			
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1
				Return True
			EndIf
		EndIf
		Return False
	EndMethod

	Method CheckPlayerColl()
		Return False
	EndMethod	

	Method DrawStats(x,y)
		Color(COL_TANKERS)
		DrawText "i= "+e_Index+" h="+Int(height)+" f="+cargo_flipper+" b="+cargo_fuseball+" p="+cargo_pulsar ,x,y	
	End Method

	Function Create:Tanker(index, numc,nump,numf)
		Local t:Tanker = New Tanker
		t.OnEdge = theLevel.edges[index]
		t.cargo_flipper = numc
		t.cargo_pulsar = nump
		t.cargo_fuseball = numf
		t.e_Index= index
		t.xx = t.onEdge.xx
		t.yy = t.onEdge.yy
		t.height = 10
		t.hasbullets = Rand(1,2)
		t.baddietype = BAD_TANKER
		BADDIE_LIST.AddLast t
		enemiesleft:+1
		Return t
	EndFunction
	
EndType




Type Flipper Extends Baddies
	Field typ       '0 just slides up the tube
	                '1 flips round the tube
					'2 flipping on rim
					'3 pausing
	Field oldtyp
	Field hasbullets
	
	Field Pause     'the pause before changing edge
	Field dir       'direction left or right
	Field angle#     'the angle when changing lanes
	Field totangle#	 ' the total angle to flip

	Method DrawStats(x,y)
		Color(COL_FLIPPERS)
		DrawText "i= "+e_Index+"  d="+dir+" h="+Int(height)+" a="+Int(angle)+" t="+Int(totangle) ,x,y
	End Method
	
	Method Draw()
		Local xx#,yy#,zz1#,zz2#
		Local x#[7],y#[7]
		Select typ
		Case 0 ' sliding up
			zz1 = theLevel.position+theLevel.depth
			zz2 = zz1 - height
			TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
			TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
		Case 1,2 ' flipping
			zz1 = theLevel.position+theLevel.depth
			zz2 = zz1 - height
			TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
			TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
			If dir = -1 'pivot around p1 of dest edge  (current edge+1)
				TFormR(x[1],y[1],-angle+totangle, x[0],y[0])	
			Else
				TFormR(x[0],y[0],-(totangle-angle), x[1],y[1])				
			EndIf			
		Case 3,7 'delaying
			zz1 = theLevel.position+theLevel.depth
			zz2 = zz1 - height
			TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
			TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
		End Select
		
		Local xn#
		Local yn#
		Local zh#' =  height/(theLevel.position+theLevel.depth)*24
		zh = TFormSZ(20,zz2)

		Local xd# = x[1]-x[0]
		Local yd# = y[1]-y[0]
		Local sz# = Sqr(xd*xd + yd*yd)
		If sz = 0
			xn# = 0
			yn# = 0
		Else
			xn# = -yd/sz
			yn# = xd/sz
		EndIf
		x[2] = x[1]-(xd)*0.3 - xn*zh/2
		y[2] = y[1]-(yd)*0.3 - yn*zh/2
		
		x[3] = x[1]-(xd)*0.1 - xn*zh
		y[3] = y[1]-(yd)*0.1 - yn*zh
		
		x[5] = x[1]-(xd)*0.9 - xn*zh
		y[5] = y[1]-(yd)*0.9 - yn*zh
		
		x[6] = x[1]-(xd)*0.7 - xn*zh/2
		y[6] = y[1]-(yd)*0.7 - yn*zh/2
		
		Color(COL_FLIPPERS)
		DrawLine x[0],y[0],x[3],y[3]
		DrawLine x[5],y[5],x[1],y[1]
		DrawLine x[6],y[6],x[5],y[5]
		DrawLine x[2],y[2],x[3],y[3]

		DrawLine x[6],y[6],x[0],y[0]
		DrawLine x[2],y[2],x[1],y[1]
		
	EndMethod

	Method ZapIt(t)
		dietime = t 'die after t tics
		Return True
	End Method
	
	Method Update()
		If dietime > 0
			dietime:-1
			If dietime = 0 'die
				PlaySound(zapsfx,zapchan)
				Local xx#,yy#,zz1#
				zz1 = theLevel.position + theLevel.depth - height
				TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)
				Explosion.Create(xx,yy,height)
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1				
				MainPlayer.Score = MainPlayer.Score+150
				Return		
			EndIf
		EndIf
		Select typ
		Case 0 ' sliding up
			If onEdge.Spike
				If height < OnEdge.Spike.height
					height:+2
				Else
					oldtyp = 1
					typ = 3
				EndIf
			Else
				If height < theLevel.Depth
					height:+1
					If canflip Then oldtyp=1;typ = 3
				Else
					height = theLevel.Depth
					oldtyp=2
					typ = 3
				EndIf
			EndIf
			If Rand(0,100) > 98 And hasbullets Then bullets.Create(e_index,height);hasbullets:-1
			dir = FindShortDir(e_Index, MainPlayer.e_Index)
		Case 1,2 ' flipping
			angle = angle + flipflipspeed
			If typ = 1
				If height < theLevel.Depth
					height:+1
				Else
					height = theLevel.Depth
				EndIf	
			EndIf
			totangle = theLevel.edges[e_Index].angle'-8
			If dir = -1
				Local ind = e_index-1
				If ind < 0 Then ind = theLevel.e_cnt-1
				totangle = theLevel.edges[ind].angle
			EndIf
			If angle >= totangle
				angle = 0
				If height < theLevel.Depth
					oldtyp = 1
					typ = 3
				Else
					oldtyp = 2 ' return to rim case, not climbing
					typ = 3
				EndIf				
				pause = 20
			EndIf				
		Case 3 'delaying
			pause :-1
			If height < theLevel.Depth
				height:+1
			Else
				height = theLevel.Depth
			EndIf
			If pause <= 0
				typ = oldtyp				

				If height >= theLevel.depth Then dir = FindShortDir(e_Index, MainPlayer.e_Index)

				If theLevel.continuous = False
					If e_index - dir < 0 Or e_index - dir > theLevel.e_cnt-1
						dir = -dir
					EndIf
				EndIf
				'move to next edge
				If dir = 1			
					If e_Index=0
						If theLevel.continuous
							e_Index= theLevel.e_Cnt-1
						Else
							dir = -dir
						EndIf
					Else
						e_Index:-1
					EndIf
				Else
					If e_Index=theLevel.e_cnt-1
						If theLevel.continuous
							e_Index= 0
						Else
							dir = -dir
						EndIf
					Else
						e_Index:+1
					EndIf
				EndIf				
				OnEdge = theLevel.edges[e_Index]
				totangle = theLevel.edges[e_Index].angle'-8	
				
				If Rand(0,100) > 98 And hasbullets Then bullets.Create(e_index,height);hasbullets:-1

				If dir = -1
					Local ind = e_index-1
					If ind < 0 Then ind = theLevel.e_cnt-1
					totangle = theLevel.edges[ind].angle '-8
				EndIf
				If onEdge.Spike
					If height < OnEdge.Spike.height
						typ = 0
					EndIf
				Else
					typ = oldtyp
				EndIf
				
			EndIf
		Case 7 'killing player!
			'If height> 0 Then height:-3
		End Select
	EndMethod

	Method CheckColl(e:edge,z#)
		Local sp# = height-z
		If e = OnEdge
			If sp < 16 And sp > 0
				Local xx#,yy#,zz1#,x#[2],y#[2]
				If typ = 1 Or typ = 2
					zz1 = theLevel.position+theLevel.depth-height
					TForm(OnEdge.p1.x,OnEdge.p1.y,zz1,x[0],y[0])
					TForm(OnEdge.p2.x,OnEdge.p2.y,zz1,x[1],y[1])
					If dir = -1 'pivot around p1 of dest edge  (current edge+1)
						TFormR(x[1],y[1],-angle+totangle, x[0],y[0])	
					Else
						TFormR(x[0],y[0],-(totangle-angle), x[1],y[1])				
					EndIf
					xx = (x[0]+x[1])/2
					yy = (y[0]+y[1])/2
				Else
					zz1 = theLevel.position + theLevel.depth - height
					TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)		
				EndIf
				PlaySound(flippershotsfx)
				Explosion.Create(xx,yy,height)
				BADDIE_LIST.Remove(Self)
				MainPlayer.Score = MainPlayer.Score+150
				enemiesleft:-1
				Return True
			EndIf
		EndIf
		Return False
	EndMethod

	Method CheckPlayerColl()
		If MainPlayer.e_Index = e_index
			If theLevel.depth = height
				If typ <> 1 And typ <> 2
					typ=7
					PlaySound(killedbyflippersfx)
					KillPlayer(KILLED_BY_FLIPPER)
					Return True
				Else
					If Abs(totangle-angle) < 30
						typ=7
						PlaySound(killedbyflippersfx)						
						KillPlayer(KILLED_BY_FLIPPER)
						Return True		
					EndIf					
				EndIf
			EndIf
		EndIf
		Return False
	EndMethod

	Function Create:flipper(index,typ = 0,height)
		Local c:flipper = New flipper
		c.OnEdge = theLevel.edges[index]
		c.e_Index= index
		c.typ    = typ
		c.height = height
		c.hasbullets = Rand(1,3)
		c.baddietype = BAD_FLIPPER
		BADDIE_LIST.AddLast c
		enemiesleft:+1		
		Return c
	EndFunction
	
EndType




Type Pulsar Extends Baddies
	Field typ       	
	Field oldtyp
	Field canflip = True
	Field timetoflip = 0
	
	Field Pause     'the pause before changing edge
	Field dir       'direction left or right
	Field hdir
	Field angle#     'the angle when changing lanes
	Field totangle#

	Method DrawStats(x,y)
		Color(COL_PULSARS)
		DrawText "i= "+e_Index+"  d="+dir+" h="+Int(height)+" a="+Int(typ)+" t="+Int(timetoflip) ,x,y
	End Method
	
	Method Draw()
		Local xx#,yy#,zz1#,zz2#
		Local x#[7],y#[7]
		Select typ
		Case 0,4 ' sliding up/down
			zz1 = theLevel.position+theLevel.depth
			zz2 = zz1 - height
			TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
			TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
		Case 1,2 ' flipping
			zz1 = theLevel.position+theLevel.depth
			zz2 = zz1 - height
			TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
			TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
			If dir = -1 'pivot around p1 of dest edge  (current edge+1)
				TFormR(x[1],y[1],-angle+totangle, x[0],y[0])	
			Else
				TFormR(x[0],y[0],-(totangle-angle), x[1],y[1])				
			EndIf			
		Case 3,5,7 'delaying
			zz1 = theLevel.position+theLevel.depth
			zz2 = zz1 - height
			TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
			TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
		End Select
		
		Local xn#
		Local yn#
		Local zh# = pulse_zh#

		Local xd# = x[1]-x[0]
		Local yd# = y[1]-y[0]
		Local sz# = Sqr(xd*xd + yd*yd)
		If sz = 0
			xn# = 0
			yn# = 0
		Else
			xn# = -yd/sz
			yn# = xd/sz
		EndIf
		x[2] = x[1]-(xd)*0.2 - xn*zh
		y[2] = y[1]-(yd)*0.2 - yn*zh
		x[3] = x[1]-(xd)*0.35 + xn*zh
		y[3] = y[1]-(yd)*0.35 + yn*zh
		x[4] = x[1]-(xd)*0.5 - xn*zh
		y[4] = y[1]-(yd)*0.5 - yn*zh
		x[5] = x[1]-(xd)*0.65 + xn*zh
		y[5] = y[1]-(yd)*0.65 + yn*zh
		x[6] = x[1]-(xd)*0.8 - xn*zh
		y[6] = y[1]-(yd)*0.8 - yn*zh
		
		If pulsing
			Color(COL_BULLETS)
		Else
			Color(COL_PULSARS)
		EndIf
		DrawLine x[1],y[1],x[2],y[2]
		DrawLine x[2],y[2],x[3],y[3]
		DrawLine x[3],y[3],x[4],y[4]
		DrawLine x[4],y[4],x[5],y[5]
		DrawLine x[5],y[5],x[6],y[6]
		DrawLine x[6],y[6],x[0],y[0]
		
	EndMethod
	
	Method ZapIt(t)
		dietime = t 'die after t tics
		Return True
	End Method
	
	Method Update()
		If dietime > 0
			dietime:-1
			If dietime = 0 'die
				PlaySound(zapsfx,zapchan)
				Local xx#,yy#,zz1#
				zz1 = theLevel.position + theLevel.depth - height
				TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)
				Explosion.Create(xx,yy,height)
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1				
				MainPlayer.Score = MainPlayer.Score+200
				Return		
			EndIf
		EndIf
		onEdge.haspulser = True
		OnEdge.pulsing = pulsing
		timetoflip:+1
		Select typ
		Case 0 ' sliding up
			If height < theLevel.Depth
				height:+1
				If timetoflip > 50
					If Rand(0,1)
						oldtyp=1;typ = 3
					Else
						oldtyp=0;typ = 5
					EndIf
					timetoflip = 0
				EndIf
			Else
				' reached the top , go down or flip?
				height = theLevel.Depth
				If Rand(0,1) Or rimit
					'flip 
					oldtyp=1;typ = 3
				Else
					'go down
					oldtyp=4;typ = 5
				EndIf
				timetoflip = 0
			EndIf
			pause = 20
			dir = FindShortDir(e_Index, MainPlayer.e_Index)
		Case 4 ' sliding down
			If height > 0
				height:-1
				If timetoflip > 50
					If Rand(0,1) 
						oldtyp=1;typ = 3
					Else
						oldtyp=4;typ = 5
					EndIf
					timetoflip = 0
				EndIf
			Else
				' reached the bottom
				height = 0
				If Rand(0,1)
					'flip
					oldtyp=1;typ = 3
				Else
					'go up
					oldtyp=0;typ = 5
				EndIf
				timetoflip = 0								
			EndIf
			pause = 20
			dir = FindShortDir(e_Index, MainPlayer.e_Index)
		Case 1,2 ' flipping
			angle = angle + pulseflipspeed
			If typ = 1
				If height < theLevel.Depth
					height:+1
				Else
					height = theLevel.Depth
				EndIf	
			EndIf
			totangle = theLevel.edges[e_Index].angle'-8
			If dir = -1
				Local ind = e_index-1
				If ind < 0 Then ind = theLevel.e_cnt-1
'				If ind > theLevel.e_cnt-1 Then ind = 0
				totangle = theLevel.edges[ind].angle '-8
			EndIf
			If angle >= totangle
				angle = 0
				If height < theLevel.Depth
					oldtyp = 0
					typ = 5
				Else
					oldtyp = 0 'made it to the rim
					typ = 5
				EndIf				
				pause = 20
			EndIf				
		Case 5 'delaying 2
			pause :-1
			If pause <= 0
				timetoflip = 0
				typ = oldtyp
			EndIf
		Case 3 'delaying
			pause :-1
			If pause <= 0
				timetoflip = 0
				typ = oldtyp
				
				If theLevel.continuous = False
					If e_index - dir < 0 Or e_index - dir > theLevel.e_cnt-1
						dir = -dir
					EndIf
				EndIf
				'move to next edge
				If dir = 1			
					If e_Index=0
						If theLevel.continuous
							e_Index= theLevel.e_Cnt-1
						Else
							dir = -dir
						EndIf
					Else
						e_Index:-1
					EndIf
				Else
					If e_Index=theLevel.e_cnt-1
						If theLevel.continuous
							e_Index= 0
						Else
							dir = -dir
						EndIf
					Else
						e_Index:+1
					EndIf
				EndIf				
				OnEdge = theLevel.edges[e_Index]
				totangle = theLevel.edges[e_Index].angle'-8			
				If dir = -1
					Local ind = e_index-1
					If ind < 0 Then ind = theLevel.e_cnt-1
					totangle = theLevel.edges[ind].angle '-8
				EndIf
			EndIf
		Case 7 'killing player!
			'If height> 0 Then height:-3
		End Select
		pulsesalive = True
	EndMethod

	Method CheckColl(e:edge,z#)
		Local sp# = height-z
		If e = OnEdge
			If sp < 16 And sp > 0
				Local xx#,yy#,zz1#,x#[2],y#[2]
				If typ = 1 Or typ = 2
					zz1 = theLevel.position+theLevel.depth-height
					TForm(OnEdge.p1.x,OnEdge.p1.y,zz1,x[0],y[0])
					TForm(OnEdge.p2.x,OnEdge.p2.y,zz1,x[1],y[1])
					If dir = -1 'pivot around p1 of dest edge  (current edge+1)
						TFormR(x[1],y[1],-angle+totangle, x[0],y[0])	
					Else
						TFormR(x[0],y[0],-(totangle-angle), x[1],y[1])				
					EndIf
					xx = (x[0]+x[1])/2
					yy = (y[0]+y[1])/2
				Else
					zz1 = theLevel.position + theLevel.depth - height
					TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)		
				EndIf
				Explosion.Create(xx,yy,height)
				PlaySound(pulsarshotsfx)			
				BADDIE_LIST.Remove(Self)
				MainPlayer.Score = MainPlayer.Score+200
				enemiesleft:-1				
				Return True
			EndIf
		EndIf
		Return False
	EndMethod

	Method CheckPlayerColl()
		If MainPlayer.e_Index = e_index
			If theLevel.depth-height < 8
				If typ <> 1 And typ <> 2
					PlaySound(killedbypulsarsfx)
					KillPlayer(KILLED_BY_FLIPPER)
					typ = 7
					Return True
				Else
					If Abs(totangle-angle) < 30
						PlaySound(killedbypulsarsfx)
						KillPlayer(KILLED_BY_FLIPPER)
						typ = 7
						Return True		
					EndIf
				EndIf
			Else
				If typ <> 1 And typ <> 2
					If pulsing
						PlaySound(killedbypulsarsfx)
						KillPlayer(KILLED_BY_PULSAR)
						Return True
					EndIf
				EndIf
			EndIf
		EndIf
		Return False
	EndMethod

	Function Create:Pulsar(index,typ = 0,height)
		Local p:Pulsar = New Pulsar
		p.OnEdge = theLevel.edges[index]
		p.e_Index= index
		p.typ    = typ
		p.height = height
		p.baddietype = BAD_PULSAR
		BADDIE_LIST.AddLast p
		enemiesleft:+1		
		Return p
	EndFunction


	Function UpdatePulseTimers()
		
		pulsecount:+pulsespeed
		If pulsecount > 180 Then pulsecount = 0
		If pulsecount = 71 And pulsesalive Then PlaySound(pulsesfx)
		If pulsecount > 70 And pulsecount < 110 Then pulsing = True Else pulsing = False	
		
		pulse_zh# = Abs((pulsecount Mod 90)-45)/4.0
		If pulse_zh# < 2 Then pulse_zh# = 0
		If pulse_zh# > 12 Then pulse_zh# = 12
		
		pulsesalive = False
	End Function
	
EndType



Type Fuseball Extends Baddies
	Field act
	Field cnt
	Field dir
	Field w ' position across the edge
	
	Method DrawStats(x,y)
		SetColor 255,255,255
		DrawText "i="+e_Index+" h="+Int(height)+" a="+act+" w="+w+" d="+dir ,x,y
	End Method

	Method Draw()
		Local xx#,yy#,zz1#,zz2#,x#[2],y#[2]
		zz1# = theLevel.position+theLevel.depth
		zz2# = zz1 - height
		TForm(OnEdge.p1.x,OnEdge.p1.y,zz2,x[0],y[0])
		TForm(OnEdge.p2.x,OnEdge.p2.y,zz2,x[1],y[1])
		xx = x[1]+(x[0]-x[1]) *w/8
		yy = y[1]+(y[0]-y[1]) *w/8
		Local sc# '= height/theLevel.depth*7.0+1
		sc = TFormSZ(8,zz2)+1

		For Local arm = 0 To 5
			Select arm
				Case 0
					Color(COL_CLAW)
				Case 1
					Color(COL_SPIKERS)				
				Case 2
					Color(COL_TANKERS)
				Case 3
					Color(COL_PULSARS)
				Case 4
					Color(COL_FLIPPERS)
			End Select
			For Local i = 0 To 4
				DrawLine xx+fusex[fuseball_frame,arm,i]*sc,yy+fusey[fuseball_frame,arm,i]*sc,xx+fusex[fuseball_frame,arm,i+1]*sc,yy+fusey[fuseball_frame,arm,i+1]*sc
			Next
		Next
	EndMethod

	Method ZapIt(t)
		dietime = t 'die after t tics
		Return True
	End Method

	Method Update()
		If dietime > 0
			dietime:-1
			If dietime = 0 'die
				PlaySound(zapsfx,zapchan)
				Local xx#,yy#,zz1#
				zz1 = theLevel.position + theLevel.depth - height
				TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)
				Local sc = Int((theLevel.depth-height)/100+1)*250
				fusepoint.Create(xx,yy,height,sc)
				MainPlayer.Score = MainPlayer.Score+sc
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1				
				Return		
			EndIf
		EndIf	
		cnt = cnt + 1
		Select act
		Case 0
			If cnt > 8
				If Rand(0,100) > 90 Then dir = -FindShortDir(e_Index, MainPlayer.e_Index)			
				cnt = 0
				'move left or right....
				Select dir
					Case 1
						w = w + 1
						If w >= 8
							w = 0
							If e_Index=theLevel.e_cnt-1
								If theLevel.continuous
									e_Index= 0
								Else
									w = 8
									dir = -dir
								EndIf
							Else
								e_Index:+1
							EndIf
						EndIf				
												
					Case -1
						w = w - 1
						If w =< 0
							w = 8
							If e_Index=0
								If theLevel.continuous
									e_Index= theLevel.e_Cnt-1
								Else
									w = 0
									dir = -dir
								EndIf
							Else
								e_Index:-1
							EndIf
						EndIf
				End Select
				OnEdge = theLevel.edges[e_Index]
				If w = 0 Or w = 8 
					act = Rand(1,2)
					If rimit Or height = 0 Then act = 1
				EndIf
			EndIf
		Case 1 ' going up
			If height < theLevel.Depth
				height:+4
				If cnt > 25*(Rand(1,3))
					act = 0
					cnt = 0					
				EndIf
			Else
				height = theLevel.Depth
				act = 0
				cnt = 0				
			EndIf
		Case 2 ' going down
			If height >= 0
				height:-4
				If cnt > 25*(Rand(1,3))
					act = 0
					cnt = 0					
				EndIf				
			Else
				act = 0
				cnt = 0				
				height = 0
			EndIf
		Case 7
			w = 3
			'killing player
		End Select
	EndMethod
	
	Method CheckColl(e:edge,z#)
	
		Local sp# = height-z
		If e = OnEdge
			If sp < 16 And sp > 0
				If w >1 And w < 7
					Local xx#,yy#,zz1#
					zz1 = theLevel.position + theLevel.depth - height
					TForm(OnEdge.xx,OnEdge.yy,zz1,xx,yy)
					Local sc = Int((theLevel.depth-height)/100+1)*250
					fusepoint.Create(xx,yy,height,sc)
					MainPlayer.Score = MainPlayer.Score+sc
					BADDIE_LIST.Remove(Self)
					PlaySound(fuseballshotsfx)					
					enemiesleft:-1
					Return True
				EndIf
			EndIf
		EndIf
		Return False
	EndMethod

	Method CheckPlayerColl()
		If MainPlayer.e_Index = e_index
			If act = 0 And height = theLevel.depth
				If w > 1 And w < 7
					act = 7
					KillPlayer(KILLED_BY_FUSEBALL)
					PlaySound(killedbyfuseballsfx)
					Return True
				EndIf
			EndIf
		EndIf
		Return False
	EndMethod
		
	Function Create:fuseball(index,act,height)
		Local f:fuseball= New fuseball
		f.OnEdge=theLevel.Edges[index]
		f.height=height
		f.act = act
		f.e_Index = index
		f.cnt = 0
		f.w = 0
		f.dir = 1
		f.baddietype = BAD_FUSEBALL
		BADDIE_LIST.AddLast f
		enemiesleft:+1
		Return f
	EndFunction

	Function UpdateFuseballTimers()
		
		fuseball_count:+1
		fuseball_frame = (fuseball_count/4) Mod 4
		
	End Function
	
	
EndType




Type Spikes Extends Baddies
	
	Method DrawStats(x,y)
		Color(COL_SPIKERS)
		DrawText "i="+e_Index+" h="+Int(height),x,y
	End Method

	Method Draw()
		Local oldz
		If theLevel.state = LEVEL_INTO_VORTEX 
			oldz = ZOFFSET	
			ZOFFSET = 5
		EndIf

		Local xx#,yy#,zz1#,zz2#
		zz1 = theLevel.position+theLevel.depth
		zz2 = zz1 - height
		
		Local x#[2],y#[2]
		xx =( ( OnEdge.p2.x - OnEdge.p1.x ) / 2.0 ) + OnEdge.p1.x
		yy =( ( OnEdge.p2.y - OnEdge.p1.y ) / 2.0 ) + OnEdge.p1.y
		TForm(xx,yy,zz1,x[0],y[0])
		TForm(xx,yy,zz2,x[1],y[1])
		Color(COL_SPIKERS)
		DrawLine x[0],y[0],x[1],y[1]
		Color(COL_BULLETS)
		Plot x[1],y[1]
		If theLevel.state = LEVEL_INTO_VORTEX 
			ZOFFSET	= oldz
		EndIf

	EndMethod

	Method ZapIt(t)
		Return False
	End Method
	
	Method Update()
	EndMethod

	Method CheckColl(e:edge,z#)
		'check to see if shot hits it
		If e = OnEdge
			If z < height
				height:-8
				MainPlayer.Score = MainPlayer.Score+1	
				PlaySound(spikeshotsfx)				
				If height =< 0
					OnEdge.Spike = Null
					BADDIE_LIST.Remove(Self)
					Return True
				EndIf
				Return True
			EndIf
		EndIf
		Return False
	EndMethod

	Method CheckPlayerColl()
		If MainPlayer.e_Index = e_index
			If height > mainplayer.zPos And mainplayer.deathcount = 0
				PlaySound(killedbyspikesfx)
				KillPlayer(KILLED_BY_SPIKE)
				Return True
			EndIf
		EndIf
		Return False
	EndMethod
	
	Function Create:Spikes(index,h#)
		Local s:Spikes = New Spikes
		s.OnEdge=theLevel.Edges[index]
		theLevel.Edges[index].Spike = s
		s.e_index = index
		s.height=h
		s.baddietype = BAD_SPIKE
		BADDIE_LIST.AddLast s
		Return s
	EndFunction
	
EndType





Type Spinner Extends Baddies
	Field grow_speed#
	Field growth# = 0
	Field r#
	Field act
	
	Method DrawStats(x,y)
		Color(COL_SPIKERS)
		DrawText "i="+e_Index+" h="+Int(height)+" a="+act ,x,y
	End Method

	Method Draw()
		Local xx#,yy#,zz1#,zz2#
		zz1# = theLevel.position+theLevel.depth
		zz2# = zz1 - height
		Local x#,y#,xd1#,yd1#,xd2#,yd2#
		xx = OnEdge.xx
		yy = OnEdge.yy
		Color(COL_SPIKERS)
		TForm(xx,yy,zz2,x,y)
		Local scale#' = height/theLevel.depth*16.0+1
		scale = TFormSZ(22,zz2)+2


		For Local sc# = 0 To -13 Step -1
			xd1 = Sin(r+sc*60)*sc*scale/16
			yd1 = Cos(r+sc*60)*sc*scale/16
			xd2 = Sin(r+(sc+1)*60)*(sc+1)*scale/16
			yd2 = Cos(r+(sc+1)*60)*(sc+1)*scale/16
			DrawLine x+xd1,y+yd1,x+xd2,y+yd2		
		Next
		r = r+45
	EndMethod
	
	Method ZapIt(t)
		dietime = t 'die after t tics
		Return True
	End Method

	Method Update()
		If dietime > 0
			dietime:-1
			If dietime = 0 'die
				PlaySound(zapsfx,zapchan)
				MainPlayer.Score = MainPlayer.Score+50
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1				
				Return		
			EndIf
		EndIf
		Select act
		Case 0 
			' go directly to building spike
			act = 1
			
		Case 1 ' going up/building spike
			If height < theLevel.Depth-4
				height:+grow_speed
				If onEdge.Spike
					If height > onEdge.Spike.height
						onEdge.Spike.height = height - 4
						growth:+grow_speed
						If growth > 100
							If Rnd(0,140) > 88
								act = 2
								If Rnd(0,100) > 70 Then bullets.Create(e_index,height)
							EndIf
						EndIf
					EndIf
				Else
					OnEdge.Spike = spikes.Create(e_index,10)
					OnEdge.Spike.height = height
				EndIf
			Else
				act = 2
			EndIf
		Case 2 ' going down spike
			growth = 0
			If height > 0
				height:-grow_speed
			Else
				height = 0
				act = 0
				BADDIE_LIST.Remove(Self)
				enemiesleft:-1
				eggsleft:+1
			EndIf
		End Select
	EndMethod

	Method CheckColl(e:edge,z#)
		'check to see if any will hit
		If e = OnEdge
			If z < height
				MainPlayer.Score = MainPlayer.Score+50
				enemiesleft:-1
				PlaySound(spinnershotsfx)
				BADDIE_LIST.Remove(Self)
				Return True
			EndIf
		EndIf
		Return False
	EndMethod

	Method CheckPlayerColl()
		' never hits the player
		Return False
	EndMethod
	
	Function Create:Spinner(index,speed#)
		Local s:Spinner = New Spinner
		s.OnEdge=theLevel.Edges[index]
		s.height=0
		s.act = 0
		s.e_Index = index
		s.grow_speed# = speed
		s.baddietype = BAD_SPINNER		
		BADDIE_LIST.AddLast s
		enemiesleft:+1
		Return s
	EndFunction
	
EndType








Function Game()

	Local done = False
	
	While Not done
		FlushKeys()
		done = theLevel.LevelSelect()
		mainplayer.score = 0
		mainplayer.men = 2
		mainplayer.bonusmencnt = 0
		FlushKeys()
		If Not done
			'main loop
			Local gamedone = False
			While Not gamedone 
				If KeyHit(KEY_ESCAPE) Then gamedone = True
				Local tim = MilliSecs()
				globalclock = globalclock + 1	
			
				If (globalclock Mod enemyreleaserate = 0)
					For Local a = 0 To 5
					If eggsleft > 0 
						Egg.Create(Rand(0,theLevel.e_cnt-2+(theLevel.continuous)))
						eggsleft:-1
					EndIf
					Next
				EndIf
			
				point.UpdatePoints()
				theLevel.Update()
				theLevel.UpdateAngles()
				If theLevel.state <> LEVEL_INTO_VORTEX
					pulsar.UpdatePulseTimers()
					fuseball.UpdateFuseBallTimers()
					shot.UpdateShots()
					egg.UpdateEggs()
					If theLevel.state <> LEVEL_COMPLETE Then Baddies.UpdateBaddies()
					MainPlayer.Update()
				EndIf
				
				If theLevel.state <> LEVEL_COMPLETE
					theLevel.Draw()
					shot.DrawShots()
					egg.DrawEggs()
					Baddies.DrawBaddies()
					explosion.UpdateDrawExplosions()	
					fusepoint.UpdateDrawFusePoints()
			
					If theLevel.state <> LEVEL_INTO_VORTEX Then MainPlayer.Draw()
				Else
					If startbonus > 0
						DrawString("BONUS",300,170,10)
						Local l$ = startbonus
						Local ln = Len(l$)					
						DrawString(startbonus,400-ln*20,270,10)
					EndIf					
					DrawString("SUPERZAPPER RECHARGE",120,420,6)
				EndIf
			
				Color(COL_CLAW)
				MainPlayer.DrawMenLeft()	
				DrawString(MainPlayer.Score,10,10,6.0)
				Color(COL_INFO)
				DrawString((current_level+1),400-6*(current_level>8),10,3.0) 
					
				tim = 16-(MilliSecs()-tim)
				If tim > 0 Then Delay tim
				
				If eggsleft = 0 And CountList(EGG_LIST) = 0
					If enemiesleft = 0 Or onrim = True
						If theLevel.state = LEVEL_READY
							theLevel.state = LEVEL_START_ZOOM
						EndIf
					Else
						rimit = True
					EndIf
				EndIf
			
'				If KeyHit(key_u) Then YOFFSET = YOFFSET - 10
'				If KeyHit(key_j) Then YOFFSET = YOFFSET + 10
'				DrawText YOFFSET ,700,0
'				If KeyHit(key_i) Then CCenterY = CCenterY - 10
'				If KeyHit(key_k) Then CCenterY = CCenterY + 10
'				DrawText CCenterY,700,20
				
				If showdebug DrawString(theLevel.state+" ("+eggsleft+")("+CountList(EGG_LIST)+")("+enemiesleft+")",400,40,5.0)
				If KeyDown(KEY_LSHIFT)
					If KeyHit(key_s) Then superzapper = 2
					If KeyHit(key_b) Then mainplayer.score:+10000
					If KeyHit(key_z) Then theLevel.state = LEVEL_START_ZOOM
					If KeyHit(key_m) Then theLevel.mutate()
					If KeyHit(key_n) Then point.ResetPoints()
					If KeyHit(key_t) Then tubes:+16; If tubes > 32 Then tubes = 0
					If KeyHit(key_d) Then showdebug = 1-showdebug
				EndIf
			
				Local skip = False
				While KeyDown(key_f1) And Not skip 
					Delay 100
					If KeyHit(key_f2) Then skip = True
				Wend
				
							
			
				If mainplayer.men < 0 Then gameover();gamedone = True

				Flip
				Cls			
			Wend
			ClearLevel()
		EndIf
	Wend
End Function




Function GameOver()

	Local done = False	
	Local sc# = .2
	Local scd# = .05
	Local s$ = "GAME OVER"
	While Not done
		
		Cls 
		SetColor 0,255,0
		DrawString(s$,400-sc*25,200,sc)

		DrawString(MainPlayer.Score,10,10,6.0)
		DrawString(current_level,400,10,3.0) 
		
		If KeyHit(KEY_SPACE) Then done = True

		If KeyHit(KEY_ESCAPE) Then done = True
		
		sc = sc + scd
		If sc > 4 Or sc < .1 Then scd = -scd;If s$ = "GAME OVER" Then s$ = "PRESS ZAP" Else s$ = "GAME OVER"
		
		Flip
		Delay 16
	Wend
	
End Function





Function KillPlayer(nme)

	Select nme
		Case KILLED_BY_BULLET
			mainplayer.deathcount = 60
			theLevel.state = LEVEL_PLAYER_DYING
			mainplayer.deathtype = KILLED_BY_BULLET
		Case KILLED_BY_PULSAR
			mainplayer.deathcount = 60
			theLevel.state = LEVEL_PLAYER_DYING
			mainplayer.deathtype = KILLED_BY_PULSAR
		Case KILLED_BY_SPIKE
			mainplayer.deathcount = 60
			theLevel.state = LEVEL_REVERSE_ZOOM
			mainplayer.deathtype = KILLED_BY_SPIKE
			Baddies.ConvertBaddieToEggs()
		Case KILLED_BY_FLIPPER
			mainplayer.deathcount = 60
			theLevel.state = LEVEL_PLAYER_DYING
			mainplayer.deathtype = KILLED_BY_FLIPPER
		Case KILLED_BY_FUSEBALL
			mainplayer.deathcount = 60
			theLevel.state = LEVEL_PLAYER_DYING
			mainplayer.deathtype = KILLED_BY_FUSEBALL
	End Select
	
End Function




Function FindShortDir(from_i, to_i)
	
	Local d
	If theLevel.continuous
'		d = -(MainPlayer.e_Index - e_Index) 'how far from player
		d = -(to_i - from_i) 'how far from player
		If Abs(d) > 8 Then d = -Sgn(d) Else d = Sgn(d) 'take the shorter route
		If d = 0 Then d = 1 - Rand(0,1)*2 '-1 or 1					
	Else
		d = -Sgn(to_i - from_i)
		If d = 0 Then d = 1 - Rand(0,1)*2 '-1 or 1
	EndIf
	Return d
	
End Function




Function Color(c)

	Select current_color
		Case 0 'level 1-16
			Select c
				Case COL_BULLETS
					SetColor 255,255,255
				Case COL_CLAW
					SetColor 255,255,0
				Case COL_TANKERS
					SetColor 255,0,255
				Case COL_FLIPPERS
					SetColor 255,0,0
				Case COL_PULSARS
					SetColor 0,255,255
				Case COL_SPIKERS
					SetColor 0,255,0
				Case COL_LEVEL
					SetColor 0,0,255
				Case COL_INFO
					SetColor 0,0,255
			End Select
		Case 1 'level 17-32
			Select c
				Case COL_BULLETS
					SetColor 255,255,255
				Case COL_CLAW
					SetColor 0,255,0
				Case COL_TANKERS
					SetColor 0,0,255
				Case COL_FLIPPERS
					SetColor 255,0,255
				Case COL_PULSARS
					SetColor 255,255,0
				Case COL_SPIKERS
					SetColor 0,255,255
				Case COL_LEVEL
					SetColor 255,0,0
				Case COL_INFO
					SetColor 255,0,0
			End Select		
		Case 2 'level 33-48
			Select c
				Case COL_BULLETS
					SetColor 255,255,255
				Case COL_CLAW
					SetColor 0,0,255
				Case COL_TANKERS
					SetColor 0,255,255
				Case COL_FLIPPERS
					SetColor 0,255,0
				Case COL_PULSARS
					SetColor 255,0,255
				Case COL_SPIKERS
					SetColor 255,0,0
				Case COL_LEVEL
					SetColor 255,255,0
				Case COL_INFO
					SetColor 255,255,0
			End Select		
		Case 3 'level 49-64			
			Select c
				Case COL_BULLETS
					SetColor 255,255,255
				Case COL_CLAW
					SetColor 0,0,255
				Case COL_TANKERS
					SetColor 255,0,255
				Case COL_FLIPPERS
					SetColor 0,255,0
				Case COL_PULSARS
					SetColor 255,255,0
				Case COL_SPIKERS
					SetColor 255,0,0
				Case COL_LEVEL
					SetColor 0,255,255
				Case COL_INFO
					SetColor 0,255,255
			End Select

		Case 4 'level 65-80
			Select c
				Case COL_BULLETS
					SetColor 255,255,255
				Case COL_CLAW
					SetColor 255,255,0
				Case COL_TANKERS
					SetColor 255,0,255
				Case COL_FLIPPERS
					SetColor 255,0,0
				Case COL_PULSARS
					SetColor 0,255,255
				Case COL_SPIKERS
					SetColor 0,255,0
				Case COL_LEVEL
					SetColor 0,0,0
				Case COL_INFO
					SetColor 0,0,255
			End Select
		
		Case 5 'level 81-96
			Select c
				Case COL_BULLETS
					SetColor 255,255,255
				Case COL_CLAW
					SetColor 255,0,0
				Case COL_TANKERS
					SetColor 255,0,255
				Case COL_FLIPPERS
					SetColor 255,255,0
				Case COL_PULSARS
					SetColor 0,255,255
				Case COL_SPIKERS
					SetColor 0,0,255
				Case COL_LEVEL
					SetColor 0,255,0
				Case COL_INFO
					SetColor 0,255,0
			End Select
		
	End Select			

End Function








Function ClearLevel()

	' delete all eggs and baddies
	Local e:egg
	For e = EachIn EGG_LIST
		EGG_LIST.Remove(e)
	Next
	
	Local b:Baddies
	For b = EachIn BADDIE_LIST
		BADDIE_LIST.Remove(b)
	Next

	Local s:shot
	For s=EachIn SHOT_LIST
		SHOT_LIST.remove(s)
	Next

	Local p:Point
	For p=EachIn POINT_LIST
		POINT_LIST.Remove(p)
	Next
	
	For Local a = 0 Until 16
		theLevel.Edges[a] = Null
	Next
	theLevel.E_cnt = 0

	eggsleft = 0
	enemiesleft = 0
	hatchingeggs = 0	

End Function




Function SetUpLevel()

	Local p1:Point = Null
	Local p2:Point = Null
	Local fp:Point = Null
	
	theLevel.continuous = leveldata[current_board+tubes,0]
	k = 70
	CCenterY = leveldata[current_board+tubes,1]
	YOFFSET =  leveldata[current_board+tubes,2]

	For Local a = 0 Until 16
		p1 = theLevel.AddPoint( Float(leveldata[current_board+tubes,3+a*2]),Float(leveldata[current_board+tubes,3+a*2+1]))
		If p2
			theLevel.AddEdge(p1,p2)
		Else
			fp = p1
		EndIf
		p2=p1
	Next
	If theLevel.continuous
		Local lastedge:edge = theLevel.AddEdge(fp,p2)
	EndIf
		
End Function



Function SetUpEnemies()

	Local lv = current_level

	enemiesleft = 0
	eggsleft = 10+lv*2+current_board*2
	If eggsleft > 100 Then eggsleft = 100
	maxeggs = eggsleft
	For Local t = 0 To 3
		eggsleft:-1
		Egg.Create(Rand(0,theLevel.e_cnt-2+(theLevel.continuous)))
	Next
	
	theLevel.hasflippers = True
	theLevel.hastankers = False
	theLevel.hasspikes = False
	theLevel.hasfuseballs = False
	theLevel.haspulsars = False
	theLevel.hastankersp = False
	theLevel.hastankersf = False
		
	If current_board > 2 Or lv > 47 Then theLevel.hasspikes = True
	If lv > 9 Then theLevel.hasfuseballs = True
	If lv > 1 Then theLevel.hastankers = True
	If lv > 15 Then theLevel.haspulsars = True
	If lv > 20 Then theLevel.hastankersp = True
	If lv > 31 Then theLevel.hastankersf = True

	If theLevel.hasspikes
		For Local a = 0 To theLevel.e_cnt-1
			Spikes.Create(a,60.0)
		Next
	EndIf
	
	enemyreleaserate = 60
	hatchrate = lv/8
	rimit = False

	flipflipspeed = 15+lv/5  'degrees
	pulseflipspeed = 15+lv/9
	fuseclimbspeed = lv/2  ' not used yet
	
	If lv = 0 Then canflip = False Else canflip = True
	
	hatchingeggs = 0

End Function










Function ReadFuseballData()

	Local x,y

	For Local frame = 0 To 3
		For Local arm = 0 To 4
			For Local i = 0 To 5
				ReadData x
				ReadData y
				fusex[frame,arm,i] = Float(x)/6.0
				fusey[frame,arm,i] = Float(y)/6.0
			Next
		Next
	Next

End Function

DefData 0,0, 7,-5, 6,-8, 9,-10, 7,-13, 11,-15
DefData 0,0, 6,3, 6,6, 10,4, 12,4, 13,12
DefData 0,0, 2,7, -4,10, 1,14, -4,17, 1,20
DefData 0,0, -7,4, -7,1, -9,1, -11,6, -14,8
DefData 0,0, -4,-5, -3,-10, -5,-13, -9,-13, -9,-15

DefData 0,0, 6,-8, 5,-11, 9,-14, 7,-18, 6,-20
DefData 0,0, 7,-3, 6,6, 10,6, 6,11, 11,16
DefData 0,0, -3,8, -7,6, -5,12, -7,17, -3,21
DefData 0,0, -6,3, -7,-4, -10,2, -11,-4, -18,4
DefData 0,0, -3,-6, 2,-11, -4,-13, 2,-16, -2,-21

DefData 0,0, 5,-8, 7,-7, 7,-12, 10,-16, 14,-14
DefData 0,0, 7,1, 8,5, 11,6, 10,9, 14,10
DefData 0,0, -5,6, -6,11, -3,11, -6,16, -6,19
DefData 0,0, -6,1, -8,4, -11,3, -14,5, -16,6
DefData 0,0, -2,-8, -7,-8, -5,-14, -8,-14, -10,-11

DefData 0,0, 6,-6, 7,-12, 11,-6, 12,-12, 16,-12
DefData 0,0, 6,5, 6,8, 11,9, 12,14, 16,14
DefData 0,0, -3,6, -4,10, -9,11, -6,18, -9,21
DefData 0,0, -4,2, -6,1, -7,2, -12,1, -15,6
DefData 0,0, 1,-11, 3,-8, 5,-14, 3,-17, 6,-24




Function ReadLevelData()

	Local l,t,v
	
	For Local l = 0 To 47
		For Local t = 0 To 34
			ReadData v
			leveldata[l,t] = v
		Next
	Next

End Function


Include "boarddata.bmx"
