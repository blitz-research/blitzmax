
Strict

Const WIDTH = 640,HEIGHT = 480, DEPTH = 32
Const ShadowOn   = 1
Const ShadowSize = 10

Global gtime
Global Pipes_img:TImage
Global Tiles_img:TImage
Global logo_img:TImage
Global paddle:TImage
Global ballvis:TImage
'Setup the level
Global Tilelist:TList
Global Balllist:TList
Global playerX#,PlayerY#
Global Score

Private
  Global ballcount=0

  Function Minf#(a#,b#)
    If a<b Return a
    Return b
  EndFunction
  Function Maxf#(a#,b#)
    If a>b Return a
    Return b
  EndFunction
Public

Type ball
  Field x#,y#
  Field dx#,dy#,spd#,rot#=0

  Field visual

  Method Update()
    x:+ (dx * spd)
    y:+ (dy * spd)
    If x<34 Or x>606
      dx=-dx
    EndIf
    If y<50
      dy=-dy
    EndIf
    If y>Height-8
      ballcount:-1
      BallList.Remove(Self)
    Else
      If dy>0
        If y>playery-8
          If x>playerx-32 And x<playerx+32
            dy=dy*-1
          EndIf
        EndIf
      EndIf
      rot:+10
    EndIf
  EndMethod

  Method Draw(offx,offy)
    SetRotation rot
    DrawImage ballvis,x+offx,y+offy
    SetRotation 0
  EndMethod

  Function Create:Ball(x=Width/2 , y=Height/2)
    Local b:Ball = New Ball
    ballcount:+1
    b.x = x
    b.y = y
    b.dx = Rnd(-2, 2)
    b.dy = Rnd(-2, 2)
    b.spd = 4'0.1
    Return b
  EndFunction
EndType

'all tiles are a standard size so
Type Tile
  Field x#,y#
  Field typ = 0
  Field state = 0
  Field rot#=0,size#=1

  Method Draw(offx,offy)
    Select state
      Case 0
        SetRotation rot
        If size>1
          SetScale size,size
          size=size*0.9
        Else
          size = 1
          SetScale 0.95+(0.05*Cos(gTime)),0.95+(0.05*Sin(gTime))
        EndIf
      Case 1
        SetRotation rot
        SetScale size,size
    EndSelect
    Select typ
      Case 0
        DrawImage tiles_img,x+offx,y+offy+(2*Sin(gtime)),0
      Case 1
        DrawImage tiles_img,x+offx,y+offy+(2*Sin(gtime)),1
      Case 2
        DrawImage tiles_img,x+offx,y+offy+(2*Sin(gtime)),2
      Case 3
        DrawImage tiles_img,x+offx,y+offy+(2*Sin(gtime)),3
      Case 4
        DrawImage tiles_img,x+offx,y+offy+(2*Sin(gtime)),4
    EndSelect

    SetScale 1,1
    SetRotation 0
  EndMethod

  Method Update()
    Local c
    Local b:Ball
    If state = 0
      'Check this tile for collision with all of the balls
      For b=EachIn BallList
        If b.x>x-4 And b.x<x+24
          If b.y>y-4 And b.y<y+24
            b.dy=-b.dy
            Select typ
              Case 1
                If ballcount=1
                  For c=0 Until 2
                    BallList.AddLast(ball.Create(b.x,b.y))
                  Next
                EndIf
                state = 1
                size = 1
              Case 2
                typ = 3
                size=1.5
              Case 3
                typ = 4
                size=1.5
              Default
                Score:+((1+typ)*100)
                state = 1
            EndSelect
            Return
          EndIf
        EndIf
      Next
    Else
      y:+4
      rot:+5
      size:-.005
      If y>HEIGHT
        BallList.Remove(b)
      EndIf
    EndIf
  EndMethod


  Function Create:Tile(x=0,y=0,typ=0)
    Local t:Tile = New Tile
      t.x=x
      t.y=y
      t.typ = typ
      Return t
  EndFunction
EndType

Graphics WIDTH,HEIGHT,DEPTH

AutoMidHandle True

'Media
Global back:TImage[2]
back[0] = LoadImage("media\back1.png")
back[1] = LoadImage("media\back2.png")
Pipes_img=LoadAnimImage("media\pipes.png",32,32,0,4)
Tiles_img=LoadAnimImage("media\tiles.png",32,20,0,5)
paddle = LoadImage("media\paddle.png")
ballvis = LoadImage("media\ball.png")
logo_img=LoadImage("media\B-Max.png")


Tilelist:TList = New TList
Balllist:TList = New TList
playerX# = Width/2
PlayerY# = Height-40
Score=0

ResetGame()



HideMouse
While Not KeyDown(KEY_ESCAPE)

	'Update Players Position
	playerx = minf(574,maxf(64,MouseX()))
	'Update Balls
	UpdateBalls()
	'Update Tiles
	UpdateTiles()
	'Draw Level
	DrawLevel()

	gTime:+10

	SetAlpha .75
	SetColor 0,0,255
	DrawRect 0,0,Width,20

	SetBlend ALPHABLEND

	SetAlpha 0.5
	SetColor 0,0,0
	DrawText "Score:"+Score,4,4

	SetAlpha 1
	SetColor 255,255,255
	DrawText "Score:"+Score+" "+ballcount,2,2

	Flip
Wend

End


Function DrawLevel()
  Local w,aa#
  TileImage back[1],0,gTime/20
  SetBlend ALPHABLEND
  DrawImage logo_img,width/2,height/2
  aa#=0.5+(0.5*Cos(gtime/50))
  SetBlend AlphaBLEND
  SetAlpha aa
  TileImage back[0],0,gTime/10

  If ShadowOn
    SetColor 0,0,0
    SetBlend AlphaBLEND
    SetAlpha 0.5
    DrawPipes ShadowSize+16,ShadowSize+16

    DrawTiles ShadowSize+16,ShadowSize+10
    DrawPlayer ShadowSize,ShadowSize
    DrawBalls ShadowSize,ShadowSize
  EndIf

  SetColor 255,255,255
  SetBlend MASKBLEND
  SetAlpha 1
  DrawPipes()
  DrawTiles()
  DrawPlayer()
  DrawBalls()
EndFunction

Function ResetGame()
  TileList = New TList
  BallList = New TList
  Local x,y
  For y=0 Until 5
    For x=0 Until 18
        Tilelist.AddLast(Tile.Create(38+x*32,(y*24)+66,4-Y))
    Next
  Next

  BallList.AddLast(Ball.Create())
EndFunction

Function DrawPipes(x=16,y=16)
  Local tmp

  'top
  For tmp=0 Until 18
    DrawImage Pipes_img,x+32+(tmp*32),y+16,3
  Next

  'sides
  For tmp=0 Until 14
    DrawImage Pipes_img,x,y+48+(tmp*32),2
    DrawImage Pipes_img,x+Width-32,y+48+(tmp*32),2
  Next

  'Corners
  DrawImage Pipes_img,x,y+16 ,0
  DrawImage Pipes_img,x+Width-32,y+16,1

EndFunction

Function DrawTiles(x_off=10, y_off=10)
	Local tl:Tile
	Local any=0
  For tl=EachIn TileList
		tl.Draw(x_off, y_off)
		any=1
	Next
	If Not any 
	 ResetGame()
	 score:+10000
	EndIf
EndFunction

Function DrawBalls(x_off=0, y_off=0)
	Local bl:Ball
	For bl=EachIn balllist
		bl.Draw(x_off, y_off)
	Next
EndFunction

Function UpdateBalls()
  If ballcount=0
    BallList.AddLast(Ball.Create(Width/2,Height/2))
  Else
  	Local bl:Ball
  	For bl = EachIn BallList
  		bl.Update()
  	Next
  EndIf
EndFunction

Function UpdateTiles()
	Local tl:Tile
	For tl=EachIn tilelist
		tl.Update()
	Next
EndFunction

Function DrawPlayer(x_off=0,y_off=0)
  DrawImage paddle, playerx+x_off, playery+y_off
End Function
