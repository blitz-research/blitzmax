
Strict

Module Pub.FreeType

ModuleInfo "Version: 1.08"
ModuleInfo "License: FreeType License"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Updated to FreeType 2.3.11"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Linux version now uses installed freetype"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed too large fonts crashing"
ModuleInfo "History: Updated to latest FreeType lib version"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Tiger build warnings in ftmac.c"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added stream hooks (new code in 'ftsystem.c')"

Rem

Changes to freetype source:

ftoption.h : Enabled FT_CONFIG_OPTION_SYSTEM_ZLIB define
ftoption.h : FT_RENDER_POOL_SIZE changed to 65536L, was 16384. This appears to be the cause of the 'big font' crashes

End Rem

?Linux

ModuleInfo "CC_OPTS: `freetype-config --cflags`"

Import "-lfreetype"

?Not Linux

Import Pub.ZLib

Rem
bbox   bdf    bitmap debug  gasp
glyph  gxval  init   lcdfil mm
otval  pfr    stroke synth  system
type1  winfnt xf86   patent
End Rem

ModuleInfo "CC_OPTS: -DFT2_BUILD_LIBRARY"

Import "include/*.h"

Import "src/base/ftbase.c"

Import "src/base/ftapi.c"
Import "src/base/ftbbox.c"
Import "src/base/ftbdf.c"
Import "src/base/ftbitmap.c"
Import "src/base/ftdebug.c"
Import "src/base/ftgasp.c"
Import "src/base/ftglyph.c"
Import "src/base/ftgxval.c"
Import "src/base/ftinit.c"
Import "src/base/ftlcdfil.c"
Import "src/base/ftmm.c"
Import "src/base/ftotval.c"
Import "src/base/ftpfr.c"
Import "src/base/ftstroke.c"
Import "src/base/ftsynth.c"
Import "src/base/ftsystem.c"
Import "src/base/fttype1.c"
Import "src/base/ftwinfnt.c"
Import "src/base/ftxf86.c"
Import "src/base/ftpatent.c"

Import "src/autofit/autofit.c"
Import "src/bdf/bdf.c"
Import "src/cache/ftcache.c"
Import "src/cff/cff.c"
Import "src/cid/type1cid.c"
Import "src/gzip/ftgzip.c"
Import "src/lzw/ftlzw.c"
Import "src/otvalid/otvalid.c"
Import "src/pcf/pcf.c"
Import "src/pfr/pfr.c"
Import "src/psaux/psaux.c"
Import "src/pshinter/pshinter.c"
Import "src/psnames/psnames.c"
Import "src/raster/raster.c"
Import "src/sfnt/sfnt.c"
Import "src/smooth/smooth.c"
Import "src/truetype/truetype.c"
Import "src/type1/type1.c"
Import "src/type42/type42.c"
Import "src/winfonts/winfnt.c"

?

Extern

Function FT_Init_FreeType( ft_lib:Byte Ptr Ptr )

Function FT_Done_FreeType( ft_lib:Byte Ptr )
Function FT_Done_Face( ft_face:Byte Ptr )
Function FT_Done_Glyph( ft_glyph:Byte Ptr )

Function FT_New_Face( ft_lib:Byte Ptr,arg$z,faceIndex,ft_face:Byte Ptr Ptr )
Function FT_New_Memory_Face( ft_lib:Byte Ptr,buf:Byte Ptr,size,faceIndex,ft_face:Byte Ptr Ptr )

Function FT_Set_Pixel_Sizes( ft_face:Byte Ptr,width,height )
Function FT_Get_Char_Index( ft_face:Byte Ptr,index )
Function FT_Set_Charmap( ft_face:Byte Ptr,charmap )

Function FT_Load_Char( ft_face:Byte Ptr,index,flags )
Function FT_Load_Glyph( ft_face:Byte Ptr,index,flags )
Function FT_Render_Glyph( ft_glyph:Byte Ptr,mode )

End Extern

Const FT_LOAD_DEFAULT=0
Const FT_LOAD_NO_SCALE=1
Const FT_LOAD_NO_HINTING=2
Const FT_LOAD_RENDER=4
Const FT_LOAD_NO_BITMAP=8
Const FT_LOAD_VERTICAL_LAYOUT=$10
Const FT_LOAD_FORCE_AUTOHINT=$20
Const FT_LOAD_CROP_BITMAP=$40
Const FT_LOAD_PEDANTIC=$80
Const FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH=$200
Const FT_LOAD_NO_RECURSE=$400
Const FT_LOAD_IGNORE_TRANSFORM=$800
Const FT_LOAD_MONOCHROME=$1000
Const FT_LOAD_LINEAR_DESIGN=$2000

Const FT_RENDER_MODE_NORMAL=0
Const FT_RENDER_MODE_LIGHT=1
Const FT_RENDER_MODE_MONO=2
Const FT_RENDER_MODE_LCD=3
Const FT_RENDER_MODE_LCD_V=4


Type FTFace
	Field	numfaces,index,flags,style,numglyphs
	Field	fname:Byte Ptr
	Field	sname:Byte Ptr
	Field	numsizes
	Field	sizes:Int Ptr
	Field	numcharmaps
	Field	charmaps:Int Ptr
	Field	genericdata:Byte Ptr,genericdestructor
	Field	bx0,by0,bx1,by1
	Field	unitsperem:Short
	Field	ascender:Short
	Field	descender:Short
	Field	height:Short
	Field	maxawidth:Short
	Field	maxahieght:Short
	Field	underlinepos:Short
	Field	underlinethick:Short
	Field	glyphslot:Int Ptr	
	Field	metrics:Byte Ptr
End Type	

Type FTMetrics
	Field	mface,mgeneric0,mgeneric1
	Field	xppem:Short,yppem:Short
	Field	xscale,yscale
	Field	ascend,descend,height,max_advance
End Type
	
Type FTGlyph
	Field	lib,face,nextglyph,reserved
	Field	genericdata:Byte Ptr,genericdestructor	
	Field	metric_width,metric_height,metric_horibearingx,metric_horibearingy
	Field	metric_horiadvance,metric_vertbearingx,metric_vertbearingy,metric_vertadvance
	Field	hadvance,vadvance
    Field	advancex,advancey
	Field	glyphformat
'bitmap
	Field	rows,width,pitch
	Field	buffer:Byte Ptr
	Field	numgreys:Short,pixel_mode:Byte,palette_mode:Byte
	Field	palette:Byte Ptr
	Field	bitmap_left,bitmap_top
End Type
