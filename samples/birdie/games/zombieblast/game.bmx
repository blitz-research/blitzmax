Strict
'
' Game Demo Coded By David Bird (Birdie)
'
Incbin "media/sand.png"
Incbin "media/ship1.png"
Incbin "media/cloud.png"
Incbin "media/shot.png"
Incbin "media/shot2.PNG"
Incbin "media/mud.png"
Incbin "media/smoke.png"
Incbin "media/scan.png"
Incbin "media/zombie_0.png"
Incbin "media/zombie_1.png"
Incbin "media/zombie_2.PNG"
Incbin "media/zombie_3.PNG"
Incbin "media/zombie_4.PNG"
Incbin "media/zombie_5.PNG"
Incbin "media/zombie_6.png"
Incbin "media/zombie_7.PNG"
Incbin "media/Title.png"
Incbin "media/HitSpace.png"

Global C_ScreenWidth# = 640, C_ScreenHeight# = 480
Global C_ScreenMidX# =C_ScreenWidth/2
Global C_ScreenMidY# =C_ScreenHeight/2
Global MapPosition_X#=400, MapPosition_Y#=400
Global WorldSize = 8192
Global Scanner_Rot#
Global Scanner_X#= C_ScreenWidth - 80
Global Scanner_Y#= 80
Global Scanner_Scale# = 0.5
Global ObjectList:TList = New TList
Global DetailList:TList = New TList
Global CloudList:TList  = New TList
Global ScanList:TList   = New TList

Global TitleWidth#,TitleHeight#
Graphics C_ScreenWidth, C_ScreenHeight ,32
HideMouse
AutoImageFlags MASKEDIMAGE|FILTEREDIMAGE|MIPMAPPEDIMAGE

'media globals
Global media_sand:TImage
Global media_ship1:TImage
Global media_cloud:TImage
Global media_shots:TImage
Global media_shot2:TImage
Global media_mud:TImage
Global media_smoke:TImage
Global Media_scan:TImage
Global media_Title:TImage
Global media_HitSP:TImage

Global Media_zombie:TImage[8]
LoadMedia()

Local P1:Player = New Player
ObjectList.AddLast p1

'title screen

While Not KeyDown(KEY_SPACE)
  Cls
  SetBlend SOLIDBLEND
  SetColor 255,255,255
  TileImage Media_sand,MapPosition_X,MapPosition_Y
  MapPosition_X:+1
  SetRotation 0
  SetBlend ALPHABLEND
  SetColor 255,255,255
  SetAlpha 1
  SetScale TitleWidth,TitleHeight
  DrawImage Media_Title,C_ScreenMidX,C_ScreenMidY-24
  SetScale 1,1
  SetAlpha 0.5
  DrawImage media_HitSP, C_ScreenMidX, C_ScreenHeight - media_HitSP.height
  Flip
Wend

Local a
For a=0 Until 100
  cloud.Create( Rnd(-WorldSize,WorldSize), Rnd(-WorldSize,WorldSize) )
Next
For a=0 Until 250
  Baddie.Create(Rnd(-1000,1000), Rnd(-1000,1000), 0)
Next

While Not KeyDown(KEY_ESCAPE)
  Cls
  UpdateObjects()

  DrawLevel(p1)
  DrawObjects()
  DrawScanner( P1 )

  Flip
Wend
End

Function LoadMedia()
  SetHandle 0.5,0.5
  AutoMidHandle True
  media_sand  = LoadImage("incbin::media/sand.png")
  media_ship1 = LoadImage("incbin::media/ship1.png")
  media_cloud = LoadImage("incbin::media/cloud.png")
  media_shots = LoadImage("incbin::media/shot.png")
  media_shot2 = LoadImage("incbin::media/shot2.PNG")
  media_scan  = LoadImage("incbin::media/scan.png")
  media_mud   = LoadImage("incbin::media/mud.png")
  media_smoke = LoadImage("incbin::media/smoke.png")
  media_Title = LoadImage("incbin::media/Title.png")
  media_HitSP = LoadImage("incbin::media/HitSpace.png")
  
  'scale to fullscreen

  TitleWidth = media_title.width / C_ScreenWidth
  TitleHeight= media_title.height / (C_ScreenHeight+48)
  Media_zombie[0] = LoadAnimImage("incbin::media/zombie_0.png",32,64,0,17)
  Media_zombie[1] = LoadAnimImage("incbin::media/zombie_1.png",32,64,0,17)
  Media_zombie[2] = LoadAnimImage("incbin::media/zombie_2.PNG",32,64,0,17)
  Media_zombie[3] = LoadAnimImage("incbin::media/zombie_3.PNG",32,64,0,17)
  Media_zombie[4] = LoadAnimImage("incbin::media/zombie_4.PNG",32,64,0,17)
  Media_zombie[5] = LoadAnimImage("incbin::media/zombie_5.PNG",32,64,0,17)
  Media_zombie[6] = LoadAnimImage("incbin::media/zombie_6.png",32,64,0,17)
  Media_zombie[7] = LoadAnimImage("incbin::media/zombie_7.PNG",32,64,0,17)

EndFunction

Function DrawLevel(o:Entity)
  'using the object{o} position and direction to draw the map
'  MapPosition_X = MapPosition_X + ((o.x - MapPosition_X)*0.25)
'  MapPosition_Y = MapPosition_Y + ((o.y - MapPosition_Y)*0.25)
  MapPosition_X = o.x
  MapPosition_Y = o.y
  SetBlend SOLIDBLEND
  SetColor 255,255,255
  SetScale 1,1
  TileImage Media_sand,MapPosition_X,MapPosition_Y

EndFunction

Function UpdateObjects()
  Local e:Entity
  For e=EachIn ObjectList
    e.Update()
  Next
EndFunction

Function DrawObjects()
  Local e:Entity
  Local c:Cloud
  For c=EachIn CloudList
    c.Update()
  Next

  'Draw Shadows
  For e=EachIn ObjectList
    e.DrawShadow()
  Next
  'Draw Details
  Local d:Detail
  For d=EachIn DetailList
    d.Update(MapPosition_X, MapPosition_Y)
  Next


  'Draw objects without shadows
  For e=EachIn ObjectList
    e.DrawBody()
  Next

  'DrawClouds

  For c=EachIn CloudList
    c.DrawShadow()
  Next
  For c=EachIn CloudList
    c.DrawBody()
  Next

EndFunction

Type Entity
  Field x#,y#
  Field height#
  Field rotation#
  Field spd#=1

  Method Update() Abstract

  Method DrawBody() Abstract
  Method DrawShadow() Abstract
EndType

Type Player Extends Entity
  Field RotationSpd#
  Field liftSpd#
  Field thrust#
  Field osc#

  Method Update()
    If KeyDown(KEY_UP)
      thrust:+0.01
      If thrust>0.5
        thrust = 0.5
      EndIf
    EndIf
    If KeyDown(KEY_DOWN)
      thrust:-0.05
    EndIf
    spd:+thrust

    If thrust<0
      thrust = 0
    EndIf

    If spd>8
      spd=8
    EndIf
    If spd<0.5 spd = 0.5

    If KeyHit(KEY_SPACE)
      Local a,thei#
      thei = height +(3.5*Cos(osc) )

      Shots.Create x, y, spd+5, thei, rotation
      For a=0 Until 3
        Shots.Create x, y, spd+5, thei, rotation+Rnd(-1.75,1.75)
      Next
    EndIf
    Local sz#=14*(1+(height/140.0))
    Local sd#=16
    Local cs#= Cos(rotation-90)
    Local sn#= Sin(rotation-90)
    Local ddx# = sz
    Local ddy# = 9

    Local tx1# = ddx*cs + ddy*sn
    Local ty1# = ddx*sn - ddy*cs
    ddx=-ddx
    Local tx2# = ddx*cs + ddy*sn
    Local ty2# = ddx*sn - ddy*cs

    Local thei#
    thei = height +(3.5*Cos(osc) )
    Local deltasm#= ( 0.5 * (spd/8.0))
    Trail.Create( x+tx1, y+ty1, thei, deltasm, rotation )
    Trail.Create( x+tx2, y+ty2, thei, deltasm, rotation )

    Local tx#= 20 * Cos(rotation)
    Local ty#= 20 * Sin(rotation)
    Local rd= 255*thrust*2
    Local gn= rd*0.7
    Local bl= gn*0.5
    ColTrail.Create( x-tx, y-ty, thei, 0.3, rotation, [rd, gn, bl] ,2.0)

    ColTrail.Create( x-tx, y-ty, thei, 0.3, rotation, [rd*2, 0, 0] ,1.0)

    If KeyDown(KEY_RIGHT)
      rotationSpd:+0.25
      If rotationSpd>2
        rotationSpd=2
      EndIf
    EndIf
    If KeyDown(KEY_LEFT)
      rotationSpd:-0.25
      If rotationSpd<-2
        rotationSpd=-2
      EndIf
    EndIf
    rotation:+rotationSpd
    rotationSpd:*0.95

    If KeyDown(KEY_A)
      liftSpd:-0.02
      If liftSpd<-1
        liftSpd=-1
      EndIf
    EndIf
    If KeyDown(KEY_Z)
      liftSpd:+0.02
      If liftSpd>1
        liftSpd=1
      EndIf
    EndIf
    height:+liftSpd

    liftspd:*0.985

    If height<4
      height = 4
      liftspd = 0
    EndIf
    If height>50
      height = 50
      liftspd=0
    EndIf
    x=x+(spd*Cos(rotation))
    y=y+(spd*Sin(rotation))
    If x>WorldSize x=-WorldSize
    If x<-WorldSize x=WorldSize
    If y>WorldSize y=-WorldSize
    If y<-WorldSize y=WorldSize
    osc:+1
  EndMethod

  Method DrawShadow()
    Local dx#,dy#,sz#,thei#
    thei = height +(3.5*Cos(osc) )
    sz =(0.002*thei)
    SetRotation rotation+90
    SetBlend ALPHABLEND
    SetScale 0.25+sz,0.25+sz
    SetColor 0,0,0
    SetAlpha 0.5
    DrawImage media_ship1,C_ScreenMidX + (x-MapPosition_X), C_ScreenMidY + ( y - MapPosition_Y )
  EndMethod

  Method DrawBody()
    Local dx#,dy#,sz#,thei#
    thei = height +(3.5*Cos(osc) )
    sz =(0.002*thei)
    SetAlpha 1
    SetRotation rotation+90
    SetBlend MASKBLEND
    SetColor 255,255,255
    dx=thei/3.0
    dy=thei
    SetScale 0.25+sz, 0.25+sz
    DrawImage media_ship1,(x-MapPosition_X+dx) + C_ScreenMidX,(y-MapPosition_Y+dy) + C_ScreenMidY
  EndMethod
  Function Create:Player(x#,y#)
    Local p:Player = New Player
    p.x=x
    p.y=y
    p.height = 4
    p.spd=1
    ObjectList.AddFirst p
    Return p
  EndFunction
EndType

Type Cloud
  Field x#,y#,height#, rotation

  Method Update()
    x:+1
    y:+0.1
    If x>WorldSize x=-WorldSize
    If x<-WorldSize x=WorldSize
    If y>WorldSize y=-WorldSize
    If y<-WorldSize y=WorldSize
  EndMethod

  Method DrawBody()
    Local dx#,dy#
    dx=height/2.0
    dy=height
    SetBlend LIGHTBLEND
    SetAlpha 1
    SetScale 2.4,2.4
    SetRotation rotation
    SetColor 255,255,255
    DrawImage media_cloud,(MapPosition_X+dx-x) + C_ScreenMidX,(MapPosition_Y+dy-y) + C_ScreenMidY
  EndMethod

  Method DrawShadow()
    SetBlend ALPHABLEND
    SetColor 0,0,0
    SetAlpha 0.2
    SetScale 4, 4
    SetRotation rotation
    DrawImage media_cloud,(MapPosition_X-x) + C_ScreenMidX,(MapPosition_Y-y) + C_ScreenMidY
  EndMethod

  Function Create:Cloud( x#, y# )
    Local c:Cloud = New Cloud
    c.x= x
    c.y= y
    c.rotation = Rnd(360)
    c.height = 75
    CloudList.AddLast c
    Return c
  EndFunction
EndType

Type Shots Extends Entity
  Field life
  Method DrawBody()
    Local dx#,dy#
    dx=height/3.0
    dy=height
    SetBlend MASKBLEND
    SetColor 255,255,255
    SetAlpha 1
    SetScale 1, 1
    SetRotation rotation + 90
    DrawImage media_shots,(MapPosition_X+dx-x) + C_ScreenMidX,(MapPosition_Y+dy-y) + C_ScreenMidY
  EndMethod

  Method DrawShadow()
    SetBlend ALPHABLEND
    SetColor 0,0,0
    SetAlpha 0.2
    SetScale 1, 1
    SetRotation rotation + 90
    DrawImage media_shots,(MapPosition_X-x) + C_ScreenMidX,(MapPosition_Y-y) + C_ScreenMidY
  EndMethod
  Method Update()
    x=x+(spd*Cos(rotation))
    y=y+(spd*Sin(rotation))
    If x>WorldSize x=-WorldSize
    If x<-WorldSize x=WorldSize
    If y>WorldSize y=-WorldSize
    If y<-WorldSize y=WorldSize
    If life<80
      height:-0.75
    EndIf
    Trail.Create( x, y, height, 0.3, rotation )
    If height<0
      ObjectList.Remove Self
      Mud.Create(x, y, rotation)
      Local ee#
      ee=1
      SmokeEmitter.create( x#,y#, 0,ee, ee, ee )
    Else
      life:-1
      If life<0
        ObjectList.Remove Self
      EndIf
    EndIf
  EndMethod

  Function Create:Shots(x#,y#,spd#,hei#,rot#)
    Local s:Shots = New Shots
    s.x=x
    s.y=y
    s.rotation = rot
    s.spd = spd
    s.height = hei
    s.life = 100
    ObjectList.AddFirst s
    Return s
  EndFunction
EndType

Type Detail
  Field life
  Field x#,y#,rot#,alp#
  Field col[3]

  Method Update( wx#, wy# ) Abstract
EndType

Type Trail Extends Detail
  Field height#
  Field size#

  Method Update( wx#, wy# )
    Local dx#, dy#
    alp:-0.005
    If alp<0
      life = 0
    EndIf

    life:-1
    If life<0
      DetailList.Remove Self
    Else
      dx=height/3.0
      dy=height
      SetAlpha alp
      SetBlend alphablend
      SetRotation rot
      SetColor 255,255,255
      size:+0.05
      SetScale 1,size
      DrawRect (wx-x+dx)+C_ScreenMidX,(wy-y+dy)+C_ScreenMidY,10,1
    EndIf
  EndMethod

  Function Create:Trail(x#,y#,hei#,alp#,rot#)
    Local t:Trail = New Trail
    t.x=x
    t.y=y
    t.height= hei
    t.alp = alp
    t.rot = rot
    t.life= 100
    t.size= 1
    DetailList.AddLast t
  EndFunction
EndType

Type ColTrail Extends Detail
  Field height#,size#

  Method Update( wx#, wy# )
    Local dx#, dy#
    alp:-0.01
    size:*0.9
    If alp<0
      life = 0
    EndIf

    life:-1
    If life<0
      DetailList.Remove Self
    Else
      dx=height/3.0
      dy=height
      SetAlpha alp
      SetBlend LIGHTBLEND
      SetRotation rot
      SetColor Col[0],Col[1],Col[2]
      SetScale size,size
      DrawRect (wx-x+dx)+C_ScreenMidX,(wy-y+dy)+C_ScreenMidY,10,4
    EndIf
  EndMethod

  Function Create:ColTrail(x#,y#,hei#,alp#,rot#,col[],size#)
    Local t:ColTrail = New ColTrail
    t.x=x
    t.y=y
    t.height= hei
    t.alp = alp
    t.rot = rot
    t.life= 100
    t.size=size
    t.col = col
    DetailList.AddLast t
  EndFunction
EndType

Type Mud Extends Detail

  Method Update( wx#, wy# )
    SetRotation rot
    SetBlend ALPHABLEND
    If life<50
      alp = Float(life)/100.0
    EndIf
    SetAlpha alp
    SetColor 0,0,0
    SetScale 0.5,0.5

    DrawImage media_mud,(wx-x)+C_ScreenMidX,(wy-y)+C_ScreenMidY
    life:-1
    If life<0
      DetailList.Remove Self
    EndIf
  EndMethod

  Function Create:Mud(x#,y#, rot#)
    Local m:Mud = New Mud
    m.x = x
    m.y = y
    m.rot = rot
    m.alp = 0.5
    m.life = 200
    DetailList.AddLast M
  EndFunction
EndType

Type smoke_prt
  Field x#,y#,height#  'local to emitter
  Field scl#
  Field alp#
  Field dx#,dy#
  Field life
  Field rot#, rotdir#

  Method Draw( tx#, ty# )
    y:-dy
    x:+dx
    life:-1
    alp:-0.005
    scl:+0.017
    If alp<=0
      life =0
      Return
    EndIf
    SetBlend LightBlend
    SetAlpha alp
    SetScale scl,scl
    SetRotation rot
    rot:+rotdir
    DrawImage media_smoke, tx+x, ty+y
  EndMethod

  Function Create:smoke_prt(scl#,alp#,x#,y#,dx#,dy#,life)
    Local s:Smoke_prt = New Smoke_prt
    s.x=x
    s.y=y
    s.dx=dx
    s.dy=dy
    s.life=life
    s.alp=alp
    s.scl=scl
    s.rotdir = Rnd(-4,4)
    s.rot = Rnd(360)
    Return s
  EndFunction
EndType

Type SmokeEmitter Extends Detail
  Field smlist:TList = New TList

  Field rd#,gn#,bl#, max_cnt=50, cur_cnt

  Method Update( wx#, wy# )
    Local sp:smoke_prt
    SetColor 255*rd,255*gn,255*bl
    For sp=EachIn smlist
      sp.Draw((wx-x)+C_ScreenMidX, (wy-y)+C_ScreenMidY)
      If sp.life<0
        'remove it and add another
        smlist.remove sp
        cur_cnt:-1
      EndIf
    Next
    If cur_cnt<max_cnt
      smlist.addfirst( smoke_prt.Create( 0.2, 0.3, 0, 0, Rnd( -0.1, 0.1 ), Rnd(0.1,1), 40 ) )
      cur_cnt:+1
    EndIf
    life:-1
    If life<0
      DetailList.Remove Self
      smlist.clear()
    EndIf
  EndMethod

  Function Create:SmokeEmitter(x#,y#, rot#,cr#,cg#,cb#)
    Local sm:SmokeEmitter = New SmokeEmitter
    sm.x = x
    sm.y = y
    sm.rot = rot
    sm.alp = 0.20
    sm.life = 50
    sm.rd=cr
    sm.gn=cg
    sm.bl=cb

    DetailList.AddLast sm
  EndFunction
EndType

Type Baddie Extends Entity
  Field frame = 0
  Field frm_p = 2
  Field frm_t = 0
  Field direct= 0
  Field life

  Method Update()
    frm_t:+1
    If frm_t>frm_p
      frm_t= 0
      frame:+1
      If frame = 17 frame = 0
    EndIf
    x=x+(spd*Cos(rotation-90))
    y=y+(spd*Sin(rotation-90))
    If x>WorldSize x=-WorldSize
    If x<-WorldSize x=WorldSize
    If y>WorldSize y=-WorldSize
    If y<-WorldSize y=WorldSize

    spd=0.3
    rotation:+1
    If rotation<0 rotation:+360
    If rotation>=360 rotation:-360
    direct = rotation / 45
  EndMethod
  Method DrawShadow()
    Local dx = -12
    Local dy = -4
    SetBlend alphaBlend
    SetColor 0,0,0
    SetAlpha 0.3
    SetRotation -30
    SetScale 0.43,0.47
    DrawImage Media_zombie[direct],(MapPosition_X-x) + C_ScreenMidX+dx,(MapPosition_Y-y) + C_ScreenMidY+dy, frame

  EndMethod
  Method DrawBody()
    SetBlend alphaBlend
    SetColor 255,255,255
    SetAlpha 1
    SetRotation 0
    SetScale 0.4,0.4
    DrawImage Media_zombie[direct],(MapPosition_X-x) + C_ScreenMidX,(MapPosition_Y-y) + C_ScreenMidY, frame

  EndMethod

  Function Create:Baddie(x#,y#,spd#)
    Local s:Baddie = New Baddie
    s.x=x
    s.y=y
    s.rotation = Rand(350)
    s.spd = Rnd(1,2)
    s.height = 0
    s.life = 100
    ObjectList.AddFirst s
    Return s
  EndFunction

EndType

Type Scan_Object
  Field alp#,x#,y#,typ
  Method Update(cx#, cy#)
    alp:-0.01
    If alp<0
      ScanList.Remove Self
    Else
      SetAlpha alp
      DrawRect cx+x,cy+y,5,5
    EndIf
  EndMethod
  Function Create:Scan_Object(x#, y#, typ )
    Local so:Scan_Object = New Scan_Object
    so.x=x
    so.y=y
    so.typ=typ
    so.alp=0.4
    ScanList.AddLast so
  EndFunction
EndType

Function DrawScanner(p:Player) 'according to a certain player
  SetBlend LightBlend
  SetColor 255,255,255
  SetAlpha 0.5
  SetRotation Scanner_Rot+90
  Scanner_rot:-5
  If scanner_rot<0 scanner_rot:+360

  SetScale Scanner_Scale,Scanner_Scale
  DrawImage media_scan,Scanner_X,Scanner_Y
  Local b:Baddie
  Local so:Scan_Object
  Local dx#,dy#,ang#,ln#

  For b=EachIn ObjectList
    'get angle to object
    dx=p.x-b.x
    dy=p.y-b.y
    ln=Sqr(dx*dx+dy*dy)
    If ln<1200
      ang = ATan2(dx,dy)
      If ang<0 ang=360+ang
      If Abs(ang-(Scanner_rot))<2
        'add a new dot on the scanner
        Scan_Object.Create(dx/20.0, dy/20.0, 0 )
      EndIf
    EndIf
  Next
  SetBlend LightBlend
  SetAlpha 0.25
  SetColor 48,64,48
  SetRotation 0
  DrawRect Scanner_X-64,Scanner_Y-64,256,256
  SetColor 0,255,0
  For so=EachIn ScanList
    so.Update(scanner_x,Scanner_Y)
  Next
EndFunction


