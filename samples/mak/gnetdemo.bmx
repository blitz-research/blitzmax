
Strict

?Win32
Framework BRL.D3D7Max2D
?MacOS
Framework BRL.GLMax2D
?
Import BRL.GNet
Import BRL.BASIC
Import BRL.PNGLoader

Const GAMEPORT=12345

Const SLOT_TYPE=0
Const SLOT_NAME=1
Const SLOT_CHAT=2		
Const SlOT_SCORE=3
Const SLOT_X=4
Const SLOT_Y=5
Const SLOT_VX=6
Const SLOT_VY=7
Const SLOT_ROT=8
Const SLOT_TIMEOUT=9
Const SLOT_HIT=10

Local GWIDTH=640
Local GHEIGHT=480
Local GDEPTH=0
Local GHERTZ=30

Graphics GWIDTH,GHEIGHT,GDEPTH,GHERTZ

AutoMidHandle True
Local playerImage:TImage=LoadImage( "ship.png" )
Local bulletImage:TImage=LoadImage( "bullet1.png" )
Local warpImage:TImage=LoadImage( "sparkle.png" )

Local host:TGNetHost=CreateGNetHost()

SeedRnd MilliSecs()

Local playerName$="Player"
Local playerChat$=""
Local playerX#=Rnd(GWIDTH-64)+32
Local playerY#=Rnd(GHEIGHT-64)+32
Local playerVx#=0
Local playerVy#=0
Local playerRot#=0
Local playerScore=0
Local playerHit#=0
Local playerShot=0

'create local player
Local localPlayer:TGNetObject=CreateGNetObject( host )

SetGNetString localPlayer,SLOT_TYPE,"player"
SetGNetString localPlayer,SLOT_NAME,playerName
SetGNetString localPlayer,SLOT_CHAT,"Ready"
SetGNetFloat localPlayer,SLOT_X,playerX
SetGNetFloat localPlayer,SLOT_Y,playerY
SetGNetFloat localPlayer,SLOT_ROT,playerRot
SetGNetFloat localPlayer,SLOT_HIT,playerHit
SetGNetInt localPlayer,SLOT_SCORE,playerScore

While Not KeyHit( KEY_ESCAPE )

	Local c=GetChar()
	Select c
	Case 8
		If playerChat playerChat=playerChat[..playerChat.length-1]
	Case 13
		If playerChat
			If playerChat[..1]="/"
				Local cmd$=playerChat[1..]
				Local i=cmd.Find(" "),arg$
				If i<>-1
					arg=cmd[i+1..]
					cmd=cmd[..i]
				EndIf
				Select cmd.ToLower()
				Case "nick"
					If arg
						playerName=arg
						SetGNetString localPlayer,SLOT_NAME,playerName
					EndIf
				Case "listen"
					If Not GNetListen( host,GAMEPORT ) Notify "Listen failed"
				Case "connect"
					If Not arg arg="localhost"
					If Not GNetConnect( host,arg,GAMEPORT ) Notify "Connect failed"
				End Select
			Else
				SetGNetString localPlayer,SLOT_CHAT,playerChat
			EndIf
			playerChat=""
		EndIf
	Default
		If c>31 And c<127 playerChat:+Chr(c)
	End Select
	
	If KeyDown( KEY_LEFT )
		playerRot:-5
		If playerRot<-180 playerRot:+360
		SetGNetFloat localPlayer,SLOT_ROT,playerRot
	Else If KeyDown( KEY_RIGHT )
		playerRot:+5
		If playerRot>=180 playerRot:-360
		SetGNetFloat localPlayer,SLOT_ROT,playerRot
	EndIf
	
	If KeyDown( KEY_UP )
		playerVx:+Cos(playerRot)*.15
		playerVy:+Sin(playerRot)*.15
	Else
		playerVx:*.99
		If Abs(playerVx)<.1 playerVx=0
		playerVy:*.99
		If Abs(playerVy)<.1 playerVy=0
	EndIf
	
	If playerVx
		playerX:+playerVx
		If playerX<-8 playerX:+GWIDTH+16 Else If playerX>=GWIDTH+8 playerX:-GWIDTH+16
		SetGNetFloat localPlayer,SLOT_X,playerX
	EndIf
	
	If playerVy
		playerY:+playerVy
		If playerY<-8 playerY:+GHEIGHT+16 Else If playerY>=GHEIGHT+8 playerY:-GHEIGHT+16
		SetGNetFloat localPlayer,SLOT_Y,playerY
	EndIf
	
	If playerShot playerShot:-1
	
	If KeyHit( KEY_LALT ) And Not playerShot
		Local obj:TGnetObject=CreateGNetObject( host )
		SetGNetString obj,SLOT_TYPE,"bullet"
		SetGNetFloat obj,SLOT_X,playerX
		SetGNetFloat obj,SLOT_Y,playerY
		SetGNetFloat obj,SLOT_VX,playerVx+Cos(playerRot)*10
		SetGNetFloat obj,SLOT_VY,playerVy+Sin(playerRot)*10
		SetGNetInt obj,SLOT_TIMEOUT,60
		playerShot=5
	EndIf
	
	'update bullets
	For Local obj:TGNetObject=EachIn GNetObjects( host )

		If obj.State()=GNET_CLOSED Continue
	
		Local typ$=GetGNetString( obj,SLOT_TYPE )
		If typ<>"bullet" Continue

		Local x#=GetGNetFloat( obj,SLOT_X )
		Local y#=GetGNetFloat( obj,SLOT_Y )
		
		If GNetObjectRemote( obj )
			'remote bullet? Check for collision...
			Local dx#=x-playerX,dy#=y-playerY
			If dx*dx+dy*dy<256'144
				Local msg:TGNetObject=CreateGNetMessage( host )
				If playerHit
					SetGNetString msg,SLOT_TYPE,"gotme"
				Else
					SetGNetString msg,SLOT_TYPE,"hurtme"
					playerHit=1
				EndIf
				SendGNetMessage msg,obj
			EndIf
		Else
			'local bullet? Update...
			Local t=GetGNetInt( obj,SLOT_TIMEOUT )
			
			If Not t
				CloseGNetObject obj
				Continue
			EndIf

			Local vx#=GetGNetFloat( obj,SLOT_VX )
			Local vy#=GetGNetFloat( obj,SLOT_VY )
			
			Local dx#=x-GWIDTH/2
			Local dy#=y-GHEIGHT/2
			Local rot#=ATan2(dy,dx)
			Local accel#=1/(dx*dx+dy*dy)*2000
			vx:-Cos(rot)*accel
			vy:-Sin(rot)*accel
			x:+vx
			y:+vy

			SetGNetFloat obj,SLOT_X,x
			SetGNetFloat obj,SLOT_Y,y
			SetGNetFloat obj,SLOT_VX,vx
			SetGNetFloat obj,SLOT_VY,vy
			SetGNetInt obj,SLOT_TIMEOUT,t-1
		EndIf
	Next
	
	If playerHit
		playerHit:-.05
		If playerHit<0 playerHit=0
		SetGNetFloat localPlayer,SLOT_HIT,playerHit
	EndIf
	
	GNetSync host
	
	For Local msg:TGNetObject=EachIn GNetMessages( host )
		Local typ$=GetGNetString( msg,SLOT_TYPE )
		Select typ
		Case "gotme","hurtme"
			Local obj:TGNetObject=GNetMessageObject(msg)
			If obj.State()<>GNET_CLOSED
				If typ="hurtme" 
					playerScore:+1
					SetGNetInt localPlayer,SLOT_SCORE,playerScore
				EndIf
				CloseGNetObject obj
			EndIf
		End Select
	Next
	
	Cls
	
	Local ty
	For Local obj:TGNetObject=EachIn GNetObjects( host )

		If obj.State()=GNET_CLOSED Continue

		Local typ$=GetGNetString( obj,SLOT_TYPE )
		Local x#=GetGNetFloat( obj,SLOT_X )
		Local y#=GetGNetFloat( obj,SLOT_Y )
		Select typ
		Case "bullet"
			SetBlend LIGHTBLEND
			SetColor 255,255,255
			DrawImage bulletImage,x,y
			SetBlend MASKBLEND
		Case "player"
			Local rot#=GetGNetFloat( obj,SLOT_ROT )
			Local name$=GetGNetString( obj,SLOT_NAME )
			Local chat$=GetGNetString( obj,SLOT_CHAT )
			Local score=GetGNetInt( obj,SLOT_SCORE )
			Local hit#=GetGNetFloat( obj,SLOT_HIT )
			SetRotation rot
			SetColor 255,255,255
			DrawImage playerImage,x,y
			If hit 
				SetAlpha hit
				SetBlend LIGHTBLEND
				DrawImage playerImage,x,y
				SetBlend MASKBLEND
				SetAlpha 1
				SetColor 255,255,255
			EndIf
			SetRotation 0
			DrawText name+":"+score,x,y+16
			If obj=localPlayer SetColor 255,255,255 Else SetColor 0,128,255
			DrawText name+":"+chat,0,ty
			ty:+16
		End Select
	Next
	
	If playerChat
		SetColor 255,255,0
		DrawText ">"+playerChat,0,GHEIGHT-16
		SetColor 0,255,0
		DrawRect TextWidth(">"+playerChat),GHEIGHT-16,8,16
	EndIf
	
	SetColor 255,255,255
	Local txt$="MemAllocd:"+GCMemAlloced()
	DrawText txt,GWIDTH-TextWidth(txt),0
	
	SetBlend LIGHTBLEND
	SetRotation Rnd(360)
	SetScale Rnd(2,2.125),Rnd(2,2.125)
	DrawImage warpImage,GWIDTH/2,GHEIGHT/2
	SetScale 1,1
	SetRotation 0
	SetBlend MASKBLEND
	
	Flip

Wend

CloseGNetHost host
