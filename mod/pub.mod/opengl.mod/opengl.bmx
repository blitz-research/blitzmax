
Strict

Rem
bbdoc: Graphics/OpenGL 1.1
End Rem
Module Pub.OpenGL

ModuleInfo "Version: 1.02"
ModuleInfo "License: SGI Free Software License B"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Restored GLU"

?MacOS
Import "-framework AGL"
Import "-framework OpenGL"
?Win32
Import "-lglu32"
Import "-lopengl32"
?Linux
Import "-lGL"
Import "-lGLU"
?

Import "glu.bmx"

Extern "Os"

Const GL_ACCUM=$0100
Const GL_LOAD=$0101
Const GL_RETURN=$0102
Const GL_MULT=$0103
Const GL_ADD=$0104
Const GL_NEVER=$0200
Const GL_LESS=$0201
Const GL_EQUAL=$0202
Const GL_LEQUAL=$0203
Const GL_GREATER=$0204
Const GL_NOTEQUAL=$0205
Const GL_GEQUAL=$0206
Const GL_ALWAYS=$0207
Const GL_CURRENT_BIT=$00000001
Const GL_POINT_BIT=$00000002
Const GL_LINE_BIT=$00000004
Const GL_POLYGON_BIT=$00000008
Const GL_POLYGON_STIPPLE_BIT=$00000010
Const GL_PIXEL_MODE_BIT=$00000020
Const GL_LIGHTING_BIT=$00000040
Const GL_FOG_BIT=$00000080
Const GL_DEPTH_BUFFER_BIT=$00000100
Const GL_ACCUM_BUFFER_BIT=$00000200
Const GL_STENCIL_BUFFER_BIT=$00000400
Const GL_VIEWPORT_BIT=$00000800
Const GL_TRANSFORM_BIT=$00001000
Const GL_ENABLE_BIT=$00002000
Const GL_COLOR_BUFFER_BIT=$00004000
Const GL_HINT_BIT=$00008000
Const GL_EVAL_BIT=$00010000
Const GL_LIST_BIT=$00020000
Const GL_TEXTURE_BIT=$00040000
Const GL_SCISSOR_BIT=$00080000
Const GL_ALL_ATTRIB_BITS=$000fffff
Const GL_POINTS=$0000
Const GL_LINES=$0001
Const GL_LINE_LOOP=$0002
Const GL_LINE_STRIP=$0003
Const GL_TRIANGLES=$0004
Const GL_TRIANGLE_STRIP=$0005
Const GL_TRIANGLE_FAN=$0006
Const GL_QUADS=$0007
Const GL_QUAD_STRIP=$0008
Const GL_POLYGON=$0009
Const GL_ZERO=0
Const GL_ONE=1
Const GL_SRC_COLOR=$0300
Const GL_ONE_MINUS_SRC_COLOR=$0301
Const GL_SRC_ALPHA=$0302
Const GL_ONE_MINUS_SRC_ALPHA=$0303
Const GL_DST_ALPHA=$0304
Const GL_ONE_MINUS_DST_ALPHA=$0305
Const GL_DST_COLOR=$0306
Const GL_ONE_MINUS_DST_COLOR=$0307
Const GL_SRC_ALPHA_SATURATE=$0308
Const GL_TRUE=1
Const GL_FALSE=0
Const GL_CLIP_PLANE0=$3000
Const GL_CLIP_PLANE1=$3001
Const GL_CLIP_PLANE2=$3002
Const GL_CLIP_PLANE3=$3003
Const GL_CLIP_PLANE4=$3004
Const GL_CLIP_PLANE5=$3005
Const GL_BYTE=$1400
Const GL_UNSIGNED_BYTE=$1401
Const GL_SHORT=$1402
Const GL_UNSIGNED_SHORT=$1403
Const GL_INT=$1404
Const GL_UNSIGNED_INT=$1405
Const GL_FLOAT=$1406
Const GL_2_BYTES=$1407
Const GL_3_BYTES=$1408
Const GL_4_BYTES=$1409
Const GL_DOUBLE=$140A
Const GL_NONE=0
Const GL_FRONT_LEFT=$0400
Const GL_FRONT_RIGHT=$0401
Const GL_BACK_LEFT=$0402
Const GL_BACK_RIGHT=$0403
Const GL_FRONT=$0404
Const GL_BACK=$0405
Const GL_LEFT=$0406
Const GL_RIGHT=$0407
Const GL_FRONT_AND_BACK=$0408
Const GL_AUX0=$0409
Const GL_AUX1=$040A
Const GL_AUX2=$040B
Const GL_AUX3=$040C
Const GL_NO_ERROR=0
Const GL_INVALID_ENUM=$0500
Const GL_INVALID_VALUE=$0501
Const GL_INVALID_OPERATION=$0502
Const GL_STACK_OVERFLOW=$0503
Const GL_STACK_UNDERFLOW=$0504
Const GL_OUT_OF_MEMORY=$0505
Const GL_2D=$0600
Const GL_3D=$0601
Const GL_3D_COLOR=$0602
Const GL_3D_COLOR_TEXTURE=$0603
Const GL_4D_COLOR_TEXTURE=$0604
Const GL_PASS_THROUGH_TOKEN=$0700
Const GL_POINT_TOKEN=$0701
Const GL_LINE_TOKEN=$0702
Const GL_POLYGON_TOKEN=$0703
Const GL_BITMAP_TOKEN=$0704
Const GL_DRAW_PIXEL_TOKEN=$0705
Const GL_COPY_PIXEL_TOKEN=$0706
Const GL_LINE_RESET_TOKEN=$0707
Const GL_EXP=$0800
Const GL_EXP2=$0801
Const GL_CW=$0900
Const GL_CCW=$0901
Const GL_COEFF=$0A00
Const GL_ORDER=$0A01
Const GL_DOMAIN=$0A02
Const GL_CURRENT_COLOR=$0B00
Const GL_CURRENT_INDEX=$0B01
Const GL_CURRENT_NORMAL=$0B02
Const GL_CURRENT_TEXTURE_COORDS=$0B03
Const GL_CURRENT_RASTER_COLOR=$0B04
Const GL_CURRENT_RASTER_INDEX=$0B05
Const GL_CURRENT_RASTER_TEXTURE_COORDS=$0B06
Const GL_CURRENT_RASTER_POSITION=$0B07
Const GL_CURRENT_RASTER_POSITION_VALID=$0B08
Const GL_CURRENT_RASTER_DISTANCE=$0B09
Const GL_POINT_SMOOTH=$0B10
Const GL_POINT_SIZE=$0B11
Const GL_POINT_SIZE_RANGE=$0B12
Const GL_POINT_SIZE_GRANULARITY=$0B13
Const GL_LINE_SMOOTH=$0B20
Const GL_LINE_WIDTH=$0B21
Const GL_LINE_WIDTH_RANGE=$0B22
Const GL_LINE_WIDTH_GRANULARITY=$0B23
Const GL_LINE_STIPPLE=$0B24
Const GL_LINE_STIPPLE_PATTERN=$0B25
Const GL_LINE_STIPPLE_REPEAT=$0B26
Const GL_LIST_MODE=$0B30
Const GL_MAX_LIST_NESTING=$0B31
Const GL_LIST_BASE=$0B32
Const GL_LIST_INDEX=$0B33
Const GL_POLYGON_MODE=$0B40
Const GL_POLYGON_SMOOTH=$0B41
Const GL_POLYGON_STIPPLE=$0B42
Const GL_EDGE_FLAG=$0B43
Const GL_CULL_FACE=$0B44
Const GL_CULL_FACE_MODE=$0B45
Const GL_FRONT_FACE=$0B46
Const GL_LIGHTING=$0B50
Const GL_LIGHT_MODEL_LOCAL_VIEWER=$0B51
Const GL_LIGHT_MODEL_TWO_SIDE=$0B52
Const GL_LIGHT_MODEL_AMBIENT=$0B53
Const GL_SHADE_MODEL=$0B54
Const GL_COLOR_MATERIAL_FACE=$0B55
Const GL_COLOR_MATERIAL_PARAMETER=$0B56
Const GL_COLOR_MATERIAL=$0B57
Const GL_FOG=$0B60
Const GL_FOG_INDEX=$0B61
Const GL_FOG_DENSITY=$0B62
Const GL_FOG_START=$0B63
Const GL_FOG_END=$0B64
Const GL_FOG_MODE=$0B65
Const GL_FOG_COLOR=$0B66
Const GL_DEPTH_RANGE=$0B70
Const GL_DEPTH_TEST=$0B71
Const GL_DEPTH_WRITEMASK=$0B72
Const GL_DEPTH_CLEAR_VALUE=$0B73
Const GL_DEPTH_FUNC=$0B74
Const GL_ACCUM_CLEAR_VALUE=$0B80
Const GL_STENCIL_TEST=$0B90
Const GL_STENCIL_CLEAR_VALUE=$0B91
Const GL_STENCIL_FUNC=$0B92
Const GL_STENCIL_VALUE_MASK=$0B93
Const GL_STENCIL_FAIL=$0B94
Const GL_STENCIL_PASS_DEPTH_FAIL=$0B95
Const GL_STENCIL_PASS_DEPTH_PASS=$0B96
Const GL_STENCIL_REF=$0B97
Const GL_STENCIL_WRITEMASK=$0B98
Const GL_MATRIX_MODE=$0BA0
Const GL_NORMALIZE=$0BA1
Const GL_VIEWPORT=$0BA2
Const GL_MODELVIEW_STACK_DEPTH=$0BA3
Const GL_PROJECTION_STACK_DEPTH=$0BA4
Const GL_TEXTURE_STACK_DEPTH=$0BA5
Const GL_MODELVIEW_MATRIX=$0BA6
Const GL_PROJECTION_MATRIX=$0BA7
Const GL_TEXTURE_MATRIX=$0BA8
Const GL_ATTRIB_STACK_DEPTH=$0BB0
Const GL_CLIENT_ATTRIB_STACK_DEPTH=$0BB1
Const GL_ALPHA_TEST=$0BC0
Const GL_ALPHA_TEST_FUNC=$0BC1
Const GL_ALPHA_TEST_REF=$0BC2
Const GL_DITHER=$0BD0
Const GL_BLEND_DST=$0BE0
Const GL_BLEND_SRC=$0BE1
Const GL_BLEND=$0BE2
Const GL_LOGIC_OP_MODE=$0BF0
Const GL_INDEX_LOGIC_OP=$0BF1
Const GL_COLOR_LOGIC_OP=$0BF2
Const GL_AUX_BUFFERS=$0C00
Const GL_DRAW_BUFFER=$0C01
Const GL_READ_BUFFER=$0C02
Const GL_SCISSOR_BOX=$0C10
Const GL_SCISSOR_TEST=$0C11
Const GL_INDEX_CLEAR_VALUE=$0C20
Const GL_INDEX_WRITEMASK=$0C21
Const GL_COLOR_CLEAR_VALUE=$0C22
Const GL_COLOR_WRITEMASK=$0C23
Const GL_INDEX_MODE=$0C30
Const GL_RGBA_MODE=$0C31
Const GL_DOUBLEBUFFER=$0C32
Const GL_STEREO=$0C33
Const GL_RENDER_MODE=$0C40
Const GL_PERSPECTIVE_CORRECTION_HINT=$0C50
Const GL_POINT_SMOOTH_HINT=$0C51
Const GL_LINE_SMOOTH_HINT=$0C52
Const GL_POLYGON_SMOOTH_HINT=$0C53
Const GL_FOG_HINT=$0C54
Const GL_TEXTURE_GEN_S=$0C60
Const GL_TEXTURE_GEN_T=$0C61
Const GL_TEXTURE_GEN_R=$0C62
Const GL_TEXTURE_GEN_Q=$0C63
Const GL_PIXEL_MAP_I_TO_I=$0C70
Const GL_PIXEL_MAP_S_TO_S=$0C71
Const GL_PIXEL_MAP_I_TO_R=$0C72
Const GL_PIXEL_MAP_I_TO_G=$0C73
Const GL_PIXEL_MAP_I_TO_B=$0C74
Const GL_PIXEL_MAP_I_TO_A=$0C75
Const GL_PIXEL_MAP_R_TO_R=$0C76
Const GL_PIXEL_MAP_G_TO_G=$0C77
Const GL_PIXEL_MAP_B_TO_B=$0C78
Const GL_PIXEL_MAP_A_TO_A=$0C79
Const GL_PIXEL_MAP_I_TO_I_SIZE=$0CB0
Const GL_PIXEL_MAP_S_TO_S_SIZE=$0CB1
Const GL_PIXEL_MAP_I_TO_R_SIZE=$0CB2
Const GL_PIXEL_MAP_I_TO_G_SIZE=$0CB3
Const GL_PIXEL_MAP_I_TO_B_SIZE=$0CB4
Const GL_PIXEL_MAP_I_TO_A_SIZE=$0CB5
Const GL_PIXEL_MAP_R_TO_R_SIZE=$0CB6
Const GL_PIXEL_MAP_G_TO_G_SIZE=$0CB7
Const GL_PIXEL_MAP_B_TO_B_SIZE=$0CB8
Const GL_PIXEL_MAP_A_TO_A_SIZE=$0CB9
Const GL_UNPACK_SWAP_BYTES=$0CF0
Const GL_UNPACK_LSB_FIRST=$0CF1
Const GL_UNPACK_ROW_LENGTH=$0CF2
Const GL_UNPACK_SKIP_ROWS=$0CF3
Const GL_UNPACK_SKIP_PIXELS=$0CF4
Const GL_UNPACK_ALIGNMENT=$0CF5
Const GL_PACK_SWAP_BYTES=$0D00
Const GL_PACK_LSB_FIRST=$0D01
Const GL_PACK_ROW_LENGTH=$0D02
Const GL_PACK_SKIP_ROWS=$0D03
Const GL_PACK_SKIP_PIXELS=$0D04
Const GL_PACK_ALIGNMENT=$0D05
Const GL_MAP_COLOR=$0D10
Const GL_MAP_STENCIL=$0D11
Const GL_INDEX_SHIFT=$0D12
Const GL_INDEX_OFFSET=$0D13
Const GL_RED_SCALE=$0D14
Const GL_RED_BIAS=$0D15
Const GL_ZOOM_X=$0D16
Const GL_ZOOM_Y=$0D17
Const GL_GREEN_SCALE=$0D18
Const GL_GREEN_BIAS=$0D19
Const GL_BLUE_SCALE=$0D1A
Const GL_BLUE_BIAS=$0D1B
Const GL_ALPHA_SCALE=$0D1C
Const GL_ALPHA_BIAS=$0D1D
Const GL_DEPTH_SCALE=$0D1E
Const GL_DEPTH_BIAS=$0D1F
Const GL_MAX_EVAL_ORDER=$0D30
Const GL_MAX_LIGHTS=$0D31
Const GL_MAX_CLIP_PLANES=$0D32
Const GL_MAX_TEXTURE_SIZE=$0D33
Const GL_MAX_PIXEL_MAP_TABLE=$0D34
Const GL_MAX_ATTRIB_STACK_DEPTH=$0D35
Const GL_MAX_MODELVIEW_STACK_DEPTH=$0D36
Const GL_MAX_NAME_STACK_DEPTH=$0D37
Const GL_MAX_PROJECTION_STACK_DEPTH=$0D38
Const GL_MAX_TEXTURE_STACK_DEPTH=$0D39
Const GL_MAX_VIEWPORT_DIMS=$0D3A
Const GL_MAX_CLIENT_ATTRIB_STACK_DEPTH=$0D3B
Const GL_SUBPIXEL_BITS=$0D50
Const GL_INDEX_BITS=$0D51
Const GL_RED_BITS=$0D52
Const GL_GREEN_BITS=$0D53
Const GL_BLUE_BITS=$0D54
Const GL_ALPHA_BITS=$0D55
Const GL_DEPTH_BITS=$0D56
Const GL_STENCIL_BITS=$0D57
Const GL_ACCUM_RED_BITS=$0D58
Const GL_ACCUM_GREEN_BITS=$0D59
Const GL_ACCUM_BLUE_BITS=$0D5A
Const GL_ACCUM_ALPHA_BITS=$0D5B
Const GL_NAME_STACK_DEPTH=$0D70
Const GL_AUTO_NORMAL=$0D80
Const GL_MAP1_COLOR_4=$0D90
Const GL_MAP1_INDEX=$0D91
Const GL_MAP1_NORMAL=$0D92
Const GL_MAP1_TEXTURE_COORD_1=$0D93
Const GL_MAP1_TEXTURE_COORD_2=$0D94
Const GL_MAP1_TEXTURE_COORD_3=$0D95
Const GL_MAP1_TEXTURE_COORD_4=$0D96
Const GL_MAP1_VERTEX_3=$0D97
Const GL_MAP1_VERTEX_4=$0D98
Const GL_MAP2_COLOR_4=$0DB0
Const GL_MAP2_INDEX=$0DB1
Const GL_MAP2_NORMAL=$0DB2
Const GL_MAP2_TEXTURE_COORD_1=$0DB3
Const GL_MAP2_TEXTURE_COORD_2=$0DB4
Const GL_MAP2_TEXTURE_COORD_3=$0DB5
Const GL_MAP2_TEXTURE_COORD_4=$0DB6
Const GL_MAP2_VERTEX_3=$0DB7
Const GL_MAP2_VERTEX_4=$0DB8
Const GL_MAP1_GRID_DOMAIN=$0DD0
Const GL_MAP1_GRID_SEGMENTS=$0DD1
Const GL_MAP2_GRID_DOMAIN=$0DD2
Const GL_MAP2_GRID_SEGMENTS=$0DD3
Const GL_TEXTURE_1D=$0DE0
Const GL_TEXTURE_2D=$0DE1
Const GL_FEEDBACK_BUFFER_POINTER=$0DF0
Const GL_FEEDBACK_BUFFER_SIZE=$0DF1
Const GL_FEEDBACK_BUFFER_TYPE=$0DF2
Const GL_SELECTION_BUFFER_POINTER=$0DF3
Const GL_SELECTION_BUFFER_SIZE=$0DF4
Const GL_TEXTURE_WIDTH=$1000
Const GL_TEXTURE_HEIGHT=$1001
Const GL_TEXTURE_INTERNAL_FORMAT=$1003
Const GL_TEXTURE_BORDER_COLOR=$1004
Const GL_TEXTURE_BORDER=$1005
Const GL_DONT_CARE=$1100
Const GL_FASTEST=$1101
Const GL_NICEST=$1102
Const GL_LIGHT0=$4000
Const GL_LIGHT1=$4001
Const GL_LIGHT2=$4002
Const GL_LIGHT3=$4003
Const GL_LIGHT4=$4004
Const GL_LIGHT5=$4005
Const GL_LIGHT6=$4006
Const GL_LIGHT7=$4007
Const GL_AMBIENT=$1200
Const GL_DIFFUSE=$1201
Const GL_SPECULAR=$1202
Const GL_POSITION=$1203
Const GL_SPOT_DIRECTION=$1204
Const GL_SPOT_EXPONENT=$1205
Const GL_SPOT_CUTOFF=$1206
Const GL_CONSTANT_ATTENUATION=$1207
Const GL_LINEAR_ATTENUATION=$1208
Const GL_QUADRATIC_ATTENUATION=$1209
Const GL_COMPILE=$1300
Const GL_COMPILE_AND_EXECUTE=$1301
Const GL_CLEAR=$1500
Const GL_AND=$1501
Const GL_AND_REVERSE=$1502
Const GL_COPY=$1503
Const GL_AND_INVERTED=$1504
Const GL_NOOP=$1505
Const GL_XOR=$1506
Const GL_OR=$1507
Const GL_NOR=$1508
Const GL_EQUIV=$1509
Const GL_INVERT=$150A
Const GL_OR_REVERSE=$150B
Const GL_COPY_INVERTED=$150C
Const GL_OR_INVERTED=$150D
Const GL_NAND=$150E
Const GL_SET=$150F
Const GL_EMISSION=$1600
Const GL_SHININESS=$1601
Const GL_AMBIENT_AND_DIFFUSE=$1602
Const GL_COLOR_INDEXES=$1603
Const GL_MODELVIEW=$1700
Const GL_PROJECTION=$1701
Const GL_TEXTURE=$1702
Const GL_COLOR=$1800
Const GL_DEPTH=$1801
Const GL_STENCIL=$1802
Const GL_COLOR_INDEX=$1900
Const GL_STENCIL_INDEX=$1901
Const GL_DEPTH_COMPONENT=$1902
Const GL_RED=$1903
Const GL_GREEN=$1904
Const GL_BLUE=$1905
Const GL_ALPHA=$1906
Const GL_RGB=$1907
Const GL_RGBA=$1908
Const GL_LUMINANCE=$1909
Const GL_LUMINANCE_ALPHA=$190A
Const GL_BITMAP=$1A00
Const GL_POINT=$1B00
Const GL_LINE=$1B01
Const GL_FILL=$1B02
Const GL_RENDER=$1C00
Const GL_FEEDBACK=$1C01
Const GL_SELECT=$1C02
Const GL_FLAT=$1D00
Const GL_SMOOTH=$1D01
Const GL_KEEP=$1E00
Const GL_REPLACE=$1E01
Const GL_INCR=$1E02
Const GL_DECR=$1E03
Const GL_VENDOR=$1F00
Const GL_RENDERER=$1F01
Const GL_VERSION=$1F02
Const GL_EXTENSIONS=$1F03
Const GL_S=$2000
Const GL_T=$2001
Const GL_R=$2002
Const GL_Q=$2003
Const GL_MODULATE=$2100
Const GL_DECAL=$2101
Const GL_TEXTURE_ENV_MODE=$2200
Const GL_TEXTURE_ENV_COLOR=$2201
Const GL_TEXTURE_ENV=$2300
Const GL_EYE_LINEAR=$2400
Const GL_OBJECT_LINEAR=$2401
Const GL_SPHERE_MAP=$2402
Const GL_TEXTURE_GEN_MODE=$2500
Const GL_OBJECT_PLANE=$2501
Const GL_EYE_PLANE=$2502
Const GL_NEAREST=$2600
Const GL_LINEAR=$2601
Const GL_NEAREST_MIPMAP_NEAREST=$2700
Const GL_LINEAR_MIPMAP_NEAREST=$2701
Const GL_NEAREST_MIPMAP_LINEAR=$2702
Const GL_LINEAR_MIPMAP_LINEAR=$2703
Const GL_TEXTURE_MAG_FILTER=$2800
Const GL_TEXTURE_MIN_FILTER=$2801
Const GL_TEXTURE_WRAP_S=$2802
Const GL_TEXTURE_WRAP_T=$2803
Const GL_CLAMP=$2900
Const GL_REPEAT=$2901
Const GL_CLIENT_PIXEL_STORE_BIT=$00000001
Const GL_CLIENT_VERTEX_ARRAY_BIT=$00000002
Const GL_CLIENT_ALL_ATTRIB_BITS=$ffffffff
Const GL_POLYGON_OFFSET_FACTOR=$8038
Const GL_POLYGON_OFFSET_UNITS=$2A00
Const GL_POLYGON_OFFSET_POINT=$2A01
Const GL_POLYGON_OFFSET_LINE=$2A02
Const GL_POLYGON_OFFSET_FILL=$8037
Const GL_ALPHA4=$803B
Const GL_ALPHA8=$803C
Const GL_ALPHA12=$803D
Const GL_ALPHA16=$803E
Const GL_LUMINANCE4=$803F
Const GL_LUMINANCE8=$8040
Const GL_LUMINANCE12=$8041
Const GL_LUMINANCE16=$8042
Const GL_LUMINANCE4_ALPHA4=$8043
Const GL_LUMINANCE6_ALPHA2=$8044
Const GL_LUMINANCE8_ALPHA8=$8045
Const GL_LUMINANCE12_ALPHA4=$8046
Const GL_LUMINANCE12_ALPHA12=$8047
Const GL_LUMINANCE16_ALPHA16=$8048
Const GL_INTENSITY=$8049
Const GL_INTENSITY4=$804A
Const GL_INTENSITY8=$804B
Const GL_INTENSITY12=$804C
Const GL_INTENSITY16=$804D
Const GL_R3_G3_B2=$2A10
Const GL_RGB4=$804F
Const GL_RGB5=$8050
Const GL_RGB8=$8051
Const GL_RGB10=$8052
Const GL_RGB12=$8053
Const GL_RGB16=$8054
Const GL_RGBA2=$8055
Const GL_RGBA4=$8056
Const GL_RGB5_A1=$8057
Const GL_RGBA8=$8058
Const GL_RGB10_A2=$8059
Const GL_RGBA12=$805A
Const GL_RGBA16=$805B
Const GL_TEXTURE_RED_SIZE=$805C
Const GL_TEXTURE_GREEN_SIZE=$805D
Const GL_TEXTURE_BLUE_SIZE=$805E
Const GL_TEXTURE_ALPHA_SIZE=$805F
Const GL_TEXTURE_LUMINANCE_SIZE=$8060
Const GL_TEXTURE_INTENSITY_SIZE=$8061
Const GL_PROXY_TEXTURE_1D=$8063
Const GL_PROXY_TEXTURE_2D=$8064
Const GL_TEXTURE_PRIORITY=$8066
Const GL_TEXTURE_RESIDENT=$8067
Const GL_TEXTURE_BINDING_1D=$8068
Const GL_TEXTURE_BINDING_2D=$8069
Const GL_VERTEX_ARRAY=$8074
Const GL_NORMAL_ARRAY=$8075
Const GL_COLOR_ARRAY=$8076
Const GL_INDEX_ARRAY=$8077
Const GL_TEXTURE_COORD_ARRAY=$8078
Const GL_EDGE_FLAG_ARRAY=$8079
Const GL_VERTEX_ARRAY_SIZE=$807A
Const GL_VERTEX_ARRAY_TYPE=$807B
Const GL_VERTEX_ARRAY_STRIDE=$807C
Const GL_NORMAL_ARRAY_TYPE=$807E
Const GL_NORMAL_ARRAY_STRIDE=$807F
Const GL_COLOR_ARRAY_SIZE=$8081
Const GL_COLOR_ARRAY_TYPE=$8082
Const GL_COLOR_ARRAY_STRIDE=$8083
Const GL_INDEX_ARRAY_TYPE=$8085
Const GL_INDEX_ARRAY_STRIDE=$8086
Const GL_TEXTURE_COORD_ARRAY_SIZE=$8088
Const GL_TEXTURE_COORD_ARRAY_TYPE=$8089
Const GL_TEXTURE_COORD_ARRAY_STRIDE=$808A
Const GL_EDGE_FLAG_ARRAY_STRIDE=$808C
Const GL_VERTEX_ARRAY_POINTER=$808E
Const GL_NORMAL_ARRAY_POINTER=$808F
Const GL_COLOR_ARRAY_POINTER=$8090
Const GL_INDEX_ARRAY_POINTER=$8091
Const GL_TEXTURE_COORD_ARRAY_POINTER=$8092
Const GL_EDGE_FLAG_ARRAY_POINTER=$8093
Const GL_V2F=$2A20
Const GL_V3F=$2A21
Const GL_C4UB_V2F=$2A22
Const GL_C4UB_V3F=$2A23
Const GL_C3F_V3F=$2A24
Const GL_N3F_V3F=$2A25
Const GL_C4F_N3F_V3F=$2A26
Const GL_T2F_V3F=$2A27
Const GL_T4F_V4F=$2A28
Const GL_T2F_C4UB_V3F=$2A29
Const GL_T2F_C3F_V3F=$2A2A
Const GL_T2F_N3F_V3F=$2A2B
Const GL_T2F_C4F_N3F_V3F=$2A2C
Const GL_T4F_C4F_N3F_V4F=$2A2D
Const GL_COLOR_INDEX1_EXT=$80E2
Const GL_COLOR_INDEX2_EXT=$80E3
Const GL_COLOR_INDEX4_EXT=$80E4
Const GL_COLOR_INDEX8_EXT=$80E5
Const GL_COLOR_INDEX12_EXT=$80E6
Const GL_COLOR_INDEX16_EXT=$80E7
Function glAccum(op_:Int,value_:Float)
Function glAlphaFunc(func_:Int,ref_:Float)
Function glAreTexturesResident:Byte(n_:Int,textures_:Int Ptr,residences_:Byte Ptr)
Function glArrayElement(i_:Int)
Function glBegin(mode_:Int)
Function glBindTexture(target_:Int,texture_:Int)
Function glBitmap(width_:Int,height_:Int,xorig_:Float,yorig_:Float,xmove_:Float,ymove_:Float,bitmap_:Byte Ptr)
Function glBlendFunc(sfactor_:Int,dfactor_:Int)
Function glCallList(list_:Int)
Function glCallLists(n_:Int,type_:Int,lists_:Byte Ptr)
Function glClear(mask_:Int)
Function glClearAccum(red_:Float,green_:Float,blue_:Float,alpha_:Float)
Function glClearColor(red_:Float,green_:Float,blue_:Float,alpha_:Float)
Function glClearDepth(depth_:Double)
Function glClearIndex(c_:Float)
Function glClearStencil(s_:Int)
Function glClipPlane(plane_:Int,equation_:Double Ptr)
Function glColor3b(red_:Byte,green_:Byte,blue_:Byte)
Function glColor3bv(v_:Byte Ptr)
Function glColor3d(red_:Double,green_:Double,blue_:Double)
Function glColor3dv(v_:Double Ptr)
Function glColor3f(red_:Float,green_:Float,blue_:Float)
Function glColor3fv(v_:Float Ptr)
Function glColor3i(red_:Int,green_:Int,blue_:Int)
Function glColor3iv(v_:Int Ptr)
Function glColor3s(red_:Short,green_:Short,blue_:Short)
Function glColor3sv(v_:Short Ptr)
Function glColor3ub(red_:Byte,green_:Byte,blue_:Byte)
Function glColor3ubv(v_:Byte Ptr)
Function glColor3ui(red_:Int,green_:Int,blue_:Int)
Function glColor3uiv(v_:Int Ptr)
Function glColor3us(red_:Short,green_:Short,blue_:Short)
Function glColor3usv(v_:Short Ptr)
Function glColor4b(red_:Byte,green_:Byte,blue_:Byte,alpha_:Byte)
Function glColor4bv(v_:Byte Ptr)
Function glColor4d(red_:Double,green_:Double,blue_:Double,alpha_:Double)
Function glColor4dv(v_:Double Ptr)
Function glColor4f(red_:Float,green_:Float,blue_:Float,alpha_:Float)
Function glColor4fv(v_:Float Ptr)
Function glColor4i(red_:Int,green_:Int,blue_:Int,alpha_:Int)
Function glColor4iv(v_:Int Ptr)
Function glColor4s(red_:Short,green_:Short,blue_:Short,alpha_:Short)
Function glColor4sv(v_:Short Ptr)
Function glColor4ub(red_:Byte,green_:Byte,blue_:Byte,alpha_:Byte)
Function glColor4ubv(v_:Byte Ptr)
Function glColor4ui(red_:Int,green_:Int,blue_:Int,alpha_:Int)
Function glColor4uiv(v_:Int Ptr)
Function glColor4us(red_:Short,green_:Short,blue_:Short,alpha_:Short)
Function glColor4usv(v_:Short Ptr)
Function glColorMask(red_:Byte,green_:Byte,blue_:Byte,alpha_:Byte)
Function glColorMaterial(face_:Int,mode_:Int)
Function glColorPointer(size_:Int,type_:Int,stride_:Int,pointer_:Byte Ptr)
Function glCopyPixels(x_:Int,y_:Int,width_:Int,height_:Int,type_:Int)
Function glCopyTexImage1D(target_:Int,level_:Int,internalFormat_:Int,x_:Int,y_:Int,width_:Int,border_:Int)
Function glCopyTexImage2D(target_:Int,level_:Int,internalFormat_:Int,x_:Int,y_:Int,width_:Int,height_:Int,border_:Int)
Function glCopyTexSubImage1D(target_:Int,level_:Int,xoffset_:Int,x_:Int,y_:Int,width_:Int)
Function glCopyTexSubImage2D(target_:Int,level_:Int,xoffset_:Int,yoffset_:Int,x_:Int,y_:Int,width_:Int,height_:Int)
Function glCullFace(mode_:Int)
Function glDeleteLists(list_:Int,range_:Int)
Function glDeleteTextures(n_:Int,textures_:Int Ptr)
Function glDepthFunc(func_:Int)
Function glDepthMask(flag_:Byte)
Function glDepthRange(zNear_:Double,zFar_:Double)
Function glDisable(cap_:Int)
Function glDisableClientState(array_:Int)
Function glDrawArrays(mode_:Int,first_:Int,count_:Int)
Function glDrawBuffer(mode_:Int)
Function glDrawElements(mode_:Int,count_:Int,type_:Int,indices_:Byte Ptr)
Function glDrawPixels(width_:Int,height_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glEdgeFlag(flag_:Byte)
Function glEdgeFlagPointer(stride_:Int,pointer_:Byte Ptr)
Function glEdgeFlagv(flag_:Byte Ptr)
Function glEnable(cap_:Int)
Function glEnableClientState(array_:Int)
Function glEnd()
Function glEndList()
Function glEvalCoord1d(u_:Double)
Function glEvalCoord1dv(u_:Double Ptr)
Function glEvalCoord1f(u_:Float)
Function glEvalCoord1fv(u_:Float Ptr)
Function glEvalCoord2d(u_:Double,v_:Double)
Function glEvalCoord2dv(u_:Double Ptr)
Function glEvalCoord2f(u_:Float,v_:Float)
Function glEvalCoord2fv(u_:Float Ptr)
Function glEvalMesh1(mode_:Int,i1_:Int,i2_:Int)
Function glEvalMesh2(mode_:Int,i1_:Int,i2_:Int,j1_:Int,j2_:Int)
Function glEvalPoint1(i_:Int)
Function glEvalPoint2(i_:Int,j_:Int)
Function glFeedbackBuffer(size_:Int,type_:Int,buffer_:Float Ptr)
Function glFinish()
Function glFlush()
Function glFogf(pname_:Int,param_:Float)
Function glFogfv(pname_:Int,params_:Float Ptr)
Function glFogi(pname_:Int,param_:Int)
Function glFogiv(pname_:Int,params_:Int Ptr)
Function glFrontFace(mode_:Int)
Function glFrustum(left_:Double,right_:Double,bottom_:Double,top_:Double,zNear_:Double,zFar_:Double)
Function glGenLists:Int(range_:Int)
Function glGenTextures(n_:Int,textures_:Int Ptr)
Function glGetBooleanv(pname_:Int,params_:Byte Ptr)
Function glGetClipPlane(plane_:Int,equation_:Double Ptr)
Function glGetDoublev(pname_:Int,params_:Double Ptr)
Function glGetError:Int()
Function glGetFloatv(pname_:Int,params_:Float Ptr)
Function glGetIntegerv(pname_:Int,params_:Int Ptr)
Function glGetLightfv(light_:Int,pname_:Int,params_:Float Ptr)
Function glGetLightiv(light_:Int,pname_:Int,params_:Int Ptr)
Function glGetMapdv(target_:Int,query_:Int,v_:Double Ptr)
Function glGetMapfv(target_:Int,query_:Int,v_:Float Ptr)
Function glGetMapiv(target_:Int,query_:Int,v_:Int Ptr)
Function glGetMaterialfv(face_:Int,pname_:Int,params_:Float Ptr)
Function glGetMaterialiv(face_:Int,pname_:Int,params_:Int Ptr)
Function glGetPixelMapfv(map_:Int,values_:Float Ptr)
Function glGetPixelMapuiv(map_:Int,values_:Int Ptr)
Function glGetPixelMapusv(map_:Int,values_:Short Ptr)
Function glGetPointerv(pname_:Int,params_:Byte Ptr Ptr)
Function glGetPolygonStipple(mask_:Byte Ptr)
Function glGetString:Byte Ptr(name_:Int)
Function glGetTexEnvfv(target_:Int,pname_:Int,params_:Float Ptr)
Function glGetTexEnviv(target_:Int,pname_:Int,params_:Int Ptr)
Function glGetTexGendv(coord_:Int,pname_:Int,params_:Double Ptr)
Function glGetTexGenfv(coord_:Int,pname_:Int,params_:Float Ptr)
Function glGetTexGeniv(coord_:Int,pname_:Int,params_:Int Ptr)
Function glGetTexImage(target_:Int,level_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glGetTexLevelParameterfv(target_:Int,level_:Int,pname_:Int,params_:Float Ptr)
Function glGetTexLevelParameteriv(target_:Int,level_:Int,pname_:Int,params_:Int Ptr)
Function glGetTexParameterfv(target_:Int,pname_:Int,params_:Float Ptr)
Function glGetTexParameteriv(target_:Int,pname_:Int,params_:Int Ptr)
Function glHint(target_:Int,mode_:Int)
Function glIndexMask(mask_:Int)
Function glIndexPointer(type_:Int,stride_:Int,pointer_:Byte Ptr)
Function glIndexd(c_:Double)
Function glIndexdv(c_:Double Ptr)
Function glIndexf(c_:Float)
Function glIndexfv(c_:Float Ptr)
Function glIndexi(c_:Int)
Function glIndexiv(c_:Int Ptr)
Function glIndexs(c_:Short)
Function glIndexsv(c_:Short Ptr)
Function glIndexub(c_:Byte)
Function glIndexubv(c_:Byte Ptr)
Function glInitNames()
Function glInterleavedArrays(format_:Int,stride_:Int,pointer_:Byte Ptr)
Function glIsEnabled:Byte(cap_:Int)
Function glIsList:Byte(list_:Int)
Function glIsTexture:Byte(texture_:Int)
Function glLightModelf(pname_:Int,param_:Float)
Function glLightModelfv(pname_:Int,params_:Float Ptr)
Function glLightModeli(pname_:Int,param_:Int)
Function glLightModeliv(pname_:Int,params_:Int Ptr)
Function glLightf(light_:Int,pname_:Int,param_:Float)
Function glLightfv(light_:Int,pname_:Int,params_:Float Ptr)
Function glLighti(light_:Int,pname_:Int,param_:Int)
Function glLightiv(light_:Int,pname_:Int,params_:Int Ptr)
Function glLineStipple(factor_:Int,pattern_:Short)
Function glLineWidth(width_:Float)
Function glListBase(base_:Int)
Function glLoadIdentity()
Function glLoadMatrixd(m_:Double Ptr)
Function glLoadMatrixf(m_:Float Ptr)
Function glLoadName(name_:Int)
Function glLogicOp(opcode_:Int)
Function glMap1d(target_:Int,u1_:Double,u2_:Double,stride_:Int,order_:Int,points_:Double Ptr)
Function glMap1f(target_:Int,u1_:Float,u2_:Float,stride_:Int,order_:Int,points_:Float Ptr)
Function glMap2d(target_:Int,u1_:Double,u2_:Double,ustride_:Int,uorder_:Int,v1_:Double,v2_:Double,vstride_:Int,vorder_:Int,points_:Double Ptr)
Function glMap2f(target_:Int,u1_:Float,u2_:Float,ustride_:Int,uorder_:Int,v1_:Float,v2_:Float,vstride_:Int,vorder_:Int,points_:Float Ptr)
Function glMapGrid1d(un_:Int,u1_:Double,u2_:Double)
Function glMapGrid1f(un_:Int,u1_:Float,u2_:Float)
Function glMapGrid2d(un_:Int,u1_:Double,u2_:Double,vn_:Int,v1_:Double,v2_:Double)
Function glMapGrid2f(un_:Int,u1_:Float,u2_:Float,vn_:Int,v1_:Float,v2_:Float)
Function glMaterialf(face_:Int,pname_:Int,param_:Float)
Function glMaterialfv(face_:Int,pname_:Int,params_:Float Ptr)
Function glMateriali(face_:Int,pname_:Int,param_:Int)
Function glMaterialiv(face_:Int,pname_:Int,params_:Int Ptr)
Function glMatrixMode(mode_:Int)
Function glMultMatrixd(m_:Double Ptr)
Function glMultMatrixf(m_:Float Ptr)
Function glNewList(list_:Int,mode_:Int)
Function glNormal3b(nx_:Byte,ny_:Byte,nz_:Byte)
Function glNormal3bv(v_:Byte Ptr)
Function glNormal3d(nx_:Double,ny_:Double,nz_:Double)
Function glNormal3dv(v_:Double Ptr)
Function glNormal3f(nx_:Float,ny_:Float,nz_:Float)
Function glNormal3fv(v_:Float Ptr)
Function glNormal3i(nx_:Int,ny_:Int,nz_:Int)
Function glNormal3iv(v_:Int Ptr)
Function glNormal3s(nx_:Short,ny_:Short,nz_:Short)
Function glNormal3sv(v_:Short Ptr)
Function glNormalPointer(type_:Int,stride_:Int,pointer_:Byte Ptr)
Function glOrtho(left_:Double,right_:Double,bottom_:Double,top_:Double,zNear_:Double,zFar_:Double)
Function glPassThrough(token_:Float)
Function glPixelMapfv(map_:Int,mapsize_:Int,values_:Float Ptr)
Function glPixelMapuiv(map_:Int,mapsize_:Int,values_:Int Ptr)
Function glPixelMapusv(map_:Int,mapsize_:Int,values_:Short Ptr)
Function glPixelStoref(pname_:Int,param_:Float)
Function glPixelStorei(pname_:Int,param_:Int)
Function glPixelTransferf(pname_:Int,param_:Float)
Function glPixelTransferi(pname_:Int,param_:Int)
Function glPixelZoom(xfactor_:Float,yfactor_:Float)
Function glPointSize(size_:Float)
Function glPolygonMode(face_:Int,mode_:Int)
Function glPolygonOffset(factor_:Float,units_:Float)
Function glPolygonStipple(mask_:Byte Ptr)
Function glPopAttrib()
Function glPopClientAttrib()
Function glPopMatrix()
Function glPopName()
Function glPrioritizeTextures(n_:Int,textures_:Int Ptr,priorities_:Float Ptr)
Function glPushAttrib(mask_:Int)
Function glPushClientAttrib(mask_:Int)
Function glPushMatrix()
Function glPushName(name_:Int)
Function glRasterPos2d(x_:Double,y_:Double)
Function glRasterPos2dv(v_:Double Ptr)
Function glRasterPos2f(x_:Float,y_:Float)
Function glRasterPos2fv(v_:Float Ptr)
Function glRasterPos2i(x_:Int,y_:Int)
Function glRasterPos2iv(v_:Int Ptr)
Function glRasterPos2s(x_:Short,y_:Short)
Function glRasterPos2sv(v_:Short Ptr)
Function glRasterPos3d(x_:Double,y_:Double,z_:Double)
Function glRasterPos3dv(v_:Double Ptr)
Function glRasterPos3f(x_:Float,y_:Float,z_:Float)
Function glRasterPos3fv(v_:Float Ptr)
Function glRasterPos3i(x_:Int,y_:Int,z_:Int)
Function glRasterPos3iv(v_:Int Ptr)
Function glRasterPos3s(x_:Short,y_:Short,z_:Short)
Function glRasterPos3sv(v_:Short Ptr)
Function glRasterPos4d(x_:Double,y_:Double,z_:Double,w_:Double)
Function glRasterPos4dv(v_:Double Ptr)
Function glRasterPos4f(x_:Float,y_:Float,z_:Float,w_:Float)
Function glRasterPos4fv(v_:Float Ptr)
Function glRasterPos4i(x_:Int,y_:Int,z_:Int,w_:Int)
Function glRasterPos4iv(v_:Int Ptr)
Function glRasterPos4s(x_:Short,y_:Short,z_:Short,w_:Short)
Function glRasterPos4sv(v_:Short Ptr)
Function glReadBuffer(mode_:Int)
Function glReadPixels(x_:Int,y_:Int,width_:Int,height_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glRectd(x1_:Double,y1_:Double,x2_:Double,y2_:Double)
Function glRectdv(v1_:Double Ptr,v2_:Double Ptr)
Function glRectf(x1_:Float,y1_:Float,x2_:Float,y2_:Float)
Function glRectfv(v1_:Float Ptr,v2_:Float Ptr)
Function glRecti(x1_:Int,y1_:Int,x2_:Int,y2_:Int)
Function glRectiv(v1_:Int Ptr,v2_:Int Ptr)
Function glRects(x1_:Short,y1_:Short,x2_:Short,y2_:Short)
Function glRectsv(v1_:Short Ptr,v2_:Short Ptr)
Function glRenderMode:Int(mode_:Int)
Function glRotated(angle_:Double,x_:Double,y_:Double,z_:Double)
Function glRotatef(angle_:Float,x_:Float,y_:Float,z_:Float)
Function glScaled(x_:Double,y_:Double,z_:Double)
Function glScalef(x_:Float,y_:Float,z_:Float)
Function glScissor(x_:Int,y_:Int,width_:Int,height_:Int)
Function glSelectBuffer(size_:Int,buffer_:Int Ptr)
Function glShadeModel(mode_:Int)
Function glStencilFunc(func_:Int,ref_:Int,mask_:Int)
Function glStencilMask(mask_:Int)
Function glStencilOp(fail_:Int,zfail_:Int,zpass_:Int)
Function glTexCoord1d(s_:Double)
Function glTexCoord1dv(v_:Double Ptr)
Function glTexCoord1f(s_:Float)
Function glTexCoord1fv(v_:Float Ptr)
Function glTexCoord1i(s_:Int)
Function glTexCoord1iv(v_:Int Ptr)
Function glTexCoord1s(s_:Short)
Function glTexCoord1sv(v_:Short Ptr)
Function glTexCoord2d(s_:Double,t_:Double)
Function glTexCoord2dv(v_:Double Ptr)
Function glTexCoord2f(s_:Float,t_:Float)
Function glTexCoord2fv(v_:Float Ptr)
Function glTexCoord2i(s_:Int,t_:Int)
Function glTexCoord2iv(v_:Int Ptr)
Function glTexCoord2s(s_:Short,t_:Short)
Function glTexCoord2sv(v_:Short Ptr)
Function glTexCoord3d(s_:Double,t_:Double,r_:Double)
Function glTexCoord3dv(v_:Double Ptr)
Function glTexCoord3f(s_:Float,t_:Float,r_:Float)
Function glTexCoord3fv(v_:Float Ptr)
Function glTexCoord3i(s_:Int,t_:Int,r_:Int)
Function glTexCoord3iv(v_:Int Ptr)
Function glTexCoord3s(s_:Short,t_:Short,r_:Short)
Function glTexCoord3sv(v_:Short Ptr)
Function glTexCoord4d(s_:Double,t_:Double,r_:Double,q_:Double)
Function glTexCoord4dv(v_:Double Ptr)
Function glTexCoord4f(s_:Float,t_:Float,r_:Float,q_:Float)
Function glTexCoord4fv(v_:Float Ptr)
Function glTexCoord4i(s_:Int,t_:Int,r_:Int,q_:Int)
Function glTexCoord4iv(v_:Int Ptr)
Function glTexCoord4s(s_:Short,t_:Short,r_:Short,q_:Short)
Function glTexCoord4sv(v_:Short Ptr)
Function glTexCoordPointer(size_:Int,type_:Int,stride_:Int,pointer_:Byte Ptr)
Function glTexEnvf(target_:Int,pname_:Int,param_:Float)
Function glTexEnvfv(target_:Int,pname_:Int,params_:Float Ptr)
Function glTexEnvi(target_:Int,pname_:Int,param_:Int)
Function glTexEnviv(target_:Int,pname_:Int,params_:Int Ptr)
Function glTexGend(coord_:Int,pname_:Int,param_:Double)
Function glTexGendv(coord_:Int,pname_:Int,params_:Double Ptr)
Function glTexGenf(coord_:Int,pname_:Int,param_:Float)
Function glTexGenfv(coord_:Int,pname_:Int,params_:Float Ptr)
Function glTexGeni(coord_:Int,pname_:Int,param_:Int)
Function glTexGeniv(coord_:Int,pname_:Int,params_:Int Ptr)
Function glTexImage1D(target_:Int,level_:Int,internalformat_:Int,width_:Int,border_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glTexImage2D(target_:Int,level_:Int,internalformat_:Int,width_:Int,height_:Int,border_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glTexParameterf(target_:Int,pname_:Int,param_:Float)
Function glTexParameterfv(target_:Int,pname_:Int,params_:Float Ptr)
Function glTexParameteri(target_:Int,pname_:Int,param_:Int)
Function glTexParameteriv(target_:Int,pname_:Int,params_:Int Ptr)
Function glTexSubImage1D(target_:Int,level_:Int,xoffset_:Int,width_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glTexSubImage2D(target_:Int,level_:Int,xoffset_:Int,yoffset_:Int,width_:Int,height_:Int,format_:Int,type_:Int,pixels_:Byte Ptr)
Function glTranslated(x_:Double,y_:Double,z_:Double)
Function glTranslatef(x_:Float,y_:Float,z_:Float)
Function glVertex2d(x_:Double,y_:Double)
Function glVertex2dv(v_:Double Ptr)
Function glVertex2f(x_:Float,y_:Float)
Function glVertex2fv(v_:Float Ptr)
Function glVertex2i(x_:Int,y_:Int)
Function glVertex2iv(v_:Int Ptr)
Function glVertex2s(x_:Short,y_:Short)
Function glVertex2sv(v_:Short Ptr)
Function glVertex3d(x_:Double,y_:Double,z_:Double)
Function glVertex3dv(v_:Double Ptr)
Function glVertex3f(x_:Float,y_:Float,z_:Float)
Function glVertex3fv(v_:Float Ptr)
Function glVertex3i(x_:Int,y_:Int,z_:Int)
Function glVertex3iv(v_:Int Ptr)
Function glVertex3s(x_:Short,y_:Short,z_:Short)
Function glVertex3sv(v_:Short Ptr)
Function glVertex4d(x_:Double,y_:Double,z_:Double,w_:Double)
Function glVertex4dv(v_:Double Ptr)
Function glVertex4f(x_:Float,y_:Float,z_:Float,w_:Float)
Function glVertex4fv(v_:Float Ptr)
Function glVertex4i(x_:Int,y_:Int,z_:Int,w_:Int)
Function glVertex4iv(v_:Int Ptr)
Function glVertex4s(x_:Short,y_:Short,z_:Short,w_:Short)
Function glVertex4sv(v_:Short Ptr)
Function glVertexPointer(size_:Int,type_:Int,stride_:Int,pointer_:Byte Ptr)
Function glViewport(x_:Int,y_:Int,width_:Int,height_:Int)

End Extern
