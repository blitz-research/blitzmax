
Strict

Import BRL.GNet

AppTitle="GNet Test2"

Local host:TGNetHost=CreateGNetHost()

Local me:TGNetObject
Local chat$,info$

Graphics 800,600,0,15

Repeat

	Local c=GetChar()
	
	Select c
	Case 8
		If chat chat=chat[..chat.length-1]
	Case 27
		If Confirm( "Quit?" )
			CloseGNetHost host
			End
		EndIf
	Case 13
		If chat.find("/")=0
			chat=chat[1..]
			Local cmd$=chat
			Local arg$
			Local i=chat.find(" ")
			If i<>-1
				cmd=chat[..i]
				arg=chat[i+1..]
			EndIf
			Select cmd
			Case "create"
				If me
					info="Already created"
				Else
					me=CreateGNetObject( host )
					SetGNetString me,0,arg
					SetGNetString me,1,"Ready"
				EndIf
			Case "close"
				If me
					CloseGNetObject me
					me=Null
				Else
					info="Not created"
				EndIf
			Case "quit","exit"
				CloseGNetHost host
				End
			Case "nick"
				If arg
					If me SetGNetString me,0,arg
					info="Nick changed to "+arg
				Else
					info="Expecting arg"
				EndIf
			Case "listen"
				Local port=12345
				If arg port=Int(arg)
				If GNetListen( host,port )
					info="Listening on port "+port
				Else
					info="Listen failed"
				EndIf
			Case "connect"
				If arg
					Local addr$=arg
					Local port=12345
					Local i=arg.find(":")
					If i<>-1
						addr=arg[..i]
						port=Int(arg[i+1..])
					EndIf
					If GNetConnect( host,addr,port )
						info="Connected to "+addr+":"+port
					Else
						info="Failed to connect to "+addr+":"+port
					EndIf
				Else
					info="Expecting arg"
				EndIf
			Default
				info="Unrecognized command '"+cmd+"'"
			End Select
		Else
			If me SetGNetString me,1,chat
		EndIf
		chat=""
	Default
		If c>31 And c<127 chat:+Chr(c)
	End Select
	
	GNetSync host
	
	Cls

	Local y,h=GraphicsHeight()
	
	For Local obj:TGNetObject=EachIn GNetObjects( host,GNET_ALL )
		If obj.state()=GNET_CLOSED Continue
		If obj=me
			SetColor 255,255,255
		Else
			SetColor 0,128,255
		EndIf
		DrawText GetGNetString( obj,0 )+":"+GetGNetString( obj,1 ),0,y
		y:+16
	Next
	
	SetColor 255,255,0
	DrawText info,0,h-32
	
	SetColor 0,255,0
	DrawText ">"+chat,0,h-16
	DrawRect TextWidth(">"+chat),h-16,8,16
	DrawText "/create nick    /listen    /connect host    /quit    /nick newnick",0,h-48
	
	Flip
	
Forever
