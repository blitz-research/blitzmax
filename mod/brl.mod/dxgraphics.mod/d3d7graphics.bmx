
Strict

Import BRL.Graphics
Import BRL.LinkedList

Import Pub.DirectX

Private

Extern

Global _bbusew

End Extern

Const DLOG_ENABLED=False

Const DDERR=$88760000

Const DDERR_OK=0
Const DDERR_PRIMARYSURFACEALREADYEXISTS=DDERR|564
Const DDERR_WRONGMODE=DDERR|587
Const DDERR_NOEXCLUSIVEMODE=DDERR|225
Const DDERR_EXCLUSIVEMODEALREADYSET=DDERR|581
Const DDERR_UNSUPPORTEDMODE=DDERR|590
Const DDERR_SURFACELOST=DDERR|450

Type TD3D7Surface
	Field surf:IDirectDrawSurface7
End Type

Global _driver:TD3D7GraphicsDriver
Global _wndClass:Byte Ptr="BBDX7Device Window Class".ToCString()
Global _wndClassW:Short Ptr="BBDX7Device Window Class".ToWString()

Function dderrstr$( code )
	Select code
	Case DDERR_OK Return "OK"
	Case DDERR_PRIMARYSURFACEALREADYEXISTS Return "PRIMARYSURFACEALREADYEXISTS"
	Case DDERR_WRONGMODE Return "WRONGMODE"
	Case DDERR_NOEXCLUSIVEMODE Return "NOEXCLUSIVEMODE"
	Case DDERR_EXCLUSIVEMODEALREADYSET Return "EXCLUSIVEMODEALREADYSET"
	Case DDERR_UNSUPPORTEDMODE Return "UNSUPPORTEDMODE"
	Case DDERR_SURFACELOST Return "SURFACELOST"
	End Select
'	Return "UNKNOWN:"+Hex( code )+" "+(code & 65535)
	Return "UNKNOWN:"+( code )+" "+(code & 65535)
End Function

Function dlog( t$ )
	If Not DLOG_ENABLED Return
	WriteStdout t+"~n"
End Function
	
Function WndProc( hwnd,message,wp,lp ) "win32"
	bbSystemEmitOSEvent hwnd,message,wp,lp,Null

	Select message
	Case WM_CLOSE
		Return
	Case WM_SYSKEYDOWN
		If wp<>KEY_F4 Return
	Case WM_SETFOCUS
		dlog "WM_SETFOCUS"
		_driver.ValidateGraphics
	Case WM_KILLFOCUS
		dlog "WM_KILLFOCUS"
		_driver.ValidateGraphics
	End Select

	If _bbusew Return DefWindowProcW( hwnd,message,wp,lp )
	Return DefWindowProcA( hwnd,message,wp,lp )

End Function

Function EnumModesCallback( desc:Byte Ptr,context:Object ) "win32"
	Local p:Int Ptr=Int Ptr(desc)
	Local t:TGraphicsMode=New TGraphicsMode
	t.width=p[3]
	t.height=p[2]
	t.depth=p[21]
	t.hertz=p[6]
	If t.depth>=16 TList(context).AddLast t
	Return D3DENUMRET_OK
End Function

Function DXASS( n,msg$="DXERROR" )
	If n>=0 Return
	WriteStdout msg+" err="+dderrstr( n )+"~n"
?Debug
	DebugStop
?
	End
End Function

Function FindMode:TGraphicsMode( width,height,depth,hertz,modes:TGraphicsMode[] )
	Local mode:TGraphicsMode,md=$7fff
	For Local t:TGraphicsMode=EachIn modes
		If width=t.width And height=t.height And depth=t.depth
			Local d=Abs(hertz-t.hertz)
			If d<md
				md=d
				mode=t
			EndIf
		EndIf
	Next
	Return mode
End Function

Function BestMode:TGraphicsMode( width,height,depth,hertz,modes:TGraphicsMode[] )
	Local mode:TGraphicsMode
	mode=FindMode( width,height,depth,hertz,modes )
	If mode Return mode
	mode=FindMode( width,height,32,hertz,modes )
	If mode Return mode
	mode=FindMode( width,height,24,hertz,modes )
	If mode Return mode
	mode=FindMode( width,height,16,hertz,modes )
	If mode Return mode
End Function

Public

Type TD3D7Graphics Extends TGraphics

	Method Driver:TGraphicsDriver()
		Return _driver
	End Method

	Method GetSettings( width Var,height Var,depth Var,hertz Var,flags Var )
		width=_width
		height=_height
		depth=_depth
		hertz=_hertz
		flags=_flags
	End Method

	Method Close()
		If Not _hwnd Return
		Local dd7:IDirectDraw7=_driver.DirectDraw7()

		If _depth dd7.SetCooperativeLevel Null,DDSCL_NORMAL|DDSCL_FPUPRESERVE
		
		_driver.CloseGraphics( Self )

		DestroyWindow _hwnd
		_hwnd=Null
	End Method
	
	Method Flip( sync )
		Local dd7:IDirectDraw7=_driver.DirectDraw7()

		'Ugly kludge to prevent 'render ahead'...
		Local desc:DDSURFACEDESC2=New DDSURFACEDESC2
		desc.dwSize=SizeOf(desc)
		If _renderSurf.Lock( Null,desc,DDLOCK_READONLY|DDLOCK_WAIT,Null )>=0 _renderSurf.Unlock Null

		If _depth
			Local flags	
			If Not sync flags=DDFLIP_NOVSYNC
			_primSurf.Flip Null,flags
		Else
			Local src[]=[0,0,_width,_height]
			Local dest[]=[0,0,_width,_height]
			ClientToScreen _hwnd,dest
			dest[2]:+dest[0]
			dest[3]:+dest[1]
			If sync	dd7.WaitForVerticalBlank DDWAITVB_BLOCKBEGIN,0
			_primSurf.SetClipper( _clipper )
			_primSurf.Blt( dest,_renderSurf,src,0,Null )
			_primSurf.SetClipper( Null )
		EndIf
	End Method
	
	Method RenderSurface:IDirectDrawSurface7()
		ValidateSize
		Return _renderSurf
	End Method
	
	Method CreateRenderSurface:IDirectDrawSurface7()
		Local dd7:IDirectDraw7=_driver.DirectDraw7()

		If _depth
			DXASS dd7.SetCooperativeLevel( _hwnd,DDSCL_FULLSCREEN|DDSCL_EXCLUSIVE|DDSCL_ALLOWREBOOT|DDSCL_FPUPRESERVE )
			DXASS dd7.SetDisplayMode( _width,_height,_depth,_hertz,0 )

			Local desc:DDSURFACEDESC2=New DDSURFACEDESC2
			desc.dwSize=SizeOf(desc)
			desc.dwFlags=DDSD_CAPS|DDSD_BACKBUFFERCOUNT
			desc.ddsCaps=DDSCAPS_PRIMARYSURFACE|DDSCAPS_COMPLEX|DDSCAPS_FLIP|DDSCAPS_3DDEVICE
			desc.dwBackBufferCount=1

			DXASS dd7.CreateSurface( desc,Varptr _primSurf,Null )
			
			Local caps:DDSCAPS2=New DDSCAPS2
			caps.dwCaps=DDSCAPS_BACKBUFFER
			
			DXASS _primSurf.GetAttachedSurface( caps,Varptr _renderSurf )
		Else
			If _primSurf
				_primSurf.AddRef
			Else
				Local desc:DDSURFACEDESC2=New DDSURFACEDESC2
				desc.dwSize=SizeOf(desc)
				desc.dwFlags=DDSD_CAPS
				desc.ddsCaps=DDSCAPS_PRIMARYSURFACE
				DXASS dd7.CreateSurface( desc,Varptr _primSurf,Null )
			EndIf

			Local desc:DDSURFACEDESC2=New DDSURFACEDESC2
			desc.dwSize=SizeOf(desc)
			desc.dwFlags=DDSD_WIDTH|DDSD_HEIGHT|DDSD_CAPS
			desc.dwWidth=_width
			desc.dwHeight=_height
			desc.ddsCaps=DDSCAPS_OFFSCREENPLAIN|DDSCAPS_3DDEVICE
			dlog "CreateRenderSurface _width="+_width+" _height="+_height
			DXASS dd7.CreateSurface( desc,Varptr _renderSurf,Null )
			DXASS dd7.CreateClipper( 0,Varptr _clipper,Null )
			DXASS _clipper.SetHWnd( 0,_hwnd )
		EndIf
		_primRefs:+1
		Return _renderSurf
	End Method	
	
	Method DestroyRenderSurface()
		If _clipper
			dlog "_clipper.Release_="+_clipper.Release_()
			_clipper=Null
		EndIf
		If _renderSurf
			dlog "_renderSurf.Release_="+_renderSurf.Release_()
			_renderSurf=Null
		EndIf
		If _primSurf
			dlog "_primSurf.Release_="+_primSurf.Release_()
			_primRefs:-1
			If Not _primRefs _primSurf=Null
		EndIf
	End Method
	
	Function Attach:TD3D7Graphics( hwnd,flags )
		Local rect[4]
		GetClientRect( hwnd,rect )
		Local t:TD3D7Graphics=New TD3D7Graphics
		t._hwnd=hwnd
		t._width=rect[2]
		t._height=rect[3]
		t._flags=flags
		Return t
	End Function
	
	Function Create:TD3D7Graphics( width,height,depth,hertz,flags )
		Global _reg
		If Not _reg
			If _bbusew
				Local wc:WNDCLASSW=New WNDCLASSW
				wc.hInstance=GetModuleHandleA( Null )
				wc.lpfnWndProc=WndProc
				wc.hCursor=LoadCursorA( Null,Byte Ptr IDC_ARROW )
				wc.lpszClassName=_wndClassW
				RegisterClassW( wc )
				_reg=True
			Else
				Local wc:WNDCLASS=New WNDCLASS
				wc.hInstance=GetModuleHandleA( Null )
				wc.lpfnWndProc=WndProc
				wc.hCursor=LoadCursorA( Null,Byte Ptr IDC_ARROW )
				wc.lpszClassName=_wndClass
				RegisterClassA( wc )
				_reg=True
			EndIf
		EndIf

		Local hinst=GetModuleHandleA( Null )
		Local title:Byte Ptr=AppTitle.ToCString()
		
		Local titleW$=AppTitle
		Local _wndClassW$=String.FromCString( _wndClass )
		
		Local hwnd

		If depth
			If _bbusew
				hwnd=CreateWindowExW( 0,_wndClassW,titleW,WS_VISIBLE|WS_POPUP,0,0,width,height,0,0,hinst,Null )
			Else
				hwnd=CreateWindowExA( 0,_wndClass,title,WS_VISIBLE|WS_POPUP,0,0,width,height,0,0,hinst,Null )
			EndIf
		Else
			Local style=WS_VISIBLE|WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX
			Local rect[]=[32,32,width+32,height+32]

			Local desktopHWND:Int=GetDesktopWindow()
			Local desktopRect:Int[]=New Int[4]
			GetWindowRect( desktopHWND,desktopRect)
			
			rect[0]=desktopRect[2]/2-width/2;		
			rect[1]=desktopRect[3]/2-height/2;		
			rect[2]=rect[0]+width;
			rect[3]=rect[1]+height;
			
			AdjustWindowRect rect,style,0
			If _bbusew
				hwnd=CreateWindowExW( 0,_wndClassW,titleW,style,rect[0],rect[1],rect[2]-rect[0],rect[3]-rect[1],0,0,hinst,Null )
			Else
				hwnd=CreateWindowExA( 0,_wndClass,title,style,rect[0],rect[1],rect[2]-rect[0],rect[3]-rect[1],0,0,hinst,Null )
			EndIf
			GetClientRect hwnd,rect
			width=rect[2]-rect[0]
			height=rect[3]-rect[1]
		EndIf

		MemFree title

		If Not hwnd Return
		
		Local t:TD3D7Graphics=New TD3D7Graphics
		t._hwnd=hwnd
		t._width=width
		t._height=height
		t._depth=depth
		t._hertz=hertz
		t._flags=flags
		Return t
	End Function
	
	Method ValidateSize()
		If _depth Return
		Local rect[4]
		GetClientRect _hwnd,rect
		Local width=rect[2],height=rect[3]
		If width<=0 Or height<=0 Return
		If width=_width And height=_height Return
		dlog "Size invalidated"
		DestroyRenderSurface
		_width=width
		_height=height
	End Method
	
	Field _width,_height,_depth,_hertz,_flags

	Field _hwnd
	Field _clipper:IDirectDrawClipper
	Field _renderSurf:IDirectDrawSurface7
	
	Global _primSurf:IDirectDrawSurface7,_primRefs
	
End Type

Type TD3D7GraphicsDriver Extends TGraphicsDriver

	Method GraphicsModes:TGraphicsMode[]()
		Return _modes
	End Method
	
	Method AttachGraphics:TD3D7Graphics( hwnd,flags )
		If _n_fullscreen Return
		Local g:TD3D7graphics=TD3D7Graphics.Attach( hwnd,flags )
		If g _n_graphics:+1
		_graphicss.AddLast g
		Return g
	End Method
		
	Method CreateGraphics:TD3D7Graphics( width,height,depth,hertz,flags )
		If _n_fullscreen Return
		If depth 
			If _n_graphics Return
			Local mode:TGraphicsMode=BestMode( width,height,depth,hertz,_modes )
			If Not mode Return
			depth=mode.depth
			hertz=mode.hertz
		EndIf
		Local g:TD3D7Graphics=TD3D7Graphics.Create( width,height,depth,hertz,flags )
		If Not g Return
		_graphicss.AddLast g
		If depth _n_fullscreen:+1
		_n_graphics:+1
		Return g
	End Method
	
	'Internal use only...
	Method CloseGraphics( g:TD3D7Graphics )
		If _n_graphics=1
			_Destroy
		Else
			g.DestroyRenderSurface
		EndIf
		_graphicss.Remove g
		If g=_graphics 
			_graphics=Null
			IsValid=False
		EndIf
		_n_graphics:-1
		_n_fullscreen=0
	End Method

	Method SetGraphics( g:TGraphics )
		_graphics=TD3D7Graphics( g )
		ValidateGraphics True
	End Method
	
	Method Graphics:TD3D7Graphics()
		Return _graphics
	End Method
	
	Method Flip( sync )
		If IsValid
			If _inScene _d3ddev7.EndScene
			_graphics.Flip sync
		EndIf
		ValidateGraphics True
	End Method
	
	Method DirectDraw7:IDirectDraw7()
		Return _dd7
	End Method
	
	Method Direct3D7:IDirect3D7()
		Return _d3d7
	End Method
	
	Method Direct3DDevice7:IDirect3DDevice7()
		Return _d3ddev7
	End Method
	
	Method BeginScene()
		_inScene=True
		If IsValid _d3ddev7.BeginScene
	End Method
	
	Method EndScene()
		If IsValid _d3ddev7.EndScene
		_inScene=False
	End Method
	
	Method CreateSurface:IDirectDrawSurface7( desc:DDSURFACEDESC2 )
		Local surf:IDirectDrawSurface7
		Local err=_dd7.CreateSurface( desc,Varptr surf,Null )
		If err<0
			dlog "CreateSurface failed:"+dderrstr(err)
			Return Null
		EndIf
		Local t:TD3D7Surface=New TD3D7Surface
		t.surf=surf
		_surfaces.AddLast t
		dlog "CreateSurface OK"
		Return surf
	End Method
	
	Method DestroySurface( surf:IDirectDrawSurface7 )
		For Local t:TD3D7Surface=EachIn _surfaces
			If t.surf<>surf Continue
			dlog "Destroy surface="+surf.Release_()
			_surfaces.Remove t
			Return
		Next
	End Method
	
	Method _ValidateGraphics()
		If Not _graphics Return False

		Local coop
		
		If _dd7
			coop=_dd7.TestCooperativeLevel()
			If coop=DDERR_WRONGMODE
				dlog "DDERR_WRONGMODE"
				_Destroy
			EndIf
		EndIf

		If Not _dd7
			If Not _Create() Return False
			coop=_dd7.TestCooperativeLevel()
		EndIf
		
		If coop<0 Return False
		
		Local renderSurf:IDirectDrawSurface7=_graphics.RenderSurface()
		If renderSurf
			If renderSurf.IsLost()<0
				DXASS _dd7.RestoreAllSurfaces()
			EndIf
			DXASS _d3ddev7.SetRenderTarget( renderSurf,0 )
		Else
			renderSurf=_graphics.CreateRenderSurface()
			If _d3ddev7
				DXASS _d3ddev7.SetRenderTarget( renderSurf,0 )
			Else
				If _d3d7.CreateDevice( IID_IDirect3DTnLDevice,renderSurf,Varptr _d3ddev7 )<0
					DXASS _d3d7.CreateDevice( IID_IDirect3DHALDevice,renderSurf,Varptr _d3ddev7 )
				EndIf
			EndIf
		EndIf

		Return True

	End Method
	
	Method ValidateGraphics( force=False )
		Global _busy
		If _busy
			dlog "busy: Valid="+IsValid
			Return IsValid
		EndIf
		_busy=True
		
		Local valid=IsValid
		If valid Or force valid=_ValidateGraphics()
		
		If valid<>IsValid
			dlog "Valid="+valid
			If valid And _inScene _d3ddev7.BeginScene()
		EndIf
		
		IsValid=valid
		
		_busy=False
		Return IsValid
	End Method

	Function Create:TD3D7GraphicsDriver()
		If _driver Return _driver
		
		_driver=New TD3D7GraphicsDriver._Create()
		If Not _driver Return
		
		Local mlist:TList=New TList
		_driver._dd7.EnumDisplayModes( DDEDM_REFRESHRATES,Null,mlist,EnumModesCallback )
		Local i
		_driver._modes=New TGraphicsMode[mlist.Count()]
		For Local mode:TGraphicsMode=EachIn mlist
			_driver._modes[i]=mode
			i:+1
		Next

		_driver._Destroy
		Return _driver
	End Function
	
	Method _Create:TD3D7GraphicsDriver()
	
		If Not DirectDrawCreateEx Return Null

		If DirectDrawCreateEx( Null,Varptr _dd7,IID_IDirectDraw7,Null )<0 Return _Destroy()

		If _dd7.SetCooperativeLevel( 0,DDSCL_NORMAL|DDSCL_FPUPRESERVE )<0 Return _Destroy()

		Local caps:DDCAPS_DX7=New DDCAPS_DX7
		caps.dwSize=SizeOf( DDCAPS_DX7 )
		If _dd7.GetCaps( caps,Null )<0 Return _Destroy()
		If Not (caps.dwCaps & DDCAPS_3D) Return _Destroy()
		
		If _dd7.QueryInterface( IID_IDirect3D7,Byte Ptr Ptr(Varptr _d3d7) )<0 Return _Destroy()
		
		BumpGraphicsSeq
		
		dlog "_Created"
		
		Return Self
	End Method
	
	Method _Destroy:TD3D7GraphicsDriver()

		dlog "_Destroying"
		
		BumpGraphicsSeq
		
		'have to destroy device before renderSurfs or crash in fullscreen
		If _d3ddev7 _d3ddev7.Release_

		For Local t:TD3D7Surface=EachIn _surfaces
			dlog "Destroy surface="+t.surf.Release_()
		Next

		For Local t:TD3D7Graphics=EachIn _graphicss
			t.DestroyRenderSurface
		Next

		If _d3d7 _d3d7.Release_

		If _dd7 dlog "Release dd7="+_dd7.Release_()

		_dd7=Null
		_d3d7=Null
		_d3ddev7=Null
		_surfaces.Clear

		Return Null
	End Method
	
	Global IsValid

	Field _modes:TGraphicsMode[]

	Field _dd7:IDirectDraw7
	Field _d3d7:IDirect3D7
	Field _d3ddev7:IDirect3DDevice7
	
	Field _graphics:TD3D7Graphics
	Field _n_graphics,_n_fullscreen,_inScene
	
	Field _surfaces:TList=New TList
	Field _graphicss:TList=New TList

End Type

Function D3D7GraphicsDriver:TD3D7GraphicsDriver()
	Return TD3D7GraphicsDriver.Create()
End Function

