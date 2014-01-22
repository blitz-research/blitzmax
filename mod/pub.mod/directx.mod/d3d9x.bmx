
Strict

Import Pub.Win32

Extern "win32"

Type ID3DXBuffer Extends IUnknown

	Method GetBufferPointer:Byte Ptr()
	Method GetBufferSize()
Rem
    // ID3DXBuffer
    STDMETHOD_(LPVOID, GetBufferPointer)(THIS) PURE;
    STDMETHOD_(DWORD, GetBufferSize)(THIS) PURE;
end rem
End Type

End Extern

Global d3dx9Lib=LoadLibraryA( "d3dx9" )

If Not d3dx9Lib Return

Global D3DXAssembleShader( pSrcData:Byte Ptr,SrcDataLen,pDefines:Byte Ptr,pInclude:Byte Ptr,Flags,ppShader:ID3DXBuffer Var,ppErrorMsgs:ID3DXBuffer Var )"win32"=GetProcAddress( d3dx9Lib,"D3DXAssembleShader" )
