
Strict

Rem
bbdoc: Graphics/Direct3D7 Max2D
about:
The Direct3D7 Max2D module provides a Direct3D7 driver for #Max2D.
End Rem
Module BRL.D3D7Max2D

ModuleInfo "Version: 1.19"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.19 Release"
ModuleInfo "History: Fixed/cleaned up a few things"
ModuleInfo "History: 1.18 Release"
ModuleInfo "History: Updated to work with d3d7graphics rewrite"
ModuleInfo "History: Removed buffered driver"
ModuleInfo "History: 1.17 Release"
ModuleInfo "History: Modified TD3D7Max2DDriver.SetGraphics for new dxgraphics commands"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: Fixed BufferedD3D7 vertex color errors"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Changed DrawImage tristrip to trifan to fix subpixel cracking"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Fixed MIPMAPPEDIMAGE flag effect on FILTEREDIMAGE setting"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Fixed lost device from fullscreen tabbing"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Fixed memory leak in TD3d7ImageFrame"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Fixed default mipmap filtering for imageframes"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Added flush to BufferedD3D7Max2DDriver for SetBlend and SetViewPort and Draw/GrabPixmap"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Added new BufferedD3D7Max2DDriver for optimization testing"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Replaced texture factor with vertex colors to improve compatability"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Added GL fallback for DX device failure"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Added line width support and tweaked line positioning"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added MIPMAPPEDIMAGE support"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added a bunch of redundant state change checks"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Now default driver for Win32"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Fixed negative scales"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed LIGHTBLEND"
ModuleInfo "History: Clamped alpha/color/clsColor"
ModuleInfo "History: Fixed viewport (now uses clip planes)"
ModuleInfo "History: Fixed Mag filter"

?Win32

Import BRL.DXGraphics
Import BRL.GLMax2D

Type TD3D7Max2DDriver Extends TMax2DDriver

	Field		device:IDirect3DDevice7
	Field		d3d7graphics:TD3D7Graphics

	Field		drawalpha		'0..255
	Field		drawcolor
	Field		clscolor
	Field		ix#,iy#,jx#,jy#
	Field		linewidth#
	Field		cverts#[16]
	Field		vrts:Int Ptr'=Int Ptr(Varptr cverts[0])
	Field		vp_rect[]
	Field		activeBlend
	Field		activeFrame:TD3D7ImageFrame
	Field		activeFrameFlags

	Method New()
		vrts=Int Ptr(Varptr cverts[0])
	End Method
	
	Method ToString$()
		Return "DirectX7"
	End Method

	Method IsValid()
		Return TD3D7graphicsDriver.IsValid
	End Method
	
	Method GraphicsModes:TGraphicsMode[]()
		Return D3D7GraphicsDriver().GraphicsModes()
	End Method
		
	Method AttachGraphics:TMax2DGraphics( widget,flags )
		Local g:TD3D7Graphics=D3D7GraphicsDriver().AttachGraphics( widget,flags )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method CreateGraphics:TMax2DGraphics( width,height,depth,hertz,flags )
		Local g:TD3D7Graphics=D3D7GraphicsDriver().CreateGraphics( width,height,depth,hertz,flags )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method SetGraphics( g:TGraphics )
		If Not g
			TMax2DGraphics.ClearCurrent
			D3D7GraphicsDriver().EndScene
			D3D7GraphicsDriver().SetGraphics Null
			Return
		EndIf
		
		Local t:TMax2DGraphics=TMax2DGraphics( g )
		Assert t And TD3D7Graphics( t._graphics )

		D3D7GraphicsDriver().SetGraphics t._graphics
		
		ResetD3DDevice t
		
		t.MakeCurrent

		D3D7GraphicsDriver().BeginScene
	End Method
	
	Method ResetD3DDevice( g:TGraphics )
		If Not IsValid() Return
		
		Local gw,gh,gd,gr,gf
		g.GetSettings gw,gh,gd,gr,gf
				
		device=D3D7GraphicsDriver().Direct3DDevice7()

		Local viewport:D3DVIEWPORT7=New D3DVIEWPORT7
		viewport.dwX=0
		viewport.dwY=0
		viewport.dwWidth=gw
		viewport.dwHeight=gh
		viewport.dvMinZ=0.0
		viewport.dvMaxZ=1.0
		device.SetViewport(viewport)

		device.SetTexture 0,Null

		device.SetRenderState D3DRS_ALPHAREF,$80
		device.SetRenderState D3DRS_ALPHAFUNC,D3DCMP_GREATEREQUAL 
		device.SetRenderState D3DRS_ALPHATESTENABLE,False
		device.SetRenderState D3DRS_ALPHABLENDENABLE,False
		
		device.SetRenderState D3DRS_LIGHTING,False
		device.SetRenderState D3DRS_CULLMODE,D3DCULL_NONE		
		
		device.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_SELECTARG2
		device.SetTextureStageState 0,D3DTSS_COLORARG1,D3DTA_TEXTURE		
		device.SetTextureStageState 0,D3DTSS_COLORARG2,D3DTA_DIFFUSE		
	
		device.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
		device.SetTextureStageState 0,D3DTSS_ALPHAARG1,D3DTA_TEXTURE
		device.SetTextureStageState 0,D3DTSS_ALPHAARG2,D3DTA_DIFFUSE

		device.SetTextureStageState 0,D3DTSS_ADDRESS,D3DTADDRESS_CLAMP
	
		device.SetTextureStageState 0,D3DTSS_MAGFILTER,D3DTFG_POINT
		device.SetTextureStageState 0,D3DTSS_MINFILTER,D3DTFN_POINT
		device.SetTextureStageState 0,D3DTSS_MIPFILTER,D3DTFP_POINT
	
		activeFrame=Null
		activeFrameFlags=0
		activeBlend=SOLIDBLEND
	End Method
	
	Method Flip( sync )
		Local seq=GraphicsSeq
		Local wasValid=IsValid()

		D3D7GraphicsDriver().Flip sync
		
		If Not IsValid() Return
		
		If wasValid And seq=GraphicsSeq Return
		
		ResetD3DDevice TMax2DGraphics.Current()

		TMax2DGraphics.Current().Validate
	End Method

	Method CreateFrameWithSize:TImageFrame( width,height,flags )
		If Not IsValid() Return

		Local frame:TD3D7ImageFrame=TD3D7ImageFrame.Create(Self,width,height,flags)
		Return frame
	End Method

	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags )
		If Not IsValid() Return

		Local frame:TD3D7ImageFrame=TD3D7ImageFrame.Create(Self,pixmap.Width,pixmap.Height,flags)
		Local locked:TPixmap=frame.Lock( False,True )
		locked.Paste pixmap,0,0
		frame.Unlock()
		Return frame
	End Method
	
	Method SetBlend( blend )
		If blend=activeBlend Return
		activeBlend=blend

		If Not IsValid() Return

		Select activeBlend
		Case SOLIDBLEND
			device.SetRenderState D3DRS_ALPHATESTENABLE,False
			device.SetRenderState D3DRS_ALPHABLENDENABLE,False
		Case MASKBLEND
			device.SetRenderState D3DRS_ALPHATESTENABLE,True
			device.SetRenderState D3DRS_ALPHABLENDENABLE,False
		Case ALPHABLEND
			device.SetRenderState D3DRS_ALPHATESTENABLE,False
			device.SetRenderState D3DRS_ALPHABLENDENABLE,True
			device.SetRenderState D3DRS_SRCBLEND,D3DBLEND_SRCALPHA
			device.SetRenderState D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA
		Case LIGHTBLEND
			device.SetRenderState D3DRS_ALPHATESTENABLE,False
			device.SetRenderState D3DRS_ALPHABLENDENABLE,True
			device.SetRenderState D3DRS_SRCBLEND,D3DBLEND_SRCALPHA
			device.SetRenderState D3DRS_DESTBLEND,D3DBLEND_ONE
		Case SHADEBLEND		
			device.SetRenderState D3DRS_ALPHATESTENABLE,False
			device.SetRenderState D3DRS_ALPHABLENDENABLE,True
			device.SetRenderState D3DRS_SRCBLEND,D3DBLEND_ZERO
			device.SetRenderState D3DRS_DESTBLEND,D3DBLEND_SRCCOLOR
		End Select	
	End Method

	Method SetAlpha( alpha# )
		alpha=Max(Min(alpha,1),0)
		drawcolor=(Int(255*alpha) Shl 24)|(drawcolor&$ffffff)
		vrts[3]=drawcolor
		vrts[7]=drawcolor
		vrts[11]=drawcolor
		vrts[15]=drawcolor
	End Method

	Method SetColor( red,green,blue )
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		drawcolor=(drawcolor&$ff000000)|(red Shl 16)|(green Shl 8)|blue		
		vrts[3]=drawcolor
		vrts[7]=drawcolor
		vrts[11]=drawcolor
		vrts[15]=drawcolor
	End Method
		
	Method SetClsColor( red,green,blue )
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		clscolor=$ff000000|(red Shl 16)|(green Shl 8)|blue
	End Method

	Method SetViewport( x,y,width,height )
		vp_rect=[x,y,x+width,y+height]
		
		If Not IsValid() Return
		
		If x=0 And y=0 And width=GraphicsWidth() And height=GraphicsHeight()
			device.SetRenderState D3DRS_CLIPPLANEENABLE,0
		Else
			Local err
			If device.SetClipPlane(0,[1.0,0.0,0.0,-Float(x)]) err=True
			If device.SetClipPlane(1,[-1.0,0.0,0.0,Float(x+width)]) err=True
			If device.SetClipPlane(2,[0.0,1.0,0.0,-Float(y)]) err=True
			If device.SetClipPlane(3,[0.0,-1.0,0.0,Float(y+height)]) err=True
			If err Throw "device does not support clipplanes"
			device.SetRenderState D3DRS_CLIPPLANEENABLE,15
		EndIf
	End Method

	Method SetTransform( xx#,xy#,yx#,yy# )
		ix=xx
		iy=xy
		jx=yx
		jy=yy		
	End Method

	Method SetLineWidth( width# )
		linewidth=width
	End Method
	
	Method Cls()
		If Not IsValid() Return

		device.Clear 1,vp_rect,D3DCLEAR_TARGET,clscolor,0,0
	End Method

	Method Plot( x#,y# )
		If Not IsValid() Return

		cverts[0]=x+.5001
		cverts[1]=y+.5001
		
		SetActiveFrame Null
		device.DrawPrimitive(D3DPT_POINTLIST,D3DFVF_XYZ|D3DFVF_DIFFUSE,cverts,1,0)
	End Method

	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# )
		If Not IsValid() Return

		Local lx0#,ly0#,lx1#,ly1#
		
		lx0=x0*ix+y0*iy+tx
		ly0=x0*jx+y0*jy+ty
		lx1=x1*ix+y1*iy+tx
		ly1=x1*jx+y1*jy+ty
		
		If linewidth<=1
			cverts[0]=lx0+.5001
			cverts[1]=ly0+.5001
			cverts[4]=lx1+.5001
			cverts[5]=ly1+.5001
			SetActiveFrame Null
			device.DrawPrimitive(D3DPT_LINELIST,D3DFVF_XYZ|D3DFVF_DIFFUSE,cverts,2,0)
		Else
			Local lw#=linewidth*0.5
			If Abs(ly1-ly0)>Abs(lx1-lx0)
				cverts[0]=lx0-lw
				cverts[1]=ly0
				cverts[4]=lx0+lw
				cverts[5]=ly0
				cverts[8]=lx1-lw
				cverts[9]=ly1
				cverts[12]=lx1+lw
				cverts[13]=ly1
			Else
				cverts[0]=lx0
				cverts[1]=ly0-lw
				cverts[4]=lx0
				cverts[5]=ly0+lw
				cverts[8]=lx1
				cverts[9]=ly1-lw
				cverts[12]=lx1
				cverts[13]=ly1+lw
			EndIf
			SetActiveFrame Null
			device.DrawPrimitive(D3DPT_TRIANGLESTRIP,D3DFVF_XYZ|D3DFVF_DIFFUSE,cverts,4,0)
		EndIf
	End Method

	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# )
		If Not IsValid() Return

		cverts[0]=x0*ix+y0*iy+tx
		cverts[1]=x0*jx+y0*jy+ty
		cverts[4]=x1*ix+y0*iy+tx
		cverts[5]=x1*jx+y0*jy+ty
		cverts[8]=x0*ix+y1*iy+tx
		cverts[9]=x0*jx+y1*jy+ty
		cverts[12]=x1*ix+y1*iy+tx
		cverts[13]=x1*jx+y1*jy+ty
		SetActiveFrame Null
		device.DrawPrimitive(D3DPT_TRIANGLESTRIP,D3DFVF_XYZ|D3DFVF_DIFFUSE,cverts,4,0)
	End Method

	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# )
		If Not IsValid() Return

		Local xr#=(x1-x0)*.5
		Local yr#=(y1-y0)*.5
		Local segs=Abs(xr)+Abs(yr)
		segs=Max(segs,12)&~3
		x0:+xr
		y0:+yr		
		Local vrts#[]=New Float[segs*4]	
		Local c:Int Ptr=Int Ptr(Float Ptr(vrts))
		For Local i=0 Until segs
			Local th#=-i*360#/segs
			Local x#=x0+Cos(th)*xr
			Local y#=y0-Sin(th)*yr
			vrts[i*4+0]=x*ix+y*iy+tx
			vrts[i*4+1]=x*jx+y*jy+ty			
			c[i*4+3]=drawcolor
		Next
		SetActiveFrame Null
		device.DrawPrimitive(D3DPT_TRIANGLEFAN,D3DFVF_XYZ|D3DFVF_DIFFUSE,vrts,segs,0)
	End Method

	Method DrawPoly( xy#[],handlex#,handley#,tx#,ty# )
		If Not IsValid() Return

		If xy.length<6 Or (xy.length&1) Return
		Local segs=xy.length/2
		Local vrts#[]=New Float[segs*4]		
		Local c:Int Ptr=Int Ptr(Float Ptr(vrts))
		For Local i=0 Until Len xy Step 2
			Local x#=xy[i+0]+handlex
			Local y#=xy[i+1]+handley
			vrts[i*2+0]=x*ix+y*iy+tx
			vrts[i*2+1]=x*jx+y*jy+ty
			c[i*2+3]=drawcolor			
		Next
		SetActiveFrame Null
		device.DrawPrimitive(D3DPT_TRIANGLEFAN,D3DFVF_XYZ|D3DFVF_DIFFUSE,vrts,segs,0)		
	End Method
	
	Method DrawFrame( frame:TD3D7ImageFrame,x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# )
		If Not IsValid() Return
		
		Local u0#=sx * frame.uscale
		Local v0#=sy * frame.vscale
		Local u1#=(sx+sw) * frame.uscale
		Local v1#=(sy+sh) * frame.vscale
		frame.SetUV u0,v0,u1,v1

		Local	uv:Float Ptr
		Local	c:Int Ptr
		uv=frame.xyzuv
		c=Int Ptr(uv)
		
		uv[0]=x0*ix+y0*iy+tx
		uv[1]=x0*jx+y0*jy+ty
		c[3]=drawcolor		
		
		uv[6]=x1*ix+y0*iy+tx
		uv[7]=x1*jx+y0*jy+ty
		c[9]=drawcolor
		
		uv[12]=x1*ix+y1*iy+tx
		uv[13]=x1*jx+y1*jy+ty
		c[15]=drawcolor
		
		uv[18]=x0*ix+y1*iy+tx
		uv[19]=x0*jx+y1*jy+ty
		c[21]=drawcolor

		SetActiveFrame frame
		device.DrawPrimitive(D3DPT_TRIANGLEFAN,D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1,uv,4,0)
	End Method
	
	Method DrawPixmap( pixmap:TPixmap,x,y )
		If Not IsValid() Return

		Local srcdc,destdc
		Local surf:IDirectDrawSurface7
		Local renderSurf:IDirectDrawSurface7

		D3D7GraphicsDriver().EndScene

		device.GetRenderTarget Varptr renderSurf
		
		renderSurf.GetDC Varptr destdc
		surf=surffrompixmap( pixmap )
		surf.GetDC Varptr srcdc
		BitBlt destdc,x,y,pixmap.width,pixmap.height,srcdc,0,0,ROP_SRCCOPY
		surf.ReleaseDC srcdc
		renderSurf.ReleaseDC destdc
		surf.Release_

		D3D7GraphicsDriver().BeginScene
	End Method

	Method GrabPixmap:TPixmap( x,y,width,height )
		If Not IsValid() Return
		
		Local pixmap:TPixmap
		Local srcdc,destdc
		Local surf:IDirectDrawSurface7
		Local renderSurf:IDirectDrawSurface7
		
		D3D7GraphicsDriver().EndScene

		device.GetRenderTarget Varptr renderSurf
		
		pixmap=TPixmap.Create( width,height,PF_BGR888 )
		renderSurf.GetDC Varptr srcdc
		surf=surffrompixmap( pixmap )
		surf.GetDC Varptr destdc
		BitBlt destdc,0,0,width,height,srcdc,x,y,ROP_SRCCOPY
		surf.ReleaseDC destdc
		renderSurf.ReleaseDC srcdc
		surf.Release_()
		D3D7GraphicsDriver().BeginScene

		Return pixmap	
	End Method
	
	Method SetResolution( width#,height# )
		Local gw=GraphicsWidth()
		Local gh=GraphicsHeight()
		Local world#[]=[..
			gw/width,0.0,0.0,0.0,..
			0.0,gh/height,0.0,0.0,..
			 0.0,0.0,1.0,0.0,..
			 0.0,0.0,0.0,1.0 ]
		device.SetTransform D3DTS_WORLD,world
		Local proj#[]=[..
			2.0/gw,0.0,0.0,0.0,..
			 0.0,-2.0/gh,0.0,0.0,..
			 0.0,0.0,1.0,0.0,..
			 -1-(1.0/gw),1+(1.0/gh),1.0,1.0]
		device.SetTransform D3DTS_PROJECTION,proj
	End Method
	
	Method surffrompixmap:IDirectDrawSurface7(pixmap:TPixmap)
		Local 	surf:IDirectDrawSurface7
		Local	desc:DDSURFACEDESC2=New DDSURFACEDESC2
		Local	res

		If pixmap.format=PF_I8 pixmap=pixmap.convert(PF_BGR888)
		If pixmap.format=PF_A8 pixmap=pixmap.convert(PF_BGRA8888)		
		desc.dwSize=SizeOf(desc)
		desc.dwFlags=DDSD_CAPS|DDSD_WIDTH|DDSD_HEIGHT|DDSD_PITCH|DDSD_LPSURFACE|DDSD_PIXELFORMAT
		desc.dwWidth=pixmap.width
		desc.dwHeight=pixmap.height
		desc.lPitch=pixmap.pitch
		desc.lpSurface=pixmap.pixels
		desc.ddsCaps=DDSCAPS_SYSTEMMEMORY|DDSCAPS_OFFSCREENPLAIN
		desc.ddpf_dwSize=SizeOf(DDPIXELFORMAT)
		Select pixmap.format
		Case PF_BGR888
			desc.ddpf_dwFlags=DDPF_RGB
			desc.ddpf_BitCount=24
			desc.ddpf_BitMask_0=$ff0000
			desc.ddpf_BitMask_1=$00ff00
			desc.ddpf_BitMask_2=$0000ff
		Case PF_RGB888
			desc.ddpf_dwFlags=DDPF_RGB
			desc.ddpf_BitCount=24
			desc.ddpf_BitMask_0=$0000ff
			desc.ddpf_BitMask_1=$00ff00
			desc.ddpf_BitMask_2=$ff0000
		Case PF_BGRA8888
			desc.ddpf_dwFlags=DDPF_RGB|DDPF_ALPHAPIXELS
			desc.ddpf_BitCount=32
			desc.ddpf_BitMask_0=$ff0000
			desc.ddpf_BitMask_1=$00ff00
			desc.ddpf_BitMask_2=$0000ff
			desc.ddpf_BitMask_3=$ff000000
		Case PF_RGBA8888
			desc.ddpf_dwFlags=DDPF_RGB|DDPF_ALPHAPIXELS
			desc.ddpf_BitCount=32
			desc.ddpf_BitMask_0=$0000ff
			desc.ddpf_BitMask_1=$00ff00
			desc.ddpf_BitMask_2=$ff0000
			desc.ddpf_BitMask_3=$ff000000
		End Select		
		
		res=D3D7GraphicsDriver().DirectDraw7().CreateSurface( desc,Varptr surf,Null )

		If res<>DD_OK RuntimeError "D3D7Max2D Create System Surface Failed"
		Return surf		
	End Method
	
	Method SetActiveFrame( frame:TD3D7ImageFrame )
		If frame=activeFrame Return
			
		If frame
			device.SetTexture 0,frame.surface

			If Not activeFrame
				device.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_MODULATE
				device.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_MODULATE
			EndIf

			Local flags=frame.flags & FILTEREDIMAGE
			If flags<>activeFrameFlags
				If flags & FILTEREDIMAGE
					device.SetTextureStageState 0,D3DTSS_MAGFILTER,D3DTFG_LINEAR
					device.SetTextureStageState 0,D3DTSS_MINFILTER,D3DTFG_LINEAR
					device.SetTextureStageState 0,D3DTSS_MIPFILTER,D3DTFG_LINEAR
				Else
					device.SetTextureStageState 0,D3DTSS_MAGFILTER,D3DTFG_POINT
					device.SetTextureStageState 0,D3DTSS_MINFILTER,D3DTFG_POINT
					device.SetTextureStageState 0,D3DTSS_MIPFILTER,D3DTFG_POINT
				EndIf
				activeFrameFlags=flags
			EndIf
		Else
			device.SetTexture 0,Null
			device.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_SELECTARG2
			device.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
		EndIf
		
		activeFrame=frame
	End Method

End Type

Type TD3D7ImageFrame Extends TImageFrame

	Field		seq
	Field		driver:TD3D7Max2DDriver
	Field		surface:IDirectDrawSurface7
	Field		sinfo:DDSurfaceDesc2
	Field		xyzuv#[24]
	Field		width,height,flags
	Field		uscale#,vscale#
	
	Method Delete()
		If Not surface Return
		If seq=GraphicsSeq D3D7GraphicsDriver().DestroySurface surface
		surface=Null
	End Method

	Method SetUV(u0#,v0#,u1#,v1#)
		xyzuv[4]=u0
		xyzuv[5]=v0
		xyzuv[10]=u1
		xyzuv[11]=v0
		xyzuv[16]=u1
		xyzuv[17]=v1
		xyzuv[22]=u0
		xyzuv[23]=v1
	End Method

	Function Create:TD3D7ImageFrame( driver:TD3D7Max2DDriver,width,height,flags )
		Function Pow2Size( n )
			Local t=1
			While t<n
				t:*2
			Wend
			Return t
		End Function
		
		Local	swidth=Pow2Size(width)
		Local	sheight=Pow2Size(height)
		Local	desc:DDSURFACEDESC2=New DDSURFACEDESC2
		Local	res
						
		desc.dwSize=SizeOf(desc)
		desc.dwFlags=DDSD_WIDTH|DDSD_HEIGHT|DDSD_CAPS|DDSD_PIXELFORMAT
		desc.dwWidth=swidth
		desc.dwHeight=sheight	
		
		desc.ddsCaps=DDSCAPS_TEXTURE

		'don't manage fast DYNAMICIMAGEs
		If flags<>DYNAMICIMAGE desc.ddsCaps2=DDSCAPS2_TEXTUREMANAGE
		
		desc.ddpf_dwSize=SizeOf(DDPIXELFORMAT)
		desc.ddpf_dwFlags=DDPF_RGB|DDPF_ALPHAPIXELS
		desc.ddpf_BitCount=32
		desc.ddpf_BitMask_0=$ff0000
		desc.ddpf_BitMask_1=$00ff00
		desc.ddpf_BitMask_2=$0000ff
		desc.ddpf_BitMask_3=$ff000000
		If flags & MIPMAPPEDIMAGE desc.ddsCaps:|DDSCAPS_MIPMAP|DDSCAPS_COMPLEX

		Local surf:IDirectDrawSurface7=D3D7GraphicsDriver().CreateSurface( desc )
		If Not surf Throw "Create DX7 surface Failed"
		
		Local frame:TD3D7ImageFrame=New TD3D7ImageFrame
		frame.seq=GraphicsSeq
		frame.driver=driver
		frame.surface=surf
		frame.sinfo=New DDSurfaceDesc2
		frame.sinfo.dwSize=SizeOf(frame.sinfo)
		frame.xyzuv=New Float[24]
		frame.width=width
		frame.height=height
		frame.flags=flags
		frame.uscale=1.0/swidth
		frame.vscale=1.0/sheight
		frame.SetUV 0.0,0.0,width * frame.uscale,height * frame.vscale
		Return frame
	End Function

	Method Lock:TPixmap( read_lock,write_lock )
		Local lflags=DDLOCK_WAIT|DDLOCK_SURFACEMEMORYPTR
		If read_lock And Not write_lock lflags:|DDLOCK_READONLY
		If write_lock And Not read_lock lflags:|DDLOCK_WRITEONLY
		Local res=surface.Lock(Null,sinfo,lflags,Null)
		If res<>DD_OK RuntimeError "DD3D7ImageFrame Lock failed"	' Return		
		Return TPixmap.CreateStatic( sinfo.lpSurface,sinfo.dwWidth,sinfo.dwHeight,sinfo.lPitch,PF_BGRA8888 )
	End Method
	
	Method Unlock()
		SmearEdges
		surface.Unlock Null
		If flags & MIPMAPPEDIMAGE BuildMipMaps
	End Method
	
	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# )
		driver.DrawFrame Self,x0#,y0#,x1#,y1#,tx#,ty#,sx,sy,sw,sh
	End Method
	
	Function Mix(c0,c1)
		Local	c
		c=((c0 Shr 1)&$7f7f7f7f)+((c1 Shr 1)&$7f7f7f7f)
		c:+(c Shr 3)&$01010101
		Return c
	End Function
	
	Method SmearEdges()
		Local	p:Byte Ptr
		Local	n,x,y,c
		If width<>sinfo.dwWidth
			n=1
			If flags & MIPMAPPEDIMAGE n=sinfo.dwWidth-width
			For y=0 Until height
				p=sinfo.lpSurface+y*sinfo.lPitch
				c=Int Ptr(p)[width-1]
				For x=0 Until n
					Int Ptr(p)[width+x]=c
				Next
			Next
		EndIf
		If height<>sinfo.dwHeight
			n=1
			If flags & MIPMAPPEDIMAGE n=sinfo.dwHeight-height
			p=sinfo.lpSurface+(height-1)*sinfo.lPitch
			For y=1 To n
				MemCopy p+y*sinfo.lPitch,p,sinfo.dwWidth*4
			Next
		EndIf
	End Method

	Method BuildMipMaps()					

		Type TMip
			Field	surf:IDirectDrawSurface7
			Field	info:DDSURFACEDESC2=New DDSURFACEDESC2
			
			Method Lock(srf:IDirectDrawSurface7)
				surf=srf
				info.dwSize=SizeOf(info)
				Return surf.Lock(Null,info,DDLOCK_WAIT,0)
			End Method
			
			Method Write(x,y,argb)
				Local	p:Byte Ptr
				x=Min(x,info.dwWidth-1)
				y=Min(y,info.dwHeight-1)
				p=info.lpSurface+y*info.lPitch
				Int Ptr(p)[x]=argb
			End Method
		
			Method Read(x,y)
				Local	p:Byte Ptr
				x=Min(x,info.dwWidth-1)
				y=Min(y,info.dwHeight-1)
				p=info.lpSurface+y*info.lPitch
				Return Int Ptr(p)[x]
			End Method
			
			Method Unlock()
				surf.Unlock Null
			End Method
			
		End Type
		
		Local	caps2:DDSCAPS2
		Local	src:IDirectDrawSurface7
		Local	dest:IDirectDrawSurface7
		Local	srcmip:TMip
		Local	dstmip:TMip
		Local	res,x,y,w,h,c0,c1,c2,c3
				
		caps2=New DDSCAPS2
		caps2.dwCaps=DDSCAPS_TEXTURE
		caps2.dwCaps2=DDSCAPS2_MIPMAPSUBLEVEL
		srcmip=New TMip
		dstmip=New TMip
		src=surface
		While True
			res=src.GetAttachedSurface(caps2,Varptr dest)
			If res Exit
			res=srcmip.Lock(src)
			If res RuntimeError "BuildMipMaps: lock failed"
			res=dstmip.Lock(dest)
			If res RuntimeError "BuildMipMaps: lock failed"
			w=dstmip.info.dwWidth
			h=dstmip.info.dwHeight
			For y=0 Until h
				For x=0 Until w
					c0=srcmip.read(x*2,y*2)
					c1=srcmip.read(x*2+1,y*2)
					c2=srcmip.read(x*2,y*2+1)
					c3=srcmip.read(x*2+1,y*2+1)
					dstmip.write x,y,mix(mix(c0,c1),mix(c2,c3))	
				Next
			Next
			srcmip.Unlock
			dstmip.Unlock
			dest.Release_
			src=dest
		Wend
	End Method
End Type

Rem
bbdoc: Get Direct3D7 Max2D Driver
about:
The returned driver can be used with #SetGraphicsDriver to enable Direct3D Max2D rendering.
End Rem
Function D3D7Max2DDriver:TD3D7Max2DDriver()
	If D3D7GraphicsDriver()
		Global _driver:TD3D7Max2DDriver=New TD3D7Max2DDriver
		Return _driver
	EndIf
End Function

Local driver:TD3D7Max2DDriver=D3D7Max2DDriver()
If driver SetGraphicsDriver driver
