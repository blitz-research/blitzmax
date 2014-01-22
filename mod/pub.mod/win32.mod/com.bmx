
Strict

Extern "win32"

Function CLSIDFromProgID(code$w,clsid:Byte Ptr)
Function CoCreateInstance(rclsid:Byte Ptr,pUnkOuter:Byte Ptr,dwClsContext,riid:Byte Ptr,ppv:Byte Ptr Ptr)
Function IIDFromString(lpsz$w,riid:Byte Ptr)

Type IUnknown 
	Method QueryInterface( riid:Byte Ptr,ppvObj:Byte Ptr )
	Method AddRef()
	Method Release_()
End Type


' oleautomation

Function SysAllocStringLen:Short ptr(bstr:Short Ptr,length)
Function SysFreeString(bstr:Short Ptr)

Type IDispatch Extends IUnknown
	Method lfGetTypeInfoCount(pctinfo:Byte Ptr) 
	Method lfGetTypeInfo(iTInfo,lcid,ITypeInfo:Byte Ptr)
	Method lfGetIDsOfNames( riid:Byte Ptr,rgszNames:Byte Ptr Ptr,cNames,lcid,rgDispId:Byte Ptr)
	Method Invoke(dispIdMember:Byte Ptr,riid:Byte Ptr,lcid,wFlags,pDispParams:Byte Ptr,pVarResult:Byte Ptr,pExcepInfo:Byte Ptr,puArgErr:Byte Ptr)
End Type

Type IWebBrowser Extends IDispatch	
	Method lfGoBack()
	Method lfGoForward()
	Method lfGoHome()
	Method lfGoSearch()
	Method lfNavigate(URL$w,Flags:VARIANT,TargetFrameName:VARIANT,PostData:VARIANT,Headers:Byte Ptr) 'VARIANT)
	Method lfRefresh()
	Method lfRefresh2(Level:Byte Ptr) 'VARIANT)
	Method lfStop()
	Method lfget_Application(ppDisp:IDispatch Ptr Ptr) 
	Method lfget_Parent(ppDisp:IDispatch Ptr Ptr)
	Method lfget_Container(ppDisp:IDispatch Ptr Ptr)
	Method lfget_Document(ppDisp:IDispatch Ptr)
	Method lfget_TopLevelContainer(pBool:Short Ptr)
	Method lfget_Type(_Type$w)	
	Method lfget_Left(pl:Int Ptr)
	Method put_Left(Left) 
	Method lfget_Top(pl:Int Ptr)
	Method put_Top(Top)
	Method lfget_Width(pl:Int Ptr)
	Method put_Width(Width)
	Method lfget_Height(pl:Int Ptr)
	Method put_Height(Height)
	Method lfget_LocationName(LocationName:Short Ptr Ptr)
	Method lfget_LocationURL(LocationURL:Short Ptr Ptr)
	Method lfget_Busy(pBool:Short Ptr)
End Type

Type IWebBrowserApp Extends IWebBrowser
	Method lfQuit()
	Method lfClientToWindow(pcx:Int Ptr,pcy:Int Ptr) 
	Method lfPutProperty(Property$w,vtValue:Byte Ptr) 'VARIANT)	'simon come here 
	Method lfGetProperty(Property$w,vtValue:Byte Ptr) 'VARIANT) 
	Method lfget_Name(Name:Byte Ptr )
	Method lfget_HWND(pHWND:Int Ptr)
	Method lfget_FullName(FullName:Short Ptr Ptr)
	Method lfget_Path(Path:Short Ptr Ptr)
	Method lfget_Visible(pBool:Short Ptr)
	Method put_Visible(Value:Byte Ptr) 'VARIANT)
	Method lfget_StatusBar(pBool:Short Ptr)
	Method put_StatusBar(Value:Byte Ptr) 'VARIANT)
	Method lfget_StatusText(StatusText:Short Ptr Ptr)
	Method put_StatusText(StatusText$w)
	Method lfget_ToolBar(Value:Int Ptr)
	Method put_ToolBar(Value)
	Method lfget_MenuBar(Value:Byte Ptr) 'VARIANT)
	Method put_MenuBar(Value:Byte Ptr) 'VARIANT)
	Method lfget_FullScreen(pbFullScreen:Byte Ptr) 'VARIANT)
	Method put_FullScreen(bFullScreen:Byte Ptr) 'VARIANT)
End Type

Type IWebBrowser2 Extends IWebBrowserApp
	Method lfNavigate2(URL:VARIANT,Flags:VARIANT,TargetFrameName:VARIANT,PostData:VARIANT,Headers:Byte Ptr) 'VARIANT)
	Method lfQueryStatusWB(cmdID,pcmdf)
	Method lfExecWB(cmdID,cmdexecopt,pvaIn:VARIANT,pvaOut:Byte Ptr) 'VARIANT)
	Method lfShowBrowserBar(pvaClsid:VARIANT,pvarShow:VARIANT,pvarSize:Byte Ptr) 'VARIANT)
	Method get_ReadyState(plReadyState:Int Ptr)
	Method lfget_Offline(pbOffline:Short Ptr)
	Method put_Offline(bOffline)
	Method lfget_Silent(pbSilent:Short Ptr)
	Method put_Silent(bSilent)
	Method lfget_RegisterAsBrowser(pbRegister:Short Ptr)
	Method put_RegisterAsBrowser(bRegister)
	Method lfget_RegisterAsDropTarget(pbRegister:Short Ptr)
	Method put_RegisterAsDropTarget(bRegister)
	Method lfget_TheaterMode(pbRegister:Short Ptr) 
	Method put_TheaterMode(bRegister)
	Method lfget_AddressBar(Value:Short Ptr)
	Method put_AddressBar(Value)
	Method lfget_Resizable(Value:Short Ptr)
	Method put_Resizable(Value)
End Type

' warning methods below maybe incorrectly described! 

Type IHTMLWindow2 Extends IDispatch
    Method item(this:Byte Ptr,_variant:Byte Ptr)
    Method get_length(_pint:Int Ptr)

    Method get_frames(IHTMLFramesCollection2:Byte Ptr Ptr)
    Method put_defaultStatus(_bstr:Short Ptr)
    Method get_defaultStatus(_pbstr:Short Ptr Ptr)
    Method put_status(_bstr:Short Ptr)
    Method get_status(_pbstr:Short Ptr Ptr)
    Method setTimeout(_bstr:Short Ptr,_int,_variant:Byte Ptr,_pint:Int Ptr)
    Method clearTimeout(_int)
    Method alert(_bstr:Short Ptr)
    Method _confirm(_bstr:Short Ptr,_variantbool:Short Ptr)
    Method prompt(_bstr1:Short Ptr,_bstr2:Short Ptr,_variant:Byte Ptr)
    Method get_Image(LPHTMLIMAGEELEMENTFACTORY:Byte Ptr)
    Method get_location(LPHTMLLOCATION:Byte Ptr)
    Method get_history(LPOMHISTORY:Byte Ptr)
    Method close()
    Method put_opener(_variant:Long)
    Method get_opener(this:Byte Ptr)
    Method get_navigator(LPOMNAVIGATOR:Byte Ptr)
    Method put_name(_bstr:Short Ptr)
    Method get_name(_pbstr:Short Ptr Ptr)
    Method get_parent(LPHTMLWINDOW2:Byte Ptr)
    Method open(_bstr:Short Ptr,_bstr1:Short Ptr,_bstr2:Short Ptr,_variant:Byte Ptr,LPHTMLWINDOW2:Byte Ptr)
    Method get_self(LPHTMLWINDOW2:Byte Ptr)
    Method get_top(LPHTMLWINDOW2:Byte Ptr)
    Method get_window(LPHTMLWINDOW2:Byte Ptr)
    Method navigate(_bstr:Short Ptr)
    Method put_onfocus(_variant:Long)
    Method get_onfocus(this:Byte Ptr)
    Method put_onblur(_variant:Long)
    Method get_onblur(this:Byte Ptr)
    Method put_onload(_variant:Long)
    Method get_onload(this:Byte Ptr)
    Method put_onbeforeunload(_variant:Long)
    Method get_onbeforeunload(this:Byte Ptr)
    Method put_onunload(_variant:Long)
    Method get_onunload(this:Byte Ptr)
    Method put_onhelp(_variant:Long)
    Method get_onhelp(this:Byte Ptr)
    Method put_onerror(_variant:Long)
    Method get_onerror(this:Byte Ptr)
    Method put_onresize(_variant:Long)
    Method get_onresize(this:Byte Ptr)
    Method put_onscroll(_variant:Long)
    Method get_onscroll(this:Byte Ptr)
    Method get_document(IHTMLDocument2:Byte Ptr Ptr)
    Method get_event(LPHTMLEVENTOBJ:Byte Ptr)
    Method get__newEnum(IUnknown:Byte Ptr Ptr)
    Method showModalDialog(_bstr:Short Ptr,_variant:Byte Ptr,_variant2:Byte Ptr,_variant3:Byte Ptr)
    Method showHelp(_bstr:Short Ptr,VARIANT,BSTR)
    Method get_screen(LPHTMLSCREEN:Byte Ptr)
    Method get_Option(LPHTMLOPTIONELEMENTFACTORY:Byte Ptr)
    Method focus()
    Method get_closed(_variant:Byte Ptr)
    Method blur()
    Method scroll(_int1,_int2)
    Method get_clientInformation(LPOMNAVIGATOR:Byte Ptr)
    Method setInterval(_bstr:Short Ptr,_int,_variant:Byte Ptr,_int1:Int Ptr)
    Method clearInterval(_int)
    Method put_offscreenBuffering(_variant:Long)
    Method get_offscreenBuffering(this:Byte Ptr)
    Method execScript(_bstr:Short Ptr,_bstr1:Short Ptr,_variant:Byte Ptr)
    Method toString(_pbstr:Short Ptr Ptr)
    Method scrollBy(_int,_int1)
    Method scrollTo(_int,_int1)
    Method moveTo(_int,_int1)
    Method moveBy(_int,_int1)
    Method resizeTo(_int,_int1)
    Method resizeBy(_int,_int1)
    Method get_external(IDispatch:Byte Ptr Ptr)
End Type

Type IHTMLDocument2 Extends IDispatch
	Method get_Script(IDispatch:Byte Ptr Ptr)

	Method get_all(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method get_body(LPHTMLELEMENT:Byte Ptr)
	Method get_activeElement(LPHTMLELEMENT:Byte Ptr)
	Method get_images(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method get_applets(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method get_links(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method get_forms(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method get_anchors(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method put_title(_bstr:Short Ptr)
	Method get_title(_pbstr:Short Ptr Ptr)
	Method get_scripts(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method put_designMode(_bstr:Short Ptr)
	Method get_designMode(_pbstr:Short Ptr Ptr)
	Method get_selection(LPHTMLSELECTIONOBJECT:Byte Ptr)
	Method get_readyState(_pbstr:Short Ptr Ptr)
	Method get_frames(LPHTMLFRAMESCOLLECTION:Byte Ptr)
	Method get_embeds(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method get_plugins(LPHTMLELEMENTCOLLECTION:Byte Ptr)
	Method put_alinkColor(_variant:Long)
	Method get_alinkColor(this:Byte Ptr)
	Method put_bgColor(_variant:Long)
	Method get_bgColor(this:Byte Ptr)
	Method put_fgColor(_variant:Long)
	Method get_fgColor(this:Byte Ptr)
	Method put_linkColor(_variant:Long)
	Method get_linkColor(this:Byte Ptr)
	Method put_vlinkColor(_variant:Long)
	Method get_vlinkColor(this:Byte Ptr)
	Method get_referrer(_pbstr:Short Ptr Ptr)
	Method get_location(LPHTMLLOCATION:Byte Ptr)
	Method get_lastModified(_pbstr:Short Ptr Ptr)
	Method put_url(_bstr:Short Ptr)
	Method get_url(_pbstr:Short Ptr Ptr)
	Method put_domain(_bstr:Short Ptr)
	Method get_domain(_pbstr:Short Ptr Ptr)
	Method put_cookie(_bstr:Short Ptr)
	Method get_cookie(_pbstr:Short Ptr Ptr)
	Method put_expands(_variant:Short)
	Method get_expands(_variant:Short Ptr)
	Method put_charset(_bstr:Short Ptr)
	Method get_charset(_pbstr:Short Ptr Ptr)
	Method put_defaultCharset(_bstr:Short Ptr)
	Method get_defaultCharset(_pbstr:Short Ptr Ptr)
	Method get_mimeType(_pbstr:Short Ptr Ptr)
	Method get_fileSize(_pbstr:Short Ptr Ptr)
	Method get_fileCreatedDate(_pbstr:Short Ptr Ptr)
	Method get_fileModifiedDate(_pbstr:Short Ptr Ptr)
	Method get_fileUpdatedDate(_pbstr:Short Ptr Ptr)
	Method get_security(_pbstr:Short Ptr Ptr)
	Method get_protocol(_pbstr:Short Ptr Ptr)
	Method get_nameProp(_pbstr:Short Ptr Ptr)
	Method write(SAFEARRAY)
	Method writeln(SAFEARRAY)
	Method open(_bstr:Short Ptr,v1:Long,v2:Long,v3:Long,IDispatch:Byte Ptr Ptr)
	Method close()
	Method clear()
	Method queryCommandSupported(_bstr:Short Ptr,_variantbool:Short Ptr)
	Method queryCommandEnabled(_bstr:Short Ptr,_variantbool:Short Ptr)
	Method queryCommandState(_bstr:Short Ptr,_variantbool:Short Ptr)
	Method queryCommandIndeterm(_bstr:Short Ptr,_variantbool:Short Ptr)
	Method queryCommandText(_bstr:Short Ptr,BSTR:Byte Ptr)
	Method queryCommandValue(_bstr:Short Ptr,_variant:Byte Ptr)
	Method execCommand(_bstr:Short Ptr,_variantbool:Short,_variant:Long,_variantpbool:Short Ptr)
	Method execCommandShowHelp(_bstr:Short Ptr,_variantbool:Short Ptr)
	Method createElement(_bstr:Short Ptr,LPHTMLELEMENT:Byte Ptr)
	Method put_onhelp(_variant:Long)
	Method get_onhelp(this:Byte Ptr)
	Method put_onclick(_variant:Long)
	Method get_onclick(this:Byte Ptr)
	Method put_ondblclick(_variant:Long)
	Method get_ondblclick(this:Byte Ptr)
	Method put_onkeyup(_variant:Long)
	Method get_onkeyup(this:Byte Ptr)
	Method put_onkeydown(_variant:Long)
	Method get_onkeydown(this:Byte Ptr)
	Method put_onkeypress(_variant:Long)
	Method get_onkeypress(this:Byte Ptr)
	Method put_onmouseup(_variant:Long)
	Method get_onmouseup(this:Byte Ptr)
	Method put_onmousedown(_variant:Long)
	Method get_onmousedown(this:Byte Ptr)
	Method put_onmousemove(_variant:Long)
	Method get_onmousemove(this:Byte Ptr)
	Method put_onmouseout(_variant:Long)
	Method get_onmouseout(this:Byte Ptr)
	Method put_onmouseover(_variant:Long)
	Method get_onmouseover(this:Byte Ptr)
	Method put_onreadystatechange(_variant:Long)
	Method get_onreadystatechange(this:Byte Ptr)
	Method put_onafterupdate(_variant:Long)
	Method get_onafterupdate(this:Byte Ptr)
	Method put_onrowexit(_variant:Long)
	Method get_onrowexit(this:Byte Ptr)
	Method put_onrowenter(_variant:Long)
	Method get_onrowenter(this:Byte Ptr)
	Method put_ondragstart(_variant:Long)
	Method get_ondragstart(this:Byte Ptr)
	Method put_onselectstart(_variant:Long)
	Method get_onselectstart(this:Byte Ptr)
	Method elementFromPoint(_int1,_int2,LPHTMLELEMENT:Byte Ptr)
	Method get_parentWindow(LPHTMLWINDOW2:Byte Ptr)
	Method get_styleSheets(LPHTMLSTYLESHEETSCOLLECTION:Byte Ptr)
	Method put_onbeforeupdate(_variant:Long)
	Method get_onbeforeupdate(this:Byte Ptr)
	Method put_onerrorupdate(_variant:Long)
	Method get_onerrorupdate(this:Byte Ptr)
	Method toString(_pbstr:Short Ptr Ptr)
	Method createStyleSheet(_bstr:Short Ptr,_int,LPHTMLSTYLESHEET:Byte Ptr)
End Type


End Extern 

Const IUnknown_UUID$="{00000000-0000-0000-C000-000000000046}"
Const IDispatch_UUID$="{00020400-0000-0000-C000-000000000046}"
Const IWebBrowser_UUID$="{EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}"
Const IWebBrowserApp_UUID$="{0002DF05-0000-0000-C000-000000000046}"
Const IWebBrowser2_UUID$="{D30C1661-CDAF-11d0-8A3E-00C04FC9E26E}"
Const IHTMLDocument2_UUID$="{332c4425-26cb-11d0-b483-00c04fd90119}"
Const IHTMLWindow2_UUID$="{332c4427-26cb-11d0-b483-00c04fd90119}"

Const CLSCTX_INPROC_SERVER        =$1 
Const CLSCTX_INPROC_HANDLER       =$2 
Const CLSCTX_LOCAL_SERVER         =$4 
Const CLSCTX_INPROC_SERVER16      =$8
Const CLSCTX_REMOTE_SERVER        =$10
Const CLSCTX_INPROC_HANDLER16     =$20
Const CLSCTX_RESERVED1            =$40
Const CLSCTX_RESERVED2            =$80
Const CLSCTX_RESERVED3            =$100
Const CLSCTX_RESERVED4            =$200
Const CLSCTX_NO_CODE_DOWNLOAD     =$400
Const CLSCTX_RESERVED5            =$800
Const CLSCTX_NO_CUSTOM_MARSHAL    =$1000
Const CLSCTX_ENABLE_CODE_DOWNLOAD =$2000
Const CLSCTX_NO_FAILURE_LOG       =$4000
Const CLSCTX_DISABLE_AAA          =$8000
Const CLSCTX_ENABLE_AAA           =$10000
Const CLSCTX_FROM_DEFAULT_CONTEXT =$20000

Const CLSCTX_ALL=(CLSCTX_INPROC_SERVER|CLSCTX_INPROC_HANDLER|CLSCTX_LOCAL_SERVER)
Const CLSCTX_INPROC=(CLSCTX_INPROC_SERVER|CLSCTX_INPROC_HANDLER)
Const CLSCTX_SERVER=(CLSCTX_INPROC_SERVER|CLSCTX_LOCAL_SERVER|CLSCTX_REMOTE_SERVER)

Type GUID
	Field	data1
	Field	data2:Short,data3:Short
	Field	data41:Byte
	Field	data42:Byte
	Field	data43:Byte
	Field	data44:Byte
	Field	data45:Byte
	Field	data46:Byte
	Field	data47:Byte
	Field	data48:Byte
End Type

Type VARIANT
	Field	vt:Short
	Field	res1:Short
	Field	res2:Short
	Field	res3:Short
	Field	data:Long
End Type

Const VT_EMPTY=0

Const READYSTATE_UNINITIALIZED=1
Const READYSTATE_LOADING=0
Const READYSTATE_LOADED=2
Const READYSTATE_INTERACTIVE=3
Const READYSTATE_COMPLETE=4

Const OLECMDEXECOPT_DODEFAULT=0
Const OLECMDEXECOPT_PROMPTUSER=1
Const OLECMDEXECOPT_DONTPROMPTUSER=2
Const OLECMDEXECOPT_SHOWHELP=3

Const OLECMDF_SUPPORTED=1
Const OLECMDF_ENABLED=2
Const OLECMDF_LATCHED=4
Const OLECMDF_NINCHED=8
Const OLECMDF_INVISIBLE=$10
Const OLECMDF_DEFHIDEONCTXTMENU=$20

Const OLECMDID_OPEN=1
Const OLECMDID_NEW=2
Const OLECMDID_SAVE=3
Const OLECMDID_SAVEAS=4
Const OLECMDID_SAVECOPYAS=5
Const OLECMDID_PRINT=6
Const OLECMDID_PRINTPREVIEW=7
Const OLECMDID_PAGESETUP=8
Const OLECMDID_SPELL=9
Const OLECMDID_PROPERTIES=10
Const OLECMDID_CUT=11
Const OLECMDID_COPY=12
Const OLECMDID_PASTE=13
Const OLECMDID_PASTESPECIAL=14
Const OLECMDID_UNDO=15
Const OLECMDID_REDO=16
Const OLECMDID_SELECTALL=17
Const OLECMDID_CLEARSELECTION=18
Const OLECMDID_ZOOM=19
Const OLECMDID_GETZOOMRANGE=20
Const OLECMDID_UPDATECOMMANDS=21
Const OLECMDID_REFRESH=22
Const OLECMDID_STOP=23
Const OLECMDID_HIDETOOLBARS=24
Const OLECMDID_SETPROGRESSMAX=25
Const OLECMDID_SETPROGRESSPOS=26
Const OLECMDID_SETPROGRESSTEXT=27
Const OLECMDID_SETTITLE=28
Const OLECMDID_SETDOWNLOADSTATE=29
Const OLECMDID_STOPDOWNLOAD=30
Const OLECMDID_ONTOOLBARACTIVATED=31
Const OLECMDID_FIND=32
Const OLECMDID_DELETE=33
Const OLECMDID_HTTPEQUIV=34
Const OLECMDID_HTTPEQUIV_DONE=35
Const OLECMDID_ENABLE_INTERACTION=36
Const OLECMDID_ONUNLOAD=37
Const OLECMDID_PROPERTYBAG2=38
Const OLECMDID_PREREFRESH=39
Const OLECMDID_SHOWSCRIPTERROR=40
Const OLECMDID_SHOWMESSAGE=41
Const OLECMDID_SHOWFIND=42
Const OLECMDID_SHOWPAGESETUP=43
Const OLECMDID_SHOWPRINT=44
Const OLECMDID_CLOSE=45
Const OLECMDID_ALLOWUILESSSAVEAS=46
Const OLECMDID_DONTDOWNLOADCSS=47
Const OLECMDID_UPDATEPAGESTATUS=48
Const OLECMDID_PRINT2=49
Const OLECMDID_PRINTPREVIEW2=50
Const OLECMDID_SETPRINTTEMPLATE=51
Const OLECMDID_GETPRINTTEMPLATE=52
Const OLECMDID_PAGEACTIONBLOCKED=55
Const OLECMDID_PAGEACTIONUIQUERY=56
Const OLECMDID_FOCUSVIEWCONTROLS=57
Const OLECMDID_FOCUSVIEWCONTROLSQUERY=58
Const OLECMDID_SHOWPAGEACTIONMENU=59

