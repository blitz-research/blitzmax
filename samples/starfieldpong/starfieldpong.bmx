Strict
Const WIDTH=640,HEIGHT=480,DEPTH=32
Const Star_Count 	= 1000	       ' Stars Count
Const MAX_SIZE		= 12	         ' Maximum starts
Const MAX_ROTSPD#	= 1.5	         ' How much rotation goin on

Global Delta_X#,Delta_Y#, Delta_Ang#=0 ,tick#=0

Type TEntity
	Field x#,y#
	Method Update() Abstract
EndType

Type Star Extends TEntity
	Field s#
	Field size#
	Field col#,alp#
	Field rot#
	Field tcol[3]
	Field vtype

	Method Update()
		Local cs# , sn#
		Local tx# , ty#

		x:+ ( x-319.99999 ) / s
		y:+ ( y-239.99999 ) / s

		x=x-320
		y=y-240
		
		cs = Cos(Delta_Ang)
		sn = Sin(Delta_Ang)

		tx = x
		ty = y

		x = tx * cs - ty * sn
		y = tx * sn + ty * Cs

		x=x +320
		y=y +240

		'Pitch Horiz and Verti
		x = x + Delta_X / s
		y = y + Delta_Y / s

		If x<0 Or x>WIDTH
			x=Rnd(WIDTH)
			alp=0
		EndIf
		If y<0 Or y>HEIGHT
			y=Rnd(HEIGHT)
			alp=0
		EndIf
		If alp<1
			alp = alp + .05
			EndIf
		SetBlend LIGHTBLEND
		SetRotation rot
		SetAlpha alp
		rot=rot+5
		SetColor tcol[0],tcol[1],tcol[2]
		Select vtype
			Case 0
				SetHandle size*.5,.5
				DrawRect x,y,size,1
				SetHandle .5,size*.5
				DrawRect x,y,1,size
				SetHandle 0,0
			Case 1
				SetHandle size*.5,size*.5
				DrawRect x,y,size,size
				SetHandle 0,0
		End Select
	End Method

	Function CreateStar:Star()
		Local s:Star = New Star
		Local r =Rand(128)
		s.x=Rnd(640)
		s.y=Rnd(480)
		s.s=Rnd(150,250)
		s.tcol=[r,r,r]
		s.size = Rnd(1,MAX_SIZE)
		s.vtype = Rnd(1)
		Return s
	EndFunction
End Type

Function UpdateEntities( list:TList )
	Delta_X = 400*Cos(tick)
	Delta_Y = 400*Sin(tick)

	Delta_Ang = MAX_ROTSPD*Cos( tick )
	tick=tick+.5
	Local c:TEntity
  For c=EachIn list
		c.Update
	Next
End Function

Graphics WIDTH,HEIGHT,DEPTH
HideMouse

Local StarList:TList = New TList
Local a

Local px1#=30,py1#
Local px2#=WIDTH-30,py2#
Local bx#=WIDTH/2, by#=HEIGHT/2
Local bdx#=Rnd(-8,4)
Local bdy#=3
Local sc1,sc2


For a= 0 To Star_Count-1
	StarList.AddLast( star.CreateStar() )
Next

While Not KeyHit( KEY_ESCAPE )
	Cls
	UpdateEntities StarList

  py1=MouseY()
	If py1<40 py1=40
	If py1>HEIGHT-40 py1=HEIGHT-40

	SetBlend SOLIDBLEND
	SetColor 255,0,0
	SetRotation 0
	SetHandle 5,40
	DrawRect px1,py1,10,80

	DrawRect px2,py2,10,80
	SetHandle 0,0
  SetColor 0,0,255
	SetHandle 2.5,2.5
	DrawRect bx,by,5,5
	SetHandle 0,0


  bx=bx+bdx
  by=by+bdy
  If by<3 bdy=-bdy
  If by>HEIGHT-3 bdy=-bdy

  'check players paddle
  If bx<px1+10
    If by>py1-40 And by<py1+40
      bdx=-bdx*Rnd(1.1,1.2)
      bdy=-bdy+Rnd(-1,1)
    EndIf

  EndIf

  If bx>px2-10  And bx<px2+10
    If by>py2-40 And by<py2+40
      bdx=-bdx*Rnd(1.1,1.2)
      bdy=-bdy+Rnd(-1,1)
    EndIf
  EndIf

  If bx>WIDTH-3 Or bx<3
    bdx= Rnd(-8,8)
    bdy= Rnd(-8,8)
    If bx>Width-3
      sc1:+1
    Else
      sc2:+1
    EndIf
    bx=width/2
    by=height/2
  EndIf

  If py2<by
    If py2<HEIGHT-40
      py2=py2+3
    EndIf
  EndIf
  If py2>by
    If py2>40
      py2=py2-3
    EndIf
  EndIf
  DrawText sc1,width/2-40,0
  DrawText sc2,width/2+40,0

	Flip
Wend
