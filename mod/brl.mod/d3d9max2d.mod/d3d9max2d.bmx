
Strict

Rem
bbdoc: Graphics/Direct3D9 Max2D
about:
The Direct3D9 Max2D module provides a Direct3D9 driver for #Max2D.
End Rem
Module BRL.D3D9Max2D

ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

?Win32

Import BRL.Max2D
Import BRL.DXGraphics

Import BRL.D3D7Max2D

Const LOG_ERRS=True'False

Private

Global _gw,_gh,_gd,_gr,_gf
Global _color
Global _clscolor
Global _ix#,_iy#,_jx#,_jy#
Global _fverts#[24]
Global _iverts:Int Ptr=Int Ptr( Varptr _fverts[0] )
Global _lineWidth#

Global _bound_texture:IDirect3DTexture9
Global _texture_enabled

Global _active_blend

Global _driver:TD3D9Max2DDriver
Global _d3dDev:IDirect3DDevice9
Global _d3d9Graphics:TD3D9Graphics
Global _max2dGraphics:TMax2dGraphics

Function Pow2Size( n )
	Local t=1
	While t<n
		t:*2
	Wend
	Return t
End Function

Function DisableTex()
	If Not _texture_enabled Return
	_d3dDev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_SELECTARG2
	_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
	_texture_enabled=False
End Function

Function d3derr( str$ )
	If LOG_ERRS WriteStdout "D3DERR: "+str+"~n"
End Function

Public

Type TD3D9ImageFrame Extends TImageFrame

	Method Delete()
		If _texture
			If _seq=GraphicsSeq
				If _texture=_bound_texture
					_d3dDev.SetTexture 0,Null
					_bound_texture=Null
				EndIf
				_d3d9Graphics.ReleaseNow _texture
			EndIf
			_texture=Null
		EndIf
	End Method

	Method Create:TD3D9ImageFrame( pixmap:TPixmap,flags )
	
		Local width=pixmap.width,pow2width=Pow2Size( width )
		Local height=pixmap.height,pow2height=Pow2Size( height )
		
		If width<pow2width Or height<pow2height
			Local src:TPixmap=pixmap
			pixmap=TPixmap.Create( pow2width,pow2height,PF_BGRA8888 )
			pixmap.Paste src,0,0
			If width<pow2width
				pixmap.Paste pixmap.Window( width-1,0,1,height ),width,0
			EndIf
			If height<pow2height
				pixmap.Paste pixmap.Window( 0,height-1,width,1 ),0,height
				If width<pow2width 
					pixmap.Paste pixmap.Window( width-1,height-1,1,1 ),width,height
				EndIf
			EndIf
		Else
			If pixmap.Format<>PF_BGRA8888 pixmap=pixmap.Convert( PF_BGRA8888 )
		EndIf

		Local levels=(flags & MIPMAPPEDIMAGE)=0
		Local format=D3DFMT_A8R8G8B8
		Local usage=0
		Local pool=D3DPOOL_MANAGED
		
		If _d3dDev.CreateTexture( pow2width,pow2height,levels,usage,format,pool,_texture,Null )<0
			d3derr "Unable to create texture~n"
			Return
		EndIf
		
		_d3d9Graphics.AutoRelease _texture

		Local level
		Repeat
			Local dstsurf:IDirect3DSurface9
			If _texture.GetSurfaceLevel( level,dstsurf )<0
				If level=0
					d3derr "_texture.GetSurfaceLevel failed~n"
				EndIf
				Exit
			EndIf

			Local lockedrect:D3DLOCKED_RECT=New D3DLOCKED_RECT
			If dstsurf.LockRect( lockedrect,Null,0 )<0
				d3derr "dstsurf.LockRect failed~n"
			EndIf
		
			For Local y=0 Until pixmap.height
				Local src:Byte Ptr=pixmap.pixels+y*pixmap.pitch
				Local dst:Byte Ptr=lockedrect.pBits+y*lockedrect.Pitch
				MemCopy dst,src,pixmap.width*4
			Next
		
			dstsurf.UnlockRect
			dstsurf.Release_
			
			If (flags & MIPMAPPEDIMAGE)=0 Exit

			level:+1

			If pixmap.width>1 And pixmap.height>1
				pixmap=ResizePixmap( pixmap,pixmap.width/2,pixmap.height/2 )
			Else If pixmap.width>1
				pixmap=ResizePixmap( pixmap,pixmap.width/2,pixmap.height )
			Else If pixmap.height>1
				pixmap=ResizePixmap( pixmap,pixmap.width,pixmap.height/2 )
			EndIf
		Forever
		
		_uscale=1.0/pow2width
		_vscale=1.0/pow2height

		Local u0#,u1#=width * _uscale
		Local v0#,v1#=height * _vscale

		_fverts[4]=u0
		_fverts[5]=v0
		_fverts[10]=u1
		_fverts[11]=v0
		_fverts[16]=u1
		_fverts[17]=v1
		_fverts[22]=u0
		_fverts[23]=v1
		
		If flags & FILTEREDIMAGE
			_magfilter=D3DTFG_LINEAR
			_minfilter=D3DTFG_LINEAR
			_mipfilter=D3DTFG_LINEAR
		Else
			_magfilter=D3DTFG_POINT
			_minfilter=D3DTFG_POINT
			_mipfilter=D3DTFG_POINT
		EndIf
		
		_seq=GraphicsSeq
		
		Return Self
	End Method
	
	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# )
		Local u0#=sx * _uscale
		Local v0#=sy * _vscale
		Local u1#=(sx+sw) * _uscale
		Local v1#=(sy+sh) * _vscale
	
		_fverts[0]=x0*_ix+y0*_iy+tx
		_fverts[1]=x0*_jx+y0*_jy+ty
		_iverts[3]=_color
		_fverts[4]=u0
		_fverts[5]=v0
		
		_fverts[6]=x1*_ix+y0*_iy+tx
		_fverts[7]=x1*_jx+y0*_jy+ty
		_iverts[9]=_color
		_fverts[10]=u1
		_fverts[11]=v0
		
		_fverts[12]=x1*_ix+y1*_iy+tx
		_fverts[13]=x1*_jx+y1*_jy+ty
		_iverts[15]=_color
		_fverts[16]=u1
		_fverts[17]=v1
		
		_fverts[18]=x0*_ix+y1*_iy+tx
		_fverts[19]=x0*_jx+y1*_jy+ty
		_iverts[21]=_color
		_fverts[22]=u0
		_fverts[23]=v1
		
		If _texture<>_bound_texture
			_d3dDev.SetTexture 0,_texture
			_d3dDev.SetTextureStageState 0,D3DTSS_MAGFILTER,_magfilter
			_d3dDev.SetTextureStageState 0,D3DTSS_MINFILTER,_minfilter
			_d3dDev.SetTextureStageState 0,D3DTSS_MIPFILTER,_mipfilter
			_bound_texture=_texture
		EndIf
		
		If Not _texture_enabled
			_d3dDev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_MODULATE
			_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_MODULATE
			_texture_enabled=True
		EndIf
		
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,2,_fverts,24
	End Method
	
	Field _texture:IDirect3DTexture9,_seq
	
	Field _magfilter,_minfilter,_mipfilter,_uscale#,_vscale#
	
	Field _fverts#[24],_iverts:Int Ptr=Int Ptr( Varptr _fverts[0] )

End Type

Type TD3D9Max2DDriver Extends TMax2dDriver

	Method ToString$()
		Return "DirectX9"
	End Method

	Method Create:TD3D9Max2DDriver()
		If Not D3D9GraphicsDriver() Return Null
		
		Local d3d:IDirect3D9=D3D9GraphicsDriver().GetDirect3D()

		If d3d.CheckDeviceFormat( D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,D3DFMT_X8R8G8B8,0,D3DRTYPE_TEXTURE,D3DFMT_A8R8G8B8 )<0
			Return Null
		EndIf
		
		Return Self
	End Method

	'***** TGraphicsDriver *****
	Method GraphicsModes:TGraphicsMode[]()
		Return D3D9GraphicsDriver().GraphicsModes()
	End Method
	
	Method AttachGraphics:TGraphics( widget,flags )
		Local g:TD3D9Graphics=D3D9GraphicsDriver().AttachGraphics( widget,flags )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags )
		Local g:TD3D9Graphics=D3D9GraphicsDriver().CreateGraphics( width,height,depth,hertz,flags )
		If Not g Return Null
		Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method SetGraphics( g:TGraphics )
		If Not g
			If _d3dDev
				_d3dDev.EndScene
				_d3dDev=Null
			EndIf
			_d3d9graphics=Null
			_max2dGraphics=Null
			TMax2DGraphics.ClearCurrent
			D3D9GraphicsDriver().SetGraphics Null
			Return
		EndIf

		_max2dGraphics=TMax2dGraphics( g )

		_d3d9graphics=TD3D9Graphics( _max2dGraphics._graphics )

		Assert _max2dGraphics And _d3d9graphics

		_d3dDev=_d3d9Graphics.GetDirect3DDevice()
		
		D3D9GraphicsDriver().SetGraphics _d3d9Graphics

		If _d3dDev.TestCooperativeLevel()<>D3D_OK Return
		
		ResetDevice

		_max2dGraphics.MakeCurrent
		
	End Method
	
	Method Flip( sync )
		_d3dDev.EndScene
		If D3D9GraphicsDriver().Flip( sync )
			_d3dDev.BeginScene
		Else If _d3dDev.TestCooperativeLevel()=D3D_OK
			ResetDevice
			_max2dGraphics.MakeCurrent
		EndIf

	End Method
	
	Method ResetDevice()
	
		_d3d9graphics.ValidateSize
		_d3d9graphics.GetSettings _gw,_gh,_gd,_gr,_gf
	
		Local viewport:D3DVIEWPORT9=New D3DVIEWPORT9
		viewport.X=0
		viewport.Y=0
		viewport.Width=_gw
		viewport.Height=_gh
		viewport.MinZ=0.0
		viewport.MaxZ=1.0
		_d3dDev.SetViewport viewport

		_d3dDev.SetRenderState D3DRS_ALPHAREF,$80
		_d3dDev.SetRenderState D3DRS_ALPHAFUNC,D3DCMP_GREATEREQUAL

		_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
		_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,False
		_active_blend=SOLIDBLEND
		
		_d3dDev.SetRenderState D3DRS_LIGHTING,False
		_d3dDev.SetRenderState D3DRS_CULLMODE,D3DCULL_NONE	
		
		_d3dDev.SetTexture 0,Null
		_bound_texture=Null
		
		_d3dDev.SetFVF D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1
		
		_d3dDev.SetTextureStageState 0,D3DTSS_COLORARG1,D3DTA_TEXTURE		
		_d3dDev.SetTextureStageState 0,D3DTSS_COLORARG2,D3DTA_DIFFUSE		
		_d3dDev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_SELECTARG2
		_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAARG1,D3DTA_TEXTURE
		_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAARG2,D3DTA_DIFFUSE
		_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
		_texture_enabled=False
		
		_d3dDev.SetTextureStageState 0,D3DTSS_ADDRESS,D3DTADDRESS_CLAMP
	
		_d3dDev.SetTextureStageState 0,D3DTSS_MAGFILTER,D3DTFG_POINT
		_d3dDev.SetTextureStageState 0,D3DTSS_MINFILTER,D3DTFN_POINT
		_d3dDev.SetTextureStageState 0,D3DTSS_MIPFILTER,D3DTFP_POINT
		
		_d3dDev.BeginScene

	End Method

	'***** TMax2DDriver *****
	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags )
		Return New TD3D9ImageFrame.Create( pixmap,flags )
	End Method
	
	Method SetBlend( blend )
		If blend=_active_blend Return
		Select blend
		Case SOLIDBLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,False
		Case MASKBLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,True
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,False
		Case ALPHABLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,True
			_d3dDev.SetRenderState D3DRS_SRCBLEND,D3DBLEND_SRCALPHA
			_d3dDev.SetRenderState D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA
		Case LIGHTBLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,True
			_d3dDev.SetRenderState D3DRS_SRCBLEND,D3DBLEND_SRCALPHA
			_d3dDev.SetRenderState D3DRS_DESTBLEND,D3DBLEND_ONE
		Case SHADEBLEND		
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,True
			_d3dDev.SetRenderState D3DRS_SRCBLEND,D3DBLEND_ZERO
			_d3dDev.SetRenderState D3DRS_DESTBLEND,D3DBLEND_SRCCOLOR
		End Select
		_active_blend=blend
	End Method
	
	Method SetAlpha( alpha# )
		alpha=Max(Min(alpha,1),0)
		_color=(Int(255*alpha) Shl 24)|(_color&$ffffff)
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method
	
	Method SetColor( red,green,blue )
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		_color=(_color&$ff000000)|(red Shl 16)|(green Shl 8)|blue		
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method
	
	Method SetClsColor( red,green,blue )
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		_clscolor=$ff000000|(red Shl 16)|(green Shl 8)|blue
	End Method
	
	Method SetViewport( x,y,width,height )
		If x=0 And y=0 And width=_gw And height=_gh 'GraphicsWidth() And height=GraphicsHeight()
			_d3dDev.SetRenderState D3DRS_SCISSORTESTENABLE,False
		Else
			_d3dDev.SetRenderState D3DRS_SCISSORTESTENABLE,True
			Local rect[]=[x,y,x+width,y+height]
			_d3dDev.SetScissorRect rect
		EndIf
	End Method
	
	Method SetTransform( xx#,xy#,yx#,yy# )
		_ix=xx
		_iy=xy
		_jx=yx
		_jy=yy		
	End Method
	
	Method SetLineWidth( width# )
		_lineWidth=width
	End Method
	
	Method Cls()
		_d3dDev.Clear 0,Null,D3DCLEAR_TARGET,_clscolor,0,0
	End Method
	
	Method Plot( x#,y# )
		_fverts[0]=x+.5
		_fverts[1]=y+.5
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_POINTLIST,1,_fverts,24
	End Method
	
	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# )
		Local lx0# = x0*_ix + y0*_iy + tx
		Local ly0# = x0*_jx + y0*_jy + ty
		Local lx1# = x1*_ix + y1*_iy + tx
		Local ly1# = x1*_jx + y1*_jy + ty
		If _lineWidth<=1
			_fverts[0]=lx0+.5
			_fverts[1]=ly0+.5
			_fverts[6]=lx1+.5
			_fverts[7]=ly1+.5
			DisableTex
			_d3dDev.DrawPrimitiveUP D3DPT_LINELIST,1,_fverts,24
			Return
		EndIf
		Local lw#=_lineWidth*.5
		If Abs(ly1-ly0)>Abs(lx1-lx0)
			_fverts[0]=lx0-lw
			_fverts[1]=ly0
			_fverts[6]=lx0+lw
			_fverts[7]=ly0
			_fverts[12]=lx1-lw
			_fverts[13]=ly1
			_fverts[18]=lx1+lw
			_fverts[19]=ly1
		Else
			_fverts[0]=lx0
			_fverts[1]=ly0-lw
			_fverts[6]=lx0
			_fverts[7]=ly0+lw
			_fverts[12]=lx1
			_fverts[13]=ly1-lw
			_fverts[18]=lx1
			_fverts[19]=ly1+lw
		EndIf
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLESTRIP,2,_fverts,24
	End Method
	
	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# )
		_fverts[0]  = x0*_ix + y0*_iy + tx
		_fverts[1]  = x0*_jx + y0*_jy + ty
		_fverts[6]  = x1*_ix + y0*_iy + tx
		_fverts[7]  = x1*_jx + y0*_jy + ty
		_fverts[12] = x0*_ix + y1*_iy + tx
		_fverts[13] = x0*_jx + y1*_jy + ty
		_fverts[18] = x1*_ix + y1*_iy + tx
		_fverts[19] = x1*_jx + y1*_jy + ty
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLESTRIP,2,_fverts,24
	End Method
	
	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# )
		Local xr#=(x1-x0)*.5
		Local yr#=(y1-y0)*.5
		Local segs=Abs(xr)+Abs(yr)
		segs=Max(segs,12)&~3
		x0:+xr
		y0:+yr
		Local fverts#[segs*6]
		Local iverts:Int Ptr=Int Ptr( Varptr fverts[0] )
		For Local i=0 Until segs
			Local th#=-i*360#/segs
			Local x#=x0+Cos(th)*xr
			Local y#=y0-Sin(th)*yr
			fverts[i*6+0]=x*_ix+y*_iy+tx
			fverts[i*6+1]=x*_jx+y*_jy+ty			
			iverts[i*6+3]=_color
		Next
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,segs-2,fverts,24
	End Method
	
	Method DrawPoly( verts#[],handlex#,handley#,tx#,ty# )
		If verts.length<6 Or (verts.length&1) Return
		Local segs=verts.length/2
		Local fverts#[segs*6]
		Local iverts:Int Ptr=Int Ptr( Varptr fverts[0] )
		For Local i=0 Until segs
			Local x#=verts[i*2+0]+handlex
			Local y#=verts[i*2+1]+handley
			fverts[i*6+0]= x*_ix + y*_iy + tx
			fverts[i*6+1]= x*_jx + y*_jy + ty
			iverts[i*6+3]=_color
		Next
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,segs-2,fverts,24
	End Method
		
	'GetDC/BitBlt MUCH faster than locking backbuffer!	
	Method DrawPixmap( pixmap:TPixmap,x,y )
		Local width=pixmap.width,height=pixmap.height
	
		Local dstsurf:IDirect3DSurface9
		If _d3dDev.GetRenderTarget( 0,dstsurf )<0
			d3derr "GetRenderTarget failed~n"
			Return
		EndIf
		
		Local desc:D3DSURFACE_DESC=New D3DSURFACE_DESC
		If dstsurf.GetDesc( desc )<0
			d3derr "GetDesc failed~n"
		EndIf
		
		Local rect[]=[x,y,x+width,y+height]
		Local lockedrect:D3DLOCKED_RECT=New D3DLOCKED_RECT
		If dstsurf.LockRect( lockedrect,rect,0 )<0
			d3derr "Unable to lock render target surface~n"
			dstsurf.Release_
			Return
		EndIf
		
		Local dstpixmap:TPixmap=CreateStaticPixmap( lockedrect.pBits,width,height,lockedrect.Pitch,PF_BGRA8888 );
		
		dstpixmap.Paste pixmap,0,0
		
		dstsurf.UnlockRect
		dstsurf.Release_
	End Method

	'GetDC/BitBlt MUCH faster than locking backbuffer!	
	Method GrabPixmap:TPixmap( x,y,width,height )
	
		Local srcsurf:IDirect3DSurface9
		If _d3dDev.GetRenderTarget( 0,srcsurf )<0
			d3derr "GetRenderTarget failed~n"
		EndIf

		Local dstsurf:IDirect3DSurface9
		If _d3dDev.CreateOffscreenPlainSurface( width,height,D3DFMT_X8R8G8B8,D3DPOOL_SYSTEMMEM,dstsurf,Null )<0
			d3derr "CreateOffscreenPlainSurface failed~n"
		EndIf
		
		Local srcdc:Byte Ptr
		If srcsurf.GetDC( srcdc )<0
			d3derr "srcsurf.GetDC failed~n"
		EndIf
		
		Local dstdc:Byte Ptr
		If dstsurf.GetDC( dstdc )<0
			d3derr "dstsurf.GetDC failed~n"
		EndIf
		
		BitBlt Int(dstdc),0,0,width,height,Int(srcdc),x,y,ROP_SRCCOPY
		
		srcsurf.ReleaseDC srcdc
		dstsurf.ReleaseDC dstdc
		
		Local lockedrect:D3DLOCKED_RECT=New D3DLOCKED_RECT
		If dstsurf.LockRect( lockedrect,Null,D3DLOCK_READONLY )<0
			d3derr "dstsurf.LockRect failed~n"
		EndIf
		
		Local pixmap:TPixmap=CreatePixmap( width,height,PF_BGRA8888 )
		
		'Copy and set alpha in the process...
		For Local y=0 Until height
			Local src:Int Ptr=Int Ptr( lockedrect.pBits+y*lockedrect.Pitch )
			Local dst:Int Ptr=Int Ptr( pixmap.PixelPtr( 0,y ) )
			For Local x=0 Until width
				dst[x]=src[x] | $ff000000
			Next
		Next
		
		srcsurf.Release_
		dstsurf.Release_
		
		Return pixmap
	End Method
	
	Method SetResolution( width#,height# )
		Local matrix#[]=[..
		2.0/width,0.0,0.0,0.0,..
		 0.0,-2.0/height,0.0,0.0,..
		 0.0,0.0,1.0,0.0,..
		 -1-(1.0/width),1+(1.0/height),1.0,1.0]

		_d3dDev.SetTransform D3DTS_PROJECTION,matrix
	End Method
	
End Type

Rem
bbdoc: Get Direct3D9 Max2D Driver
about:
The returned driver can be used with #SetGraphicsDriver to enable Direct3D9 Max2D rendering.
End Rem
Function D3D9Max2DDriver:TD3D9Max2DDriver()
	Global _done
	If Not _done
		_driver=New TD3D9Max2DDriver.Create()
		_done=True
	EndIf
	Return _driver
End Function

Local driver:TD3D9Max2DDriver=D3D9Max2DDriver()
If driver SetGraphicsDriver driver

?
