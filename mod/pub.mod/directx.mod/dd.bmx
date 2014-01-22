 
Strict

Import Pub.Win32

Const DIRECTDRAW_VERSION=$0700
Const _FACDD=$876

Const FOURCC_DXT1$="DXT1"	'TODO: convert to 32 bit hex
Const FOURCC_DXT2$="DXT2"
Const FOURCC_DXT3$="DXT3"
Const FOURCC_DXT4$="DXT4"

Const DDENUM_ATTACHEDSECONDARYDEVICES=1
Const DDENUM_DETACHEDSECONDARYDEVICES=2
Const DDENUM_NONDISPLAYDEVICES=4

Const REGSTR_KEY_DDHW_DESCRIPTION$="Description"
Const REGSTR_KEY_DDHW_DRIVERNAME$="DriverName"
Const REGSTR_PATH_DDHW$="Hardware\\DirectDrawDrivers"

Const DDCREATE_HARDWAREONLY=$11
Const DDCREATE_EMULATIONONLY=$21

Const DDSD_CAPS=$1
Const DDSD_HEIGHT=$2
Const DDSD_WIDTH=$4
Const DDSD_PITCH=$8
Const DDSD_BACKBUFFERCOUNT=$20
Const DDSD_ZBUFFERBITDEPTH=$40
Const DDSD_ALPHABITDEPTH=$80
Const DDSD_LPSURFACE=$800
Const DDSD_PIXELFORMAT=$1000
Const DDSD_CKDESTOVERLAY=$2000
Const DDSD_CKDESTBLT=$4000
Const DDSD_CKSRCOVERLAY=$8000
Const DDSD_CKSRCBLT=$10000
Const DDSD_MIPMAPCOUNT=$20000
Const DDSD_REFRESHRATE=$40000
Const DDSD_LINEARSIZE=$80000
Const DDSD_TEXTURESTAGE=$100000
Const DDSD_FVF=$200000
Const DDSD_SRCVBHANDLE=$400000
Const DDSD_ALL=$7ff9ee

Const DDOSD_GUID=$1
Const DDOSD_COMPRESSION_RATIO=$2
Const DDOSD_SCAPS=$4
Const DDOSD_OSCAPS=$8
Const DDOSD_ALL=$f

Const DDOSDCAPS_OPTCOMPRESSED=$1
Const DDOSDCAPS_OPTREORDERED=$2
Const DDOSDCAPS_MONOLITHICMIPMAP=$4
Const DDOSDCAPS_VALIDSCAPS=$30004800
Const DDOSDCAPS_VALIDOSCAPS=$7

Const DDCOLOR_BRIGHTNESS=$1
Const DDCOLOR_CONTRAST=$2
Const DDCOLOR_HUE=$4
Const DDCOLOR_SATURATION=$8
Const DDCOLOR_SHARPNESS=$10
Const DDCOLOR_GAMMA=$20
Const DDCOLOR_COLORENABLE=$40
Const DDSCAPS_RESERVED1=$1
Const DDSCAPS_ALPHA=$2
Const DDSCAPS_BACKBUFFER=$4
Const DDSCAPS_COMPLEX=$8
Const DDSCAPS_FLIP=$10
Const DDSCAPS_FRONTBUFFER=$20
Const DDSCAPS_OFFSCREENPLAIN=$40
Const DDSCAPS_OVERLAY=$80
Const DDSCAPS_PALETTE=$100
Const DDSCAPS_PRIMARYSURFACE=$200
Const DDSCAPS_RESERVED3=$400
Const DDSCAPS_SYSTEMMEMORY=$800
Const DDSCAPS_TEXTURE=$1000
Const DDSCAPS_3DDEVICE=$2000
Const DDSCAPS_VIDEOMEMORY=$4000
Const DDSCAPS_VISIBLE=$8000
Const DDSCAPS_WRITEONLY=$10000
Const DDSCAPS_ZBUFFER=$20000
Const DDSCAPS_OWNDC=$40000
Const DDSCAPS_LIVEVIDEO=$80000
Const DDSCAPS_HWCODEC=$100000
Const DDSCAPS_MODEX=$200000
Const DDSCAPS_MIPMAP=$400000
Const DDSCAPS_RESERVED2=$800000
Const DDSCAPS_ALLOCONLOAD=$4000000
Const DDSCAPS_VIDEOPORT=$8000000
Const DDSCAPS_LOCALVIDMEM=$10000000
Const DDSCAPS_NONLOCALVIDMEM=$20000000
Const DDSCAPS_STANDARDVGAMODE=$40000000
Const DDSCAPS_OPTIMIZED=$80000000

Const DDSCAPS2_HARDWAREDEINTERLACE=$2
Const DDSCAPS2_HINTDYNAMIC=$4
Const DDSCAPS2_HINTSTATIC=$8
Const DDSCAPS2_TEXTUREMANAGE=$10
Const DDSCAPS2_RESERVED1=$20
Const DDSCAPS2_RESERVED2=$40
Const DDSCAPS2_OPAQUE=$80
Const DDSCAPS2_HINTANTIALIASING=$100
Const DDSCAPS2_CUBEMAP=$200
Const DDSCAPS2_CUBEMAP_POSITIVEX=$400
Const DDSCAPS2_CUBEMAP_NEGATIVEX=$800
Const DDSCAPS2_CUBEMAP_POSITIVEY=$1000
Const DDSCAPS2_CUBEMAP_NEGATIVEY=$2000
Const DDSCAPS2_CUBEMAP_POSITIVEZ=$4000
Const DDSCAPS2_CUBEMAP_NEGATIVEZ=$8000
Const DDSCAPS2_CUBEMAP_ALLFACES=DDSCAPS2_CUBEMAP_POSITIVEX|DDSCAPS2_CUBEMAP_NEGATIVEX|DDSCAPS2_CUBEMAP_POSITIVEY|DDSCAPS2_CUBEMAP_NEGATIVEY|DDSCAPS2_CUBEMAP_POSITIVEZ|DDSCAPS2_CUBEMAP_NEGATIVEZ
Const DDSCAPS2_MIPMAPSUBLEVEL=$10000
Const DDSCAPS2_D3DTEXTUREMANAGE=$20000
Const DDSCAPS2_DONOTPERSIST=$40000
Const DDSCAPS2_STEREOSURFACELEFT=$80000

Const DDCAPS_3D=$1
Const DDCAPS_ALIGNBOUNDARYDEST=$2
Const DDCAPS_ALIGNSIZEDEST=$4
Const DDCAPS_ALIGNBOUNDARYSRC=$8
Const DDCAPS_ALIGNSIZESRC=$10
Const DDCAPS_ALIGNSTRIDE=$20
Const DDCAPS_BLT=$40
Const DDCAPS_BLTQUEUE=$80
Const DDCAPS_BLTFOURCC=$100
Const DDCAPS_BLTSTRETCH=$200
Const DDCAPS_GDI=$400
Const DDCAPS_OVERLAY=$800
Const DDCAPS_OVERLAYCANTCLIP=$1000
Const DDCAPS_OVERLAYFOURCC=$2000
Const DDCAPS_OVERLAYSTRETCH=$4000
Const DDCAPS_PALETTE=$8000
Const DDCAPS_PALETTEVSYNC=$10000
Const DDCAPS_READSCANLINE=$20000
Const DDCAPS_RESERVED1=$40000
Const DDCAPS_VBI=$80000
Const DDCAPS_ZBLTS=$100000
Const DDCAPS_ZOVERLAYS=$200000
Const DDCAPS_COLORKEY=$400000
Const DDCAPS_ALPHA=$800000
Const DDCAPS_COLORKEYHWASSIST=$1000000
Const DDCAPS_NOHARDWARE=$2000000
Const DDCAPS_BLTCOLORFILL=$4000000
Const DDCAPS_BANKSWITCHED=$8000000
Const DDCAPS_BLTDEPTHFILL=$10000000
Const DDCAPS_CANCLIP=$20000000
Const DDCAPS_CANCLIPSTRETCHED=$40000000
Const DDCAPS_CANBLTSYSMEM=$80000000

Const DDCAPS2_CERTIFIED=$1
Const DDCAPS2_NO2DDURING3DSCENE=$2
Const DDCAPS2_VIDEOPORT=$4
Const DDCAPS2_AUTOFLIPOVERLAY=$8
Const DDCAPS2_CANBOBINTERLEAVED=$10
Const DDCAPS2_CANBOBNONINTERLEAVED=$20
Const DDCAPS2_COLORCONTROLOVERLAY=$40
Const DDCAPS2_COLORCONTROLPRIMARY=$80
Const DDCAPS2_CANDROPZ16BIT=$100
Const DDCAPS2_NONLOCALVIDMEM=$200
Const DDCAPS2_NONLOCALVIDMEMCAPS=$400
Const DDCAPS2_NOPAGELOCKREQUIRED=$800
Const DDCAPS2_WIDESURFACES=$1000
Const DDCAPS2_CANFLIPODDEVEN=$2000
Const DDCAPS2_CANBOBHARDWARE=$4000
Const DDCAPS2_COPYFOURCC=$8000
Const DDCAPS2_PRIMARYGAMMA=$20000
Const DDCAPS2_CANRENDERWINDOWED=$80000
Const DDCAPS2_CANCALIBRATEGAMMA=$100000
Const DDCAPS2_FLIPINTERVAL=$200000
Const DDCAPS2_FLIPNOVSYNC=$400000
Const DDCAPS2_CANMANAGETEXTURE=$800000
Const DDCAPS2_TEXMANINNONLOCALVIDMEM=$1000000
Const DDCAPS2_STEREO=$2000000
Const DDCAPS2_SYSTONONLOCAL_AS_SYSTOLOCAL=$4000000

Const DDFXALPHACAPS_BLTALPHAEDGEBLEND=$1
Const DDFXALPHACAPS_BLTALPHAPIXELS=$2
Const DDFXALPHACAPS_BLTALPHAPIXELSNEG=$4
Const DDFXALPHACAPS_BLTALPHASURFACES=$8
Const DDFXALPHACAPS_BLTALPHASURFACESNEG=$10
Const DDFXALPHACAPS_OVERLAYALPHAEDGEBLEND=$20
Const DDFXALPHACAPS_OVERLAYALPHAPIXELS=$40
Const DDFXALPHACAPS_OVERLAYALPHAPIXELSNEG=$80
Const DDFXALPHACAPS_OVERLAYALPHASURFACES=$100
Const DDFXALPHACAPS_OVERLAYALPHASURFACESNEG=$200

Const DDFXCAPS_BLTARITHSTRETCHY=$20
Const DDFXCAPS_BLTARITHSTRETCHYN=$10
Const DDFXCAPS_BLTMIRRORLEFTRIGHT=$40
Const DDFXCAPS_BLTMIRRORUPDOWN=$80
Const DDFXCAPS_BLTROTATION=$100
Const DDFXCAPS_BLTROTATION90=$200
Const DDFXCAPS_BLTSHRINKX=$400
Const DDFXCAPS_BLTSHRINKXN=$800
Const DDFXCAPS_BLTSHRINKY=$1000
Const DDFXCAPS_BLTSHRINKYN=$2000
Const DDFXCAPS_BLTSTRETCHX=$4000
Const DDFXCAPS_BLTSTRETCHXN=$8000
Const DDFXCAPS_BLTSTRETCHY=$10000
Const DDFXCAPS_BLTSTRETCHYN=$20000
Const DDFXCAPS_OVERLAYARITHSTRETCHY=$40000
Const DDFXCAPS_OVERLAYARITHSTRETCHYN=$8
Const DDFXCAPS_OVERLAYSHRINKX=$80000
Const DDFXCAPS_OVERLAYSHRINKXN=$100000
Const DDFXCAPS_OVERLAYSHRINKY=$200000
Const DDFXCAPS_OVERLAYSHRINKYN=$400000
Const DDFXCAPS_OVERLAYSTRETCHX=$800000
Const DDFXCAPS_OVERLAYSTRETCHXN=$1000000
Const DDFXCAPS_OVERLAYSTRETCHY=$2000000
Const DDFXCAPS_OVERLAYSTRETCHYN=$4000000
Const DDFXCAPS_OVERLAYMIRRORLEFTRIGHT=$8000000
Const DDFXCAPS_OVERLAYMIRRORUPDOWN=$10000000

Const DDFXCAPS_BLTALPHA=$1
Const DDFXCAPS_BLTFILTER=DDFXCAPS_BLTARITHSTRETCHY
Const DDFXCAPS_OVERLAYALPHA=$4
Const DDFXCAPS_OVERLAYFILTER=DDFXCAPS_OVERLAYARITHSTRETCHY
Const DDSVCAPS_RESERVED1=$1
Const DDSVCAPS_RESERVED2=$2
Const DDSVCAPS_RESERVED3=$4
Const DDSVCAPS_RESERVED4=$8
Const DDSVCAPS_STEREOSEQUENTIAL=$10

Const DDPCAPS_4BIT=$1
Const DDPCAPS_8BITENTRIES=$2
Const DDPCAPS_8BIT=$4
Const DDPCAPS_INITIALIZE=$0
Const DDPCAPS_PRIMARYSURFACE=$10
Const DDPCAPS_PRIMARYSURFACELEFT=$20
Const DDPCAPS_ALLOW256=$40
Const DDPCAPS_VSYNC=$80
Const DDPCAPS_1BIT=$100
Const DDPCAPS_2BIT=$200
Const DDPCAPS_ALPHA=$400

Const DDSPD_IUNKNOWNPOINTER=$1
Const DDSPD_VOLATILE=$2

Const DDBD_1=$4000
Const DDBD_2=$2000
Const DDBD_4=$1000
Const DDBD_8=$800
Const DDBD_16=$400
Const DDBD_24=$200
Const DDBD_32=$100

Const DDCKEY_COLORSPACE=$1
Const DDCKEY_DESTBLT=$2
Const DDCKEY_DESTOVERLAY=$4
Const DDCKEY_SRCBLT=$8
Const DDCKEY_SRCOVERLAY=$10

Const DDCKEYCAPS_DESTBLT=$1
Const DDCKEYCAPS_DESTBLTCLRSPACE=$2
Const DDCKEYCAPS_DESTBLTCLRSPACEYUV=$4
Const DDCKEYCAPS_DESTBLTYUV=$8
Const DDCKEYCAPS_DESTOVERLAY=$10
Const DDCKEYCAPS_DESTOVERLAYCLRSPACE=$20
Const DDCKEYCAPS_DESTOVERLAYCLRSPACEYUV=$40
Const DDCKEYCAPS_DESTOVERLAYONEACTIVE=$80
Const DDCKEYCAPS_DESTOVERLAYYUV=$100
Const DDCKEYCAPS_SRCBLT=$200
Const DDCKEYCAPS_SRCBLTCLRSPACE=$400
Const DDCKEYCAPS_SRCBLTCLRSPACEYUV=$800
Const DDCKEYCAPS_SRCBLTYUV=$1000
Const DDCKEYCAPS_SRCOVERLAY=$2000
Const DDCKEYCAPS_SRCOVERLAYCLRSPACE=$4000
Const DDCKEYCAPS_SRCOVERLAYCLRSPACEYUV=$8000
Const DDCKEYCAPS_SRCOVERLAYONEACTIVE=$10000
Const DDCKEYCAPS_SRCOVERLAYYUV=$20000
Const DDCKEYCAPS_NOCOSTOVERLAY=$40000

Const DDPF_ALPHAPIXELS=$1
Const DDPF_ALPHA=$2
Const DDPF_FOURCC=$4
Const DDPF_PALETTEINDEXED4=$8
Const DDPF_PALETTEINDEXEDTO8=$10
Const DDPF_PALETTEINDEXED8=$20
Const DDPF_RGB=$40
Const DDPF_COMPRESSED=$80
Const DDPF_RGBTOYUV=$100
Const DDPF_YUV=$200
Const DDPF_ZBUFFER=$400
Const DDPF_PALETTEINDEXED1=$800
Const DDPF_PALETTEINDEXED2=$1000
Const DDPF_ZPIXELS=$2000
Const DDPF_STENCILBUFFER=$4000
Const DDPF_ALPHAPREMULT=$8000
Const DDPF_LUMINANCE=$20000
Const DDPF_BUMPLUMINANCE=$40000
Const DDPF_BUMPDUDV=$80000


Const DDENUMSURFACES_ALL=$1
Const DDENUMSURFACES_MATCH=$2
Const DDENUMSURFACES_NOMATCH=$4
Const DDENUMSURFACES_CANBECREATED=$8
Const DDENUMSURFACES_DOESEXIST=$10

Const DDSDM_STANDARDVGAMODE=$1
Const DDEDM_REFRESHRATES=$1
Const DDEDM_STANDARDVGAMODES=$2

Const DDSCL_FULLSCREEN=$1
Const DDSCL_ALLOWREBOOT=$2
Const DDSCL_NOWINDOWCHANGES=$4
Const DDSCL_NORMAL=$8
Const DDSCL_EXCLUSIVE=$10
Const DDSCL_ALLOWMODEX=$40
Const DDSCL_SETFOCUSWINDOW=$80
Const DDSCL_SETDEVICEWINDOW=$100
Const DDSCL_CREATEDEVICEWINDOW=$200
Const DDSCL_MULTITHREADED=$400
Const DDSCL_FPUSETUP=$800
Const DDSCL_FPUPRESERVE=$1000

Const DDBLT_ALPHADEST=$1
Const DDBLT_ALPHADESTCONSTOVERRIDE=$2
Const DDBLT_ALPHADESTNEG=$4
Const DDBLT_ALPHADESTSURFACEOVERRIDE=$8
Const DDBLT_ALPHAEDGEBLEND=$10
Const DDBLT_ALPHASRC=$20
Const DDBLT_ALPHASRCCONSTOVERRIDE=$40
Const DDBLT_ALPHASRCNEG=$80
Const DDBLT_ALPHASRCSURFACEOVERRIDE=$100
Const DDBLT_ASYNC=$200
Const DDBLT_COLORFILL=$400
Const DDBLT_DDFX=$800
Const DDBLT_DDROPS=$1000
Const DDBLT_KEYDEST=$2000
Const DDBLT_KEYDESTOVERRIDE=$4000
Const DDBLT_KEYSRC=$8000
Const DDBLT_KEYSRCOVERRIDE=$10000
Const DDBLT_ROP=$20000
Const DDBLT_ROTATIONANGLE=$40000
Const DDBLT_ZBUFFER=$80000
Const DDBLT_ZBUFFERDESTCONSTOVERRIDE=$100000
Const DDBLT_ZBUFFERDESTOVERRIDE=$200000
Const DDBLT_ZBUFFERSRCCONSTOVERRIDE=$400000
Const DDBLT_ZBUFFERSRCOVERRIDE=$800000
Const DDBLT_WAIT=$1000000
Const DDBLT_DEPTHFILL=$2000000
Const DDBLT_DONOTWAIT=$8000000

Const DDBLTFAST_NOCOLORKEY=$0
Const DDBLTFAST_SRCCOLORKEY=$1
Const DDBLTFAST_DESTCOLORKEY=$2
Const DDBLTFAST_WAIT=$10
Const DDBLTFAST_DONOTWAIT=$20

Const DDFLIP_WAIT=$1
Const DDFLIP_EVEN=$2
Const DDFLIP_ODD=$4
Const DDFLIP_NOVSYNC=$8
Const DDFLIP_INTERVAL2=$2000000
Const DDFLIP_INTERVAL3=$3000000
Const DDFLIP_INTERVAL4=$4000000
Const DDFLIP_STEREO=$10
Const DDFLIP_DONOTWAIT=$20

Const DDOVER_ALPHADEST=$1
Const DDOVER_ALPHADESTCONSTOVERRIDE=$2
Const DDOVER_ALPHADESTNEG=$4
Const DDOVER_ALPHADESTSURFACEOVERRIDE=$8
Const DDOVER_ALPHAEDGEBLEND=$10
Const DDOVER_ALPHASRC=$20
Const DDOVER_ALPHASRCCONSTOVERRIDE=$40
Const DDOVER_ALPHASRCNEG=$80
Const DDOVER_ALPHASRCSURFACEOVERRIDE=$100
Const DDOVER_HIDE=$200
Const DDOVER_KEYDEST=$400
Const DDOVER_KEYDESTOVERRIDE=$800
Const DDOVER_KEYSRC=$1000
Const DDOVER_KEYSRCOVERRIDE=$2000
Const DDOVER_SHOW=$4000
Const DDOVER_ADDDIRTYRECT=$8000
Const DDOVER_REFRESHDIRTYRECTS=$10000
Const DDOVER_REFRESHALL=$20000
Const DDOVER_DDFX=$80000
Const DDOVER_AUTOFLIP=$100000
Const DDOVER_BOB=$200000
Const DDOVER_OVERRIDEBOBWEAVE=$400000
Const DDOVER_INTERLEAVED=$800000
Const DDOVER_BOBHARDWARE=$1000000
Const DDOVER_ARGBSCALEFACTORS=$2000000
Const DDOVER_DEGRADEARGBSCALING=$4000000

Const DDLOCK_SURFACEMEMORYPTR=$0
Const DDLOCK_WAIT=$1
Const DDLOCK_EVENT=$2
Const DDLOCK_READONLY=$10
Const DDLOCK_WRITEONLY=$20
Const DDLOCK_NOSYSLOCK=$800
Const DDLOCK_NOOVERWRITE=$1000
Const DDLOCK_DISCARDCONTENTS=$2000
Const DDLOCK_OKTOSWAP=$2000
Const DDLOCK_DONOTWAIT=$4000

Const DDBLTFX_ARITHSTRETCHY=$1
Const DDBLTFX_MIRRORLEFTRIGHT=$2
Const DDBLTFX_MIRRORUPDOWN=$4
Const DDBLTFX_NOTEARING=$8
Const DDBLTFX_ROTATE180=$10
Const DDBLTFX_ROTATE270=$20
Const DDBLTFX_ROTATE90=$40
Const DDBLTFX_ZBUFFERRANGE=$80
Const DDBLTFX_ZBUFFERBASEDEST=$100

Const DDOVERFX_ARITHSTRETCHY=$1
Const DDOVERFX_MIRRORLEFTRIGHT=$2
Const DDOVERFX_MIRRORUPDOWN=$4

Const DDWAITVB_BLOCKBEGIN=$1
Const DDWAITVB_BLOCKBEGINEVENT=$2
Const DDWAITVB_BLOCKEND=$4

Const DDGFS_CANFLIP=$1
Const DDGFS_ISFLIPDONE=$2

Const DDGBS_CANBLT=$1
Const DDGBS_ISBLTDONE=$2

Const DDENUMOVERLAYZ_BACKTOFRONT=$0
Const DDENUMOVERLAYZ_FRONTTOBACK=$1

Const DDOVERZ_SENDTOFRONT=$1
Const DDOVERZ_SENDTOBACK=$1
Const DDOVERZ_MOVEFORWARD=$2
Const DDOVERZ_MOVEBACKWARD=$3
Const DDOVERZ_INSERTINFRONTOF=$4
Const DDOVERZ_INSERTINBACKOF=$5

Const DDSGR_CALIBRATE=1
Const DDSMT_ISTESTREQUIRED=1

Const DDEM_MODEPASSED=1
Const DDEM_MODEFAILED=2

Const DD_OK=0
Const DD_FALSE=1

Const DDENUMRET_CANCEL=0
Const DDENUMRET_OK=1

' DIRECTDRAW ERRORS

Const DDERR=$88760000

Const DDERR_ALREADYINITIALIZED=DDERR+5
Const DDERR_CANNOTATTACHSURFACE=DDERR+10
Const DDERR_CANNOTDETACHSURFACE=DDERR+20
Const DDERR_CURRENTLYNOTAVAIL=DDERR+40
Const DDERR_EXCEPTION=DDERR+55

Const DDERR_GENERIC=$80004005	'E_FAIL

Const DDERR_HEIGHTALIGN=DDERR+90
Const DDERR_INCOMPATIBLEPRIMARY=DDERR+95
Const DDERR_INVALIDCAPS=DDERR+100
Const DDERR_INVALIDCLIPLIST=DDERR+110
Const DDERR_INVALIDMODE=DDERR+120
Const DDERR_INVALIDOBJECT=DDERR+130
Const DDERR_INVALIDPARAMS=$80070057		' E_INVALIDARG

Const DDERR_INVALIDPIXELFORMAT=DDERR+145
Const DDERR_INVALIDRECT=DDERR+150
Const DDERR_LOCKEDSURFACES=DDERR+160
Const DDERR_NO3D=DDERR+170
Const DDERR_NOALPHAHW=DDERR+180
Const DDERR_NOSTEREOHARDWARE=DDERR+181
Const DDERR_NOSURFACELEFT=DDERR+182
Const DDERR_NOCLIPLIST=DDERR+205
Const DDERR_NOCOLORCONVHW=DDERR+210
Const DDERR_NOCOOPERATIVELEVELSET=DDERR+212
Const DDERR_NOCOLORKEY=DDERR+215
Const DDERR_NOCOLORKEYHW=DDERR+220
Const DDERR_NODIRECTDRAWSUPPORT=DDERR+222
Const DDERR_NOEXCLUSIVEMODE=DDERR+225
Const DDERR_NOFLIPHW=DDERR+230
Const DDERR_NOGDI=DDERR+240
Const DDERR_NOMIRRORHW=DDERR+250
Const DDERR_NOTFOUND=DDERR+255
Const DDERR_NOOVERLAYHW=DDERR+260
Const DDERR_OVERLAPPINGRECTS=DDERR+270
Const DDERR_NORASTEROPHW=DDERR+280
Const DDERR_NOROTATIONHW=DDERR+290
Const DDERR_NOSTRETCHHW=DDERR+310
Const DDERR_NOT4BITCOLOR=DDERR+316
Const DDERR_NOT4BITCOLORINDEX=DDERR+317
Const DDERR_NOT8BITCOLOR=DDERR+320
Const DDERR_NOTEXTUREHW=DDERR+330
Const DDERR_NOVSYNCHW=DDERR+335
Const DDERR_NOZBUFFERHW=DDERR+340
Const DDERR_NOZOVERLAYHW=DDERR+350
Const DDERR_OUTOFCAPS=DDERR+360
Const DDERR_OUTOFMEMORY=$8007000E	' E_OUTOFMEMORY
Const DDERR_OUTOFVIDEOMEMORY=DDERR+380
Const DDERR_OVERLAYCANTCLIP=DDERR+382
Const DDERR_OVERLAYCOLORKEYONLYONEACTIVE=DDERR+384
Const DDERR_PALETTEBUSY=DDERR+387
Const DDERR_COLORKEYNOTSET=DDERR+400
Const DDERR_SURFACEALREADYATTACHED=DDERR+410
Const DDERR_SURFACEALREADYDEPENDENT=DDERR+420
Const DDERR_SURFACEBUSY=DDERR+430
Const DDERR_CANTLOCKSURFACE=DDERR+435
Const DDERR_SURFACEISOBSCURED=DDERR+440
Const DDERR_SURFACELOST=DDERR+450
Const DDERR_SURFACENOTATTACHED=DDERR+460
Const DDERR_TOOBIGHEIGHT=DDERR+470
Const DDERR_TOOBIGSIZE=DDERR+480
Const DDERR_TOOBIGWIDTH=DDERR+490
Const DDERR_UNSUPPORTED=$80000001	' E_NOTIMPL
Const DDERR_UNSUPPORTEDFORMAT=DDERR+510
Const DDERR_UNSUPPORTEDMASK=DDERR+520
Const DDERR_INVALIDSTREAM=DDERR+521
Const DDERR_VERTICALBLANKINPROGRESS=DDERR+537
Const DDERR_WASSTILLDRAWING=DDERR+540
Const DDERR_DDSCAPSCOMPLEXREQUIRED=DDERR+542
Const DDERR_XALIGN=DDERR+560
Const DDERR_INVALIDDIRECTDRAWGUID=DDERR+561
Const DDERR_DIRECTDRAWALREADYCREATED=DDERR+562
Const DDERR_NODIRECTDRAWHW=DDERR+563
Const DDERR_PRIMARYSURFACEALREADYEXISTS=DDERR+564
Const DDERR_NOEMULATION=DDERR+565
Const DDERR_REGIONTOOSMALL=DDERR+566
Const DDERR_CLIPPERISUSINGHWND=DDERR+567
Const DDERR_NOCLIPPERATTACHED=DDERR+568
Const DDERR_NOHWND=DDERR+569
Const DDERR_HWNDSUBCLASSED=DDERR+570
Const DDERR_HWNDALREADYSET=DDERR+571
Const DDERR_NOPALETTEATTACHED=DDERR+572
Const DDERR_NOPALETTEHW=DDERR+573
Const DDERR_BLTFASTCANTCLIP=DDERR+574
Const DDERR_NOBLTHW=DDERR+575
Const DDERR_NODDROPSHW=DDERR+576
Const DDERR_OVERLAYNOTVISIBLE=DDERR+577
Const DDERR_NOOVERLAYDEST=DDERR+578
Const DDERR_INVALIDPOSITION=DDERR+579
Const DDERR_NOTAOVERLAYSURFACE=DDERR+580
Const DDERR_EXCLUSIVEMODEALREADYSET=DDERR+581
Const DDERR_NOTFLIPPABLE=DDERR+582
Const DDERR_CANTDUPLICATE=DDERR+583
Const DDERR_NOTLOCKED=DDERR+584
Const DDERR_CANTCREATEDC=DDERR+585
Const DDERR_NODC=DDERR+586
Const DDERR_WRONGMODE=DDERR+587
Const DDERR_IMPLICITLYCREATED=DDERR+588
Const DDERR_NOTPALETTIZED=DDERR+589
Const DDERR_UNSUPPORTEDMODE=DDERR+590
Const DDERR_NOMIPMAPHW=DDERR+591
Const DDERR_INVALIDSURFACETYPE=DDERR+592
Const DDERR_NOOPTIMIZEHW=DDERR+600
Const DDERR_NOTLOADED=DDERR+601
Const DDERR_NOFOCUSWINDOW=DDERR+602
Const DDERR_NOTONMIPMAPSUBLEVEL=DDERR+603
Const DDERR_DCALREADYCREATED=DDERR+620
Const DDERR_NONONLOCALVIDMEM=DDERR+630
Const DDERR_CANTPAGELOCK=DDERR+640
Const DDERR_CANTPAGEUNLOCK=DDERR+660
Const DDERR_NOTPAGELOCKED=DDERR+680
Const DDERR_MOREDATA=DDERR+690
Const DDERR_EXPIRED=DDERR+691
Const DDERR_TESTFINISHED=DDERR+692
Const DDERR_NEWMODE=DDERR+693
Const DDERR_D3DNOTINITIALIZED=DDERR+694
Const DDERR_VIDEONOTACTIVE=DDERR+695
Const DDERR_NOMONITORINFORMATION=DDERR+696
Const DDERR_NODRIVERSUPPORT=DDERR+697
Const DDERR_DEVICEDOESNTOWNSURFACE=DDERR+699
Const DDERR_NOTINITIALIZED=$800401F0	' CO_E_NOTINITIALIZED

Rem

DEFINE_GUID( CLSID_DirectDraw,=$D7B70EE0,0x4340,0x11CF,0xB0,0x63,0x00,0x20,0xAF,0xC2,0xCD,0x35 );
DEFINE_GUID( CLSID_DirectDraw7,=$3c305196,0x50db,0x11d3,0x9c,0xfe,0x00,0xc0,0x4f,0xd9,0x30,0xc5 );
DEFINE_GUID( CLSID_DirectDrawClipper,=$593817A0,0x7DB3,0x11CF,0xA2,0xDE,0x00,0xAA,0x00,0xb9,0x33,0x56 );
DEFINE_GUID( IID_IDirectDraw,=$6C14DB80,0xA733,0x11CE,0xA5,0x21,0x00,0x20,0xAF,0x0B,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDraw2,=$B3A6F3E0,0x2B43,0x11CF,0xA2,0xDE,0x00,0xAA,0x00,0xB9,0x33,0x56 );
DEFINE_GUID( IID_IDirectDraw4,=$9c59509a,0x39bd,0x11d1,0x8c,0x4a,0x00,0xc0,0x4f,0xd9,0x30,0xc5 );
DEFINE_GUID( IID_IDirectDraw7,=$15e65ec0,0x3b9c,0x11d2,0xb9,0x2f,0x00,0x60,0x97,0x97,0xea,0x5b );
DEFINE_GUID( IID_IDirectDrawSurface,=$6C14DB81,0xA733,0x11CE,0xA5,0x21,0x00,0x20,0xAF,0x0B,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDrawSurface2,=$57805885,0x6eec,0x11cf,0x94,0x41,0xa8,0x23,0x03,0xc1,0x0e,0x27 );
DEFINE_GUID( IID_IDirectDrawSurface3,=$DA044E00,0x69B2,0x11D0,0xA1,0xD5,0x00,0xAA,0x00,0xB8,0xDF,0xBB );
DEFINE_GUID( IID_IDirectDrawSurface4,=$B2B8630,0xAD35,0x11D0,0x8E,0xA6,0x00,0x60,0x97,0x97,0xEA,0x5B );
DEFINE_GUID( IID_IDirectDrawSurface7,=$6675a80,0x3b9b,0x11d2,0xb9,0x2f,0x00,0x60,0x97,0x97,0xea,0x5b );

DEFINE_GUID( IID_IDirectDrawPalette,=$6C14DB84,0xA733,0x11CE,0xA5,0x21,0x00,0x20,0xAF,0x0B,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDrawClipper,=$6C14DB85,0xA733,0x11CE,0xA5,0x21,0x00,0x20,0xAF,0x0B,0xE5,0x60 );
DEFINE_GUID( IID_IDirectDrawColorControl,=$4B9F0EE0,0x0D7E,0x11D0,0x9B,0x06,0x00,0xA0,0xC9,0x03,0xA3,0xB8 );
DEFINE_GUID( IID_IDirectDrawGammaControl,=$69C11C3E,0xB46B,0x11D1,0xAD,0x7A,0x00,0xC0,0x4F,0xC2,0x9B,0x4E );

typedef BOOL (FAR PASCAL * LPDDENUMCALLBACKA)(GUID FAR *, LPSTR, LPSTR, LPVOID);
typedef BOOL (FAR PASCAL * LPDDENUMCALLBACKW)(GUID FAR *, LPWSTR, LPWSTR, LPVOID);
Extern HRESULT WINAPI DirectDrawEnumerateW( LPDDENUMCALLBACKW lpCallback, LPVOID lpContext );
Extern HRESULT WINAPI DirectDrawEnumerateA( LPDDENUMCALLBACKA lpCallback, LPVOID lpContext );

EndRem

Type DDSURFACEDESC
	Field dwSize' size of the DDSURFACEDESC structure
	Field dwFlags' determines what fields are valid
	Field dwHeight' height of surface To be created
	Field dwWidth' width of Input surface
' union	Field dwLinearSize' Formless late-allocated optimized surface size
	Field lPitch' distance To start of Next line (Return value only)
	Field dwBackBufferCount' number of back buffers requested
'union Field dwMipMapCount' number of mip-map levels requested
'union Field dwZBufferBitDepth' depth of Z buffer requested
	Field dwRefreshRate' refresh rate (used when display mode is described)
	Field dwAlphaBitDepth' depth of alpha buffer requested
	Field dwReserved' reserved
	Field lpSurface:Byte Ptr' pointer To the associated surface memory
' DDCOLORKEYs
	Field ddckCKDestOverlay:Long' color key For destination overlay use
	Field ddckCKDestBlt:Long' color key For destination blt use
	Field ddckCKSrcOverlay:Long' color key For source overlay use
	Field ddckCKSrcBlt:Long' color key For source blt use
' DDPIXELFORMAT
	Field ddpf_dwSize' size of structure
	Field ddpf_dwFlags' pixel format flags
	Field ddpf_dwFourCC' (FOURCC code)
	Field ddpf_BitCount
	Field ddpf_BitMask_0
	Field ddpf_BitMask_1
	Field ddpf_BitMask_2
	Field ddpf_BitMask_3
' DDSCAPS
	Field ddsCaps' direct draw surface capabilities
End Type

Type DDSURFACEDESC2
	Field dwSize' size of the DDSURFACEDESC structure
	Field dwFlags' determines what fields are valid
	Field dwHeight' height of surface To be created
	Field dwWidth' width of Input surface
' union dwLinearSize
	Field lPitch' distance To start of Next line (Return value only)
	Field dwBackBufferCount' number of back buffers requested
' union dwRefreshRate,dwSrcVBHandle
	Field dwMipMapCount' number of mip-map levels requestde
	Field dwAlphaBitDepth' depth of alpha buffer requested
	Field dwReserved' reserved
	Field lpSurface:Byte Ptr' pointer To the associated surface memory
' union dwEmptyFaceColor
' DDCOLORKEYs
	Field dddckCKDestOverlay:Long' color key For destination overlay use
	Field ddckCKDestBlt:Long' color key For destination blt use
	Field ddckCKSrcOverlay:Long' color key For source overlay use
	Field ddckCKSrcBlt:Long' color key For source blt use
' union dwFVF
' DDPFPIXELFORMAT
	Field ddpf_dwSize' size of structure
	Field ddpf_dwFlags' pixel format flags
	Field ddpf_dwFourCC' (FOURCC code)
	Field ddpf_BitCount
	Field ddpf_BitMask_0
	Field ddpf_BitMask_1
	Field ddpf_BitMask_2
	Field ddpf_BitMask_3
' DDSCAPS2
	Field ddsCaps' capabilities of surface wanted
	Field ddsCaps2
	Field ddsCaps3
	Field ddsCaps4
	Field dwTextureStage' stage in multitexture cascade
End Type

Type DDOPTSURFACEDESC
	Field dwSize' size of the DDOPTSURFACEDESC structure
	Field dwFlags' determines what fields are valid
' DDSCAPS2
	Field ddSCaps_0' Common caps like: Memory Type
	Field ddsCaps_1
	Field ddsCaps_2
	Field ddsCaps_3
	Field ddOSCaps' Common caps like: Memory Type
' GUID
	Field guid_0' Compression technique GUID
	Field guid_1
	Field guid_2
	Field guid_3
	Field dwCompressionRatio' Compression ratio
End Type

Type DDCOLORCONTROL
	Field dwSize
	Field dwFlags
	Field lBrightness
	Field lContrast
	Field lHue
	Field lSaturation
	Field lSharpness
	Field lGamma
	Field lColorEnable
	Field dwReserved1
End Type

Type DDARGB
	Field	blue:Byte,green:Byte,red:Byte,alpha:Byte
End Type

Type DDRGBA
	Field	red:Byte,green:Byte,blue:Byte,alpha:Byte
End Type

Type DDCOLORKEY
	Field	dwColorSpaceLowValue	' low boundary of color space that is to be treated as Color Key, inclusive
	Field	dwColorSpaceHighValue	' high boundary of color space that is to be treated as Color Key, inclusive
End Type

Type DDBLTFX
	Field dwSize' size of structure
	Field dwDDFX' FX operations
	Field dwROP' Win32 raster operations
	Field dwDDROP' Raster operations New For DirectDraw
	Field dwRotationAngle' Rotation angle For blt
	Field dwZBufferOpCode' ZBuffer compares
	Field dwZBufferLow' Low limit of Z buffer
	Field dwZBufferHigh' High limit of Z buffer
	Field dwZBufferBaseDest' Destination base value
	Field dwZDestConstBitDepth' Bit depth used To specify Z constant For destination
' union LPDIRECTDRAWSURFACE lpDDSZBufferDest
	Field dwZDestConst' Constant To use as Z buffer For dest
	Field dwZSrcConstBitDepth' Bit depth used To specify Z constant For source
' union LPDIRECTDRAWSURFACE lpDDSZBufferSrc
	Field dwZSrcConst' Constant To use as Z buffer For src
	Field dwAlphaEdgeBlendBitDepth' Bit depth used To specify constant For alpha edge blend
	Field dwAlphaEdgeBlend' Alpha For edge blending
	Field dwReserved
	Field dwAlphaDestConstBitDepth' Bit depth used To specify alpha constant For destination
' union LPDIRECTDRAWSURFACE lpDDSAlphaDest
	Field dwAlphaDestConst' Constant To use as Alpha Channel
	Field dwAlphaSrcConstBitDepth' Bit depth used To specify alpha constant For source
' union LPDIRECTDRAWSURFACE lpDDSAlphaSrc
	Field dwAlphaSrcConst' Constant To use as Alpha Channel
' union dwFillDepth,dwFillPixel,LPDIRECTDRAWSURFACE lpDDSPattern
	Field dwFillColor' color in RGB Or Palettized
' DDCOLORKEYs
	Field ddckDestColorkeyLo,ddckDestColorkeyHi	' DestColorkey override
	Field ddckSrcColorkeyLo,ddckSrcColorkeyHi	' SrcColorkey override
End Type

Type DDSCAPS
	Field dwCaps	' capabilities of surface wanted
End Type

Type DDOSCAPS
	Field dwCaps	' capabilities of surface wanted
End Type

Type DDSCAPSEX
	Field dwCaps2
	Field dwCaps3
	Field dwCaps4
End Type

Type DDSCAPS2
	Field dwCaps' capabilities of surface wanted
	Field dwCaps2
	Field dwCaps3
	Field dwCaps4
End Type

Const DD_ROP_SPACE=(256/32) ' space required To store ROP array

Type DDCAPS_DX1
	Field dwSize' size of the DDDRIVERCAPS structure
	Field dwCaps' driver specific capabilities
	Field dwCaps2' more driver specific capabilites
	Field dwCKeyCaps' color key capabilities of the surface
	Field dwFXCaps' driver specific stretching And effects capabilites
	Field dwFXAlphaCaps' alpha driver specific capabilities
	Field dwPalCaps' palette capabilities
	Field dwSVCaps' stereo vision capabilities
	Field dwAlphaBltConstBitDepths' DDBD_2,4,8
	Field dwAlphaBltPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaBltSurfaceBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlayConstBitDepths' DDBD_2,4,8
	Field dwAlphaOverlayPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlaySurfaceBitDepths' DDBD_1,2,4,8
	Field dwZBufferBitDepths' DDBD_8,16,24,32
	Field dwVidMemTotal' total amount of video memory
	Field dwVidMemFree' amount of free video memory
	Field dwMaxVisibleOverlays' maximum number of visible overlays
	Field dwCurrVisibleOverlays' current number of visible overlays
	Field dwNumFourCCCodes' number of four cc codes
	Field dwAlignBoundarySrc' source rectangle alignment
	Field dwAlignSizeSrc' source rectangle Byte size
	Field dwAlignBoundaryDest' dest rectangle alignment
	Field dwAlignSizeDest' dest rectangle Byte size
	Field dwAlignStrideAlign' stride alignment
	Field dwRops_0' ROPS supported
	Field dwRops_1
	Field dwRops_2
	Field dwRops_3
	Field dwRops_4
	Field dwRops_5
	Field dwRops_6
	Field dwRops_7
' DDSCAPS
	Field ddsCaps' DDSCAPS structure has all the general capabilities
	Field dwMinOverlayStretch' minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxOverlayStretch' maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinLiveVideoStretch' OBSOLETE! This Field remains For compatability reasons only
	Field dwMaxLiveVideoStretch' OBSOLETE! This Field remains For compatability reasons only
	Field dwMinHwCodecStretch' OBSOLETE! This Field remains For compatability reasons only
	Field dwMaxHwCodecStretch' OBSOLETE! This Field remains For compatability reasons only
	Field dwReserved1' reserved
	Field dwReserved2' reserved
	Field dwReserved3' reserved
End Type

Type DDCAPS_DX3
	Field dwSize' size of the DDDRIVERCAPS structure
	Field dwCaps' driver specific capabilities
	Field dwCaps2' more driver specific capabilites
	Field dwCKeyCaps' color key capabilities of the surface
	Field dwFXCaps' driver specific stretching And effects capabilites
	Field dwFXAlphaCaps' alpha driver specific capabilities
	Field dwPalCaps' palette capabilities
	Field dwSVCaps' stereo vision capabilities
	Field dwAlphaBltConstBitDepths' DDBD_2,4,8
	Field dwAlphaBltPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaBltSurfaceBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlayConstBitDepths' DDBD_2,4,8
	Field dwAlphaOverlayPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlaySurfaceBitDepths' DDBD_1,2,4,8
	Field dwZBufferBitDepths' DDBD_8,16,24,32
	Field dwVidMemTotal' total amount of video memory
	Field dwVidMemFree' amount of free video memory
	Field dwMaxVisibleOverlays' maximum number of visible overlays
	Field dwCurrVisibleOverlays' current number of visible overlays
	Field dwNumFourCCCodes' number of four cc codes
	Field dwAlignBoundarySrc' source rectangle alignment
	Field dwAlignSizeSrc' source rectangle Byte size
	Field dwAlignBoundaryDest' dest rectangle alignment
	Field dwAlignSizeDest' dest rectangle Byte size
	Field dwAlignStrideAlign' stride alignment
	Field dwRops_0' ROPS supported
	Field dwRops_1
	Field dwRops_2
	Field dwRops_3
	Field dwRops_4
	Field dwRops_5
	Field dwRops_6
	Field dwRops_7
' DDSCAPS
	Field ddsCaps' DDSCAPS structure has all the general capabilities
	Field dwMinOverlayStretch' minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxOverlayStretch' maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinLiveVideoStretch' minimum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxLiveVideoStretch' maximum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinHwCodecStretch' minimum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxHwCodecStretch' maximum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwReserved1' reserved
	Field dwReserved2' reserved
	Field dwReserved3' reserved
	Field dwSVBCaps' driver specific capabilities For System->Vmem blts
	Field dwSVBCKeyCaps' driver color key capabilities For System->Vmem blts
	Field dwSVBFXCaps' driver FX capabilities For System->Vmem blts
	Field dwSVBRops_0 ' ROPS supported For System->Vmem blts
	Field dwSVBRops_1
	Field dwSVBRops_2
	Field dwSVBRops_3
	Field dwSVBRops_4
	Field dwSVBRops_5
	Field dwSVBRops_6
	Field dwSVBRops_7
	Field dwVSBCaps' driver specific capabilities For Vmem->System blts
	Field dwVSBCKeyCaps' driver color key capabilities For Vmem->System blts
	Field dwVSBFXCaps' driver FX capabilities For Vmem->System blts
	Field dwVSBRops_0' ROPS supported For Vmem->System blts
	Field dwVSBRops_1
	Field dwVSBRops_2
	Field dwVSBRops_3
	Field dwVSBRops_4
	Field dwVSBRops_5
	Field dwVSBRops_6
	Field dwVSBRops_7
	Field dwSSBCaps' driver specific capabilities For System->System blts
	Field dwSSBCKeyCaps' driver color key capabilities For System->System blts
	Field dwSSBFXCaps' driver FX capabilities For System->System blts
	Field dwSSBRops_0' ROPS supported For System->System blts
	Field dwSSBRops_1
	Field dwSSBRops_2
	Field dwSSBRops_3
	Field dwSSBRops_4
	Field dwSSBRops_5
	Field dwSSBRops_6
	Field dwSSBRops_7
	Field dwReserved4' reserved
	Field dwReserved5' reserved
	Field dwReserved6' reserved
End Type

Type DDCAPS_DX5
	Field dwSize' size of the DDDRIVERCAPS structure
	Field dwCaps' driver specific capabilities
	Field dwCaps2' more driver specific capabilites
	Field dwCKeyCaps' color key capabilities of the surface
	Field dwFXCaps' driver specific stretching And effects capabilites
	Field dwFXAlphaCaps' alpha driver specific capabilities
	Field dwPalCaps' palette capabilities
	Field dwSVCaps' stereo vision capabilities
	Field dwAlphaBltConstBitDepths' DDBD_2,4,8
	Field dwAlphaBltPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaBltSurfaceBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlayConstBitDepths' DDBD_2,4,8
	Field dwAlphaOverlayPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlaySurfaceBitDepths' DDBD_1,2,4,8
	Field dwZBufferBitDepths' DDBD_8,16,24,32
	Field dwVidMemTotal' total amount of video memory
	Field dwVidMemFree' amount of free video memory
	Field dwMaxVisibleOverlays' maximum number of visible overlays
	Field dwCurrVisibleOverlays' current number of visible overlays
	Field dwNumFourCCCodes' number of four cc codes
	Field dwAlignBoundarySrc' source rectangle alignment
	Field dwAlignSizeSrc' source rectangle Byte size
	Field dwAlignBoundaryDest' dest rectangle alignment
	Field dwAlignSizeDest' dest rectangle Byte size
	Field dwAlignStrideAlign' stride alignment
	Field dwRops_0' ROPS supported
	Field dwRops_1
	Field dwRops_2
	Field dwRops_3
	Field dwRops_4
	Field dwRops_5
	Field dwRops_6
	Field dwRops_7
' DDSCAPS
	Field ddsCaps' DDSCAPS structure has all the general capabilities
	Field dwMinOverlayStretch' minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxOverlayStretch' maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinLiveVideoStretch' minimum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxLiveVideoStretch' maximum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinHwCodecStretch' minimum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxHwCodecStretch' maximum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwReserved1' reserved
	Field dwReserved2' reserved
	Field dwReserved3' reserved
	Field dwSVBCaps' driver specific capabilities For System->Vmem blts
	Field dwSVBCKeyCaps' driver color key capabilities For System->Vmem blts
	Field dwSVBFXCaps' driver FX capabilities For System->Vmem blts
	Field dwSVBRops_0' ROPS supported For System->Vmem blts
	Field dwSVBRops_1
	Field dwSVBRops_2
	Field dwSVBRops_3
	Field dwSVBRops_4
	Field dwSVBRops_5
	Field dwSVBRops_6
	Field dwSVBRops_7
	Field dwVSBCaps' driver specific capabilities For Vmem->System blts
	Field dwVSBCKeyCaps' driver color key capabilities For Vmem->System blts
	Field dwVSBFXCaps' driver FX capabilities For Vmem->System blts
	Field dwVSBRops_0' ROPS supported For Vmem->System blts
	Field dwVSBRops_1
	Field dwVSBRops_2
	Field dwVSBRops_3
	Field dwVSBRops_4
	Field dwVSBRops_5
	Field dwVSBRops_6
	Field dwVSBRops_7
	Field dwSSBCaps' driver specific capabilities For System->System blts
	Field dwSSBCKeyCaps' driver color key capabilities For System->System blts
	Field dwSSBFXCaps' driver FX capabilities For System->System blts
	Field dwSSBRops_0' ROPS supported For System->System blts
	Field dwSSBRops_1
	Field dwSSBRops_2
	Field dwSSBRops_3
	Field dwSSBRops_4
	Field dwSSBRops_5
	Field dwSSBRops_6
	Field dwSSBRops_7
' Members added For DX5:
	Field dwMaxVideoPorts' maximum number of usable video ports
	Field dwCurrVideoPorts' current number of video ports used
	Field dwSVBCaps2' more driver specific capabilities For System->Vmem blts
	Field dwNLVBCaps' driver specific capabilities For non-Local->Local vidmem blts
	Field dwNLVBCaps2' more driver specific capabilities non-Local->Local vidmem blts
	Field dwNLVBCKeyCaps' driver color key capabilities For non-Local->Local vidmem blts
	Field dwNLVBFXCaps' driver FX capabilities For non-Local->Local blts
	Field dwNLVBRops_0' ROPS supported For non-Local->Local blts
	Field dwNLVBRops_1
	Field dwNLVBRops_2
	Field dwNLVBRops_3
	Field dwNLVBRops_4
	Field dwNLVBRops_5
	Field dwNLVBRops_6
	Field dwNLVBRops_7
End Type

Type DDCAPS_DX6
	Field dwSize' size of the DDDRIVERCAPS structure
	Field dwCaps' driver specific capabilities
	Field dwCaps2' more driver specific capabilites
	Field dwCKeyCaps' color key capabilities of the surface
	Field dwFXCaps' driver specific stretching And effects capabilites
	Field dwFXAlphaCaps' alpha caps
	Field dwPalCaps' palette capabilities
	Field dwSVCaps' stereo vision capabilities
	Field dwAlphaBltConstBitDepths' DDBD_2,4,8
	Field dwAlphaBltPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaBltSurfaceBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlayConstBitDepths' DDBD_2,4,8
	Field dwAlphaOverlayPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlaySurfaceBitDepths' DDBD_1,2,4,8
	Field dwZBufferBitDepths' DDBD_8,16,24,32
	Field dwVidMemTotal' total amount of video memory
	Field dwVidMemFree' amount of free video memory
	Field dwMaxVisibleOverlays' maximum number of visible overlays
	Field dwCurrVisibleOverlays' current number of visible overlays
	Field dwNumFourCCCodes' number of four cc codes
	Field dwAlignBoundarySrc' source rectangle alignment
	Field dwAlignSizeSrc' source rectangle Byte size
	Field dwAlignBoundaryDest' dest rectangle alignment
	Field dwAlignSizeDest' dest rectangle Byte size
	Field dwAlignStrideAlign' stride alignment
	Field dwRops_0' ROPS supported
	Field dwRops_1
	Field dwRops_2
	Field dwRops_3
	Field dwRops_4
	Field dwRops_5
	Field dwRops_6
	Field dwRops_7
' DDSCAPS
	Field ddsOldCaps' Was DDSCAPS ddsCaps. ddsCaps is of Type DDSCAPS2 For DX6
	Field dwMinOverlayStretch' minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxOverlayStretch' maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinLiveVideoStretch' minimum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxLiveVideoStretch' maximum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinHwCodecStretch' minimum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxHwCodecStretch' maximum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwReserved1' reserved
	Field dwReserved2' reserved
	Field dwReserved3' reserved
	Field dwSVBCaps' driver specific capabilities For System->Vmem blts
	Field dwSVBCKeyCaps' driver color key capabilities For System->Vmem blts
	Field dwSVBFXCaps' driver FX capabilities For System->Vmem blts
	Field dwSVBRops_0' ROPS supported for System->Vmem blts
	Field dwSVBRops_1
	Field dwSVBRops_2
	Field dwSVBRops_3
	Field dwSVBRops_4
	Field dwSVBRops_5
	Field dwSVBRops_6
	Field dwSVBRops_7	
	Field dwVSBCaps' driver specific capabilities For Vmem->System blts
	Field dwVSBCKeyCaps' driver color key capabilities For Vmem->System blts
	Field dwVSBFXCaps' driver FX capabilities For Vmem->System blts
	Field dwVSBRops_0' ROPS supported for Vmem->System blts
	Field dwVSBRops_1
	Field dwVSBRops_2
	Field dwVSBRops_3
	Field dwVSBRops_4
	Field dwVSBRops_5
	Field dwVSBRops_6
	Field dwVSBRops_7	
	Field dwSSBCaps' driver specific capabilities For System->System blts
	Field dwSSBCKeyCaps' driver color key capabilities For System->System blts
	Field dwSSBFXCaps' driver FX capabilities For System->System blts
	Field dwSSBRops_0' ROPS supported for System->System blts
	Field dwSSBRops_1
	Field dwSSBRops_2
	Field dwSSBRops_3
	Field dwSSBRops_4
	Field dwSSBRops_5
	Field dwSSBRops_6
	Field dwSSBRops_7		
	Field dwMaxVideoPorts' maximum number of usable video ports
	Field dwCurrVideoPorts' current number of video ports used
	Field dwSVBCaps2' more driver specific capabilities For System->Vmem blts
	Field dwNLVBCaps' driver specific capabilities For non-Local->Local vidmem blts
	Field dwNLVBCaps2' more driver specific capabilities non-Local->Local vidmem blts
	Field dwNLVBCKeyCaps' driver color key capabilities For non-Local->Local vidmem blts
	Field dwNLVBFXCaps' driver FX capabilities For non-Local->Local blts
	Field dwNLVBRops_0' ROPS supported For non-Local->Local blts
	Field dwNLVBRops_1
	Field dwNLVBRops_2
	Field dwNLVBRops_3
	Field dwNLVBRops_4
	Field dwNLVBRops_5
	Field dwNLVBRops_6
	Field dwNLVBRops_7	
' Members added For DX6 Release
' DDSCAPS2
	Field ddsCaps_0' Surface Caps
	Field ddsCaps_1
	Field ddsCaps_2
	Field ddsCaps_3			
End Type

Type DDCAPS_DX7
	Field dwSize' size of the DDDRIVERCAPS structure
	Field dwCaps' driver specific capabilities
	Field dwCaps2' more driver specific capabilites
	Field dwCKeyCaps' color key capabilities of the surface
	Field dwFXCaps' driver specific stretching And effects capabilites
	Field dwFXAlphaCaps' alpha driver specific capabilities
	Field dwPalCaps' palette capabilities
	Field dwSVCaps' stereo vision capabilities
	Field dwAlphaBltConstBitDepths' DDBD_2,4,8
	Field dwAlphaBltPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaBltSurfaceBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlayConstBitDepths' DDBD_2,4,8
	Field dwAlphaOverlayPixelBitDepths' DDBD_1,2,4,8
	Field dwAlphaOverlaySurfaceBitDepths' DDBD_1,2,4,8
	Field dwZBufferBitDepths' DDBD_8,16,24,32
	Field dwVidMemTotal' total amount of video memory
	Field dwVidMemFree' amount of free video memory
	Field dwMaxVisibleOverlays' maximum number of visible overlays
	Field dwCurrVisibleOverlays' current number of visible overlays
	Field dwNumFourCCCodes' number of four cc codes
	Field dwAlignBoundarySrc' source rectangle alignment
	Field dwAlignSizeSrc' source rectangle Byte size
	Field dwAlignBoundaryDest' dest rectangle alignment
	Field dwAlignSizeDest' dest rectangle Byte size
	Field dwAlignStrideAlign' stride alignment
	Field dwRops_0' ROPS supported
	Field dwRops_1
	Field dwRops_2
	Field dwRops_3
	Field dwRops_4
	Field dwRops_5
	Field dwRops_6
	Field dwRops_7			
' DDSCAPS
	Field ddsOldCaps' Was DDSCAPS ddsCaps. ddsCaps is of Type DDSCAPS2 For DX6
	Field dwMinOverlayStretch' minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxOverlayStretch' maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinLiveVideoStretch' minimum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxLiveVideoStretch' maximum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMinHwCodecStretch' minimum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwMaxHwCodecStretch' maximum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
	Field dwReserved1' reserved
	Field dwReserved2' reserved
	Field dwReserved3' reserved
	Field dwSVBCaps' driver specific capabilities For System->Vmem blts
	Field dwSVBCKeyCaps' driver color key capabilities For System->Vmem blts
	Field dwSVBFXCaps' driver FX capabilities For System->Vmem blts
	Field dwSVBRops_0' ROPS supported For System->Vmem blts
	Field dwSVBRops_1
	Field dwSVBRops_2
	Field dwSVBRops_3
	Field dwSVBRops_4
	Field dwSVBRops_5
	Field dwSVBRops_6
	Field dwSVBRops_7	
	Field dwVSBCaps' driver specific capabilities For Vmem->System blts
	Field dwVSBCKeyCaps' driver color key capabilities For Vmem->System blts
	Field dwVSBFXCaps' driver FX capabilities For Vmem->System blts
	Field dwVSBRops_0' ROPS supported For Vmem->System blts
	Field dwVSBRops_1
	Field dwVSBRops_2
	Field dwVSBRops_3
	Field dwVSBRops_4
	Field dwVSBRops_5
	Field dwVSBRops_6
	Field dwVSBRops_7		
	Field dwSSBCaps' driver specific capabilities For System->System blts
	Field dwSSBCKeyCaps' driver color key capabilities For System->System blts
	Field dwSSBFXCaps' driver FX capabilities For System->System blts
	Field dwSSBRops_0' ROPS supported For System->System blts
	Field dwSSBRops_1
	Field dwSSBRops_2
	Field dwSSBRops_3
	Field dwSSBRops_4
	Field dwSSBRops_5
	Field dwSSBRops_6
	Field dwSSBRops_7			
	Field dwMaxVideoPorts' maximum number of usable video ports
	Field dwCurrVideoPorts' current number of video ports used
	Field dwSVBCaps2' more driver specific capabilities For System->Vmem blts
	Field dwNLVBCaps' driver specific capabilities For non-Local->Local vidmem blts
	Field dwNLVBCaps2' more driver specific capabilities non-Local->Local vidmem blts
	Field dwNLVBCKeyCaps' driver color key capabilities For non-Local->Local vidmem blts
	Field dwNLVBFXCaps' driver FX capabilities For non-Local->Local blts
	Field dwNLVBRops_0' ROPS supported For non-Local->Local blts
	Field dwNLVBRops_1
	Field dwNLVBRops_2
	Field dwNLVBRops_3
	Field dwNLVBRops_4
	Field dwNLVBRops_5
	Field dwNLVBRops_6
	Field dwNLVBRops_7		
	' Members added For DX6 Release
' DDSCAPS2
	Field ddsCaps_0' Surface Caps
	Field ddsCaps_1
	Field ddsCaps_2
	Field ddsCaps_3			
End Type

Type DDPIXELFORMAT
	Field dwSize' size of structure
	Field dwFlags' pixel format flags
	Field dwFourCC' (FOURCC code)
	Field BitCount
	Field BitMask_0
	Field BitMask_1
	Field BitMask_2
	Field BitMask_3
End Type

Type DDOVERLAYFX
	Field dwSize' size of structure
	Field dwAlphaEdgeBlendBitDepth' Bit depth used To specify constant For alpha edge blend
	Field dwAlphaEdgeBlend' Constant To use as alpha For edge blend
	Field dwReserved
	Field dwAlphaDestConstBitDepth' Bit depth used To specify alpha constant For destination
' union LPDIRECTDRAWSURFACE lpDDSAlphaDest
	Field dwAlphaDestConst' Constant To use as alpha channel For dest
	Field dwAlphaSrcConstBitDepth' Bit depth used To specify alpha constant For source
' union LPDIRECTDRAWSURFACE lpDDSAlphaSrc
	Field dwAlphaSrcConst' Constant To use as alpha channel For src
' DDCOLORKEYs
	Field dckDestColorkey:Long' DestColorkey override
	Field dckSrcColorkey:Long' DestColorkey override
	Field dwDDFX' Overlay FX
	Field dwFlags' flags
End Type

Rem
Type DDBLTBATCH
	LPRECT lprDest
	LPDIRECTDRAWSURFACE lpDDSSrc
	LPRECT lprSrc
	Field dwFlags
	LPDDBLTFX lpDDBltFx;
End Type

Type DDGAMMARAMP
	WORD red[256];
	WORD green[256];
	WORD blue[256];
End Type

Const MAX_DDDEVICEID_STRING=512

Type tagDDDEVICEIDENTIFIER
	char szDriver[MAX_DDDEVICEID_STRING];
	char szDescription[MAX_DDDEVICEID_STRING];
	LARGE_INTEGER liDriverVersion; /* Defined For applications And other 32 bit components */
	Field dwVendorId;
	Field dwDeviceId;
	Field dwSubSysId;
	Field dwRevision;
	GUID guidDeviceIdentifier;
End Type

Type tagDDDEVICEIDENTIFIER2
	char szDriver[MAX_DDDEVICEID_STRING];
	char szDescription[MAX_DDDEVICEID_STRING];
	LARGE_INTEGER liDriverVersion; /* Defined For applications And other 32 bit components */
	Field dwVendorId;
	Field dwDeviceId;
	Field dwSubSysId;
	Field dwRevision;
	GUID guidDeviceIdentifier;
	Field dwWHQLLevel;
End Type
endrem

'Const DDGDI_GETHOSTIDENTIFIER=$1
'typedef DWORD (FAR PASCAL *LPCLIPPERCALLBACK)(LPDIRECTDRAWCLIPPER lpDDClipper, HWND hWnd, DWORD code, LPVOID lpContext );
'typedef DWORD (FAR PASCAL *LPSURFACESTREAMINGCALLBACK)(DWORD);

Extern "win32"

Type IDirectDraw Extends IUnknown
	Method Compact()
	Method CreateClipper()
	Method CreatePalette()
	Method CreateSurface(surfacedesc:Byte Ptr,surf:IDirectDrawSurface Ptr,outer:Byte Ptr)
	Method DuplicateSurface()
	Method EnumDisplayModes( flags,surf:Byte Ptr,context:Object,callback(surf:Byte Ptr,context:Object))	'surf:DDSurfaceDesc
	Method EnumSurfaces()
	Method FlipToGDISurface()
	Method GetCaps( driverCaps:Byte Ptr,helCaps:Byte Ptr )
	Method GetDisplayMode()
	Method GetFourCCCodes()
	Method GetGDISurface()
	Method GetMonitorFrequency()
	Method GetScanLine()
	Method GetVerticalBlankStatus()
	Method Initialize()
	Method RestoreDisplayMode()
	Method SetCooperativeLevel(hwnd,flags)
	Method SetDisplayMode(width,height,bpp)
	Method WaitForVerticalBlank(flags,event)
Rem
 STDMETHOD(Compact)(THIS) PURE;
 STDMETHOD(CreateClipper)(THIS_ DWORD, LPDIRECTDRAWCLIPPER FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreatePalette)(THIS_ DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreateSurface)(THIS_ LPDDSURFACEDESC, LPDIRECTDRAWSURFACE FAR *, IUnknown FAR *) PURE;
 STDMETHOD(DuplicateSurface)( THIS_ LPDIRECTDRAWSURFACE, LPDIRECTDRAWSURFACE FAR * ) PURE;
 STDMETHOD(EnumDisplayModes)( THIS_ DWORD, LPDDSURFACEDESC, LPVOID, LPDDENUMMODESCALLBACK ) PURE;
 STDMETHOD(EnumSurfaces)(THIS_ DWORD, LPDDSURFACEDESC, LPVOID,LPDDENUMSURFACESCALLBACK ) PURE;
 STDMETHOD(FlipToGDISurface)(THIS) PURE;
 STDMETHOD(GetCaps)( THIS_ LPDDCAPS, LPDDCAPS) PURE;
 STDMETHOD(GetDisplayMode)( THIS_ LPDDSURFACEDESC) PURE;
 STDMETHOD(GetFourCCCodes)(THIS_ LPDWORD, LPDWORD ) PURE;
 STDMETHOD(GetGDISurface)(THIS_ LPDIRECTDRAWSURFACE FAR *) PURE;
 STDMETHOD(GetMonitorFrequency)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetScanLine)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetVerticalBlankStatus)(THIS_ LPBOOL ) PURE;
 STDMETHOD(Initialize)(THIS_ GUID FAR *) PURE;
 STDMETHOD(RestoreDisplayMode)(THIS) PURE;
 STDMETHOD(SetCooperativeLevel)(THIS_ HWND, DWORD) PURE;
 STDMETHOD(SetDisplayMode)(THIS_ DWORD, DWORD,DWORD) PURE;
 STDMETHOD(WaitForVerticalBlank)(THIS_ DWORD, HANDLE ) PURE;
End Rem
End Type

Type IDirectDraw2 Extends IUnknown

Rem
 STDMETHOD(Compact)(THIS) PURE;
 STDMETHOD(CreateClipper)(THIS_ DWORD, LPDIRECTDRAWCLIPPER FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreatePalette)(THIS_ DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreateSurface)(THIS_ LPDDSURFACEDESC, LPDIRECTDRAWSURFACE FAR *, IUnknown FAR *) PURE;
 STDMETHOD(DuplicateSurface)( THIS_ LPDIRECTDRAWSURFACE, LPDIRECTDRAWSURFACE FAR * ) PURE;
 STDMETHOD(EnumDisplayModes)( THIS_ DWORD, LPDDSURFACEDESC, LPVOID, LPDDENUMMODESCALLBACK ) PURE;
 STDMETHOD(EnumSurfaces)(THIS_ DWORD, LPDDSURFACEDESC, LPVOID,LPDDENUMSURFACESCALLBACK ) PURE;
 STDMETHOD(FlipToGDISurface)(THIS) PURE;
 STDMETHOD(GetCaps)( THIS_ LPDDCAPS, LPDDCAPS) PURE;
 STDMETHOD(GetDisplayMode)( THIS_ LPDDSURFACEDESC) PURE;
 STDMETHOD(GetFourCCCodes)(THIS_ LPDWORD, LPDWORD ) PURE;
 STDMETHOD(GetGDISurface)(THIS_ LPDIRECTDRAWSURFACE FAR *) PURE;
 STDMETHOD(GetMonitorFrequency)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetScanLine)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetVerticalBlankStatus)(THIS_ LPBOOL ) PURE;
 STDMETHOD(Initialize)(THIS_ GUID FAR *) PURE;
 STDMETHOD(RestoreDisplayMode)(THIS) PURE;
 STDMETHOD(SetCooperativeLevel)(THIS_ HWND, DWORD) PURE;
 STDMETHOD(SetDisplayMode)(THIS_ DWORD, DWORD,DWORD, DWORD, DWORD) PURE;
 STDMETHOD(WaitForVerticalBlank)(THIS_ DWORD, HANDLE ) PURE;
 ' Added in the v2 interface
 STDMETHOD(GetAvailableVidMem)(THIS_ LPDDSCAPS, LPDWORD, LPDWORD) PURE;
End Rem
End Type

Type IDirectDraw4 Extends IUnknown
Rem
 STDMETHOD(Compact)(THIS) PURE;
 STDMETHOD(CreateClipper)(THIS_ DWORD, LPDIRECTDRAWCLIPPER FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreatePalette)(THIS_ DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreateSurface)(THIS_ LPDDSURFACEDESC2, LPDIRECTDRAWSURFACE4 FAR *, IUnknown FAR *) PURE;
 STDMETHOD(DuplicateSurface)( THIS_ LPDIRECTDRAWSURFACE4, LPDIRECTDRAWSURFACE4 FAR * ) PURE;
 STDMETHOD(EnumDisplayModes)( THIS_ DWORD, LPDDSURFACEDESC2, LPVOID, LPDDENUMMODESCALLBACK2 ) PURE;
 STDMETHOD(EnumSurfaces)(THIS_ DWORD, LPDDSURFACEDESC2, LPVOID,LPDDENUMSURFACESCALLBACK2 ) PURE;
 STDMETHOD(FlipToGDISurface)(THIS) PURE;
 STDMETHOD(GetCaps)( THIS_ LPDDCAPS, LPDDCAPS) PURE;
 STDMETHOD(GetDisplayMode)( THIS_ LPDDSURFACEDESC2) PURE;
 STDMETHOD(GetFourCCCodes)(THIS_ LPDWORD, LPDWORD ) PURE;
 STDMETHOD(GetGDISurface)(THIS_ LPDIRECTDRAWSURFACE4 FAR *) PURE;
 STDMETHOD(GetMonitorFrequency)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetScanLine)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetVerticalBlankStatus)(THIS_ LPBOOL ) PURE;
 STDMETHOD(Initialize)(THIS_ GUID FAR *) PURE;
 STDMETHOD(RestoreDisplayMode)(THIS) PURE;
 STDMETHOD(SetCooperativeLevel)(THIS_ HWND, DWORD) PURE;
 STDMETHOD(SetDisplayMode)(THIS_ DWORD, DWORD,DWORD, DWORD, DWORD) PURE;
 STDMETHOD(WaitForVerticalBlank)(THIS_ DWORD, HANDLE ) PURE;
' /*** Added in the v2 interface ***/
 STDMETHOD(GetAvailableVidMem)(THIS_ LPDDSCAPS2, LPDWORD, LPDWORD) PURE;
' /*** Added in the V4 Interface ***/
 STDMETHOD(GetSurfaceFromDC) (THIS_ HDC, LPDIRECTDRAWSURFACE4 *) PURE;
 STDMETHOD(RestoreAllSurfaces)(THIS) PURE;
 STDMETHOD(TestCooperativeLevel)(THIS) PURE;
 STDMETHOD(GetDeviceIdentifier)(THIS_ LPDDDEVICEIDENTIFIER, DWORD ) PURE;
End Rem
End Type

Type IDirectDraw7 Extends IUnknown
	Method Compact()
	Method CreateClipper(flags,clipper:Byte Ptr,outer:Byte Ptr)
	Method CreatePalette()
	Method CreateSurface(surfdesc2:Byte Ptr,surf:IDirectDrawSurface7 Ptr,outer:Byte Ptr)
	Method DuplicateSurface()
	Method EnumDisplayModes(flags,surfdesc2:Byte Ptr,context:Object,callback(surfdesc2:Byte Ptr,context:Object))	'surf:DDSurfaceDesc
	Method EnumSurfaces()
	Method FlipToGDISurface()
	Method GetCaps( driverCaps:Byte Ptr,helCaps:Byte Ptr )
	Method GetDisplayMode()
	Method GetFourCCCodes()
	Method GetGDISurface()
	Method GetMonitorFrequency()
	Method GetScanLine()
	Method GetVerticalBlankStatus()
	Method Initialize()
	Method RestoreDisplayMode()
	Method SetCooperativeLevel(hwnd,flags)
	Method SetDisplayMode(width,height,bpp,rate,flags)
	Method WaitForVerticalBlank(flags,event)
	
 	Method GetAvailableVidMem(Caps:Byte Ptr, Total:Int Ptr, Free: Int Ptr)
 	Method GetSurfaceFromDC(HDC :Int, surf:IDirectDrawSurface7)
 	Method RestoreAllSurfaces()
 	Method TestCooperativeLevel()

	
	
Rem
 STDMETHOD(Compact)(THIS) PURE;
 STDMETHOD(CreateClipper)(THIS_ DWORD, LPDIRECTDRAWCLIPPER FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreatePalette)(THIS_ DWORD, LPPALETTEENTRY, LPDIRECTDRAWPALETTE FAR*, IUnknown FAR * ) PURE;
 STDMETHOD(CreateSurface)(THIS_ LPDDSURFACEDESC2, LPDIRECTDRAWSURFACE7 FAR *, IUnknown FAR *) PURE;
 STDMETHOD(DuplicateSurface)( THIS_ LPDIRECTDRAWSURFACE7, LPDIRECTDRAWSURFACE7 FAR * ) PURE;
 STDMETHOD(EnumDisplayModes)( THIS_ DWORD, LPDDSURFACEDESC2, LPVOID, LPDDENUMMODESCALLBACK2 ) PURE;
 STDMETHOD(EnumSurfaces)(THIS_ DWORD, LPDDSURFACEDESC2, LPVOID,LPDDENUMSURFACESCALLBACK7 ) PURE;
 STDMETHOD(FlipToGDISurface)(THIS) PURE;
 STDMETHOD(GetCaps)( THIS_ LPDDCAPS, LPDDCAPS) PURE;
 STDMETHOD(GetDisplayMode)( THIS_ LPDDSURFACEDESC2) PURE;
 STDMETHOD(GetFourCCCodes)(THIS_ LPDWORD, LPDWORD ) PURE;
 STDMETHOD(GetGDISurface)(THIS_ LPDIRECTDRAWSURFACE7 FAR *) PURE;
 STDMETHOD(GetMonitorFrequency)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetScanLine)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetVerticalBlankStatus)(THIS_ LPBOOL ) PURE;
 STDMETHOD(Initialize)(THIS_ GUID FAR *) PURE;
 STDMETHOD(RestoreDisplayMode)(THIS) PURE;
 STDMETHOD(SetCooperativeLevel)(THIS_ HWND, DWORD) PURE;
 STDMETHOD(SetDisplayMode)(THIS_ DWORD, DWORD,DWORD, DWORD, DWORD) PURE;
 STDMETHOD(WaitForVerticalBlank)(THIS_ DWORD, HANDLE ) PURE;
' /*** Added in the v2 interface ***/
 STDMETHOD(GetAvailableVidMem)(THIS_ LPDDSCAPS2, LPDWORD, LPDWORD) PURE;
' /*** Added in the V4 Interface ***/
 STDMETHOD(GetSurfaceFromDC) (THIS_ HDC, LPDIRECTDRAWSURFACE7 *) PURE;
 STDMETHOD(RestoreAllSurfaces)(THIS) PURE;
 STDMETHOD(TestCooperativeLevel)(THIS) PURE;
 STDMETHOD(GetDeviceIdentifier)(THIS_ LPDDDEVICEIDENTIFIER2, DWORD ) PURE;
 STDMETHOD(StartModeTest)(THIS_ LPSIZE, DWORD, DWORD ) PURE;
 STDMETHOD(EvaluateMode)(THIS_ DWORD, DWORD * ) PURE;
End Rem
End Type

Type IDirectDrawPalette Extends IUnknown
Rem
 STDMETHOD(GetCaps)(THIS_ LPDWORD) PURE;
 STDMETHOD(GetEntries)(THIS_ DWORD,DWORD,DWORD,LPPALETTEENTRY) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, DWORD, LPPALETTEENTRY) PURE;
 STDMETHOD(SetEntries)(THIS_ DWORD,DWORD,DWORD,LPPALETTEENTRY) PURE;
End Rem
End Type

Type IDirectDrawClipper Extends IUnknown
	Method GetClipList(rect:Byte Ptr,region:Byte Ptr,flags)
	Method GetHWnd()
	Method Initialize()
	Method IsClipListChanged()
	Method SetClipList()
	Method SetHWnd(flags,hwnd)
Rem
 STDMETHOD(GetClipList)(THIS_ LPRECT, LPRGNDATA, LPDWORD) PURE;
 STDMETHOD(GetHWnd)(THIS_ HWND FAR *) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, DWORD) PURE;
 STDMETHOD(IsClipListChanged)(THIS_ BOOL FAR *) PURE;
 STDMETHOD(SetClipList)(THIS_ LPRGNDATA,DWORD) PURE;
 STDMETHOD(SetHWnd)(THIS_ DWORD, HWND ) PURE;
End Rem
End Type

Type IDirectDrawSurface Extends IUnknown
	Method AddAttachedSurface(surface:Byte Ptr)
	Method AddOverlayDirtyRect(rect:Byte Ptr)
	Method Blt(destrect:Byte Ptr,srcsurface:Byte Ptr,srcrect:Byte Ptr,flags,blitfx:Byte Ptr)
	Method BltBatch(bltbatch:Byte Ptr,count,flags)
	Method BltFast(x,y,srcsurface:Byte Ptr,srcrect:Byte Ptr,trans)
	Method DeleteAttachedSurface(flags,surface:Byte Ptr)
	Method EnumAttachedSurfaces()
	Method EnumOverlayZOrders()
	Method Flip(target:Byte Ptr,flags)
	Method GetAttachedSurface(caps:Byte Ptr,surface:IDirectDrawSurface Ptr)
Rem
 STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE) PURE;
 STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT) PURE;
 STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE, LPRECT,DWORD, LPDDBLTFX) PURE;
 STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD ) PURE;
 STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE, LPRECT,DWORD) PURE;
 STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE) PURE;
 STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK) PURE;
 STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK) PURE;
 STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE, DWORD) PURE;
 STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS, LPDIRECTDRAWSURFACE FAR *) PURE;
 STDMETHOD(GetBltStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetCaps)(THIS_ LPDDSCAPS) PURE;
 STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER FAR*) PURE;
 STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(GetDC)(THIS_ HDC FAR *) PURE;
 STDMETHOD(GetFlipStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG ) PURE;
 STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE FAR*) PURE;
 STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT) PURE;
 STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC) PURE;
 STDMETHOD(IsLost)(THIS) PURE;
 STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC,DWORD,HANDLE) PURE;
 STDMETHOD(ReleaseDC)(THIS_ HDC) PURE;
 STDMETHOD(Restore)(THIS) PURE;
 STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER) PURE;
 STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(SetOverlayPosition)(THIS_ Long, Long ) PURE;
 STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE) PURE;
 STDMETHOD(Unlock)(THIS_ LPVOID) PURE;
 STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE,LPRECT,DWORD, LPDDOVERLAYFX) PURE;
 STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD) PURE;
 STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE) PURE;
End Rem
End Type

Type IDirectDrawSUrface2 Extends IUnknown
Rem
 STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE2) PURE;
 STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT) PURE;
 STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE2, LPRECT,DWORD, LPDDBLTFX) PURE;
 STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD ) PURE;
 STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE2, LPRECT,DWORD) PURE;
 STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE2) PURE;
 STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK) PURE;
 STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK) PURE;
 STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE2, DWORD) PURE;
 STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS, LPDIRECTDRAWSURFACE2 FAR *) PURE;
 STDMETHOD(GetBltStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetCaps)(THIS_ LPDDSCAPS) PURE;
 STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER FAR*) PURE;
 STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(GetDC)(THIS_ HDC FAR *) PURE;
 STDMETHOD(GetFlipStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG ) PURE;
 STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE FAR*) PURE;
 STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT) PURE;
 STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC) PURE;
 STDMETHOD(IsLost)(THIS) PURE;
 STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC,DWORD,HANDLE) PURE;
 STDMETHOD(ReleaseDC)(THIS_ HDC) PURE;
 STDMETHOD(Restore)(THIS) PURE;
 STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER) PURE;
 STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(SetOverlayPosition)(THIS_ Long, Long ) PURE;
 STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE) PURE;
 STDMETHOD(Unlock)(THIS_ LPVOID) PURE;
 STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE2,LPRECT,DWORD, LPDDOVERLAYFX) PURE;
 STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD) PURE;
 STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE2) PURE;
' /*** Added in the v2 interface ***/
 STDMETHOD(GetDDInterface)(THIS_ LPVOID FAR *) PURE;
 STDMETHOD(PageLock)(THIS_ DWORD) PURE;
 STDMETHOD(PageUnlock)(THIS_ DWORD) PURE;
End Rem
End Type

Type IDirectDrawSurface3 Extends IUnknown
Rem
 STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE3) PURE;
 STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT) PURE;
 STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE3, LPRECT,DWORD, LPDDBLTFX) PURE;
 STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD ) PURE;
 STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE3, LPRECT,DWORD) PURE;
 STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE3) PURE;
 STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK) PURE;
 STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK) PURE;
 STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE3, DWORD) PURE;
 STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS, LPDIRECTDRAWSURFACE3 FAR *) PURE;
 STDMETHOD(GetBltStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetCaps)(THIS_ LPDDSCAPS) PURE;
 STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER FAR*) PURE;
 STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(GetDC)(THIS_ HDC FAR *) PURE;
 STDMETHOD(GetFlipStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG ) PURE;
 STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE FAR*) PURE;
 STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT) PURE;
 STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC) PURE;
 STDMETHOD(IsLost)(THIS) PURE;
 STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC,DWORD,HANDLE) PURE;
 STDMETHOD(ReleaseDC)(THIS_ HDC) PURE;
 STDMETHOD(Restore)(THIS) PURE;
 STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER) PURE;
 STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(SetOverlayPosition)(THIS_ Long, Long ) PURE;
 STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE) PURE;
 STDMETHOD(Unlock)(THIS_ LPVOID) PURE;
 STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE3,LPRECT,DWORD, LPDDOVERLAYFX) PURE;
 STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD) PURE;
 STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE3) PURE;
' /*** Added in the v2 interface ***/
 STDMETHOD(GetDDInterface)(THIS_ LPVOID FAR *) PURE;
 STDMETHOD(PageLock)(THIS_ DWORD) PURE;
 STDMETHOD(PageUnlock)(THIS_ DWORD) PURE;
' /*** Added in the V3 interface ***/
 STDMETHOD(SetSurfaceDesc)(THIS_ LPDDSURFACEDESC, DWORD) PURE;
End Rem
End Type

Type IDirectDrawSurface4 Extends IUnknown
Rem
 STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE4) PURE;
 STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT) PURE;
 STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE4, LPRECT,DWORD, LPDDBLTFX) PURE;
 STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD ) PURE;
 STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE4, LPRECT,DWORD) PURE;
 STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE4) PURE;
 STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK2) PURE;
 STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK2) PURE;
 STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE4, DWORD) PURE;
 STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS2, LPDIRECTDRAWSURFACE4 FAR *) PURE;
 STDMETHOD(GetBltStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetCaps)(THIS_ LPDDSCAPS2) PURE;
 STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER FAR*) PURE;
 STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(GetDC)(THIS_ HDC FAR *) PURE;
 STDMETHOD(GetFlipStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG ) PURE;
 STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE FAR*) PURE;
 STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT) PURE;
 STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC2) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC2) PURE;
 STDMETHOD(IsLost)(THIS) PURE;
 STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC2,DWORD,HANDLE) PURE;
 STDMETHOD(ReleaseDC)(THIS_ HDC) PURE;
 STDMETHOD(Restore)(THIS) PURE;
 STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER) PURE;
 STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(SetOverlayPosition)(THIS_ Long, Long ) PURE;
 STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE) PURE;
 STDMETHOD(Unlock)(THIS_ LPRECT) PURE;
 STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE4,LPRECT,DWORD, LPDDOVERLAYFX) PURE;
 STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD) PURE;
 STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE4) PURE;
' /*** Added in the v2 interface ***/
 STDMETHOD(GetDDInterface)(THIS_ LPVOID FAR *) PURE;
 STDMETHOD(PageLock)(THIS_ DWORD) PURE;
 STDMETHOD(PageUnlock)(THIS_ DWORD) PURE;
' /*** Added in the v3 interface ***/
 STDMETHOD(SetSurfaceDesc)(THIS_ LPDDSURFACEDESC2, DWORD) PURE;
' /*** Added in the v4 interface ***/
 STDMETHOD(SetPrivateData)(THIS_ REFGUID, LPVOID, DWORD, DWORD) PURE;
 STDMETHOD(GetPrivateData)(THIS_ REFGUID, LPVOID, LPDWORD) PURE;
 STDMETHOD(FreePrivateData)(THIS_ REFGUID) PURE;
 STDMETHOD(GetUniquenessValue)(THIS_ LPDWORD) PURE;
 STDMETHOD(ChangeUniquenessValue)(THIS) PURE;
End Rem
End Type

Type IDirectDrawSurface7 Extends IUnknown
	Method AddAttachedSurface(surface:Byte Ptr)
	Method AddOverlayDirtyRect(rect:Byte Ptr)
	Method Blt(destrect:Byte Ptr,srcsurface:Byte Ptr,srcrect:Byte Ptr,flags,blitfx:Byte Ptr)
	Method BltBatch(bltbatch:Byte Ptr,count,flags)
	Method BltFast(x,y,srcsurface:Byte Ptr,srcrect:Byte Ptr,trans)
	Method DeleteAttachedSurface(flags,surface:Byte Ptr)
	Method EnumAttachedSurfaces()
	Method EnumOverlayZOrders()
	Method Flip(target:Byte Ptr,flags)
	Method GetAttachedSurface(caps:Byte Ptr,surface:IDirectDrawSurface7 Ptr)
	Method GetBltStatus()
	Method GetCaps()
	Method GetClipper()
	Method GetColorKey()
	Method GetDC(hdc:Int Ptr)
	Method GetFlipStatus()
	Method GetOverlayPosition()
	Method GetPalette()
	Method GetPixelFormat()
	Method GetSurfaceDesc(surfdesc:Byte Ptr)
	Method Initialize()
	Method IsLost()
	Method Lock(rect:Byte Ptr,surfacedesc2:Byte Ptr,flags,handle)
	Method ReleaseDC(hdc)
	Method Restore()
	Method SetClipper(clipper:Byte Ptr)
	Method SetColorKey()
	Method SetOverlayPosition()
	Method SetPalette()
	Method Unlock(rect:Byte Ptr)
	Method UpdateOverlay()
	Method UpdateOverlayDisplay()
	Method UpdateOverlayZOrder()
	Method GetDDInterface(ddinterface:Byte Ptr)
 	Method PageLock(flags)
	Method PageUnlock(flags)
Rem
 STDMETHOD(AddAttachedSurface)(THIS_ LPDIRECTDRAWSURFACE7) PURE;
 STDMETHOD(AddOverlayDirtyRect)(THIS_ LPRECT) PURE;
 STDMETHOD(Blt)(THIS_ LPRECT,LPDIRECTDRAWSURFACE7, LPRECT,DWORD, LPDDBLTFX) PURE;
 STDMETHOD(BltBatch)(THIS_ LPDDBLTBATCH, DWORD, DWORD ) PURE;
 STDMETHOD(BltFast)(THIS_ DWORD,DWORD,LPDIRECTDRAWSURFACE7, LPRECT,DWORD) PURE;
 STDMETHOD(DeleteAttachedSurface)(THIS_ DWORD,LPDIRECTDRAWSURFACE7) PURE;
 STDMETHOD(EnumAttachedSurfaces)(THIS_ LPVOID,LPDDENUMSURFACESCALLBACK7) PURE;
 STDMETHOD(EnumOverlayZOrders)(THIS_ DWORD,LPVOID,LPDDENUMSURFACESCALLBACK7) PURE;
 STDMETHOD(Flip)(THIS_ LPDIRECTDRAWSURFACE7, DWORD) PURE;
 STDMETHOD(GetAttachedSurface)(THIS_ LPDDSCAPS2, LPDIRECTDRAWSURFACE7 FAR *) PURE;
 STDMETHOD(GetBltStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetCaps)(THIS_ LPDDSCAPS2) PURE;
 STDMETHOD(GetClipper)(THIS_ LPDIRECTDRAWCLIPPER FAR*) PURE;
 STDMETHOD(GetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(GetDC)(THIS_ HDC FAR *) PURE;
 STDMETHOD(GetFlipStatus)(THIS_ DWORD) PURE;
 STDMETHOD(GetOverlayPosition)(THIS_ LPLONG, LPLONG ) PURE;
 STDMETHOD(GetPalette)(THIS_ LPDIRECTDRAWPALETTE FAR*) PURE;
 STDMETHOD(GetPixelFormat)(THIS_ LPDDPIXELFORMAT) PURE;
 STDMETHOD(GetSurfaceDesc)(THIS_ LPDDSURFACEDESC2) PURE;
 STDMETHOD(Initialize)(THIS_ LPDIRECTDRAW, LPDDSURFACEDESC2) PURE;
 STDMETHOD(IsLost)(THIS) PURE;
 STDMETHOD(Lock)(THIS_ LPRECT,LPDDSURFACEDESC2,DWORD,HANDLE) PURE;
 STDMETHOD(ReleaseDC)(THIS_ HDC) PURE;
 STDMETHOD(Restore)(THIS) PURE;
 STDMETHOD(SetClipper)(THIS_ LPDIRECTDRAWCLIPPER) PURE;
 STDMETHOD(SetColorKey)(THIS_ DWORD, LPDDCOLORKEY) PURE;
 STDMETHOD(SetOverlayPosition)(THIS_ Long, Long ) PURE;
 STDMETHOD(SetPalette)(THIS_ LPDIRECTDRAWPALETTE) PURE;
 STDMETHOD(Unlock)(THIS_ LPRECT) PURE;
 STDMETHOD(UpdateOverlay)(THIS_ LPRECT, LPDIRECTDRAWSURFACE7,LPRECT,DWORD, LPDDOVERLAYFX) PURE;
 STDMETHOD(UpdateOverlayDisplay)(THIS_ DWORD) PURE;
 STDMETHOD(UpdateOverlayZOrder)(THIS_ DWORD, LPDIRECTDRAWSURFACE7) PURE;
' /*** Added in the v2 interface ***/
 STDMETHOD(GetDDInterface)(THIS_ LPVOID FAR *) PURE;
 STDMETHOD(PageLock)(THIS_ DWORD) PURE;
 STDMETHOD(PageUnlock)(THIS_ DWORD) PURE;
' /*** Added in the v3 interface ***/
 STDMETHOD(SetSurfaceDesc)(THIS_ LPDDSURFACEDESC2, DWORD) PURE;
' /*** Added in the v4 interface ***/
 STDMETHOD(SetPrivateData)(THIS_ REFGUID, LPVOID, DWORD, DWORD) PURE;
 STDMETHOD(GetPrivateData)(THIS_ REFGUID, LPVOID, LPDWORD) PURE;
 STDMETHOD(FreePrivateData)(THIS_ REFGUID) PURE;
 STDMETHOD(GetUniquenessValue)(THIS_ LPDWORD) PURE;
 STDMETHOD(ChangeUniquenessValue)(THIS) PURE;
' /*** Moved Texture7 methods here ***/
 STDMETHOD(SetPriority)(THIS_ DWORD) PURE;
 STDMETHOD(GetPriority)(THIS_ LPDWORD) PURE;
 STDMETHOD(SetLOD)(THIS_ DWORD) PURE;
 STDMETHOD(GetLOD)(THIS_ LPDWORD) PURE;
End Rem
End Type

Type IDirectDrawColorControl Extends IUnknown
Rem
DECLARE_INTERFACE_( IDirectDrawColorControl, IUnknown )
 STDMETHOD(GetColorControls)(THIS_ LPDDCOLORCONTROL) PURE;
 STDMETHOD(SetColorControls)(THIS_ LPDDCOLORCONTROL) PURE;
End Rem
End Type

Type IDirectDrawGammaControl Extends IUnknown
Rem
 STDMETHOD(GetGammaRamp)(THIS_ DWORD, LPDDGAMMARAMP) PURE;
 STDMETHOD(SetGammaRamp)(THIS_ DWORD, LPDDGAMMARAMP) PURE;
End Rem
End Type

End Extern

Global ddLib=LoadLibraryA( "ddraw" )

If Not ddLib Return

Global IID_IDirectDraw7[]=[$15e65ec0,$11d23b9c,$60002fb9,$5bea9797]

Global DirectDrawCreate( guid Ptr,ddraw:IDirectDraw Ptr,outer Ptr )"win32"=GetProcAddress( ddLib,"DirectDrawCreate" )
Global DirectDrawCreateEx( guid:Byte Ptr,ddraw:Byte Ptr,iid Ptr,outer:Byte Ptr )"win32"=GetProcAddress( ddLib,"DirectDrawCreateEx" )
Global DirectDrawEnumerate( callback(guid Ptr,desc:Byte Ptr,name:Byte Ptr,context Ptr),context Ptr )"win32"=GetProcAddress( ddLib,"DirectDrawEnumerateA" )

