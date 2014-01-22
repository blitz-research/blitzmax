'Tempest
'Coded by David Bird
Strict

Const CWidth#=640
Const CHeight#=480
Const K# = 50

Global CCenterX#=CWidth/2.0
Global CCenterY#=(CHeight/3.0)'*2

Global SHOT_LIST:TList = New TList
Global theLevel:Level

Function TFormSZ#(x#, z#)
  z:+5
  Return (x/(z/K))
EndFunction

Function TForm(x#, y#, z#, x2d# Var, y2d# Var )
  z:+5
  y:+100
  x2d = CCenterX+(x/(z/K))
  y2d = CCenterY+(y/(z/K))
EndFunction

'Setup Graphics mode
Graphics CWidth,CHeight,32

HideMouse


Global MainPlayer:Player

Type Player
  Field e_Index        'the edge the player is on
  Field zPos

  Field scl#=0.5          'where on the edge 0-1

  Method SetEdge(index)
    e_index = index
  EndMethod

  Method AddShot()
    Shot.Create(theLevel.edges[e_Index])
  EndMethod

  Method ShiftLeft()
    If e_Index=0
      e_Index = theLevel.e_Cnt-1
    Else
      e_Index:-1
    EndIf
  EndMethod

  Method ShiftRight()
    If e_Index=theLevel.e_cnt-1
      e_Index = 0
    Else
      e_Index:+1
    EndIf
  EndMethod

  Method Update()
    'Control it
    If KeyHit(KEY_SPACE) self.AddShot()

    If KeyDown(KEY_LEFT)
      scl:-0.1
      If scl<0 Then
        self.ShiftLeft()
        scl:+1
      EndIf
    EndIf
    If KeyDown(KEY_RIGHT)
      scl:+0.1
      If scl>1 Then
        self.ShiftRight()
        scl:-1
      EndIf
    EndIf
    SetRotation 0
    'Draw it
    SetColor 255,255,0
    Local zz#
    Local x#[3],y#[3]
    Select theLevel.state
      Case Level_Begin
        zz# = theLevel.position
      Case Level_Ready
        zpos=theLevel.position
        zz = zpos
      Case Level_Complete
        zz = zpos
    EndSelect


    Local zh# = 4
    Local e:Edge = theLevel.edges[e_Index]
    TForm e.p1.x, e.p1.y, zz,x[0],y[0]

    TForm e.p2.x+ ( (e.p1.x - e.p2.x) * scl ), e.p2.y+ ( (e.p1.y - e.p2.y) * scl ),zz-zh,x[1],y[1]

    TForm e.p2.x, e.p2.y, zz,x[2],y[2]
    DrawLine x[0],y[0],x[1],y[1]
    DrawLine x[1],y[1],x[2],y[2]
  EndMethod


  Function Create:Player()
    Local p:Player = New Player

    Return p
  EndFunction
EndType

Type Point
  Field x#,y#
  Field e0:edge
  Field e1:edge

  Function Create:Point( x#, y# )
    Local p:Point = New Point
    p.x=x
    p.y=y
    Return p
  EndFunction

EndType

Type Edge
  Field p1:point
  Field p2:point

  Field xx#,yy#

  Method Draw( zd1#, zd2# )
    If zd1<1 zd1=1
    If zd2<1 zd2=1

    'draw the edge at zero position,
    'the depth line and the far point
    Local x#[4],y#[4]
    TForm p1.x,p1.y,zd1, x[0],y[0]
    TForm p1.x,p1.y,zd2, x[1],y[1]

    TForm p2.x,p2.y,zd1, x[2],y[2]
    TForm p2.x,p2.y,zd2, x[3],y[3]

    DrawLine x[0],y[0],x[1],y[1]
    DrawLine x[0],y[0],x[2],y[2]
    DrawLine x[1],y[1],x[3],y[3]
    DrawLine x[3],y[3],x[2],y[2]
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

Const Level_Begin    = 0
Const Level_Complete = 1
Const Level_Ready    = 2

Type Level
  Field depth#    = 400
  Field position# = 1500
  Field move#     = 0
  Field state     = Level_Begin

  Field points:TList
  Field edges:Edge[10],e_cnt,e_cap=10

  Method AddPoint:Point(x#,y#)
    Local p:Point = Point.Create( x, y )
    points.AddLast( p )
    Return p
  EndMethod

  Method AddEdge:Edge( p1:Point, p2:point )
    Local e:Edge = Edge.Create( p1, p2 )
    If e_cnt>=e_cap
      e_cap:+10
      edges=edges[..e_cap]
    EndIf
    edges[e_cnt] = e
    e_cnt:+1
    Return e
  EndMethod

  Method Update()
    Select state
      Case Level_Begin
        If position>50
          position:-10
        Else
          state=Level_Ready
        EndIf
      Case Level_Ready

      Case Level_Complete
        position:-10
    EndSelect

  EndMethod

  Method Draw()
    Local a=0
    Select state
      Case Level_Begin

      Case Level_Ready

      Case Level_Complete
    EndSelect
    SetRotation 0
    SetColor 0,0,100
    For a=0 Until e_cnt
      edges[a].Draw(position,position+depth)
    Next
  EndMethod

  Function Create:Level()
    Local l:Level = New Level
    l.points = New TList

    Return l
  EndFunction
EndType

Type Shot
  Field e:edge  ' the edge its on
  Field z#      ' its position
  Field r#      ' rotation
  Field xx#,yy#

  Method Draw()
    SetColor Rand(255),Rand(255),Rand(255)
    Local zz = z+theLevel.position
    Local sz = TFormSZ(10,zz)
    Local pxx#,pyy#

    TForm(xx,yy,zz,pxx,pyy)

    For Local a=0 Until 360 Step 45
      SetRotation r+a
      DrawLine pxx+sz,pyy,pxx-sz,pyy
    Next
    r:+15
    SetRotation 0
  EndMethod

  Method Update()
    z:+5
    Local bad:Baddies
    If z>theLevel.depth
      SHOT_LIST.Remove(Self)
      Return
    Else
      'check for collisions
      For bad = EachIn BaddieList
        If bad.CheckColl(e,z)
          SHOT_LIST.Remove(Self)
          Return
        EndIf
      Next
    EndIf

  EndMethod

  Function Create:Shot(e:Edge)
    Local ns:Shot = New Shot
    ns.e = e
    ns.xx =e.xx
    ns.yy =e.yy
    ns.z  = -5
    SHOT_LIST.AddLast( ns )
    Return ns
  EndFunction
EndType

Function UpdateShots()
  Local s:shot
  For s=EachIn SHOT_LIST
    s.Update
  Next
  For s=EachIn SHOT_LIST
    s.Draw()
  Next
EndFunction

Global BaddieList:Tlist = New TList

Function UpdateBaddies()
  Local b:Baddies
  For b = EachIn Baddielist
    b.Update()
  Next
  For b = EachIn Baddielist
    b.Draw()
  Next
EndFunction

Type Baddies
  Field OnEdge:Edge

  Method Update() Abstract
  Method Draw() Abstract
  Method CheckColl(e:edge,z#) Abstract
EndType

Type Crawler Extends Baddies
  Field EdgeIndex 'used to traverse theLevel edgelist
  Field typ       '0 just slide up the tube
                  '1 rolls round the tube

  Field Pause     'the pause before changing edge
  Field dir       'direction left or right
  Field angle     'the angle when changing lanes

  Method Update()
  EndMethod
  Method Draw()
  EndMethod
  Method CheckColl(e:edge,z#)
  EndMethod

  Function Create:Crawler(index,typ = 0)
    Local c:Crawler = New Crawler
    c.OnEdge = theLevel.edges[index]
    c.typ    = typ
    BaddieList.AddLast c
    Return c
  EndFunction
EndType

Type Spikes Extends Baddies
  Field height#=0
  Field grow_speed#

  Method CheckColl(e:edge,z#)
    'check to see if any will hit
    Local sp# = theLevel.Depth-height
    If e = OnEdge
      If z>sp
        height:-40
        If height<0
          BaddieList.Remove(Self)
          Return True
        EndIf
        Return True
      EndIf
    EndIf
    Return False
  EndMethod

  Method Draw()
    Local xx#,yy#,zz1#,zz2#
    zz1 = theLevel.position+theLevel.depth
    zz2 = zz1 - height

    Local x#[2],y#[2]
    xx =( ( OnEdge.p2.x - OnEdge.p1.x ) / 2.0 ) + OnEdge.p1.x
    yy =( ( OnEdge.p2.y - OnEdge.p1.y ) / 2.0 ) + OnEdge.p1.y
    TForm(xx,yy,zz1,x[0],y[0])
    TForm(xx,yy,zz2,x[1],y[1])
    SetColor 0,255,0
    DrawLine x[0],y[0],x[1],y[1]
    SetColor 255,0,0
    Plot x[1],y[1]
  EndMethod

  Method Update()
    If height<theLevel.Depth
      height:+grow_speed
    Else
      height = theLevel.Depth
    EndIf
  EndMethod

  Function Create:Spikes(index,speed#)
    Local s:Spikes = New Spikes
    s.OnEdge=theLevel.Edges[index]
    s.height=10
    s.grow_speed# = speed
    BaddieList.AddLast s
    Return s
  EndFunction
EndType


Local a
Local p1:Point
Local p2:Point
Local fp:Point
theLevel = Level.Create()
MainPlayer = Player.Create()

For a=0 Until 360 Step 30
  p1 = theLevel.AddPoint( Cos(a)*280, Sin(a)*180 )
  If p2
    theLevel.AddEdge(p1,p2)
  Else
    fp = p1
  EndIf
  p2=p1
Next
Local lastedge:edge = theLevel.AddEdge(fp,p2)
MainPlayer.SetEdge( 0 )

For a=0 Until 10
  spikes.Create( a ,Rnd(0.5,1.0))
Next

'main loop
While Not KeyDown(KEY_ESCAPE)
  Cls
  theLevel.Update()
  theLevel.Draw()
  UpdateShots()
  UpdateBaddies()

  MainPlayer.Update()

  Flip
Wend
End

