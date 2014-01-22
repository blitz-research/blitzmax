 
Strict

Import Pub.Win32

'This is very much a WORK IN PROGRESS, and highly subject to change!

'IDirect3DDevice7 parameter definitions still incomplete

Const D3DDEVCAPS_HWRASTERIZATION=$80000

Const D3DTFN_POINT=1
Const D3DTFN_LINEAR=2
Const D3DTFN_ANISOTROPIC=3

Const D3DTFP_NONE=1
Const D3DTFP_POINT=2
Const D3DTFP_LINEAR=3

Const D3DTFG_POINT=1
Const D3DTFG_LINEAR=2
Const D3DTFG_FLATCUBIC=3
Const D3DTFG_GAUSSIANCUBIC=4
Const D3DTFG_ANISOTROPIC=5

Const D3DVBCAPS_SYSTEMMEMORY=$800
Const D3DVBCAPS_WRITEONLY=$10000
Const D3DVBCAPS_OPTIMIZED=$80000000
Const D3DVBCAPS_DONOTCLIP=$1

Type D3DMATERIAL7
	Field	diffuse_r#,diffuse_g#,diffuse_b#,diffuse_a#
	Field 	ambient_r#,ambient_g#,ambient_b#,ambient_a#
	Field	specular_r#,specular_g#,specular_b#,specular_a#
	Field	emissive_r#,emissive_g#,emissive_b#,emissive_a#
	Field	power#
End Type

Type D3DVIEWPORT7
	Field	dwX,dwY,dwWidth,dwHeight
	Field	dvMinZ,dvMaxZ
End Type

Type D3DVERTEXBUFFERDESC
	Field	dwSize,dwCaps,dwFVF,dwNumVertices
End Type

Extern "win32"

Type IDirect3D7 Extends IUnknown
	Method EnumDevices(callback(desc:Byte Ptr,name:Byte Ptr,d3ddevice:Byte Ptr,context:Object),user:Object)
	Method CreateDevice(clsid:Byte Ptr,ddsurface7:Byte Ptr,d3ddevice7:Byte Ptr)
	Method CreateVertexBuffer(lpVBDesc:Byte Ptr,lplpD3DVertexBuffer:Byte Ptr,dwFlags)
	Method EnumZBufferFormats(clsid,d3dpfcallback,void)
	Method EvictManagedTextures()
'    /*** IDirect3D7 methods ***/
'    STDMETHOD(EnumDevices)(THIS_ LPD3DENUMDEVICESCALLBACK7,LPVOID) PURE;
'    STDMETHOD(CreateDevice)(THIS_ REFCLSID,LPDIRECTDRAWSURFACE7,LPDIRECT3DDEVICE7*) PURE;
'    STDMETHOD(CreateVertexBuffer)(THIS_ LPD3DVERTEXBUFFERDESC,LPDIRECT3DVERTEXBUFFER7*,DWORD) PURE;
'    STDMETHOD(EnumZBufferFormats)(THIS_ REFCLSID,LPD3DENUMPIXELFORMATSCALLBACK,LPVOID) PURE;
'    STDMETHOD(EvictManagedTextures)(THIS) PURE;
End Type

Type IDirect3DDevice7 Extends IUnknown
	Method GetCaps(desc:Byte Ptr)
	Method EnumTextureFormats(callback(),context:Object)
	Method BeginScene()
	Method EndScene()
	Method GetDirect3D()
	Method SetRenderTarget(surf7:Byte Ptr,flags)
	Method GetRenderTarget(surf7:Byte Ptr)
	Method Clear(count,rects:Byte Ptr,flags,color,z,stencil)
	Method SetTransform(state,matrix:Byte Ptr)
	Method GetTransform(state,matrix:Byte Ptr)

	Method SetViewport(viewport:Byte Ptr)
	Method MultiplyTransform()
	Method GetViewport()
	Method SetMaterial(material:Byte Ptr)
	Method GetMaterial()
	Method SetLight()
	Method GetLight()
	Method SetRenderState(renderstate,value)
	Method GetRenderState()
	Method BeginStateBlock()
	Method EndStateBlock()

	Method PreLoad()
	Method DrawPrimitive(primtype,verttype,verts:Byte Ptr,count,flags)
	Method DrawIndexedPrimitive(d3dptPrimitiveType,dwVertexTypeDesc,lpvVertices:Byte Ptr,dwVertexCount,lpwIndices:Short Ptr,dwIndexCount,dwFlags)
	Method SetClipStatus( lpD3DClipStatus:Byte Ptr )
	Method GetClipStatus( lpD3DClipStatus:Byte Ptr )
	Method DrawPrimitiveStrided(d3dptPrimitiveType,dwVertexTypeDesc,lpVertexArray:Byte Ptr,dwVertexCount,dwFlags)
	Method DrawIndexedPrimitiveStrided(d3dptPrimitiveType,dwVertexTypeDesc,lpVertexArray:Byte Ptr,dwVertexCount,lpwIndices:Short Ptr,dwIndexCount,dwFlags)
	Method DrawPrimitiveVB(d3dptPrimitiveType,lpd3dVertexBuffer:Byte Ptr,dwStartVertex,dwNumVertices,dwFlags)	
	Method DrawIndexedPrimitiveVB(d3dptPrimitiveType,lpd3dVertexBuffer:Byte Ptr,dwStartVertex,dwNumVertices,lpwIndices:Short Ptr,dwIndexCount,dwFlags)

	Method ComputeSphereVisibility()
	Method GetTexture()
	
	Method SetTexture(stage,ddsurface7:Byte Ptr)
	
	Method GetTextureStageState()
	Method SetTextureStageState(stage,state,value)
	Method ValidateDevice()
	Method ApplyStateBlock()
	Method CaptureStateBlock()
	Method DeleteStateBlock()
	Method CreateStateBlock()
	Method Load()
	Method LightEnable()
	Method GetLightEnable()
	Method SetClipPlane( dwIndex,pPlaneEquation:Float Ptr )
	Method GetClipPlane( dwIndex,pPlaneEquation:Float Ptr )
	Method GetInfo()	
'    /*** IDirect3DDevice7 methods ***/
Rem
    STDMETHOD(GetCaps)(THIS_ LPD3DDEVICEDESC7) PURE;
    STDMETHOD(EnumTextureFormats)(THIS_ LPD3DENUMPIXELFORMATSCALLBACK,LPVOID) PURE;
    STDMETHOD(BeginScene)(THIS) PURE;
    STDMETHOD(EndScene)(THIS) PURE;
    STDMETHOD(GetDirect3D)(THIS_ LPDIRECT3D7*) PURE;
    STDMETHOD(SetRenderTarget)(THIS_ LPDIRECTDRAWSURFACE7,DWORD) PURE;
    STDMETHOD(GetRenderTarget)(THIS_ LPDIRECTDRAWSURFACE7 *) PURE;
    STDMETHOD(Clear)(THIS_ DWORD,LPD3DRECT,DWORD,D3DCOLOR,D3DVALUE,DWORD) PURE;
    STDMETHOD(SetTransform)(THIS_ D3DTRANSFORMSTATETYPE,LPD3DMATRIX) PURE;
    STDMETHOD(GetTransform)(THIS_ D3DTRANSFORMSTATETYPE,LPD3DMATRIX) PURE;

    STDMETHOD(SetViewport)(THIS_ LPD3DVIEWPORT7) PURE;
    STDMETHOD(MultiplyTransform)(THIS_ D3DTRANSFORMSTATETYPE,LPD3DMATRIX) PURE;
    STDMETHOD(GetViewport)(THIS_ LPD3DVIEWPORT7) PURE;
    STDMETHOD(SetMaterial)(THIS_ LPD3DMATERIAL7) PURE;
    STDMETHOD(GetMaterial)(THIS_ LPD3DMATERIAL7) PURE;
    STDMETHOD(SetLight)(THIS_ DWORD,LPD3DLIGHT7) PURE;
    STDMETHOD(GetLight)(THIS_ DWORD,LPD3DLIGHT7) PURE;
    STDMETHOD(SetRenderState)(THIS_ D3DRENDERSTATETYPE,DWORD) PURE;
    STDMETHOD(GetRenderState)(THIS_ D3DRENDERSTATETYPE,LPDWORD) PURE;
    STDMETHOD(BeginStateBlock)(THIS) PURE;

    STDMETHOD(EndStateBlock)(THIS_ LPDWORD) PURE;
    STDMETHOD(PreLoad)(THIS_ LPDIRECTDRAWSURFACE7) PURE;
    STDMETHOD(DrawPrimitive)(THIS_ D3DPRIMITIVETYPE,DWORD,LPVOID,DWORD,DWORD) PURE;
    STDMETHOD(DrawIndexedPrimitive)(THIS_ D3DPRIMITIVETYPE,DWORD,LPVOID,DWORD,LPWORD,DWORD,DWORD) PURE;
    STDMETHOD(SetClipStatus)(THIS_ LPD3DCLIPSTATUS) PURE;
    STDMETHOD(GetClipStatus)(THIS_ LPD3DCLIPSTATUS) PURE;
    STDMETHOD(DrawPrimitiveStrided)(THIS_ D3DPRIMITIVETYPE,DWORD,LPD3DDRAWPRIMITIVESTRIDEDDATA,DWORD,DWORD) PURE;
    STDMETHOD(DrawIndexedPrimitiveStrided)(THIS_ D3DPRIMITIVETYPE,DWORD,LPD3DDRAWPRIMITIVESTRIDEDDATA,DWORD,LPWORD,DWORD,DWORD) PURE;
    STDMETHOD(DrawPrimitiveVB)(THIS_ D3DPRIMITIVETYPE,LPDIRECT3DVERTEXBUFFER7,DWORD,DWORD,DWORD) PURE;
    STDMETHOD(DrawIndexedPrimitiveVB)(THIS_ D3DPRIMITIVETYPE,LPDIRECT3DVERTEXBUFFER7,DWORD,DWORD,LPWORD,DWORD,DWORD) PURE;

    STDMETHOD(ComputeSphereVisibility)(THIS_ LPD3DVECTOR,LPD3DVALUE,DWORD,DWORD,LPDWORD) PURE;
    STDMETHOD(GetTexture)(THIS_ DWORD,LPDIRECTDRAWSURFACE7 *) PURE;
    STDMETHOD(SetTexture)(THIS_ DWORD,LPDIRECTDRAWSURFACE7) PURE;
    STDMETHOD(GetTextureStageState)(THIS_ DWORD,D3DTEXTURESTAGESTATETYPE,LPDWORD) PURE;
    STDMETHOD(SetTextureStageState)(THIS_ DWORD,D3DTEXTURESTAGESTATETYPE,DWORD) PURE;
    STDMETHOD(ValidateDevice)(THIS_ LPDWORD) PURE;
    STDMETHOD(ApplyStateBlock)(THIS_ DWORD) PURE;
    STDMETHOD(CaptureStateBlock)(THIS_ DWORD) PURE;
    STDMETHOD(DeleteStateBlock)(THIS_ DWORD) PURE;
    STDMETHOD(CreateStateBlock)(THIS_ D3DSTATEBLOCKTYPE,LPDWORD) PURE;
    STDMETHOD(Load)(THIS_ LPDIRECTDRAWSURFACE7,LPPOINT,LPDIRECTDRAWSURFACE7,LPRECT,DWORD) PURE;
    STDMETHOD(LightEnable)(THIS_ DWORD,BOOL) PURE;
    STDMETHOD(GetLightEnable)(THIS_ DWORD,BOOL*) PURE;
    STDMETHOD(SetClipPlane)(THIS_ DWORD,D3DVALUE*) PURE;
    STDMETHOD(GetClipPlane)(THIS_ DWORD,D3DVALUE*) PURE;
    STDMETHOD(GetInfo)(THIS_ DWORD,LPVOID,DWORD) PURE;
EndRem
End Type

Type IDirect3DVertexBuffer7 Extends IUnknown
	Method Lock(flags,data:Byte Ptr,size:Int Ptr)
	Method Unlock()
	Method ProcessVertices(dwVertexOp,dwDestIndex,dwCount,lpSrcBuffer:Byte Ptr,dwSrcIndex,lpD3DDevice:Byte Ptr,dwFlags)
	Method GetVertexBufferDesc(lpVBDesc:Byte Ptr)
	Method Optimize(lpD3DDevice:Byte Ptr,dwFlags)
	Method ProcessVerticesStrided(dwVertexOp,dwDestIndex,dwCount,lpVertexArray:Byte Ptr,dwSrcIndex,lpD3DDevice:Byte Ptr,dwFlags)	
'    /*** IDirect3DVertexBuffer7 methods ***/
Rem
    STDMETHOD(Lock)(THIS_ DWORD,LPVOID*,LPDWORD) PURE;
    STDMETHOD(Unlock)(THIS) PURE;
    STDMETHOD(ProcessVertices)(THIS_ DWORD,DWORD,DWORD,LPDIRECT3DVERTEXBUFFER7,DWORD,LPDIRECT3DDEVICE7,DWORD) PURE;
    STDMETHOD(GetVertexBufferDesc)(THIS_ LPD3DVERTEXBUFFERDESC) PURE;
    STDMETHOD(Optimize)(THIS_ LPDIRECT3DDEVICE7,DWORD) PURE;
    STDMETHOD(ProcessVerticesStrided)(THIS_ DWORD,DWORD,DWORD,LPD3DDRAWPRIMITIVESTRIDEDDATA,DWORD,LPDIRECT3DDEVICE7,DWORD) PURE;
EndRem
End Type

End Extern

Global IID_IDirect3D7[]=[$f5049e77,$11d24861,$a00007a4,$a82906c9]
Global IID_IDirect3DHALDevice[]=[$84e63de0,$11cf46aa,$00006f81,$6e1520c0]
Global IID_IDirect3DTnLDevice[]=[$f5049e78,$11d24861,$A00007a4,$a82906c9]

Rem

DEFINE_GUID( IID_IDirect3D,             0x3BBA0080,0x2421,0x11CF,0xA3,0x1A,0x00,0xAA,0x00,0xB9,0x33,0x56 );
DEFINE_GUID( IID_IDirect3D2,            0x6aae1ec1,0x662a,0x11d0,0x88,0x9d,0x00,0xaa,0x00,0xbb,0xb7,0x6a);
DEFINE_GUID( IID_IDirect3D3,            0xbb223240,0xe72b,0x11d0,0xa9,0xb4,0x00,0xaa,0x00,0xc0,0x99,0x3e);
DEFINE_GUID( IID_IDirect3D7,            0xf5049e77,0x4861,0x11d2,0xa4,0x7,0x0,0xa0,0xc9,0x6,0x29,0xa8);
DEFINE_GUID( IID_IDirect3DRampDevice,   0xF2086B20,0x259F,0x11CF,0xA3,0x1A,0x00,0xAA,0x00,0xB9,0x33,0x56 );
DEFINE_GUID( IID_IDirect3DRGBDevice,    0xA4665C60,0x2673,0x11CF,0xA3,0x1A,0x00,0xAA,0x00,0xB9,0x33,0x56 );
DEFINE_GUID( IID_IDirect3DHALDevice,    0x84E63dE0,0x46AA,0x11CF,0x81,0x6F,0x00,0x00,0xC0,0x20,0x15,0x6E );
DEFINE_GUID( IID_IDirect3DMMXDevice,    0x881949a1,0xd6f3,0x11d0,0x89,0xab,0x00,0xa0,0xc9,0x05,0x41,0x29 );
DEFINE_GUID( IID_IDirect3DRefDevice,    0x50936643, 0x13e9, 0x11d1, 0x89, 0xaa, 0x0, 0xa0, 0xc9, 0x5, 0x41, 0x29);
DEFINE_GUID( IID_IDirect3DNullDevice, 0x8767df22, 0xbacc, 0x11d1, 0x89, 0x69, 0x0, 0xa0, 0xc9, 0x6, 0x29, 0xa8);
DEFINE_GUID( IID_IDirect3DTnLHalDevice, 0xf5049e78, 0x4861, 0x11d2, 0xa4, 0x7, 0x0, 0xa0, 0xc9, 0x6, 0x29, 0xa8);
DEFINE_GUID( IID_IDirect3DDevice,       0x64108800,0x957d,0X11d0,0x89,0xab,0x00,0xa0,0xc9,0x05,0x41,0x29 );
DEFINE_GUID( IID_IDirect3DDevice2,  0x93281501, 0x8cf8, 0x11d0, 0x89, 0xab, 0x0, 0xa0, 0xc9, 0x5, 0x41, 0x29);
DEFINE_GUID( IID_IDirect3DDevice3,  0xb0ab3b60, 0x33d7, 0x11d1, 0xa9, 0x81, 0x0, 0xc0, 0x4f, 0xd7, 0xb1, 0x74);
DEFINE_GUID( IID_IDirect3DDevice7,  0xf5049e79, 0x4861, 0x11d2, 0xa4, 0x7, 0x0, 0xa0, 0xc9, 0x6, 0x29, 0xa8);
DEFINE_GUID( IID_IDirect3DTexture,      0x2CDCD9E0,0x25A0,0x11CF,0xA3,0x1A,0x00,0xAA,0x00,0xB9,0x33,0x56 );
DEFINE_GUID( IID_IDirect3DTexture2, 0x93281502, 0x8cf8, 0x11d0, 0x89, 0xab, 0x0, 0xa0, 0xc9, 0x5, 0x41, 0x29);
DEFINE_GUID( IID_IDirect3DLight,        0x4417C142,0x33AD,0x11CF,0x81,0x6F,0x00,0x00,0xC0,0x20,0x15,0x6E );
DEFINE_GUID( IID_IDirect3DMaterial,     0x4417C144,0x33AD,0x11CF,0x81,0x6F,0x00,0x00,0xC0,0x20,0x15,0x6E );
DEFINE_GUID( IID_IDirect3DMaterial2,    0x93281503, 0x8cf8, 0x11d0, 0x89, 0xab, 0x0, 0xa0, 0xc9, 0x5, 0x41, 0x29);
DEFINE_GUID( IID_IDirect3DMaterial3,    0xca9c46f4, 0xd3c5, 0x11d1, 0xb7, 0x5a, 0x0, 0x60, 0x8, 0x52, 0xb3, 0x12);
DEFINE_GUID( IID_IDirect3DExecuteBuffer,0x4417C145,0x33AD,0x11CF,0x81,0x6F,0x00,0x00,0xC0,0x20,0x15,0x6E );
DEFINE_GUID( IID_IDirect3DViewport,     0x4417C146,0x33AD,0x11CF,0x81,0x6F,0x00,0x00,0xC0,0x20,0x15,0x6E );
DEFINE_GUID( IID_IDirect3DViewport2,    0x93281500, 0x8cf8, 0x11d0, 0x89, 0xab, 0x0, 0xa0, 0xc9, 0x5, 0x41, 0x29);
DEFINE_GUID( IID_IDirect3DViewport3,    0xb0ab3b61, 0x33d7, 0x11d1, 0xa9, 0x81, 0x0, 0xc0, 0x4f, 0xd7, 0xb1, 0x74);
DEFINE_GUID( IID_IDirect3DVertexBuffer, 0x7a503555, 0x4a83, 0x11d1, 0xa5, 0xdb, 0x0, 0xa0, 0xc9, 0x3, 0x67, 0xf8);
DEFINE_GUID( IID_IDirect3DVertexBuffer7, 0xf5049e7d, 0x4861, 0x11d2, 0xa4, 0x7, 0x0, 0xa0, 0xc9, 0x6, 0x29, 0xa8);

EndRem
