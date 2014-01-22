
Module Pub.LibPNG

ModuleInfo "Version: 1.03"
ModuleInfo "Author: Guy Eric Schalnat, Andreas Dilger, Glenn Randers-Pehrson, Others"
ModuleInfo "License: ZLib/PNG License"
ModuleInfo "Modserver: BRL"
ModuleInfo "Credit: Adapted for BlitzMax by Mark Sibly"

ModuleInfo "History: 1.03"
ModuleInfo "History: Fixed for Intel Macs"
ModuleInfo "History: 1.02"
ModuleInfo "History: Update to libpng 1.2.12"

Import Pub.ZLib

Import "png.c"
Import "pngerror.c"
Import "pngget.c"
Import "pngmem.c"
Import "pngpread.c"
Import "pngread.c"
Import "pngrio.c"
Import "pngrtran.c"
Import "pngrutil.c"
Import "pngset.c"
Import "pngtrans.c"
Import "pngwio.c"
Import "pngwrite.c"
Import "pngwtran.c"
Import "pngwutil.c"
'Import "pngvcrd.c"
?MacosX86
Import "pnggccrd.c"
?

Extern

Const PNG_COLOR_MASK_PALETTE=		1
Const PNG_COLOR_MASK_COLOR=			2
Const PNG_COLOR_MASK_ALPHA=			4

Const PNG_COLOR_TYPE_GRAY=			0
Const PNG_COLOR_TYPE_PALETTE=		(PNG_COLOR_MASK_COLOR | PNG_COLOR_MASK_PALETTE)
Const PNG_COLOR_TYPE_RGB=			(PNG_COLOR_MASK_COLOR)
Const PNG_COLOR_TYPE_RGB_ALPHA=		(PNG_COLOR_MASK_COLOR | PNG_COLOR_MASK_ALPHA)
Const PNG_COLOR_TYPE_GRAY_ALPHA=	(PNG_COLOR_MASK_ALPHA)
Const PNG_COLOR_TYPE_RGBA=			PNG_COLOR_TYPE_RGB_ALPHA
Const PNG_COLOR_TYPE_GA=			PNG_COLOR_TYPE_GRAY_ALPHA

Const PNG_TRANSFORM_IDENTITY=		$0000		'read and write
Const PNG_TRANSFORM_STRIP_16=		$0001		'read only
Const PNG_TRANSFORM_STRIP_ALPHA=	$0002		'read only
Const PNG_TRANSFORM_PACKING=		$0004		'read and write
Const PNG_TRANSFORM_PACKSWAP=		$0008		'read and write
Const PNG_TRANSFORM_EXPAND=			$0010		'read only
Const PNG_TRANSFORM_INVERT_MONO=	$0020		'read and write
Const PNG_TRANSFORM_SHIFT=			$0040		'read and write
Const PNG_TRANSFORM_BGR=			$0080		'read and write
Const PNG_TRANSFORM_SWAP_ALPHA=		$0100		'read and write
Const PNG_TRANSFORM_SWAP_ENDIAN=	$0200		'read and write
Const PNG_TRANSFORM_INVERT_ALPHA=   $0400		'read and write
Const PNG_TRANSFORM_STRIP_FILLER=   $0800		'write only

Const PNG_COMPRESSION_TYPE_DEFAULT=	0

Const PNG_FILTER_TYPE_DEFAULT=		0
Const PNG_INTRAPIXEL_DIFFERENCING=	64

Const PNG_INTERLACE_NONE=			0
Const PNG_INTERLACE_ADAM7=			1

Function png_sig_cmp( buf:Byte Ptr,start,count )

Function png_create_read_struct( ver_string$z,user_error_ptr:Byte Ptr,user_error_fn:Byte Ptr,user_warning_fn:Byte Ptr)
Function png_create_write_struct( ver_string$z,user_error_ptr:Byte Ptr,user_error_fn:Byte Ptr,user_warning_fn:Byte Ptr)

Function png_destroy_read_struct( png_ptr Ptr,info_ptr1 Ptr,info_ptr2 Ptr )
Function png_destroy_write_struct( png_ptr Ptr,info_ptr1 Ptr,info_ptr2 Ptr )

Function png_create_info_struct( png_ptr )

Function png_init_io( png_ptr,c_stream )
Function png_set_sig_bytes( png_ptr,number )

Function png_set_read_fn( png_ptr,user:Byte Ptr,read_fn(png_ptr,buf:Byte Ptr,size) )
Function png_set_write_fn( png_ptr,user:Byte Ptr,write_fn(png_ptr,buf:Byte Ptr,size),flush_fn(png_ptr) )

Function png_set_expand( png_ptr )
Function png_set_strip_16( png_ptr )
Function png_set_gray_to_rgb( png_ptr )

Function png_set_compression_level( png_ptr,level )
Function png_set_compression_strategy( png_ptr,strategy )

Function png_read_png( png_ptr,info_ptr,png_transforms,reserved )
Function png_write_png( png_ptr,info_ptr,png_transforms,reserved )

Function png_get_rows:Byte Ptr Ptr( png_ptr,info_ptr )
Function png_set_rows( png_ptr,info_ptr,rows:Byte Ptr )

Function png_get_IHDR( png_ptr,info_ptr,width Var,height Var,bit_depth Var,color_type Var,interlace_type Var,compression_type Var,filter_method Var )
Function png_set_IHDR( png_ptr,info_ptr,width,height,bit_depth,color_type,interlace_type,compression_type,filter_method )

End Extern
