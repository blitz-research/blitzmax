
Strict

Rem
bbdoc: Networking/GameNet
End Rem
Module BRL.GNet

ModuleInfo "Version: 1.06"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Object id's now unmapped ASAP"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Some doc fixes"
ModuleInfo "History: 1.04 Release"
ModuleInfo "Histort: Fixed low level send/recv leaks"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Now uses Pub.ENet"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed Closing host not closing server socket"
ModuleInfo "History: 1.01 Release"

Import Pub.ENet
Import BRL.Socket
Import BRL.LinkedList
Import BRL.System

Private

Const GNET_INT=		1
Const GNET_FLOAT16=		2
Const GNET_STRING=		3
Const GNET_UINT8=		4
Const GNET_UINT16=		5
Const GNET_FLOAT32=		6

Global GNET_DIAGNOSTICS=False

Const GNET_MAXIDS=		4096

?Debug
Function dprint( t$ )
	If GNET_DIAGNOSTICS WriteStdout t+"~n"
End Function
?

Function PackFloat16( f# )
	Local i=(Int Ptr Varptr f)[0]
	If i=$00000000 Return $0000	'+0
	If i=$80000000 Return $8000	'-0
	Local M=i Shl 9
	Local S=i Shr 31
	Local E=(i Shr 23 & $ff)-127
	If E=128
		If M Return $ffff		'NaN
		Return S Shl 15 | $7c00	'+/-Infinity
	EndIf
	M:+$00200000
	If Not (M & $ffe00000) E:+1
	If E>15
		Return S Shl 15 | $7c00	'+/-Infinity
	Else If E<-15
		Return S Shl 15			'+/- 0
	EndIf
	Return S Shl 15 | (E+15) Shl 10 | M Shr 22
End Function

Function UnpackFloat16#( i )
	i:&$ffff
	If i=$0000 Return +0.0
	If i=$8000 Return -0.0
	Local M=i Shl 22
	Local S=i Shr 15
	Local E=(i Shr 10 & $1f)-15
	If E=16
		If M Return 0.0/0.0		'NaN
		If S Return -1.0/0.0		'-Infinity
		Return +1.0/0.0			'+Infinity
	Else If E = -15				'denormal as float16, but normal as float32.
		Local i
		For i = 0 To 9          'find the leading 1-bit
			Local bit = M & $80000000
			M:Shl 1
			If bit Exit
		Next
		E:-i
	End If
	Local n=S Shl 31 | (E+127) Shl 23 | M Shr 9
	Return (Float Ptr Varptr n)[0]
End Function

Function PackFloat32( f# )
	Return (Int Ptr Varptr f)[0]
End Function

Function UnpackFloat32#( i )
	Return (Float Ptr Varptr i)[0]
End Function

Public

Const GNET_ALL=		0

'object states
Const GNET_CREATED=		1
Const GNET_MODIFIED=	2
Const GNET_CLOSED=		3
Const GNET_SYNCED=		4
Const GNET_MESSAGE=		5
Const GNET_ZOMBIE=		-1

Type TGNetMsg

	Field id
	Field state
	Field data:Byte[]
	
End Type

Type TGNetSlot
	Field _type
	Field _int
	Field _float#
	Field _string$
	
	Method SetInt( data )
		Assert _type=0 Or _type=GNET_INT Or _type=GNET_UINT8 Or _type=GNET_UINT16
		_int=data
		If data<0
			_type=GNET_INT
		Else If data<=255
			_type=GNET_UINT8
		Else If data<=65535
			_type=GNET_UINT16
		Else
			_type=GNET_INT
		EndIf
	End Method
	
	Method SetFloat( data# )
		Assert _type=0 Or _type=GNET_FLOAT32
		_float=data
		_type=GNET_FLOAT32
	End Method
	
	Method SetString( data$ )
		Assert _type=0 Or _type=GNET_STRING
		_string=data
		_type=GNET_STRING
	End Method
	
	Method GetInt()
		Assert _type=GNET_INT Or _type=GNET_UINT8 Or _type=GNET_UINT16
		Return _int
	End Method
	
	Method GetFloat#()
		Assert _type=GNET_FLOAT32
		Return _float
	End Method
	
	Method GetString$()
		Assert _type=GNET_STRING
		Return _string
	End Method
	
End Type

Type TGNetObject

	Method New()
		For Local i=0 Until 32
			_slots[i]=New TGNetSlot
		Next
	End Method
	
	Method State()
		Return _state
	End Method

	'close object
	Method Close()
		Select _state
		Case GNET_CREATED
			_state=GNET_ZOMBIE
		Case GNET_MODIFIED,GNET_SYNCED
			_state=GNET_CLOSED
		Case GNET_CLOSED
		Default
			Throw "Illegal object state"
		End Select
	End Method
	
	Method SetInt( index,data )
		WriteSlot( index ).SetInt data
	End Method

	Method SetFloat( index,data# )
		WriteSlot( index ).SetFloat data
	End Method

	Method SetString( index,data$ )
		WriteSlot( index ).SetString data
	End Method
	
	Method GetInt( index )
		Return _slots[index].GetInt()
	End Method
	
	Method GetFloat#( index )
		Return _slots[index].GetFloat()
	End Method
	
	Method GetString$( index )
		Return _slots[index].GetString()
	End Method
	
	Method WriteSlot:TGNetSlot( index )
		Assert _state<>GNET_CLOSED And _state<>GNET_ZOMBIE Else "Object has been closed"
		_modified:|1 Shl index
		If _state=GNET_SYNCED _state=GNET_MODIFIED
		Return _slots[index]
	End Method
	
	Method Sync:TGNetMsg()
		Select _state
		Case GNET_SYNCED,GNET_ZOMBIE
			Return
		End Select
		
		Local msg:TGNetMsg
		
		If Not _peer
			msg:TGNetMsg=New TGNetmsg
			msg.id=_id
			msg.state=_state
			msg.data=PackSlots( _modified )
		EndIf

		_modified=0

		Select _state
		Case GNET_CREATED,GNET_MODIFIED
			_state=GNET_SYNCED
		Case GNET_CLOSED
			_target=Null
			_state=GNET_ZOMBIE
		End Select

		Return msg
	End Method
	
	Method Update( msg:TGNetMsg )
		Assert _id=msg.id
		UnpackSlots msg.data
		_state=msg.state
	End Method
	
	Method CreatedMsg:TGNetMsg()
		Local msg:TGNetMsg=New TGNetmsg
		msg.id=_id
		msg.state=GNET_CREATED
		msg.data=PackSlots( ~0 )
		Return msg
	End Method
	
	Method ClosedMsg:TGNetMsg()
		Local msg:TGNetMsg=New TGNetMsg
		msg.id=_id
		msg.state=GNET_CLOSED
		msg.data=PackSlots( 0 )
		Return msg
	End Method
	
	Method MessageMsg:TGNetMsg( id )
		Local msg:TGNetMsg=New TGNetMsg
		msg.id=id
		msg.state=GNET_MESSAGE
		msg.data=PackSlots( ~0 )
		Return msg
	End Method
	
	Method PackSlots:Byte[]( mask )
		Local sz
		For Local index=0 Until 32
			If Not (mask & 1 Shl index) Continue
			Local ty=_slots[index]._type
			If Not ty Continue
			Select ty
			Case GNET_INT
				sz:+5
			Case GNET_UINT8
				sz:+2
			Case GNET_UINT16
				sz:+3
			Case GNET_FLOAT16
				sz:+3
			Case GNET_FLOAT32
				sz:+5
			Case GNET_STRING
				sz:+3+GetString(index).length
			End Select
		Next
		If sz>$fff0 Throw "GNet message data too large"
		Local data:Byte[sz]
		Local p:Byte Ptr=data
		For Local index=0 Until 32
			If Not (mask & 1 Shl index) Continue
			Local ty=_slots[index]._type
			If Not ty Continue
			Select ty
			Case GNET_INT
				Local n=GetInt( index )
				p[0]=GNET_INT Shl 5 | index
				p[1]=n Shr 24
				p[2]=n Shr 16
				p[3]=n Shr 8
				p[4]=n Shr 0
				p:+5
			Case GNET_UINT8
				Local n=GetInt( index )
				p[0]=GNET_UINT8 Shl 5 | index
				p[1]=n
				p:+2
			Case GNET_UINT16
				Local n=GetInt( index )
				p[0]=GNET_UINT16 Shl 5 | index
				p[1]=n Shr 8
				p[2]=n Shr 0
				p:+3
			Case GNET_FLOAT16
				Local n=PackFloat16( GetFloat(index) )
				p[0]=GNET_FLOAT16 Shl 5 | index
				p[1]=n Shr 8
				p[2]=n Shr 0
				p:+3
			Case GNET_FLOAT32
				Local n=PackFloat32( GetFloat(index) )
				p[0]=GNET_FLOAT32 Shl 5 | index
				p[1]=n Shr 24
				p[2]=n Shr 16
				p[3]=n Shr 8
				p[4]=n Shr 0
				p:+5
			Case GNET_STRING
				Local data$=GetString( index )
				Local n=data.length
				p[0]=GNET_STRING Shl 5 | index
				p[1]=n Shr 8
				p[2]=n Shr 0
				Local t:Byte Ptr=data.ToCString()
				MemCopy p+3,t,n
				MemFree t
				p:+3+n
			Default
				Throw "Invalid GNet data type"
			End Select
		Next
		Return data
	End Method
	
	Method UnpackSlots( data:Byte[] )
		Local p:Byte Ptr=data
		Local e:Byte Ptr=p+data.length
		While p<e
			Local ty=p[0] Shr 5
			Local index=p[0] & 31
			p:+1
			Select ty
			Case GNET_INT
				SetInt index,p[0] Shl 24 | p[1] Shl 16 | p[2] Shl 8 | p[3]
				p:+4
			Case GNET_UINT8
				SetInt index,p[0]
				p:+1
			Case GNET_UINT16
				SetInt index,p[0] Shl 8 | p[1]
				p:+2
			Case GNET_FLOAT16
				Local t=p[0] Shl 8 | p[1]
				SetFloat index,UnpackFloat16( t )
				p:+2
			Case GNET_FLOAT32
				Local t=p[0] Shl 24 | p[1] Shl 16 | p[2] Shl 8 | p[3]
				SetFloat index,UnpackFloat32( t )
				p:+4
			Case GNET_STRING
				Local n=p[0] Shl 8 | p[1]
				Local data$=String.FromBytes( p+2,n )
				SetString index,data
				p:+2+n
			Default
				Throw "Invalid GNet data type"
			End Select
		Wend
		If p<>e Throw "Corrupt GNet message"
	End Method
	
	Function Create:TGNetObject( id,state,host:TGNetHost,peer:TGNetPeer )
		Local t:TGNetObject=New TGNetObject
		t._id=id
		t._state=state
		t._host=host
		t._peer=peer
		Return t
	End Function

	Field _id
	Field _state
	Field _host:TGNetHost
	Field _peer:TGNetPeer
	Field _target:Object
	
	Field _slots:TGNetSlot[32],_modified
	
End Type

Type TGNetHost 

	Method UpdateENetEvents()
		If Not _enetHost Return
		Repeat
			Local ev:ENetEvent=New ENetEvent
			If Not enet_host_service( _enetHost,ev,0 ) Return
			_enetEvents.AddLast ev
		Forever
	End Method

	Method Sync()
	
		_created.Clear
		_modified.Clear
		_closed.Clear
		_messages.Clear
		
		Local succ:TLink
	
		'sync all objects
		succ=_objects.FirstLink()
		While succ
			Local link:TLink=succ
			succ=link.NextLink()

			Local obj:TGNetObject=TGNetObject(link.Value())
			
			Local msg:TGNetMsg=obj.Sync()
			If msg BroadCast msg,obj._peer

			If obj._state=GNET_ZOMBIE
				If Not obj._peer UnmapObject obj
				link.Remove
			EndIf
		Wend
		
		Repeat
		
			UpdateENetEvents
			
			If _enetEvents.IsEmpty() Return
	
			Local ev:ENetEvent=ENetEvent( _enetEvents.RemoveFirst() )

			Local peer:TGNetPeer
			For Local t:TGNetPeer=EachIn _peers
				If t._enetPeer=ev.peer
					peer=t
					Exit
				EndIf
			Next
			
			Select ev.event
			Case ENET_EVENT_TYPE_CONNECT
				Assert Not peer Else "GNet error"
				peer=AddPeer( ev.peer )
			Case ENET_EVENT_TYPE_DISCONNECT
				If peer				
					For Local obj:TGNetObject=EachIn _objects			
						If obj._peer<>peer Continue
						BroadCast obj.ClosedMsg(),peer
						peer.UnmapLocalId obj._id
						UnmapObject obj
						_closed.AddLast obj
						obj.Close
					Next
					_peers.Remove peer
				EndIf
			Case ENET_EVENT_TYPE_RECEIVE
				Assert peer Else "GNet error"
				Local msg:TGNetMsg=peer.RecvMsg( ev.packet )
				enet_packet_destroy ev.packet
				Select msg.state
				Case GNET_MESSAGE
					Local obj:TGNetObject=_idMap[msg.id]
					If Not obj Continue
					If obj._peer
						obj._peer.SendMsg msg
					Else
						obj=TGNetObject.Create( msg.id,GNET_MESSAGE,Self,Null )
						_messages.AddLast obj
						obj.Update msg
					EndIf
				Default
					Local obj:TGNetObject
					Select msg.state
					Case GNET_CREATED
						obj=TGNetObject.Create( AllocId(),GNET_CREATED,Self,peer )
						MapObject obj
						peer.MapLocalId obj._id,msg.id
						msg.id=obj._id
						_objects.AddLast obj
						_created.AddLast obj
					Case GNET_MODIFIED
						obj=_idMap[msg.id]
						_modified.AddLast obj
					Case GNET_CLOSED
						obj=_idMap[msg.id]
						Assert peer=obj._peer
						peer.UnmapLocalId obj._id
						UnmapObject obj
						_closed.AddLast obj
					End Select
					BroadCast msg,peer
					obj.Update msg
				End Select
			Default
				Throw "GNet error"
			End Select

		Forever
		
	End Method
	
	Method Close()
		If Not _peers Return
		For Local peer:TGNetPeer=EachIn _peers
			peer.Close
		Next
		_peers=Null
		If _enetHost
			enet_host_flush _enetHost
			enet_host_destroy _enetHost
		EndIf
	End Method
	
	Method BroadCast( msg:TGNetMsg,except:TGNetPeer )
		For Local peer:TGNetPeer=EachIn _peers
			If peer<>except peer.SendMsg msg
		Next
	End Method
	
	Method AddPeer:TGNetPeer( enetPeer:Byte Ptr )
		Local peer:TGNetPeer=TGNetPeer.Create( enetPeer )
?Debug
		dprint "Adding peer"
?
		_peers.AddLast peer
		For Local obj:TGNetObject=EachIn _objects
			Select obj._state
			Case GNET_SYNCED,GNET_MODIFIED
				peer.SendMsg obj.CreatedMsg()
			End Select
		Next
		Return peer
	End Method
	
	Method Objects:TList()
		Return _objects
	End Method
	
	Method Peers:TList()
		Return _peers
	End Method
	
	Method ObjectsCreated:TList()
		Return _created
	End Method
	
	Method ObjectsModified:TList()
		Return _modified
	End Method
	
	Method ObjectsClosed:TList()
		Return _closed
	End Method
	
	Method CreateObject:TGNetObject()
		Local obj:TGNetObject=TGNetObject.Create( AllocId(),GNET_CREATED,Self,Null )
		MapObject obj
		_objects.AddLast obj
		Return obj
	End Method
	
	Method CreateMessage:TGNetObject()
		Return TGNetObject.Create( 0,GNET_MESSAGE,Self,Null )
	End Method
	
	Method SendGNetMessage( msg:TGNetObject,toObject:TGNetObject )
		If toObject._peer
			toObject._peer.SendMsg msg.MessageMsg( toObject._id )
		EndIf
	End Method
	
	Method AllocId()
		For Local id=1 Until GNET_MAXIDS
			If Not _idMap[id] Return id
		Next
		Throw "Out of GNet object IDs"
	End Method
	
	Method MapObject( obj:TGNetObject )
		Assert Not _idMap[obj._id]
		_idMap[obj._id]=obj
	End Method
	
	Method UnmapObject( obj:TGNetObject )
		Assert _idMap[obj._id]=obj
		_idMap[obj._id]=Null
	End Method
	
	Method Listen( port )
		If _enetHost Return
		Local addr:Byte Ptr=enet_address_create( ENET_HOST_ANY,port )
		_enetHost=enet_host_create( addr,32,0,0 )
		enet_address_destroy addr
		If Not _enetHost Return
		Return True
	End Method
	
	Method Connect( ip,port,timeout )
		If _enetHost Return
		_enetHost=enet_host_create( Null,32,0,0 )
		If Not _enetHost Return
		Local addr:Byte Ptr=enet_address_create( ip,port )
		Local peer:Byte Ptr=enet_host_connect( _enetHost,addr,1 )
		enet_address_destroy addr
		If peer
			timeout:+MilliSecs()
			While timeout-MilliSecs()>0
				UpdateENetEvents
				For Local ev:ENetEvent=EachIn _enetEvents
					If ev.event=ENET_EVENT_TYPE_CONNECT And ev.peer=peer
						_enetEvents.Remove ev
						AddPeer peer
						Return True
					EndIf
				Next
			Wend
		EndIf
		enet_host_destroy _enetHost
		_enetHost=Null
	End Method

	Function Create:TGNetHost()
		Local t:TGNetHost=New TGNetHost
		Return t
	End Function
	
	Field _enetHost:Byte Ptr
	Field _enetEvents:TList=New TList
	
	Field _peers:TList=New TList	'active peers
	Field _objects:TList=New TList		'all objects
	
	Field _created:TList=New TList		'created remote objects
	Field _modified:TList=New TList		'modified remote objects
	Field _closed:TList=New TList		'closed remote objects
	Field _messages:TList=New TList		'messages received
	
	Field _idMap:TGNetObject[GNET_MAXIDS]
	
End Type

Type TGNetPeer

	'enet peer
	Field _enetPeer:Byte Ptr

	'id mapping
	Field _localToRemote[GNET_MAXIDS]
	Field _remoteToLocal[GNET_MAXIDS]
	
	Method Close()
		If Not _enetPeer Return
		enet_peer_disconnect _enetPeer
		_enetPeer=Null
	End Method

	Method MapLocalId( localId,remoteId )
		Assert Not _localToRemote[localId] And Not _remoteToLocal[remoteId]
		_localToRemote[localId]=remoteId
		_remoteToLocal[remoteId]=localId
?Debug
		dprint "Mapped localId:"+localId+"<->remoteId:"+remoteId
?
	End Method
	
	Method UnmapLocalId( localId )
		Local remoteId=_localToRemote[localId]
		Assert _localToRemote[localId]=remoteId And _remoteToLocal[remoteId]=localId
		_localToRemote[localId]=0
		_remoteToLocal[remoteId]=0
?Debug
		dprint "Unmapped localId:"+localId+"<->remoteId:"+remoteId
?
	End Method
	
	Method RecvMsg:TGNetMsg( packet:Byte Ptr )
	
		Local buf:Byte Ptr=enet_packet_data( packet )
		Local sz=enet_packet_size( packet )-2
		
		Local id=(buf[0] Shl 8 | buf[1]) & (GNET_MAXIDS-1)
		Local state=(buf[0] Shl 8 | buf[1]) Shr 12
			
		If state<>GNET_MESSAGE
			id=_remoteToLocal[id]
			If id
				Assert state<>GNET_CREATED Else "Illegal remoteId"
			Else
				Assert state=GNET_CREATED Else "Unmapped remoteId: obj.state="+buf[1]
				id=(buf[0] Shl 8 | buf[1]) & (GNET_MAXIDS-1)
			EndIf
		EndIf
			
		Local msg:TGNetMsg=New TGNetmsg
		msg.id=id
		msg.state=state
		
		If sz
			msg.data=New Byte[sz]
			MemCopy msg.data,buf+2,sz
		EndIf
?Debug
		If msg.state<>2 dprint "RecvMsg id="+msg.id+", state="+msg.state+", size="+sz
?
		Return msg
	End Method
	
	Method SendMsg( msg:TGNetMsg )
		Local sz=msg.data.length
		Local buf:Byte Ptr=MemAlloc( sz+2 )

		Local id=msg.id
		If msg.state=GNET_MESSAGE
			id=_localToRemote[id]
			Assert id Else "SendMsg: Unmapped localId="+msg.id
		EndIf
		
		buf[0]=(msg.state Shl 12 | id) Shr 8
		buf[1]=(msg.state Shl 12 | id) Shr 0
		If sz MemCopy buf+2,msg.data,sz
?Debug
		dprint "SendMsg id="+id+", state="+msg.state+", size="+sz
?
		Local packet:Byte Ptr=enet_packet_create( buf,sz+2,ENET_PACKET_FLAG_RELIABLE )
		
		MemFree buf
		
		If enet_peer_send( _enetPeer,0,packet )<0 Throw "ENet errror"
		
	End Method

	Function Create:TGNetPeer( enetPeer:Byte Ptr )
		Local t:TGNetPeer=New TGNetPeer
		t._enetPeer=enetPeer
		Return t
	End Function

End Type

Rem
bbdoc: Create GNet host
returns: A new GNet host
about:
Once you have created a GNet host, you can use it to create objects with #CreateGNetObject,
connect to other hosts with #GNetConnect and listen for connections from other hosts with
#GNetListen.
End Rem
Function CreateGNetHost:TGNetHost()
	Return TGNetHost.Create()
End Function

Rem 
bbdoc: Close a GNet host
about:
Once closed, a GNet host cannot be reopened.
End Rem
Function CloseGNetHost( host:TGNetHost )
	host.Close
End Function

Rem
bbdoc: Synchronize GNet host
about:
#GNetSync will update the state of all GNet objects. Once you have used this command,
use the #GNetObjects function to determine which objects have been remotely created, modified
or closed.
End Rem
Function GNetSync( host:TGNetHost )
	Return host.Sync()
End Function

Rem
bbdoc: Listen for connections
returns: True if successful, otherwise false
about:
Causes @host to start listening for connection attempts on the specified @port. 
Once a host is listening, hosts on other machines can connect using #GNetConnect.

#GNetListen may fail if @port is already in use by another application, or if @host
is already listening or has already connected to a remote host using #GNetConnect.
End Rem
Function GNetListen( host:TGNetHost,port )
	Return host.Listen( port )
End Function

Rem
bbdoc: Connect to a remote GNet host
returns: True if connection successful, otherwise false
about:
Attempts to connect @host to the specified remote address and port.

A GNet host must be listening (see #GNetListen) at the specified address and port for the
connection to succeed.
End Rem
Function GNetConnect( host:TGNetHost,address$,port,timeout_ms=10000 )
	Return host.Connect( HostIp(address),port,timeout_ms )
End Function

Rem
bbdoc: Get a list of GNet objects
returns: A linked list
about:
#GNetObjects returns a list of GNet objects in a certain state.

The @state parameter controls which objects are listed, and can be one of &GNET_ALL, 
&GNET_CREATED, &GNET_MODIFIED or &GNET_CLOSED.

Note that with the exception of &GNET_ALL, the returned lists will only ever contain remote objects.
End Rem
Function GNetObjects:TList( host:TGNetHost,state=GNET_ALL )
	Select state
	Case GNET_ALL
		Return host.Objects()
	Case GNET_CREATED
		Return host.ObjectsCreated()
	Case GNET_MODIFIED
		Return host.ObjectsModified()
	Case GNET_CLOSED
		Return host.ObjectsClosed()
	End Select
	Throw "Unknown object state"
End Function

Rem
bbdoc: Get a list of GNet messages sent to local objects
returns: A linked list
End Rem
Function GNetMessages:TList( host:TGNetHost )
	Return host._messages
End Function

Rem
bbdoc: Create a GNet object
returns: A new GNet object
End Rem
Function CreateGNetObject:TGNetObject( host:TGNetHost )
	Return host.CreateObject()
End Function

Rem
bbdoc: Create a GNet message object
returns: A new GNet object
End Rem
Function CreateGNetMessage:TGNetObject( host:TGNetHost )
	Return host.CreateMessage()
End Function

Rem
bbdoc: Send a GNet message to a remote object
End Rem
Function SendGNetMessage( msg:TGNetObject,toObject:TGNetObject )
	Return msg._host.SendGNetMessage( msg,toObject )
End Function

Rem
bbdoc: Get message target object
returns: The object that @msg was sent to
End Rem
Function GNetMessageObject:TGNetObject( msg:TGNetObject )
	Return msg._host._idMap[msg._id]
End Function

Rem
bbdoc: Get state of a GNet object
returns: An integer state
about:The returned value can be one of the following:
<table>
<tr><th>Object State</th><td>Meaning</td></tr>
<tr><td>GNET_CREATED</td><td>Object has been created</td></tr>
<tr><td>GNET_SYNCED</td><td>Object is in sync</td><tr>
<tr><td>GNET_MODIFIED</td><td>Object has been modified</td></tr>
<tr><td>GNET_CLOSED</td><td>Object has been closed</td></tr>
<tr><td>GNET_ZOMBIE</td><td>Object is a zombie</td></tr>
<tr><td>GNET_MESSAGE</td><td>Object is a message object</td></tr>
</table>
Zombie objects are objects that have been successfully closed and will never again be used
by GameNet. Therefore, such objects will never appear in any list returned by the 
#GNetObjects function.
End Rem
Function GNetObjectState( obj:TGNetObject )
	Return obj.State()
End Function

Rem
bbdoc: Determine whether a GNet object is local
returns: True if object is a local object
End Rem
Function GNetObjectLocal( obj:TGNetObject )
	Return obj._peer=Null
End Function

Rem
bbdoc: Determine whether a GNet object is remote
returns: True if object is a remote object
End Rem
Function GNetObjectRemote( obj:TGNetObject )
	Return obj._peer<>Null
End Function

Rem
bbdoc: Set GNet object int data
End Rem
Function SetGNetInt( obj:TGNetObject,index,value )
	obj.SetInt index,value
End Function

Rem
bbdoc: Set GNet object float data
End Rem
Function SetGNetFloat( obj:TGNetObject,index,value# )
	obj.SetFloat index,value
End Function

Rem
bbdoc: Set GNet object string data
End Rem
Function SetGNetString( obj:TGNetObject,index,value$ )
	obj.SetString index,value
End Function

Rem
bbdoc: Get GNet object int data
End Rem
Function GetGNetInt( obj:TGNetObject,index )
	Return obj.GetInt( index )
End Function

Rem
bbdoc: Get GNet object float data
End Rem
Function GetGNetFloat#( obj:TGNetObject,index )
	Return obj.GetFloat( index )
End Function

Rem
bbdoc: Get GNet object string data
End Rem
Function GetGNetString$( obj:TGNetObject,index )
	Return obj.GetString( index )
End Function

Rem
bbdoc: Set a GNet object's target object
about:
This command allows you to bind an abitrary object to a GNet object.
End Rem
Function SetGNetTarget( obj:TGNetObject,target:Object )
	obj._target=target
End Function

Rem
bbdoc: Get a GNet object's target object
returns: The currently bound target object
End Rem
Function GetGNetTarget:Object( obj:TGNetObject )
	Return obj._target
End Function

Rem
bbdoc: Close a GNet object
End Rem
Function CloseGNetObject( obj:TGNetObject )
	Assert Not obj._peer Else "CloseGNetObject can only be used with local objects"
	obj.Close
End Function
