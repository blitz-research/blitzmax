
Strict

Import Pub.Win32

Const DIRECT3D_VERSION9=$900

'what's up with this...?
Type D3DDEVTYPE
	Const D3DDEVTYPE_HAL = 1
	Const D3DDEVTYPE_REF = 2
	Const D3DDEVTYPE_SW = 3
	Const D3DDEVTYPE_NULLREF = 4
	Const D3DDEVTYPE_FORCE_DWORD = $7fffffff
End Type

Type D3DCAPS9
	Field DeviceType	'D3DDEVTYPE
	Field AdapterOrdinal;
	Field Caps;
	Field Caps2;
	Field Caps3;
	Field PresentationIntervals;
	Field CursorCaps;
	Field DevCaps;
	Field PrimitiveMiscCaps;
	Field RasterCaps;
	Field ZCmpCaps;
	Field SrcBlendCaps;
	Field DestBlendCaps;
	Field AlphaCmpCaps;
	Field ShadeCaps;
	Field TextureCaps;
	Field TextureFilterCaps;
	Field CubeTextureFilterCaps;
	Field VolumeTextureFilterCaps;
	Field TextureAddressCaps;
	Field VolumeTextureAddressCaps;
	Field LineCaps;
	Field MaxTextureWidth;
	Field MaxTextureHeight;
	Field MaxVolumeExtent;
	Field MaxTextureRepeat;
	Field MaxTextureAspectRatio;
	Field MaxAnisotropy;
	Field MaxVertexW#;
	Field GuardBandLeft#;
	Field GuardBandTop#;
	Field GuardBandRight#;
	Field GuardBandBottom#;
	Field ExtentsAdjust#;
	Field StencilCaps;
	Field FVFCaps;
	Field TextureOpCaps;
	Field MaxTextureBlendStages;
	Field MaxSimultaneousTextures;
	Field VertexProcessingCaps;
	Field MaxActiveLights;
	Field MaxUserClipPlanes;
	Field MaxVertexBlendMatrices;
	Field MaxVertexBlendMatrixIndex;
	Field MaxPointSize#;
	Field MaxPrimitiveCount;
	Field MaxVertexIndex;
	Field MaxStreams;
	Field MaxStreamStride;
	Field VertexShaderVersion;
	Field MaxVertexShaderConst;
	Field PixelShaderVersion;
	Field PixelShader1xMaxValue#;
	Field DevCaps2;
	Field MaxNpatchTessellationLevel#;
	Field Reserved5;	
	Field MasterAdapterOrdinal;
	Field AdapterOrdinalInGroup;
	Field NumberOfAdaptersInGroup;
	Field DeclTypes;
	Field NumSimultaneousRTs;
	Field StretchRectFilterCaps;
	'D3DVSHADERCAPS2_0 VS20Caps;
	Field VS20Caps_Caps;
	Field VS20Caps_DynamicFlowControlDepth;
	Field VS20Caps_NumTemps;
	Field VS20Caps_StaticFlowControlDepth;
	'D3DPSHADERCAPS2_0 D3DPSHADERCAPS2_0;
	Field PS20Caps_Caps;
	Field PS20Caps_DynamicFlowControlDepth;
	Field PS20Caps_NumTemps;
	Field PS20Caps_StaticFlowControlDepth;
	Field PS20Caps_NumInstructionSlots;
	Field VertexTextureFilterCaps;
	Field MaxVShaderInstructionsExecuted;
	Field MaxPShaderInstructionsExecuted;
	Field MaxVertexShader30InstructionSlots;
	Field MaxPixelShader30InstructionSlots;
End Type

Type D3DCLIPSTATUS9
	Field ClipUnion
	Field ClipIntersection
End Type

Type D3DVIEWPORT9
	Field X
	Field Y
	Field Width
	Field Height
	Field MinZ#
	Field MaxZ#
End Type

Type D3DMATERIAL9
	Field Diffuse_r#,Diffuse_g#,Diffuse_b#,Diffuse_a#
	Field Ambient_r#,Ambient_g#,Ambient_b#,Ambient_a#
	Field Specular_r#,Specular_g#,Specular_b#,Specular_a#
	Field Emissive_r#,Emissive_g#,Emissive_b#,Emissive_a#
	Field Power#
End Type

Type D3DLIGHT9
	Field Type_
	Field Diffuse_r#,Diffuse_g#,Diffuse_b#,Diffuse_a#
	Field Specular_r#,Specular_g#,Specular_b#,Specular_a#
	Field Ambient_r#,Ambient_g#,Ambient_b#,Ambient_a#
	Field Position_x#,Position_y#,Position_z#
	Field Direction_x#,Direction_y#,Direction_z#
	Field Range#
	Field Falloff#
	Field Attenuation0#
	Field Attenuation1#
	Field Attenuation2#
	Field Theta#
	Field Phi#
End Type

Type D3DVERTEXELEMENT9
	Field Stream:Short
	Field Offset:Short
	Field Type_:Byte
	Field Method_:Byte
	Field Usage:Byte
	Field UsageIndex:Byte
End Type


Type D3DADAPTER_IDENTIFIER9
	Field Driver0, Driver1, Driver2, Driver3, Driver4, Driver5, Driver6, Driver7, Driver8, Driver9
	Field Driver10, Driver11, Driver12, Driver13, Driver14, Driver15, Driver16, Driver17, Driver18, Driver19
	Field Driver20, Driver21, Driver22, Driver23, Driver24, Driver25, Driver26, Driver27, Driver28, Driver29
	Field Driver30, Driver31, Driver32, Driver33, Driver34, Driver35, Driver36, Driver37, Driver38, Driver39
	Field Driver40, Driver41, Driver42, Driver43, Driver44, Driver45, Driver46, Driver47, Driver48, Driver49
	Field Driver50, Driver51, Driver52, Driver53, Driver54, Driver55, Driver56, Driver57, Driver58, Driver59
	Field Driver60, Driver61, Driver62, Driver63, Driver64, Driver65, Driver66, Driver67, Driver68, Driver69
	Field Driver70, Driver71, Driver72, Driver73, Driver74, Driver75, Driver76, Driver77, Driver78, Driver79
	Field Driver80, Driver81, Driver82, Driver83, Driver84, Driver85, Driver86, Driver87, Driver88, Driver89
	Field Driver90, Driver91, Driver92, Driver93, Driver94, Driver95, Driver96, Driver97, Driver98, Driver99
	Field Driver100, Driver101, Driver102, Driver103, Driver104, Driver105, Driver106, Driver107, Driver108, Driver109
	Field Driver110, Driver111, Driver112, Driver113, Driver114, Driver115, Driver116, Driver117, Driver118, Driver119
	Field Driver120, Driver121, Driver122, Driver123, Driver124, Driver125, Driver126, Driver127
	Field Description0, Description1, Description2, Description3, Description4, Description5, Description6, Description7, Description8, Description9
	Field Description10, Description11, Description12, Description13, Description14, Description15, Description16, Description17, Description18, Description19
	Field Description20, Description21, Description22, Description23, Description24, Description25, Description26, Description27, Description28, Description29
	Field Description30, Description31, Description32, Description33, Description34, Description35, Description36, Description37, Description38, Description39
	Field Description40, Description41, Description42, Description43, Description44, Description45, Description46, Description47, Description48, Description49
	Field Description50, Description51, Description52, Description53, Description54, Description55, Description56, Description57, Description58, Description59
	Field Description60, Description61, Description62, Description63, Description64, Description65, Description66, Description67, Description68, Description69
	Field Description70, Description71, Description72, Description73, Description74, Description75, Description76, Description77, Description78, Description79
	Field Description80, Description81, Description82, Description83, Description84, Description85, Description86, Description87, Description88, Description89
	Field Description90, Description91, Description92, Description93, Description94, Description95, Description96, Description97, Description98, Description99
	Field Description100, Description101, Description102, Description103, Description104, Description105, Description106, Description107, Description108, Description109
	Field Description110, Description111, Description112, Description113, Description114, Description115, Description116, Description117, Description118, Description119
	Field Description120, Description121, Description122, Description123, Description124, Description125, Description126, Description127
	Field DeviceName0, DeviceName1, DeviceName2, DeviceName3, DeviceName4, DeviceName5, DeviceName6, DeviceName7
	Field DriverVersionLowPart
	Field DriverVersionHighPart
	Field VendorId
	Field DeviceId
	Field SubSysId
	Field Revision
	Field DeviceIdentifier0
	Field DeviceIdentifier1
	Field DeviceIdentifier2		
	Field DeviceIdentifier3
	Field WHQLLevel

	Method Driver$()
		Return String.fromCString(Varptr Driver0)
	End Method
	Method Description$()
		Return String.fromCString(Varptr Description0)	
	End Method
	Method DeviceName$()
		Return String.fromCString(Varptr DeviceName0)	
	End Method	
End Type

Extern "win32"

Type IDirect3DQuery9 Extends IUnknown

	Method GetDevice( ppDevice:IDirect3DDevice9 Var )
	Method GetType()
	Method GetDataSize()
	Method Issue( dwIssueFlags )
	Method GetData( pData:Byte Ptr,dwSize,dwGetDataFlags )
Rem
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD_(D3DQUERYTYPE, GetType)(THIS) PURE;
	STDMETHOD_(DWORD, GetDataSize)(THIS) PURE;
	STDMETHOD(Issue)(THIS_ DWORD dwIssueFlags) PURE;
	STDMETHOD(GetData)(THIS_ void* pData,DWORD dwSize,DWORD dwGetDataFlags) PURE;
End Rem

End Type

Type IDirect3DStateBlock9 Extends IUnknown
	Method GetDevice(ppDevice: IDirect3DDevice9 Var)
	Method Capture()
	Method Apply()

Rem
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD(Capture)(THIS) PURE;
	STDMETHOD(Apply)(THIS) PURE;
End Rem

End Type

Type IDirect3DPixelShader9 Extends IUnknown

Rem
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD(GetFunction)(THIS_ void*,UINT* pSizeOfData) PURE;
End Rem

End Type

Type IDirect3DVertexShader9 Extends IUnknown

Rem
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD(GetFunction)(THIS_ void*,UINT* pSizeOfData) PURE;
End Rem

End Type

Type IDirect3DVertexDeclaration9 Extends IUnknown

Rem
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD(GetDeclaration)(THIS_ D3DVERTEXELEMENT9*,UINT* pNumElements) PURE;
End Rem

End Type

Type IDirect3D9 Extends IUnknown

	Method RegisterSoftwareDevice( pInitializeFunction() )
	Method GetAdapterCount()
	Method GetAdapterIdentifier( Adapter,Flags,pIdentifier:Byte Ptr )
	Method GetAdapterModeCount( Adapter,Format )
	Method EnumAdapterModes( Adapter,Format,Mode,pMode:Byte Ptr )
	Method GetAdapterDisplayMode( Adapter,pMode:Byte Ptr )
	Method CheckDeviceType( iAdapter,DevType,DisplayFormat,BackBufferFormat,bWindowed )
	Method CheckDeviceFormat( Adapter,DeviceType,AdapterFormat,Usage,RType,CheckFormat )
	Method CheckDeviceMultiSampleType( Adapter,DeviceType,SurfaceFormat,Windowed,MultiSampleType,pQualityLevels:Int Ptr )
	Method CheckDepthStencilMatch( Adapter,DeviceType,AdapterFormat,RenderTargetFormat,DepthStencilFormat )
	Method CheckDeviceFormatConversion( Adapter,DeviceType,SourceFormat,TargetFormat )
	Method GetDeviceCaps( Adapter,DeviceType,pCaps:Byte Ptr ) 
	Method GetAdapterMonitor( Adapter )
	Method CreateDevice( Adapter,DeviceType,hFocusWindow,BehaviorFlags,pPresentationParameters:Byte Ptr,ppReturnedDeviceInterface:IDirect3DDevice9 Var )
Rem
	STDMETHOD(RegisterSoftwareDevice)(THIS_ void* pInitializeFunction) PURE;
	STDMETHOD_(UINT, GetAdapterCount)(THIS) PURE;
	STDMETHOD(GetAdapterIdentifier)(THIS_ UINT Adapter,DWORD Flags,D3DADAPTER_IDENTIFIER9* pIdentifier) PURE;
	STDMETHOD_(UINT, GetAdapterModeCount)(THIS_ UINT Adapter,D3DFORMAT Format) PURE;
	STDMETHOD(EnumAdapterModes)(THIS_ UINT Adapter,D3DFORMAT Format,UINT Mode,D3DDISPLAYMODE* pMode) PURE;
	STDMETHOD(GetAdapterDisplayMode)(THIS_ UINT Adapter,D3DDISPLAYMODE* pMode) PURE;
	STDMETHOD(CheckDeviceType)(THIS_ UINT iAdapter,D3DDEVTYPE DevType,D3DFORMAT DisplayFormat,D3DFORMAT BackBufferFormat,BOOL bWindowed) PURE;
	STDMETHOD(CheckDeviceFormat)(THIS_ UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,DWORD Usage,D3DRESOURCETYPE RType,D3DFORMAT CheckFormat) PURE;
	STDMETHOD(CheckDeviceMultiSampleType)(THIS_ UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SurfaceFormat,BOOL Windowed,D3DMULTISAMPLE_TYPE MultiSampleType,DWORD* pQualityLevels) PURE;
	STDMETHOD(CheckDepthStencilMatch)(THIS_ UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT AdapterFormat,D3DFORMAT RenderTargetFormat,D3DFORMAT DepthStencilFormat) PURE;
	STDMETHOD(CheckDeviceFormatConversion)(THIS_ UINT Adapter,D3DDEVTYPE DeviceType,D3DFORMAT SourceFormat,D3DFORMAT TargetFormat) PURE;
	STDMETHOD(GetDeviceCaps)(THIS_ UINT Adapter,D3DDEVTYPE DeviceType,D3DCAPS9* pCaps) PURE;
	STDMETHOD_(HMONITOR, GetAdapterMonitor)(THIS_ UINT Adapter) PURE;
	STDMETHOD(CreateDevice)(THIS_ UINT Adapter,D3DDEVTYPE DeviceType,HWND hFocusWindow,DWORD BehaviorFlags,D3DPRESENT_PARAMETERS* pPresentationParameters,IDirect3DDevice9** ppReturnedDeviceInterface) PURE;
End Rem

End Type

Type IDirect3DDevice9 Extends IUnknown

	Method TestCooperativeLevel()
	Method GetAvailableTextureMem()
	Method EvictManagedResources()
	Method GetDirect3D( ppD3D9:IDirect3D9 Var )
	Method GetDeviceCaps( caps:Byte Ptr )
	Method GetDisplayMode( iSwapChain,pMode:Byte Ptr )
	Method GetCreationParameters( pParameters:Byte Ptr )
	Method SetCursorProperties( XHotSpot,YHotSpot,pCursorBitmap:IDirect3DSurface9 )
	Method SetCursorPosition( X,Y,Flags )
	Method ShowCursor( bShow )
	Method CreateAdditionalSwapChain( pPresentationParameters:Byte Ptr,pSwapChain:IDirect3DSwapChain9 Var )
	Method GetSwapChain( iSwapChain,pSwapChain:IDirect3DSwapChain9 Var )
	Method GetNumberOfSwapChains()
	Method Reset( pPresentationParameters:Byte Ptr )
	Method Present( pSourceRect:Byte Ptr,pDestRect:Byte Ptr,hDestWindowOverride,pDirtyRegion:Byte Ptr )
	Method GetBackBuffer( iSwapChain,iBackBuffer,bType,ppBackBuffer:IDirect3DSurface9 Var )
	Method GetRasterStatus( iSwapChain,pRasterStatus:Byte Ptr )
	Method SetDialogBoxMode( bEnableDialogs )
	Method SetGammaRamp( iSwapChain,Flags,pRamp:Short Ptr )
	Method GetGammaRamp( iSwapChain,pRamp:Short Ptr )
	Method CreateTexture( Width,Height,Levels,Usage,Format,Pool,ppTexture:IDirect3DTexture9 Var,pSharedHandle:Byte Ptr )
	Method CreateVolumeTexture( Width,Height,Depth,Levels,Usage,Format,Pool,ppVolumeTexture:IDirect3DVolumeTexture9,pSharedHandle:Byte Ptr )
	Method CreateCubeTexture( EdgeLength,Levels,Usage,Format,Pool,ppTexture:IDirect3DCubeTexture9 Var,pSharedHandle:Byte Ptr )
	Method CreateVertexBuffer( Length,Usage,FVF,Pool,ppVertexBuffer:IDirect3DVertexBuffer9 Var,pSharedHandle:Byte Ptr )
	Method CreateIndexBuffer( Length,Usage,Format,Pool,ppIndexBuffer:IDirect3DIndexBuffer9 Var,pSharedHandle:Byte Ptr )
	Method CreateRenderTarget( Width,Height,Format,MultiSample,MultisampleQuality,Lockable,ppSurface:IDirect3DSurface9 Var,pSharedHandle:Byte Ptr )
	Method CreateDepthStencilSurface( Width,Height,Format,MultiSample,MultisampleQuality,Discard,ppSurface:IDirect3DSurface9 Var,pSharedHandle:Byte Ptr )
	Method UpdateSurface( pSourceSurface:IDirect3DSurface9,pSourceRect:Byte Ptr,pDestinationSurface:IDirect3DSurface9,pDestPoint:Byte Ptr )
	Method UpdateTexture( pSourceTexture:IDirect3DBaseTexture9,pDestinationTexture:IDirect3DBaseTexture9 )
	Method GetRenderTargetData( pRenderTarget:IDirect3DSurface9,pDestSurface:IDirect3DSurface9 )
	Method GetFrontBufferData( iSwapChain,pDestSurface:IDirect3DSurface9 )
	Method StretchRect( pSourceSurface:IDirect3DSurface9,pSourceRect:Byte Ptr,pDestSurface:IDirect3DSurface9,pDestRect:Byte Ptr,Filter )
	Method ColorFill( pSurface:IDirect3DSurface9,pRect:Byte Ptr,color )
	Method CreateOffscreenPlainSurface( Width,Height,Format,Pool,ppSurface:IDirect3DSurface9 Var,pSharedHandle:Byte Ptr )
	Method SetRenderTarget( RenderTargetIndex,pRenderTarget:IDirect3DSurface9 )
	Method GetRenderTarget( RenderTargetIndex,pRenderTarget:IDirect3DSurface9 Var )
	Method SetDepthStencilSurface( pNewZStencil:IDirect3DSurface9 )
	Method GetDepthStencilSurface( ppZStencilSurface:IDirect3DSurface9 Var )
	Method BeginScene()
	Method EndScene()
	Method Clear( Count,pRects:Byte Ptr,Flags,Color,Z#,Stencil )
	Method SetTransform( State,pMatrix:Float Ptr )
	Method GetTransform( State,pMatrix:Float Ptr )
	Method MultiplyTransform( State,pMatrix:Float Ptr )
	Method SetViewport( pViewport:Byte Ptr )
	Method GetViewport( pViewport:Byte Ptr )
	Method SetMaterial( pMaterial:Byte Ptr )
	Method GetMaterial( pMaterial:Byte Ptr )
	Method SetLight( Index,pLight:Byte Ptr )
	Method GetLight( Index,pLight:Byte Ptr )
	Method LightEnable( Index,Enable )
	Method GetLightEnable( Index,Enable:Int Ptr )
	Method SetClipPlane( Index,pPlane:Float Ptr )
	Method GetClipPlane( Index,pPlane:Float Ptr )
	Method SetRenderState( State,Value )
	Method GetRenderState( State,Value Var )
	Method CreateStateBlock( Type_,ppSB:IDirect3DStateBlock9 Var )
	Method BeginStateBlock()
	Method EndStateBlock( ppSB:IDirect3DStateBlock9 Var )
	Method SetClipStatus( pClipStatus:Byte Ptr )
	Method GetClipStatus( pClipStatus:Byte Ptr )
	Method GetTexture( Stage,ppTexture:IDirect3DBaseTexture9 Var )
	Method SetTexture( Stage,pTexture:IDirect3DBaseTexture9 )
	Method GetTextureStageState( Stage,Type_,pValue Var )
	Method SetTextureStageState( Stage,Type_,Value )
	Method GetSamplerState( Sampler,Type_,pValue Var )
	Method SetSamplerState( Sampler,Type_,Value )
	Method ValidateDevice( pNumPasses:Int Ptr )
	Method SetPaletteEntries( PaletteNumber,pEntries:Byte Ptr )
	Method GetPaletteEntries( PaletteNumber,pEntries:Byte Ptr )
	Method SetCurrentTexturePalette( PaletteNumber )
	Method GetCurrentTexturePalette( PaletteNumber Var )
	Method SetScissorRect( pRect:Byte Ptr )
	Method GetScissorRect( pRect:Byte Ptr )
	Method SetSoftwareVertexProcessing( bSoftware )
	Method GetSoftwareVertexProcessing()
	Method SetNPatchMode( nSegments# )
	Method GetNPatchMode#()
	Method DrawPrimitive( PrimitiveType,StartVertex,PrimitiveCount )
	Method DrawIndexedPrimitive( PrimitiveType,BaseVertexIndex,MinVertexIndex,NumVertices,startIndex,primCount )
	Method DrawPrimitiveUP( PrimitiveType,PrimitiveCount,pVertexStreamZeroData:Byte Ptr,VertexStreamZeroStride )
	Method DrawIndexedPrimitiveUP( PrimitiveType,MinVertexIndex,NumVertices,PrimitiveCount,pIndexData:Byte Ptr,IndexDataFormat,pVertexStreamZeroData:Byte Ptr,VertexStreamZeroStride )
	Method ProcessVertices( SrcStartIndex,DestIndex,VertexCount,pDestBuffer:IDirect3DVertexBuffer9,pVertexDecl:IDirect3DVertexDeclaration9,Flags )
	Method CreateVertexDeclaration( pVertexElements:Byte Ptr,ppDecl:IDirect3DVertexDeclaration9 Var )
	Method SetVertexDeclaration( pDecl:IDirect3DVertexDeclaration9 )
	Method GetVertexDeclaration( ppDecl:IDirect3DVertexDeclaration9 Var )
	Method SetFVF( FVF )
	Method GetFVF( FVF Var )
	Method CreateVertexShader( pFunction:Byte Ptr,ppShader:IDirect3DVertexShader9 Var )
	Method SetVertexShader( pShader:IDirect3DVertexShader9 )
	Method GetVertexShader( ppShader:IDirect3DVertexShader9 Var )
	Method SetVertexShaderConstantF( StartRegister,pConstantData:Float Ptr,Vector4fCount )
	Method GetVertexShaderConstantF( StartRegister,pConstantData:Float Ptr,Vector4fCount )
	Method SetVertexShaderConstantI( StartRegister,pConstantData:Int Ptr,Vector4iCount )
	Method GetVertexShaderConstantI( StartRegister,pConstantData:Int Ptr,Vector4iCount )
	Method SetVertexShaderConstantB( StartRegister,pConstantData:Byte Ptr,BoolCount )
	Method GetVertexShaderConstantB( StartRegister,pConstantData:Byte Ptr,BoolCount )
	Method SetStreamSource( StreamNumber,pStreamData:IDirect3DVertexBuffer9,OffsetInBytes,Stride )
	Method GetStreamSource( StreamNumber,ppStreamData:IDirect3DVertexBuffer9 Var,OffsetInBytes Var,Stride Var )
	Method SetStreamSourceFreq( StreamNumber,Divider )
	Method GetStreamSourceFreq( StreamNumber,Divider Var )
	Method SetIndices( pIndexData:IDirect3DIndexBuffer9 )
	Method GetIndices( ppIndexData:IDirect3DIndexBuffer9 Var )
	Method CreatePixelShader( pFunction:Byte Ptr,ppShader:IDirect3DPixelShader9 Var )
	Method SetPixelShader( pShader:IDirect3DPixelShader9 )
	Method GetPixelShader( ppShader:IDirect3DPixelShader9 Var )
	Method SetPixelShaderConstantF( StartRegister,pConstantData:Float Ptr,Vector4fCount )
	Method GetPixelShaderConstantF( StartRegister,pConstantData:Float Ptr,Vector4fCount )
	Method SetPixelShaderConstantI( StartRegister,pConstantData:Int Ptr,Vector4iCount )
	Method GetPixelShaderConstantI( StartRegister,pConstantData:Int Ptr,Vector4iCount )
	Method SetPixelShaderConstantB( StartRegister,pConstantData:Byte Ptr,BoolCount )
	Method GetPixelShaderConstantB( StartRegister,pConstantData:Byte Ptr,BoolCount )
	Method DrawRectPatch( Handle,pNumSegs:Float Ptr,pRectPathInfo:Byte Ptr )
	Method DrawTriPatch( Handle,pNumSegs:Float Ptr,pTriPatchInfo:Byte Ptr )
	Method DeletePatch( Handle )
	Method CreateQuery( Type_,ppQuery:IDirect3DQuery9 Var )
Rem
	STDMETHOD(TestCooperativeLevel)(THIS) PURE;
	STDMETHOD_(UINT, GetAvailableTextureMem)(THIS) PURE;
	STDMETHOD(EvictManagedResources)(THIS) PURE;
	STDMETHOD(GetDirect3D)(THIS_ IDirect3D9** ppD3D9) PURE;
	STDMETHOD(GetDeviceCaps)(THIS_ D3DCAPS9* pCaps) PURE;
	STDMETHOD(GetDisplayMode)(THIS_ UINT iSwapChain,D3DDISPLAYMODE* pMode) PURE;
	STDMETHOD(GetCreationParameters)(THIS_ D3DDEVICE_CREATION_PARAMETERS *pParameters) PURE;
	STDMETHOD(SetCursorProperties)(THIS_ UINT XHotSpot,UINT YHotSpot,IDirect3DSurface9* pCursorBitmap) PURE;
	STDMETHOD_(void, SetCursorPosition)(THIS_ Int X,Int Y,DWORD Flags) PURE;
	STDMETHOD_(BOOL, ShowCursor)(THIS_ BOOL bShow) PURE;
	STDMETHOD(CreateAdditionalSwapChain)(THIS_ D3DPRESENT_PARAMETERS* pPresentationParameters,IDirect3DSwapChain9** pSwapChain) PURE;
	STDMETHOD(GetSwapChain)(THIS_ UINT iSwapChain,IDirect3DSwapChain9** pSwapChain) PURE;
	STDMETHOD_(UINT, GetNumberOfSwapChains)(THIS) PURE;
	STDMETHOD(Reset)(THIS_ D3DPRESENT_PARAMETERS* pPresentationParameters) PURE;
	STDMETHOD(Present)(THIS_ Const RECT* pSourceRect,Const RECT* pDestRect,HWND hDestWindowOverride,Const RGNDATA* pDirtyRegion) PURE;
	STDMETHOD(GetBackBuffer)(THIS_ UINT iSwapChain,UINT iBackBuffer,D3DBACKBUFFER_TYPE Type,IDirect3DSurface9** ppBackBuffer) PURE;
	STDMETHOD(GetRasterStatus)(THIS_ UINT iSwapChain,D3DRASTER_STATUS* pRasterStatus) PURE;
	STDMETHOD(SetDialogBoxMode)(THIS_ BOOL bEnableDialogs) PURE;
	STDMETHOD_(void, SetGammaRamp)(THIS_ UINT iSwapChain,DWORD Flags,Const D3DGAMMARAMP* pRamp) PURE;
	STDMETHOD_(void, GetGammaRamp)(THIS_ UINT iSwapChain,D3DGAMMARAMP* pRamp) PURE;
	STDMETHOD(CreateTexture)(THIS_ UINT Width,UINT Height,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DTexture9** ppTexture,HANDLE* pSharedHandle) PURE;
	STDMETHOD(CreateVolumeTexture)(THIS_ UINT Width,UINT Height,UINT Depth,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DVolumeTexture9** ppVolumeTexture,HANDLE* pSharedHandle) PURE;
	STDMETHOD(CreateCubeTexture)(THIS_ UINT EdgeLength,UINT Levels,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DCubeTexture9** ppCubeTexture,HANDLE* pSharedHandle) PURE;
	STDMETHOD(CreateVertexBuffer)(THIS_ UINT Length,DWORD Usage,DWORD FVF,D3DPOOL Pool,IDirect3DVertexBuffer9** ppVertexBuffer,HANDLE* pSharedHandle) PURE;
	STDMETHOD(CreateIndexBuffer)(THIS_ UINT Length,DWORD Usage,D3DFORMAT Format,D3DPOOL Pool,IDirect3DIndexBuffer9** ppIndexBuffer,HANDLE* pSharedHandle) PURE;
	STDMETHOD(CreateRenderTarget)(THIS_ UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Lockable,IDirect3DSurface9** ppSurface,HANDLE* pSharedHandle) PURE;
	STDMETHOD(CreateDepthStencilSurface)(THIS_ UINT Width,UINT Height,D3DFORMAT Format,D3DMULTISAMPLE_TYPE MultiSample,DWORD MultisampleQuality,BOOL Discard,IDirect3DSurface9** ppSurface,HANDLE* pSharedHandle) PURE;
	STDMETHOD(UpdateSurface)(THIS_ IDirect3DSurface9* pSourceSurface,Const RECT* pSourceRect,IDirect3DSurface9* pDestinationSurface,Const POINT* pDestPoint) PURE;
	STDMETHOD(UpdateTexture)(THIS_ IDirect3DBaseTexture9* pSourceTexture,IDirect3DBaseTexture9* pDestinationTexture) PURE;
	STDMETHOD(GetRenderTargetData)(THIS_ IDirect3DSurface9* pRenderTarget,IDirect3DSurface9* pDestSurface) PURE;
	STDMETHOD(GetFrontBufferData)(THIS_ UINT iSwapChain,IDirect3DSurface9* pDestSurface) PURE;
	STDMETHOD(StretchRect)(THIS_ IDirect3DSurface9* pSourceSurface,Const RECT* pSourceRect,IDirect3DSurface9* pDestSurface,Const RECT* pDestRect,D3DTEXTUREFILTERTYPE Filter) PURE;
	STDMETHOD(ColorFill)(THIS_ IDirect3DSurface9* pSurface,Const RECT* pRect,D3DCOLOR color) PURE;
	STDMETHOD(CreateOffscreenPlainSurface)(THIS_ UINT Width,UINT Height,D3DFORMAT Format,D3DPOOL Pool,IDirect3DSurface9** ppSurface,HANDLE* pSharedHandle) PURE;
	STDMETHOD(SetRenderTarget)(THIS_ DWORD RenderTargetIndex,IDirect3DSurface9* pRenderTarget) PURE;
	STDMETHOD(GetRenderTarget)(THIS_ DWORD RenderTargetIndex,IDirect3DSurface9** ppRenderTarget) PURE;
	STDMETHOD(SetDepthStencilSurface)(THIS_ IDirect3DSurface9* pNewZStencil) PURE;
	STDMETHOD(GetDepthStencilSurface)(THIS_ IDirect3DSurface9** ppZStencilSurface) PURE;
	STDMETHOD(BeginScene)(THIS) PURE;
	STDMETHOD(EndScene)(THIS) PURE;
	STDMETHOD(Clear)(THIS_ DWORD Count,Const D3DRECT* pRects,DWORD Flags,D3DCOLOR Color,Float Z,DWORD Stencil) PURE;
	STDMETHOD(SetTransform)(THIS_ D3DTRANSFORMSTATETYPE State,Const D3DMATRIX* pMatrix) PURE;
	STDMETHOD(GetTransform)(THIS_ D3DTRANSFORMSTATETYPE State,D3DMATRIX* pMatrix) PURE;
	STDMETHOD(MultiplyTransform)(THIS_ D3DTRANSFORMSTATETYPE,Const D3DMATRIX*) PURE;
	STDMETHOD(SetViewport)(THIS_ Const D3DVIEWPORT9* pViewport) PURE;
	STDMETHOD(GetViewport)(THIS_ D3DVIEWPORT9* pViewport) PURE;
	STDMETHOD(SetMaterial)(THIS_ Const D3DMATERIAL9* pMaterial) PURE;
	STDMETHOD(GetMaterial)(THIS_ D3DMATERIAL9* pMaterial) PURE;
	STDMETHOD(SetLight)(THIS_ DWORD Index,Const D3DLIGHT9*) PURE;
	STDMETHOD(GetLight)(THIS_ DWORD Index,D3DLIGHT9*) PURE;
	STDMETHOD(LightEnable)(THIS_ DWORD Index,BOOL Enable) PURE;
	STDMETHOD(GetLightEnable)(THIS_ DWORD Index,BOOL* pEnable) PURE;
	STDMETHOD(SetClipPlane)(THIS_ DWORD Index,Const Float* pPlane) PURE;
	STDMETHOD(GetClipPlane)(THIS_ DWORD Index,Float* pPlane) PURE;
	STDMETHOD(SetRenderState)(THIS_ D3DRENDERSTATETYPE State,DWORD Value) PURE;
	STDMETHOD(GetRenderState)(THIS_ D3DRENDERSTATETYPE State,DWORD* pValue) PURE;
	STDMETHOD(CreateStateBlock)(THIS_ D3DSTATEBLOCKTYPE Type,IDirect3DStateBlock9** ppSB) PURE;
	STDMETHOD(BeginStateBlock)(THIS) PURE;
	STDMETHOD(EndStateBlock)(THIS_ IDirect3DStateBlock9** ppSB) PURE;
	STDMETHOD(SetClipStatus)(THIS_ Const D3DCLIPSTATUS9* pClipStatus) PURE;
	STDMETHOD(GetClipStatus)(THIS_ D3DCLIPSTATUS9* pClipStatus) PURE;
	STDMETHOD(GetTexture)(THIS_ DWORD Stage,IDirect3DBaseTexture9** ppTexture) PURE;
	STDMETHOD(SetTexture)(THIS_ DWORD Stage,IDirect3DBaseTexture9* pTexture) PURE;
	STDMETHOD(GetTextureStageState)(THIS_ DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD* pValue) PURE;
	STDMETHOD(SetTextureStageState)(THIS_ DWORD Stage,D3DTEXTURESTAGESTATETYPE Type,DWORD Value) PURE;
	STDMETHOD(GetSamplerState)(THIS_ DWORD Sampler,D3DSAMPLERSTATETYPE Type,DWORD* pValue) PURE;
	STDMETHOD(SetSamplerState)(THIS_ DWORD Sampler,D3DSAMPLERSTATETYPE Type,DWORD Value) PURE;
	STDMETHOD(ValidateDevice)(THIS_ DWORD* pNumPasses) PURE;
	STDMETHOD(SetPaletteEntries)(THIS_ UINT PaletteNumber,Const PALETTEENTRY* pEntries) PURE;
	STDMETHOD(GetPaletteEntries)(THIS_ UINT PaletteNumber,PALETTEENTRY* pEntries) PURE;
	STDMETHOD(SetCurrentTexturePalette)(THIS_ UINT PaletteNumber) PURE;
	STDMETHOD(GetCurrentTexturePalette)(THIS_ UINT *PaletteNumber) PURE;
	STDMETHOD(SetScissorRect)(THIS_ Const RECT* pRect) PURE;
	STDMETHOD(GetScissorRect)(THIS_ RECT* pRect) PURE;
	STDMETHOD(SetSoftwareVertexProcessing)(THIS_ BOOL bSoftware) PURE;
	STDMETHOD_(BOOL, GetSoftwareVertexProcessing)(THIS) PURE;
	STDMETHOD(SetNPatchMode)(THIS_ Float nSegments) PURE;
	STDMETHOD_(Float, GetNPatchMode)(THIS) PURE;
	STDMETHOD(DrawPrimitive)(THIS_ D3DPRIMITIVETYPE PrimitiveType,UINT StartVertex,UINT PrimitiveCount) PURE;
	STDMETHOD(DrawIndexedPrimitive)(THIS_ D3DPRIMITIVETYPE,Int BaseVertexIndex,UINT MinVertexIndex,UINT NumVertices,UINT startIndex,UINT primCount) PURE;
	STDMETHOD(DrawPrimitiveUP)(THIS_ D3DPRIMITIVETYPE PrimitiveType,UINT PrimitiveCount,Const void* pVertexStreamZeroData,UINT VertexStreamZeroStride) PURE;
	STDMETHOD(DrawIndexedPrimitiveUP)(THIS_ D3DPRIMITIVETYPE PrimitiveType,UINT MinVertexIndex,UINT NumVertices,UINT PrimitiveCount,Const void* pIndexData,D3DFORMAT IndexDataFormat,Const void* pVertexStreamZeroData,UINT VertexStreamZeroStride) PURE;
	STDMETHOD(ProcessVertices)(THIS_ UINT SrcStartIndex,UINT DestIndex,UINT VertexCount,IDirect3DVertexBuffer9* pDestBuffer,IDirect3DVertexDeclaration9* pVertexDecl,DWORD Flags) PURE;
	STDMETHOD(CreateVertexDeclaration)(THIS_ Const D3DVERTEXELEMENT9* pVertexElements,IDirect3DVertexDeclaration9** ppDecl) PURE;
	STDMETHOD(SetVertexDeclaration)(THIS_ IDirect3DVertexDeclaration9* pDecl) PURE;
	STDMETHOD(GetVertexDeclaration)(THIS_ IDirect3DVertexDeclaration9** ppDecl) PURE;
	STDMETHOD(SetFVF)(THIS_ DWORD FVF) PURE;
	STDMETHOD(GetFVF)(THIS_ DWORD* pFVF) PURE;
	STDMETHOD(CreateVertexShader)(THIS_ Const DWORD* pFunction,IDirect3DVertexShader9** ppShader) PURE;
	STDMETHOD(SetVertexShader)(THIS_ IDirect3DVertexShader9* pShader) PURE;
	STDMETHOD(GetVertexShader)(THIS_ IDirect3DVertexShader9** ppShader) PURE;
	STDMETHOD(SetVertexShaderConstantF)(THIS_ UINT StartRegister,Const Float* pConstantData,UINT Vector4fCount) PURE;
	STDMETHOD(GetVertexShaderConstantF)(THIS_ UINT StartRegister,Float* pConstantData,UINT Vector4fCount) PURE;
	STDMETHOD(SetVertexShaderConstantI)(THIS_ UINT StartRegister,Const Int* pConstantData,UINT Vector4iCount) PURE;
	STDMETHOD(GetVertexShaderConstantI)(THIS_ UINT StartRegister,Int* pConstantData,UINT Vector4iCount) PURE;
	STDMETHOD(SetVertexShaderConstantB)(THIS_ UINT StartRegister,Const BOOL* pConstantData,UINT  BoolCount) PURE;
	STDMETHOD(GetVertexShaderConstantB)(THIS_ UINT StartRegister,BOOL* pConstantData,UINT BoolCount) PURE;
	STDMETHOD(SetStreamSource)(THIS_ UINT StreamNumber,IDirect3DVertexBuffer9* pStreamData,UINT OffsetInBytes,UINT Stride) PURE;
	STDMETHOD(GetStreamSource)(THIS_ UINT StreamNumber,IDirect3DVertexBuffer9** ppStreamData,UINT* OffsetInBytes,UINT* pStride) PURE;
	STDMETHOD(SetStreamSourceFreq)(THIS_ UINT StreamNumber,UINT Divider) PURE;
	STDMETHOD(GetStreamSourceFreq)(THIS_ UINT StreamNumber,UINT* Divider) PURE;
	STDMETHOD(SetIndices)(THIS_ IDirect3DIndexBuffer9* pIndexData) PURE;
	STDMETHOD(GetIndices)(THIS_ IDirect3DIndexBuffer9** ppIndexData) PURE;
	STDMETHOD(CreatePixelShader)(THIS_ Const DWORD* pFunction,IDirect3DPixelShader9** ppShader) PURE;
	STDMETHOD(SetPixelShader)(THIS_ IDirect3DPixelShader9* pShader) PURE;
	STDMETHOD(GetPixelShader)(THIS_ IDirect3DPixelShader9** ppShader) PURE;
	STDMETHOD(SetPixelShaderConstantF)(THIS_ UINT StartRegister,Const Float* pConstantData,UINT Vector4fCount) PURE;
	STDMETHOD(GetPixelShaderConstantF)(THIS_ UINT StartRegister,Float* pConstantData,UINT Vector4fCount) PURE;
	STDMETHOD(SetPixelShaderConstantI)(THIS_ UINT StartRegister,Const Int* pConstantData,UINT Vector4iCount) PURE;
	STDMETHOD(GetPixelShaderConstantI)(THIS_ UINT StartRegister,Int* pConstantData,UINT Vector4iCount) PURE;
	STDMETHOD(SetPixelShaderConstantB)(THIS_ UINT StartRegister,Const BOOL* pConstantData,UINT  BoolCount) PURE;
	STDMETHOD(GetPixelShaderConstantB)(THIS_ UINT StartRegister,BOOL* pConstantData,UINT BoolCount) PURE;
	STDMETHOD(DrawRectPatch)(THIS_ UINT Handle,Const Float* pNumSegs,Const D3DRECTPATCH_INFO* pRectPatchInfo) PURE;
	STDMETHOD(DrawTriPatch)(THIS_ UINT Handle,Const Float* pNumSegs,Const D3DTRIPATCH_INFO* pTriPatchInfo) PURE;
	STDMETHOD(DeletePatch)(THIS_ UINT Handle) PURE;
	STDMETHOD(CreateQuery)(THIS_ D3DQUERYTYPE Type,IDirect3DQuery9** ppQuery) PURE;
End Rem

End Type

Type IDirect3DSwapChain9 Extends IUnknown

	Method Present( pSourceRect:Byte Ptr,pDestRect:Byte Ptr,hDestWindowOverride,pDirtyRegion:Byte Ptr,Flags )
	Method GetFrontBufferData(pDestSurface:IDirect3DSurface9) 
	Method GetBackBuffer(iBackBuffer:Int, Type_:Int,ppBackBuffer:IDirect3DSurface9 Var)
	Method GetRasterStatus(pRasterStatus:Byte Ptr)
Rem
	STDMETHOD(Present)(THIS_ Const RECT* pSourceRect,Const RECT* pDestRect,HWND hDestWindowOverride,Const RGNDATA* pDirtyRegion,DWORD dwFlags) PURE;
	STDMETHOD(GetFrontBufferData)(THIS_ IDirect3DSurface9* pDestSurface) PURE;
	STDMETHOD(GetBackBuffer)(THIS_ UINT iBackBuffer,D3DBACKBUFFER_TYPE Type,IDirect3DSurface9** ppBackBuffer) PURE;
	STDMETHOD(GetRasterStatus)(THIS_ D3DRASTER_STATUS* pRasterStatus) PURE;
	STDMETHOD(GetDisplayMode)(THIS_ D3DDISPLAYMODE* pMode) PURE;
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD(GetPresentParameters)(THIS_ D3DPRESENT_PARAMETERS* pPresentationParameters) PURE;
End Rem

End Type

Type IDirect3DResource9 Extends IUnknown

	Method GetDevice( ppDevice:IDirect3DDevice9 Var )
	Method SetPrivateData( refguid:Byte Ptr,pData:Byte Ptr,SizeOfData,Flags )
	Method GetPrivateData( refguid:Byte Ptr,pData:Byte Ptr,pSizeOfData )
	Method FreePrivateData( refguid:Byte Ptr )
	Method SetPriority( PriorityNew )
	Method GetPriority()
	Method PreLoad()
	Method GetType()
Rem
	STDMETHOD(GetDevice)(THIS_ IDirect3DDevice9** ppDevice) PURE;
	STDMETHOD(SetPrivateData)(THIS_ REFGUID refguid,Const void* pData,DWORD SizeOfData,DWORD Flags) PURE;
	STDMETHOD(GetPrivateData)(THIS_ REFGUID refguid,void* pData,DWORD* pSizeOfData) PURE;
	STDMETHOD(FreePrivateData)(THIS_ REFGUID refguid) PURE;
	STDMETHOD_(DWORD, SetPriority)(THIS_ DWORD PriorityNew) PURE;
	STDMETHOD_(DWORD, GetPriority)(THIS) PURE;
	STDMETHOD_(void, PreLoad)(THIS) PURE;
	STDMETHOD_(D3DRESOURCETYPE, GetType)(THIS) PURE;
End Rem

End Type

Type IDirect3DSurface9 Extends IDirect3dResource9

	Method GetContainer( riid:Byte Ptr,ppContainer:Byte Ptr Var )
	Method GetDesc( pDesc:Byte Ptr )
	Method LockRect( pLockedRect:Byte Ptr,pRect:Byte Ptr,Flags )
	Method UnlockRect()
	Method GetDC( phdc:Byte Ptr Var )
	Method ReleaseDC( hdc:Byte Ptr )
Rem
	STDMETHOD(GetContainer)(THIS_ REFIID riid,void** ppContainer) PURE;
	STDMETHOD(GetDesc)(THIS_ D3DSURFACE_DESC *pDesc) PURE;
	STDMETHOD(LockRect)(THIS_ D3DLOCKED_RECT* pLockedRect,Const RECT* pRect,DWORD Flags) PURE;
	STDMETHOD(UnlockRect)(THIS) PURE;
	STDMETHOD(GetDC)(THIS_ HDC *phdc) PURE;
	STDMETHOD(ReleaseDC)(THIS_ HDC hdc) PURE;
End Rem
 
End Type

Type IDirect3DVertexBuffer9 Extends IDirect3DResource9

	Method Lock( OffsetToLock,SizeToLock,ppbData:Byte Ptr Var,Flags )
	Method Unlock()
Rem
	STDMETHOD(Lock)(THIS_ UINT OffsetToLock,UINT SizeToLock,void** ppbData,DWORD Flags) PURE;
	STDMETHOD(Unlock)(THIS) PURE;
	STDMETHOD(GetDesc)(THIS_ D3DVERTEXBUFFER_DESC *pDesc) PURE;
End Rem

End Type

Type IDirect3DIndexBuffer9 Extends IDirect3DResource9

	Method Lock( OffsetToLock,SizeToLock,ppbData:Byte Ptr Var,Flags )
	Method Unlock()
Rem
	STDMETHOD(Lock)(THIS_ UINT OffsetToLock,UINT SizeToLock,void** ppbData,DWORD Flags) PURE;
	STDMETHOD(Unlock)(THIS) PURE;
	STDMETHOD(GetDesc)(THIS_ D3DINDEXBUFFER_DESC *pDesc) PURE;
End Rem

End Type

Type IDirect3DBaseTexture9 Extends IDirect3DResource9

	Method SetLOD( LODNew )
	Method GetLOD()
	Method GetLevelCount()
	Method SetAutoGenFilterType( FilterType )
	Method GetAutoGenFilterType()
	Method GenerateMipSubLevels()
Rem
	STDMETHOD_(DWORD, SetLOD)(THIS_ DWORD LODNew) PURE;
	STDMETHOD_(DWORD, GetLOD)(THIS) PURE;
	STDMETHOD_(DWORD, GetLevelCount)(THIS) PURE;
	STDMETHOD(SetAutoGenFilterType)(THIS_ D3DTEXTUREFILTERTYPE FilterType) PURE;
	STDMETHOD_(D3DTEXTUREFILTERTYPE, GetAutoGenFilterType)(THIS) PURE;
	STDMETHOD_(void, GenerateMipSubLevels)(THIS) PURE;
End Rem

End Type

Type IDirect3DTexture9 Extends IDirect3DBaseTexture9

	Method GetLevelDesc( Level,pDesc:Byte Ptr )
	Method GetSurfaceLevel( Level,ppSurfaceLevel:IDirect3DSurface9 Var )
	Method LockRect( Level,pLockedRect:Byte Ptr,pRect:Byte Ptr,Flags )
	Method UnlockRect( Level )
	Method AddDirtyRect( pDirtyRect:Byte Ptr )
Rem
	STDMETHOD(GetLevelDesc)(THIS_ UINT Level,D3DSURFACE_DESC *pDesc) PURE;
	STDMETHOD(GetSurfaceLevel)(THIS_ UINT Level,IDirect3DSurface9** ppSurfaceLevel) PURE;
	STDMETHOD(LockRect)(THIS_ UINT Level,D3DLOCKED_RECT* pLockedRect,Const RECT* pRect,DWORD Flags) PURE;
	STDMETHOD(UnlockRect)(THIS_ UINT Level) PURE;
	STDMETHOD(AddDirtyRect)(THIS_ Const RECT* pDirtyRect) PURE;
End Rem

End Type

Type IDirect3DCubeTexture9 Extends IDirect3DBaseTexture9

	Method GetLevelDesc( Level,pDesc:Byte Ptr )
	Method GetCubeMapSurface( FaceType,Level,ppCubeMapSurface:IDirect3DSurface9 Var )
	Method LockRect( FaceType,Level,pLockedRect:Byte Ptr,pRect:Byte Ptr,Flags )
	Method UnlockRect( FaceType,Level )
	Method AddDirtyRect( FaceType,pDirtyRect:Byte Ptr )
Rem
	STDMETHOD(GetLevelDesc)(THIS_ UINT Level,D3DSURFACE_DESC *pDesc) PURE;
	STDMETHOD(GetCubeMapSurface)(THIS_ D3DCUBEMAP_FACES FaceType,UINT Level,IDirect3DSurface9** ppCubeMapSurface) PURE;
	STDMETHOD(LockRect)(THIS_ D3DCUBEMAP_FACES FaceType,UINT Level,D3DLOCKED_RECT* pLockedRect,Const RECT* pRect,DWORD Flags) PURE;
	STDMETHOD(UnlockRect)(THIS_ D3DCUBEMAP_FACES FaceType,UINT Level) PURE;
	STDMETHOD(AddDirtyRect)(THIS_ D3DCUBEMAP_FACES FaceType,Const RECT* pDirtyRect) PURE;
End Rem

End Type

Type IDirect3DVolumeTexture9 Extends IDirect3DBaseTexture9

'	Method GetLevelDesc( Level,pDesc:Byte Ptr )
'	Method GetVolumeLevel( Level,ppVolumeLevel:IDirect3DVolume9 Var )
'	Method LockBox( Level,pLockedVolume:Byte Ptr,pBox:Byte Ptr,Flags )
'	Method UnlockBox( Level )
'	Method AddDirtyBox( pDirtyBox:Byte Ptr )
Rem
	STDMETHOD(GetLevelDesc)(THIS_ UINT Level,D3DVOLUME_DESC *pDesc) PURE;
	STDMETHOD(GetVolumeLevel)(THIS_ UINT Level,IDirect3DVolume9** ppVolumeLevel) PURE;
	STDMETHOD(LockBox)(THIS_ UINT Level,D3DLOCKED_BOX* pLockedVolume,Const D3DBOX* pBox,DWORD Flags) PURE;
	STDMETHOD(UnlockBox)(THIS_ UINT Level) PURE;
	STDMETHOD(AddDirtyBox)(THIS_ Const D3DBOX* pDirtyBox) PURE;
End Rem

End Type

End Extern

Global d3d9Lib=LoadLibraryA( "d3d9" )

If Not d3d9Lib Return

Global Direct3DCreate9:IDirect3D9( SDKVersion )"win32" = GetProcAddress( d3d9Lib,"Direct3DCreate9" )
