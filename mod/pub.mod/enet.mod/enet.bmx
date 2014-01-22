
Strict

Module Pub.ENet

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Lee Salzman"
ModuleInfo "Modserver: BRL"
ModuleInfo "Credit: Adapted for BlitzMax by Mark Sibly"

ModuleInfo "History: 1.01 Release"

Import Pub.StdC

Import "include/*.h"

Import "host.c"
Import "list.c"
Import "memory.c"
Import "packet.c"
Import "peer.c"
Import "protocol.c"

?Win32
Import "win32.c"
Import "-lws2_32"
?MacOS
Import "unix.c"
?Linux
Import "unix.c"
?

Type ENetEvent

	Field event
	Field peer:Byte Ptr
	Field channel
	Field packet:Byte Ptr

End Type

Extern "C"

Const ENET_HOST_ANY=0

Const ENET_EVENT_TYPE_NONE=0
Const ENET_EVENT_TYPE_CONNECT=1
Const ENET_EVENT_TYPE_DISCONNECT=2
Const ENET_EVENT_TYPE_RECEIVE=3

Const ENET_PACKET_FLAG_RELIABLE=1

Function enet_initialize()
Function enet_deinitialize()

Function enet_address_set_host( address:Byte Ptr,name$z )

Function enet_time_get()
Function enet_time_set( walltime_ms )

Function enet_packet_create:Byte Ptr( data:Byte Ptr,size,flags )
Function enet_packet_destroy( packet:Byte Ptr )

Function enet_host_create:Byte Ptr( address:Byte Ptr,peerCount,incomingBandwidth,outgoingBandwidth )
Function enet_host_destroy( host:Byte Ptr )
Function enet_host_connect:Byte Ptr( host:Byte Ptr,address:Byte Ptr,channelCount )
Function enet_host_flush( host:Byte Ptr )
Function enet_host_service( host:Byte Ptr,event:Byte Ptr,timeout_ms )
Function enet_host_broadcast( host:Byte Ptr,channel,packet:Byte Ptr )
Function enet_host_bandwidth_limit( host:Byte Ptr,incomingBandwidth,outgoingBandwidth )

Function enet_peer_send( peer:Byte Ptr,channel,packet:Byte Ptr )
Function enet_peer_receive( peer:Byte Ptr,channel )
Function enet_peer_ping( peer:Byte Ptr )
Function enet_peer_reset( peer:Byte Ptr )
Function enet_peer_disconnect( peer:Byte Ptr )
Function enet_peer_throttle_configure( peer:Byte Ptr,interval,acceleration,deceleration )

End Extern

Function enet_peer_address( peer:Byte Ptr,host_ip Var,host_port Var )
	Local ip=(Int Ptr peer)[3]
	Local port=(Short Ptr peer)[8]
?LittleEndian
	ip=(ip Shr 24) | (ip Shr 8 & $ff00) | (ip Shl 8 & $ff0000) | (ip Shl 24)
?
	host_ip=ip
	host_port=port
End Function

Function enet_packet_data:Byte Ptr( packet:Byte Ptr )
	Return Byte Ptr( (Int Ptr packet)[2] )
End Function

Function enet_packet_size( packet:Byte Ptr )
	Return (Int Ptr packet)[3]
End Function

Function enet_address_create:Byte Ptr( host_ip,host_port )
	Local t:Byte Ptr=MemAlloc( 6 )
?BigEndian
		(Int Ptr t)[0]=host_ip
?LittleEndian
		(Int Ptr t)[0]=(host_ip Shr 24) | (host_ip Shr 8 & $ff00) | (host_ip Shl 8 & $ff0000) | (host_ip Shl 24)
?
	(Short Ptr t)[2]=host_port
	Return t
End Function

Function enet_address_destroy( address:Byte Ptr )
	MemFree address
End Function

enet_initialize
atexit_ enet_deinitialize

