Strict
Incbin "media/back.png"
Incbin "media/blocks.png"            
Incbin "media/part.png"
Incbin "media/pointer.PNG"
Incbin "media/shine.png"

Graphics 640,480
Global backIm:TImage = LoadImage("incbin::media/back.png")
AutoMidHandle 1
Global blocks:TImage = LoadAnimImage("incbin::media/blocks.png",32,32,0,16)
Global partImg:TImage = LoadImage("incbin::media/part.png")
Global mousePoint:TImage= LoadImage("incbin::media/pointer.PNG")
Global shine_img:TImage = LoadImage("incbin::media/shine.png")
AutoMidHandle 0
Global Map[8,14]
Global t1x,t1y,t2x,t2y
Global mouse_left_state
Global selection_done
Global rotation# = 0
Global Center_X#
Global Center_Y#
Global mt1,mt2
Global Tile_Rad#
Global THE_Axis
Global FLIPSPEED=8
Global Scn_Flash#=0
Global shine_pos#=0

HideMouse
While Not KeyDown(KEY_ESCAPE)
  Cls
  DrawLayout()
  If selection_done =0
    FillGrid()
  EndIf

  DrawGrid()

  If selection_done
    do_swap_tiles()
  Else
    UpdateSelection()
  EndIf

  SetBlend MASKBLEND
  DrawText mouse_left_state,0,0
  DrawText t1x+","+t1y,0,12
  DrawText t2x+","+t2y,0,23
  DrawImage mousePoint,MouseX(),MouseY()
  Flip
Wend

End
Function UpdateSelection()
  Local x=MouseX()-192
  Local y=MouseY()-24
  Local dx,dy

  If MouseDown(1)
    Select mouse_left_state
      Case 0
        If x>=0 And x<256
          If y>=0 And y<448
            'select tile1
            t1x=Floor(x/32.0)
            t1y=Floor(y/32.0)
          EndIf
        EndIf
        'get tile 1
        mouse_left_state=1
      Case 2
        If x>=0 And x<256
          If y>=0 And y<448
            'select tile1
            t2x=Floor(x/32.0)
            t2y=Floor(y/32.0)
          EndIf
        EndIf
        mouse_left_state=3
    EndSelect
  Else
    Select mouse_left_state
      Case 1
        mouse_left_state=2
      Case 3
        'check that only 1 tile away and not diag
        dx=Abs(t2x-t1x)
        dy=Abs(t2y-t1y)
        If dx=1 And dy=0
'          Switch(t1x,t1y,t2x,t2y)
          selection_done=1
        ElseIf dx=0 And dy=1
'          Switch(t1x,t1y,t2x,t2y)
          selection_done=1
        EndIf
          mouse_left_state=0
      Case 99
        mouse_left_state=0
    EndSelect
  EndIf

EndFunction

'add tiles to array at the top
Function FillGrid()
  Local x,y,tl,tlc
  For x=0 Until 8
    If map[x,0]=0
      map[x,0]=1+Rnd(1)*7'15
    EndIf
  Next
  'Fall
  For y=12 To 0 Step -1
    For x=0 Until 8
      If map[x,y]>0
        If map[x,y+1]=0
          map[x,y+1]=map[x,y]
          map[x,y]=0
        EndIf
      EndIf
    Next
  Next

  For y=0 Until 14
    For x=0 Until 8
      tl=map[x,y]
      If tl>0
        If Counttile(x,y,tl,0,tlc)
          KillTiles(x,y,tlc,0)
        ElseIf Counttile(x,y,tl,1,tlc)
          KillTiles(x,y,tlc,1)
        ElseIf Counttile(x,y,tl,2,tlc)
          KillTiles(x,y,tlc,2)
        ElseIf Counttile(x,y,tl,3,tlc)
          KillTiles(x,y,tlc,3)
        EndIf

      EndIf
    Next
  Next
EndFunction

Function KillTiles(x,y,c,dir)
  Local d
  For d=0 Until c
    Select dir
      Case 0
        map[x,y]=0
        y:-1
      Case 1
        map[x,y]=0
        x:+1
      Case 2
        map[x,y]=0
        y:+1
      Case 3
        map[x,y]=0
        x:-1
    EndSelect
  Next
EndFunction

Function CountTile(x,y,ty,dir, cn Var)
  cn = 0
  Select dir
    Case 0 ' Up
      While y>0
        If map[x,y]=ty
          cn:+1
        Else
          Return cn>2
        EndIf
        y=y-1
      Wend
      Return cn>2
    Case 1 ' Right
      While x<8
        If map[x,y]=ty
          cn:+1
        Else
          Return cn>2
        EndIf
        x:+1
      Wend
      Return cn>2
    Case 2 ' Down
      While y<14
        If map[x,y]=ty
          cn:+1
        Else
          Return cn>2
        EndIf
        y:+1
      Wend
      Return cn>2
    Case 3 ' Left
      While x>0
        If map[x,y]=ty
          cn:+1
        Else
          Return cn>2
        EndIf
        x:-1
      Wend
      Return cn>2
  EndSelect
  cn = 0
  Return 0
EndFunction

Function DrawGrid()
  SetColor 255,255,255
  Local x,y
  For y=0 Until 14
    For x=0 Until 8
      If selection_done
        If map[x,y]>0
          If (x=t1x And y=t1y) Or (x=t2x And y=t2y)
          Else
            SetBlend MASKBLEND
            DrawImage blocks,208+x*32,32+y*32,map[x,y]-1
          EndIf
        EndIf
      Else
        If map[x,y]>0
          DrawImage blocks,208+x*32,32+y*32,map[x,y]-1
        EndIf
      EndIf
    Next
  Next
  SetViewport 0,0,640,480
EndFunction

Function DrawLayout()
  Cls
  If Scn_Flash<0
    Scn_Flash:+0.2
  Else
    Scn_Flash=0
  EndIf
    SetBlend SOLIDBLEND
    SetColor 255,255,255
  TileImage backIm,0,0
  SetColor 128,128,128
  SetViewport 192,24,256,448
  Cls
  TileImage backIm,0,0
  If shine_pos#=0  SetViewport 0,0,640,480
EndFunction

Function CausesPop()
  Local x,y,tl,tlc
  For y=0 Until 14
    For x=0 Until 8
      tl=map[x,y]
      If tl>0
        If Counttile(x,y,tl,0,tlc)
          Return 1
        ElseIf Counttile(x,y,tl,1,tlc)
          Return 1
        ElseIf Counttile(x,y,tl,2,tlc)
          Return 1
        ElseIf Counttile(x,y,tl,3,tlc)
          Return 1
        EndIf
      EndIf
    Next
  Next
  Return 0
EndFunction

Function Switch(x0,y0,x1,y1)
  Local a
  a=map[x0,y0]
  map[x0,y0]=map[x1,y1]
  map[x1,y1]=a
  If CausesPop() Return 1
  a=map[x0,y0]
  map[x0,y0]=map[x1,y1]
  map[x1,y1]=a
  Return 0
EndFunction

Function Do_Swap_Tiles()
  Local x1,x2,y1,y2
  Local size1#,size2#
  Select selection_done
    Case 1
      'setup tile swap
      rotation=180
      selection_done = 2
      'calculate center
      x1 = 208+t1x*32
      x2 = 208+t2x*32
      y1 = 32+t1y*32
      y2 = 32+t2y*32
      Center_X = ((x2-x1)/2)+x1
      Center_Y = ((y2-y1)/2)+y1
      Tile_Rad = 16
      'check side
      If t1y=t2y
        If t1x>t2x
          mt1 = map[t2x,t2y]
          mt2 = map[t1x,t1y]
        Else
          mt1 = map[t1x,t1y]
          mt2 = map[t2x,t2y]
        EndIf
      Else
        If t1y>t2y
          mt1 = map[t2x,t2y]
          mt2 = map[t1x,t1y]
        Else
          mt1 = map[t1x,t1y]
          mt2 = map[t2x,t2y]
        EndIf
      EndIf

      THE_Axis = 1
      If t1y=t2y THE_Axis = 0
    Case 2
      If rotation<0
        If Switch(t1x,t1y,t2x,t2y)
          selection_done = 0
        Else
          selection_done = 3
        EndIf
      Else
        rotation:-FLIPSPEED
        size2# = 0.80+0.20*Sin(rotation)
        size1# = 0.80+0.20*Sin(-rotation)
        Select THE_Axis
          Case 0 'x
            SetScale size1,size1
            DrawImage blocks, Center_X+Tile_Rad*Cos(rotation), Center_Y, mt1-1
            SetScale size2,size2
            DrawImage blocks, Center_X-Tile_Rad*Cos(rotation), Center_Y, mt2-1
            SetScale 1,1
          Case 1 ' y
            SetScale size1,size1
            DrawImage blocks, Center_X, Center_Y+Tile_Rad*Cos(rotation), mt1-1
            SetScale size2,size2
            DrawImage blocks, Center_X, Center_Y-Tile_Rad*Cos(rotation), mt2-1
            SetScale 1,1
        EndSelect
      '  DrawImage blocks,192+t2x*32,24+t2y*32,mt2
      EndIf
    Case 3 '
      If rotation>=180
        selection_done = 0
      Else
        rotation:+FLIPSPEED
        size2# = 0.80+0.20*Sin(rotation)
        size1# = 0.80+0.20*Sin(-rotation)
        Select THE_Axis
          Case 0 'x
            SetScale size1,size1
            DrawImage blocks, Center_X+Tile_Rad*Cos(rotation), Center_Y, mt1-1
            SetScale size2,size2
            DrawImage blocks, Center_X-Tile_Rad*Cos(rotation), Center_Y, mt2-1
            SetScale 1,1
          Case 1 ' y
            SetScale size1,size1
            DrawImage blocks, Center_X, Center_Y+Tile_Rad*Cos(rotation), mt1-1
            SetScale size2,size2
            DrawImage blocks, Center_X, Center_Y-Tile_Rad*Cos(rotation), mt2-1
            SetScale 1,1
        EndSelect
      EndIf
  EndSelect

EndFunction
