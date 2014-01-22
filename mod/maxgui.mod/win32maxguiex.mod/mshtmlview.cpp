
#include <w32api.h>
#include <windows.h>
#include <mshtml.h>
#include <exdisp.h>
#include <mshtmhst.h>

#include "mshtmlview.h"

// fix emit!!!

// blitzmax / mingw compilations stuff...

#include <brl.mod/blitz.mod/blitz.h>
#include <maxgui.mod/maxgui.mod/maxgui.h>

#define NOCONTEXTMENU 1
#define NONAVIGATE 2

BBString *bbStringFromVariant2(VARIANT *v){
	unsigned short *w;
	int n;
	if (v->vt!=VT_BSTR)  return 0;
	w=(unsigned short*)v->bstrVal;
	n=0;
	while (w[n++]) {}
	return bbStringFromShorts(w,n-1);
}


#define OLERENDER_DRAW 1

#define TODO {printf("htmlview TODO error line:%d\n",__LINE__);fflush(stdout);brl_blitz_NullObjectError();return 0;}

typedef IDispatch * DWebBrowserEventsPtr;
const IID IID_IDocHostUIHandler2={0xbd3f23c0,0xd43e,0x11cf,{0x89,0x3b,0x00,0xaa,0x00,0xbd,0xce,0x1a}};
const IID IID_DWebBrowserEvents2={0x34A715A0,0x6587,0x11D0,{0x92,0x4A,0x00,0x20,0xAF,0xC7,0xAC,0x4D}};
//const IID IID_IHTMLDocument={0x626FC520,0xA41E,0x11cf,{0xA7,0x31,0x00,0xa0,0xc9,0x08,0x26,0x37}};

#define DISPID_BEFORENAVIGATE2      250   // hyperlink clicked on
#define DISPID_NEWWINDOW2           251
#define DISPID_NAVIGATECOMPLETE2    252   // UIActivate new document
#define DISPID_DOCUMENTCOMPLETE	    259

//#ifdef MINGW322

typedef interface IHTMLFiltersCollection *LPHTMLFILTERSCOLLECTION;
typedef interface IHTMLLinkElement *LPHTMLLINKELEMENT;
typedef interface IHTMLImgElement *LPHTMLIMGELEMENT;
typedef interface IHTMLImageElementFactory *LPHTMLIMAGEELEMENTFACTORY;
typedef interface IHTMLEventObj *LPHTMLEVENTOBJ;
typedef interface IHTMLScreen *LPHTMLSCREEN;
typedef interface IHTMLOptionElementFactory *LPHTMLOPTIONELEMENTFACTORY;
typedef interface IOmHistory *LPOMHISTORY;
typedef interface IOmNavigator *LPOMNAVIGATOR;
 
#if __W32API_MAJOR_VERSION<3
 
EXTERN_C const IID IID_IHTMLFramesCollection2;
EXTERN_C const IID IID_IHTMLWindow2;

#undef INTERFACE
#define INTERFACE IHTMLFramesCollection2
DECLARE_INTERFACE_(IHTMLFramesCollection2,IDispatch)
{
	STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
	STDMETHOD_(ULONG,AddRef)(THIS) PURE;
	STDMETHOD_(ULONG,Release)(THIS) PURE;
	STDMETHOD(GetTypeInfoCount)(THIS_ UINT*) PURE;
	STDMETHOD(GetTypeInfo)(THIS_ UINT,LCID,LPTYPEINFO*) PURE;
	STDMETHOD(GetIDsOfNames)(THIS_ REFIID,LPOLESTR*,UINT,LCID,DISPID*) PURE;
	STDMETHOD(Invoke)(THIS_ DISPID,REFIID,LCID,WORD,DISPPARAMS*,VARIANT*,EXCEPINFO*,UINT*) PURE;
    STDMETHOD(item)(THIS_ VARIANT*,VARIANT*) PURE;
    STDMETHOD(get_length)(THIS_ long*) PURE;
};

#undef INTERFACE
#define INTERFACE IHTMLWindow2
DECLARE_INTERFACE_(IHTMLWindow2,IHTMLFramesCollection2)
{
	STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
	STDMETHOD_(ULONG,AddRef)(THIS) PURE;
	STDMETHOD_(ULONG,Release)(THIS) PURE;
	STDMETHOD(GetTypeInfoCount)(THIS_ UINT*) PURE;
	STDMETHOD(GetTypeInfo)(THIS_ UINT,LCID,LPTYPEINFO*) PURE;
	STDMETHOD(GetIDsOfNames)(THIS_ REFIID,LPOLESTR*,UINT,LCID,DISPID*) PURE;
	STDMETHOD(Invoke)(THIS_ DISPID,REFIID,LCID,WORD,DISPPARAMS*,VARIANT*,EXCEPINFO*,UINT*) PURE;
    STDMETHOD(item)(THIS_ VARIANT*,VARIANT*) PURE;
    STDMETHOD(get_length)(THIS_ long*) PURE;

    STDMETHOD(get_frames)(THIS_ IHTMLFramesCollection2**) PURE;
    STDMETHOD(put_defaultStatus)(THIS_ BSTR) PURE;
    STDMETHOD(get_defaultStatus)(THIS_ BSTR*) PURE;
    STDMETHOD(put_status)(THIS_ BSTR) PURE;
    STDMETHOD(get_status)(THIS_ BSTR*) PURE;
    STDMETHOD(setTimeout)(THIS_ BSTR,long,VARIANT*,long*) PURE;
    STDMETHOD(clearTimeout)(THIS_ long) PURE;
    STDMETHOD(alert)(THIS_ BSTR) PURE;
    STDMETHOD(confirm)(THIS_ BSTR,VARIANT_BOOL*) PURE;
    STDMETHOD(prompt)(THIS_ BSTR,BSTR,VARIANT*) PURE;
    STDMETHOD(get_Image)(THIS_ LPHTMLIMAGEELEMENTFACTORY*) PURE;
    STDMETHOD(get_location)(THIS_ LPHTMLLOCATION*) PURE;
    STDMETHOD(get_history)(THIS_ LPOMHISTORY*) PURE;
    STDMETHOD(close)(THIS) PURE;
    STDMETHOD(put_opener)(THIS_ VARIANT) PURE;
    STDMETHOD(get_opener)(THIS_ VARIANT*) PURE;
    STDMETHOD(get_navigator)(THIS_ LPOMNAVIGATOR*) PURE;
    STDMETHOD(put_name)(THIS_ BSTR) PURE;
    STDMETHOD(get_name)(THIS_ BSTR*) PURE;
    STDMETHOD(get_parent)(THIS_ LPHTMLWINDOW2*) PURE;
    STDMETHOD(open)(THIS_ BSTR,BSTR,BSTR,VARIANT_BOOL,LPHTMLWINDOW2*) PURE;
    STDMETHOD(get_self)(THIS_ LPHTMLWINDOW2*) PURE;
    STDMETHOD(get_top)(THIS_ LPHTMLWINDOW2*) PURE;
    STDMETHOD(get_window)(THIS_ LPHTMLWINDOW2*) PURE;
    STDMETHOD(navigate)(THIS_ BSTR) PURE;
    STDMETHOD(put_onfocus)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onfocus)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onblur)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onblur)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onload)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onload)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onbeforeunload)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onbeforeunload)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onunload)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onunload)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onhelp)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onhelp)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onerror)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onerror)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onresize)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onresize)(THIS_ VARIANT*) PURE;
    STDMETHOD(put_onscroll)(THIS_ VARIANT) PURE;
    STDMETHOD(get_onscroll)(THIS_ VARIANT*) PURE;
    STDMETHOD(get_document)(THIS_ IHTMLDocument2**) PURE;
    STDMETHOD(get_event)(THIS_ LPHTMLEVENTOBJ*) PURE;
    STDMETHOD(get__newEnum)(THIS_ IUnknown**) PURE;
    STDMETHOD(showModalDialog)(THIS_ BSTR,VARIANT*,VARIANT*,VARIANT*) PURE;
    STDMETHOD(showHelp)(THIS_ BSTR,VARIANT,BSTR) PURE;
    STDMETHOD(get_screen)(THIS_ LPHTMLSCREEN*) PURE;
    STDMETHOD(get_Option)(THIS_ LPHTMLOPTIONELEMENTFACTORY*) PURE;
    STDMETHOD(focus)(THIS) PURE;
    STDMETHOD(get_closed)(THIS_ VARIANT_BOOL*) PURE;
    STDMETHOD(blur)(THIS) PURE;
    STDMETHOD(scroll)(THIS_ long,long) PURE;
    STDMETHOD(get_clientInformation)(THIS_ LPOMNAVIGATOR*) PURE;
    STDMETHOD(setInterval)(THIS_ BSTR,long,VARIANT*,long*) PURE;
    STDMETHOD(clearInterval)(THIS_ long) PURE;
    STDMETHOD(put_offscreenBuffering)(THIS_ VARIANT) PURE;
    STDMETHOD(get_offscreenBuffering)(THIS_ VARIANT*) PURE;
    STDMETHOD(execScript)(THIS_ BSTR,BSTR,VARIANT*) PURE;
    STDMETHOD(toString)(THIS_ BSTR*) PURE;
    STDMETHOD(scrollBy)(THIS_ long,long) PURE;
    STDMETHOD(scrollTo)(THIS_ long,long) PURE;
    STDMETHOD(moveTo)(THIS_ long,long) PURE;
    STDMETHOD(moveBy)(THIS_ long,long) PURE;
    STDMETHOD(resizeTo)(THIS_ long,long) PURE;
    STDMETHOD(resizeBy)(THIS_ long,long) PURE;
    STDMETHOD(get_external)(THIS_ IDispatch**) PURE;
};

#endif

//#endif	//additional mingw 3.2 includes


struct CNullStorage2 : public IStorage{
	// IUnknown
	STDMETHODIMP QueryInterface(REFIID riid,void ** ppvObject);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);
	// IStorage
	STDMETHODIMP CreateStream(const WCHAR * pwcsName,DWORD grfMode,DWORD reserved1,DWORD reserved2,IStream ** ppstm);
	STDMETHODIMP OpenStream(const WCHAR * pwcsName,void * reserved1,DWORD grfMode,DWORD reserved2,IStream ** ppstm);
	STDMETHODIMP CreateStorage(const WCHAR * pwcsName,DWORD grfMode,DWORD reserved1,DWORD reserved2,IStorage ** ppstg);
	STDMETHODIMP OpenStorage(const WCHAR * pwcsName,IStorage * pstgPriority,DWORD grfMode,SNB snbExclude,DWORD reserved,IStorage ** ppstg);
	STDMETHODIMP CopyTo(DWORD ciidExclude,IID const * rgiidExclude,SNB snbExclude,IStorage * pstgDest);
	STDMETHODIMP MoveElementTo(const OLECHAR * pwcsName,IStorage * pstgDest,const OLECHAR* pwcsNewName,DWORD grfFlags);
	STDMETHODIMP Commit(DWORD grfCommitFlags);
	STDMETHODIMP Revert(void);
	STDMETHODIMP EnumElements(DWORD reserved1,void * reserved2,DWORD reserved3,IEnumSTATSTG ** ppenum);
	STDMETHODIMP DestroyElement(const OLECHAR * pwcsName);
	STDMETHODIMP RenameElement(const WCHAR * pwcsOldName,const WCHAR * pwcsNewName);
	STDMETHODIMP SetElementTimes(const WCHAR * pwcsName,FILETIME const * pctime,FILETIME const * patime,FILETIME const * pmtime);
	STDMETHODIMP SetClass(REFCLSID clsid);
	STDMETHODIMP SetStateBits(DWORD grfStateBits,DWORD grfMask);
	STDMETHODIMP Stat(STATSTG * pstatstg,DWORD grfStatFlag);
};

struct CMyFrame2 : public IOleInPlaceFrame{

	// IUnknown
	STDMETHODIMP QueryInterface(REFIID riid,void ** ppvObject);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);
	// IOleWindow
	STDMETHODIMP GetWindow(HWND FAR* lphwnd);
	STDMETHODIMP ContextSensitiveHelp(BOOL fEnterMode);
	// IOleInPlaceUIWindow
	STDMETHODIMP GetBorder(LPRECT lprectBorder);
	STDMETHODIMP RequestBorderSpace(LPCBORDERWIDTHS pborderwidths);
	STDMETHODIMP SetBorderSpace(LPCBORDERWIDTHS pborderwidths);
	STDMETHODIMP SetActiveObject(IOleInPlaceActiveObject *pActiveObject,LPCOLESTR pszObjName);
	// IOleInPlaceFrame
	STDMETHODIMP InsertMenus(HMENU hmenuShared,LPOLEMENUGROUPWIDTHS lpMenuWidths);
	STDMETHODIMP SetMenu(HMENU hmenuShared,HOLEMENU holemenu,HWND hwndActiveObject);
	STDMETHODIMP RemoveMenus(HMENU hmenuShared);
	STDMETHODIMP SetStatusText(LPCOLESTR pszStatusText);
	STDMETHODIMP EnableModeless(BOOL fEnable);
	STDMETHODIMP TranslateAccelerator(  LPMSG lpmsg,WORD wID);

	struct HTMLView *rep;
};

struct CMySite2 : public IOleClientSite,public IOleInPlaceSite,public IDocHostUIHandler
{
	// IUnknown
	STDMETHODIMP QueryInterface(REFIID riid,void ** ppvObject);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);
	// IOleClientSite
	STDMETHODIMP SaveObject();
	STDMETHODIMP GetMoniker(DWORD dwAssign,DWORD dwWhichMoniker,IMoniker ** ppmk);
	STDMETHODIMP GetContainer(LPOLECONTAINER FAR* ppContainer);
	STDMETHODIMP ShowObject();
	STDMETHODIMP OnShowWindow(BOOL fShow);
	STDMETHODIMP RequestNewObjectLayout();
	// IOleWindow
	STDMETHODIMP GetWindow(HWND FAR* lphwnd);
	STDMETHODIMP ContextSensitiveHelp(BOOL fEnterMode);
	// IOleInPlaceSite methods
	STDMETHODIMP CanInPlaceActivate();
	STDMETHODIMP OnInPlaceActivate();
	STDMETHODIMP OnUIActivate();
	STDMETHODIMP GetWindowContext(LPOLEINPLACEFRAME FAR* lplpFrame,LPOLEINPLACEUIWINDOW FAR* lplpDoc,LPRECT lprcPosRect,LPRECT lprcClipRect,LPOLEINPLACEFRAMEINFO lpFrameInfo);
	STDMETHODIMP Scroll(SIZE scrollExtent);
	STDMETHODIMP OnUIDeactivate(BOOL fUndoable);
	STDMETHODIMP OnInPlaceDeactivate();
	STDMETHODIMP DiscardUndoState();
	STDMETHODIMP DeactivateAndUndo();
	STDMETHODIMP OnPosRectChange(LPCRECT lprcPosRect);
	// idochost methods
	STDMETHODIMP ShowContextMenu( DWORD dwID,POINT __RPC_FAR *ppt,IUnknown __RPC_FAR *pcmdtReserved,IDispatch __RPC_FAR *pdispReserved) ;
	STDMETHODIMP GetHostInfo( DOCHOSTUIINFO __RPC_FAR *pInfo);
	STDMETHODIMP ShowUI( DWORD dwID,IOleInPlaceActiveObject __RPC_FAR *pActiveObject,IOleCommandTarget __RPC_FAR *pCommandTarget,IOleInPlaceFrame __RPC_FAR *pFrame,IOleInPlaceUIWindow __RPC_FAR *pDoc);
	STDMETHODIMP HideUI( void);
	STDMETHODIMP UpdateUI( void);
	STDMETHODIMP OnDocWindowActivate(  BOOL fActivate);
	STDMETHODIMP OnFrameWindowActivate(  BOOL fActivate);
	STDMETHODIMP ResizeBorder( LPCRECT prcBorder,IOleInPlaceUIWindow __RPC_FAR *pUIWindow,BOOL fRameWindow);
	STDMETHODIMP TranslateAccelerator( LPMSG lpMsg,const GUID __RPC_FAR *pguidCmdGroup,DWORD nCmdID);
	STDMETHODIMP GetOptionKeyPath( LPOLESTR __RPC_FAR *pchKey,DWORD dw);
	STDMETHODIMP GetDropTarget( IDropTarget __RPC_FAR *pDropTarget,IDropTarget __RPC_FAR *__RPC_FAR *ppDropTarget);
	STDMETHODIMP GetExternal(  IDispatch __RPC_FAR *__RPC_FAR *ppDispatch);
	STDMETHODIMP TranslateUrl(DWORD dwTranslate,OLECHAR __RPC_FAR *pchURLIn,OLECHAR __RPC_FAR *__RPC_FAR *ppchURLOut);
	STDMETHODIMP EnableModeless(  BOOL fEnable);
	STDMETHODIMP FilterDataObject( IDataObject __RPC_FAR *pDO,IDataObject __RPC_FAR *__RPC_FAR *ppDORet);
	
	struct HTMLView *rep;
};

struct CMyContainer : public IOleContainer{
	// IUnknown
	STDMETHODIMP QueryInterface(REFIID riid,void ** ppvObject);
	STDMETHODIMP_(ULONG) AddRef(void);
	STDMETHODIMP_(ULONG) Release(void);
	// IParseDisplayName
	STDMETHODIMP ParseDisplayName(IBindCtx *pbc,LPOLESTR pszDisplayName,ULONG *pchEaten,IMoniker **ppmkOut);
	// IOleContainer
	STDMETHODIMP EnumObjects(DWORD grfFlags,IEnumUnknown **ppenum);
	STDMETHODIMP LockContainer(BOOL fLock);
};

struct _bstr_t
{
	struct Data_t
	{
        wchar_t*        m_wstr;
        mutable char*   m_str;
        unsigned long   m_RefCount;
		Data_t(BSTR bstr, bool fCopy) : m_str(NULL), m_RefCount(1)			//throw(_com_error)
		{
			if (fCopy && bstr != NULL)
			{
				m_wstr = ::SysAllocStringByteLen(reinterpret_cast<char*>(bstr),::SysStringByteLen(bstr));
//				if (m_wstr == NULL) {_com_issue_error(E_OUTOFMEMORY);}
			}
			else
			{
				m_wstr = bstr;
			}
		}
		Data_t(const wchar_t* s):m_str(NULL), m_RefCount(1)
		{
			m_wstr = ::SysAllocString(s);
//			if (m_wstr == NULL && s != NULL) {_com_issue_error(E_OUTOFMEMORY);}
		}
		unsigned long AddRef() throw()
		{
			InterlockedIncrement(reinterpret_cast<long*>(&m_RefCount));
			return m_RefCount;
		}
		unsigned long Release() throw()
		{
			if (!InterlockedDecrement(reinterpret_cast<long*>(&m_RefCount))) {delete this;return 0;}
			return m_RefCount;
		}
		unsigned long RefCount() const throw()
		{
			return m_RefCount;
		}
		wchar_t* GetWString()
		{
			return m_wstr;
		}
	};
	Data_t* m_Data;

	_bstr_t(BSTR bstr, bool fCopy):m_Data(new Data_t(bstr, fCopy))
	{
//		if (m_Data == NULL) {_com_issue_error(E_OUTOFMEMORY);}
	}

	_bstr_t(const wchar_t* s):m_Data(new Data_t(s))
	{
//		if (m_Data == NULL) {_com_issue_error(E_OUTOFMEMORY);}
	}

	BBString	*bbString()
	{
		unsigned short *w;
		int		n;
		w=(unsigned short*)m_Data->m_wstr;n=0;while (w[n++]) {}
		return bbStringFromShorts(w,n-1);
	}
};

struct DWebBrowserEventsImpl2 : public DWebBrowserEvents2	//DWebBrowserEvents
{
// IUnknown methods
    STDMETHOD(QueryInterface)(REFIID riid, LPVOID* ppv);
    STDMETHOD_(ULONG, AddRef)();
    STDMETHOD_(ULONG, Release)();
// IDispatch methods
	STDMETHOD(GetTypeInfoCount)(UINT* pctinfo);
	STDMETHOD(GetTypeInfo)(UINT iTInfo,LCID lcid,ITypeInfo** ppTInfo);
	STDMETHOD(GetIDsOfNames)(REFIID riid,LPOLESTR* rgszNames,UINT cNames,LCID lcid,DISPID* rgDispId);	
	STDMETHOD(Invoke)(DISPID dispIdMember,
            REFIID riid,
            LCID lcid,
            WORD wFlags,
            DISPPARAMS __RPC_FAR *pDispParams,
            VARIANT __RPC_FAR *pVarResult,
            EXCEPINFO __RPC_FAR *pExcepInfo,
            UINT __RPC_FAR *puArgErr);
// events
    HRESULT BeforeNavigate (
        _bstr_t URL,
        long Flags,
        _bstr_t TargetFrameName,
        VARIANT * PostData,
        _bstr_t Headers,
		VARIANT_BOOL * Cancel );

	HRESULT NavigateComplete ( _bstr_t URL ) {return S_OK;}
    HRESULT StatusTextChange ( _bstr_t Text );
    void ProgressChange (
        long Progress,
        long ProgressMax );
    void DownloadComplete();
    void CommandStateChange (
        long Command,
        VARIANT_BOOL Enable );
    void DownloadBegin ();
    HRESULT NewWindow (
        _bstr_t URL,
        long Flags,
        _bstr_t TargetFrameName,
        VARIANT * PostData,
        _bstr_t Headers,
        VARIANT_BOOL * Processed );
    HRESULT TitleChange ( _bstr_t Text );
    HRESULT FrameBeforeNavigate (
        _bstr_t URL,
        long Flags,
        _bstr_t TargetFrameName,
        VARIANT * PostData,
        _bstr_t Headers,
		VARIANT_BOOL * Cancel );
    HRESULT FrameNavigateComplete (
        _bstr_t URL );
    HRESULT FrameNewWindow (
        _bstr_t URL,
        long Flags,
        _bstr_t TargetFrameName,
        VARIANT * PostData,
        _bstr_t Headers,
        VARIANT_BOOL * Processed );
    HRESULT Quit (
        VARIANT_BOOL * Cancel );
    HRESULT WindowMove ( );
    HRESULT WindowResize ( );
    HRESULT WindowActivate ( );
    HRESULT PropertyChange (
        _bstr_t Property );

	void StatusTextChange(OLECHAR*) {}
	void TitleChange(OLECHAR*) {}
	void PropertyChange(OLECHAR*) {}
	void BeforeNavigate2(IDispatch*, VARIANT*, VARIANT*, VARIANT*, VARIANT*, VARIANT*, VARIANT_BOOL*);
	void NewWindow2(IDispatch**, VARIANT_BOOL*);	// {}
	void NavigateComplete(IDispatch*, VARIANT*) ;
	void DocumentComplete(IDispatch*, VARIANT*) ;//{}
	void OnQuit() {}
	void OnVisible(short int) {}
	void OnToolBar(short int) {}
	void OnMenuBar(short int) {}
	void OnStatusBar(short int) {}
	void OnFullScreen(short int) {}
	void OnTheaterMode(short int) {}
	void WindowSetResizable(short int) {}
	void WindowSetLeft(long int) {}
	void WindowSetTop(long int) {}
	void WindowSetWidth(long int) {}
	void WindowSetHeight(long int) {}
	void WindowClosing(short int, VARIANT_BOOL*) {}
	void ClientToHostWindow(long int*, long int*) {}
	void SetSecureLockIcon(long int) {}
	void FileDownload(VARIANT_BOOL*) {}

	HTMLView *rep;
};



struct HTMLView{

	HWND hwnd;
	BBObject *owner;

	CMySite2 site;
	CMyFrame2 frame;
	CNullStorage2 storage;
	DWebBrowserEventsImpl2 eventsink;

	IOleObject *oleObject;
	IWebBrowser2* iBrowser;
	IOleInPlaceObject *inPlaceObject;
	IConnectionPointContainer *iConnection;
	IConnectionPoint *iConnectionPoint;
	IOleCommandTarget *iTarget;	
	
	BSTR current;
	
	DWORD	dwCookie;

	int		viewstyle;
	int		navcount;	//used with style&NOUSERNAV to route user navigation to event queue
	int		loading;		//state returned by getstatus()
	
	HTMLView( BBObject *gadget, wchar_t *wndclass,HWND parent,int style ){

		owner=gadget;
		current=0;

		viewstyle=style;
		navcount=0;
		loading=0;

		int xstyle=WS_EX_CONTROLPARENT;
		int wstyle=WS_CHILD|WS_TABSTOP|WS_CLIPSIBLINGS|WS_VISIBLE;
	
		hwnd=CreateWindowExW( xstyle,wndclass,0,wstyle,0,0,200,200,parent,0,GetModuleHandle(0),0 );
		
		site.rep=this;
		eventsink.rep=this;
		frame.rep=this;

		int res=OleCreate( CLSID_WebBrowser,IID_IOleObject,OLERENDER_DRAW,0,&site,&storage,(void**)&oleObject );

		OleSetContainedObject( oleObject,TRUE);
		
		oleObject->SetHostNames(L"Web Host",L"Web View");
		oleObject->QueryInterface(IID_IWebBrowser2,(void**)&iBrowser);
		oleObject->QueryInterface(IID_IOleInPlaceObject,(void**)&inPlaceObject );
		oleObject->QueryInterface(IID_IConnectionPointContainer,(void**)&iConnection);
		oleObject->QueryInterface(IID_IOleCommandTarget,(void**)&iTarget );

		iConnection->FindConnectionPoint(DIID_DWebBrowserEvents2, &iConnectionPoint);
		iConnectionPoint->Advise((LPUNKNOWN)&eventsink, &dwCookie);

		RECT rect;
		::GetClientRect( hwnd,&rect );
		oleObject->DoVerb(OLEIVERB_SHOW,NULL,&site,-1,hwnd,&rect);

		oleObject->DoVerb(OLEIVERB_UIACTIVATE,NULL,&site,0,hwnd,&rect);	//INPLACE
		
		go( L"about:blank" );
	}

	~HTMLView(){
		if (current) SysFreeString(current);
		inPlaceObject->Release();
		iBrowser->Release();
		oleObject->Close(OLECLOSE_NOSAVE);
		oleObject->Release();
	}

	void setcurrenturl(VARIANT *url)
	{
		if (current) SysFreeString(current);
		current=0;
		if (url->vt==VT_BSTR){
			current=SysAllocString(url->bstrVal);			
		}
	}
	
	void setshape(int x,int y,int w,int h){
		RECT rect;
		rect.left=0;rect.right=w;rect.top=0;rect.bottom=h;
		MoveWindow(hwnd,x,y,w,h,TRUE);
		inPlaceObject->SetObjectRects( &rect,&rect );	
	}

	void go( const wchar_t *url ){
		BSTR bstr=SysAllocString(url);
		VARIANT flags={VT_INT};
		navcount=1;
		loading=1;
		iBrowser->Navigate( bstr,&flags,0,0,0 );
		SysFreeString(bstr);
	}


#define IDM_COPY                    15
#define IDM_CUT                     16
#define IDM_PASTE                   26

	int activate(int cmd){
		
		OLECMDF tmpOutput;
		
		switch (cmd)
		{
		case ACTIVATE_CUT:
			iBrowser->QueryStatusWB(OLECMDID_CUT,&tmpOutput);
			if(tmpOutput&OLECMDF_ENABLED) return iBrowser->ExecWB(OLECMDID_CUT,OLECMDEXECOPT_DONTPROMPTUSER,0,0);
			break;
		case ACTIVATE_COPY:
			iBrowser->QueryStatusWB(OLECMDID_COPY,&tmpOutput);
			if(tmpOutput&OLECMDF_ENABLED) return iBrowser->ExecWB(OLECMDID_COPY,OLECMDEXECOPT_DONTPROMPTUSER,0,0);
			break;
		case ACTIVATE_PASTE:
			iBrowser->QueryStatusWB(OLECMDID_PASTE,&tmpOutput);
			if(tmpOutput&OLECMDF_ENABLED) return iBrowser->ExecWB(OLECMDID_PASTE,OLECMDEXECOPT_DONTPROMPTUSER,0,0);
			break;
		case ACTIVATE_PRINT:
			return iBrowser->ExecWB(OLECMDID_PRINT,OLECMDEXECOPT_PROMPTUSER,0,0);
		case ACTIVATE_BACK:
			navcount=1;
			iBrowser->GoBack();
			return 0;
		case ACTIVATE_FORWARD:
			navcount=1;
			iBrowser->GoForward();
			return 0;
		}
		return 0;
	}

	void run( const wchar_t *script )
	{
		IDispatch		*disp;
		BSTR			bstr;
		IHTMLDocument2	*doc;
		IHTMLWindow2	*win;
		HRESULT			res;
		VARIANT			result;
		
//		bstr=SysAllocStringLen((OLECHAR*)script->buf,scripturl->length);
		bstr=SysAllocString(script);//(OLECHAR*)script->buf,scripturl->length);
	
		res=iBrowser->get_Document(&disp);
		if (res==S_OK)
		{
			res=disp->QueryInterface(IID_IHTMLDocument2,(void**)&doc);
			res=doc->get_parentWindow(&win);
			result.vt=VT_EMPTY;
			res=win->execScript(bstr,0,&result);
		}
		SysFreeString(bstr);
	}
	
	int status(){
		READYSTATE	state;
		iBrowser->get_ReadyState(&state);
		return (state!=READYSTATE_COMPLETE);
	}
};
	



STDMETHODIMP CNullStorage2::QueryInterface(REFIID riid,void ** ppvObject){
	TODO
}
STDMETHODIMP_(ULONG) CNullStorage2::AddRef(void){
	return 1;
}
STDMETHODIMP_(ULONG) CNullStorage2::Release(void){
	return 1;
}
STDMETHODIMP CNullStorage2::CreateStream(const WCHAR * pwcsName,DWORD grfMode,DWORD reserved1,DWORD reserved2,IStream ** ppstm){
	TODO
}
STDMETHODIMP CNullStorage2::OpenStream(const WCHAR * pwcsName,void * reserved1,DWORD grfMode,DWORD reserved2,IStream ** ppstm){
	TODO
}
STDMETHODIMP CNullStorage2::CreateStorage(const WCHAR * pwcsName,DWORD grfMode,DWORD reserved1,DWORD reserved2,IStorage ** ppstg){
	TODO
}
STDMETHODIMP CNullStorage2::OpenStorage(const WCHAR * pwcsName,IStorage * pstgPriority,DWORD grfMode,SNB snbExclude,DWORD reserved,IStorage ** ppstg){
	TODO
}
STDMETHODIMP CNullStorage2::CopyTo(DWORD ciidExclude,IID const * rgiidExclude,SNB snbExclude,IStorage * pstgDest){
	TODO
}
STDMETHODIMP CNullStorage2::MoveElementTo(const OLECHAR * pwcsName,IStorage * pstgDest,const OLECHAR* pwcsNewName,DWORD grfFlags){
	TODO
}
STDMETHODIMP CNullStorage2::Commit(DWORD grfCommitFlags){
	TODO
}
STDMETHODIMP CNullStorage2::Revert(void){
	TODO
}
STDMETHODIMP CNullStorage2::EnumElements(DWORD reserved1,void * reserved2,DWORD reserved3,IEnumSTATSTG ** ppenum){
	TODO
}
STDMETHODIMP CNullStorage2::DestroyElement(const OLECHAR * pwcsName){
	TODO
}
STDMETHODIMP CNullStorage2::RenameElement(const WCHAR * pwcsOldName,const WCHAR * pwcsNewName){
	TODO
}
STDMETHODIMP CNullStorage2::SetElementTimes(const WCHAR * pwcsName,FILETIME const * pctime,FILETIME const * patime,FILETIME const * pmtime){
	TODO
}
STDMETHODIMP CNullStorage2::SetClass(REFCLSID clsid){
	return S_OK;
}
STDMETHODIMP CNullStorage2::SetStateBits(DWORD grfStateBits,DWORD grfMask){
	TODO
}
STDMETHODIMP CNullStorage2::Stat(STATSTG * pstatstg,DWORD grfStatFlag){
	TODO
}

STDMETHODIMP CMySite2::QueryInterface(REFIID riid,void ** ppvObject){
	if( riid == IID_IUnknown || riid == IID_IOleClientSite ){
		*ppvObject = (IOleClientSite*)this;
	}else if(riid == IID_IOleInPlaceSite){
		*ppvObject = (IOleInPlaceSite*)this;
	}else if(riid == IID_IDocHostUIHandler2){
		*ppvObject = (IDocHostUIHandler*)this;
	}else{
		*ppvObject = NULL;
		return E_NOINTERFACE;
	}
	return S_OK;
}
STDMETHODIMP_(ULONG) CMySite2::AddRef(void){
	return 1;
}
STDMETHODIMP_(ULONG) CMySite2::Release(void){
	return 1;
}
STDMETHODIMP CMySite2::SaveObject(){
	TODO
}
STDMETHODIMP CMySite2::GetMoniker(DWORD dwAssign,DWORD dwWhichMoniker,IMoniker ** ppmk){
	TODO
}
STDMETHODIMP CMySite2::GetContainer(LPOLECONTAINER FAR* ppContainer){
	*ppContainer = NULL;
	return E_NOINTERFACE;
}
STDMETHODIMP CMySite2::ShowObject(){
	return NOERROR;
}
STDMETHODIMP CMySite2::OnShowWindow(BOOL fShow){
	TODO
}
STDMETHODIMP CMySite2::RequestNewObjectLayout(){
	TODO
}
STDMETHODIMP CMySite2::GetWindow(HWND FAR* lphwnd){
	*lphwnd=rep->hwnd;
	return S_OK;
}
STDMETHODIMP CMySite2::ContextSensitiveHelp(BOOL fEnterMode){
	TODO
}
STDMETHODIMP CMySite2::CanInPlaceActivate(){
	return S_OK;
}
STDMETHODIMP CMySite2::OnInPlaceActivate(){
	return S_OK;
}
STDMETHODIMP CMySite2::OnUIActivate(){
	return S_OK;
}
STDMETHODIMP CMySite2::GetWindowContext(
	LPOLEINPLACEFRAME FAR* ppFrame,
	LPOLEINPLACEUIWINDOW FAR* ppDoc,
	LPRECT prcPosRect,
	LPRECT prcClipRect,
	LPOLEINPLACEFRAMEINFO lpFrameInfo){
	*ppFrame=&rep->frame;
	*ppDoc = NULL;
	GetClientRect(rep->hwnd,prcPosRect);
	GetClientRect(rep->hwnd,prcClipRect);
	lpFrameInfo->cb=sizeof(OLEINPLACEFRAMEINFO);
	lpFrameInfo->fMDIApp=FALSE;
	lpFrameInfo->hwndFrame=rep->hwnd;
	lpFrameInfo->haccel=NULL;
	lpFrameInfo->cAccelEntries=0;
	return S_OK;
}
STDMETHODIMP CMySite2::Scroll(SIZE scrollExtent){
	TODO
}
STDMETHODIMP CMySite2::OnUIDeactivate(BOOL fUndoable){
	return S_OK;
}
STDMETHODIMP CMySite2::OnInPlaceDeactivate(){
	return S_OK;
}
STDMETHODIMP CMySite2::DiscardUndoState(){
	TODO
}
STDMETHODIMP CMySite2::DeactivateAndUndo(){
	TODO
}
STDMETHODIMP CMySite2::OnPosRectChange( const RECT *rect ){
	TODO
}
STDMETHODIMP CMySite2::EnableModeless(  BOOL fEnable) {return S_OK;}	//[in]

STDMETHODIMP CMySite2::ShowContextMenu( 
    /* [in] */ DWORD dwID,
    /* [in] */ POINT __RPC_FAR *ppt,
    /* [in] */ IUnknown __RPC_FAR *pcmdtReserved,
    /* [in] */ IDispatch __RPC_FAR *pdispReserved) 
{
	if (rep->viewstyle&NOCONTEXTMENU) return S_OK;
	return S_FALSE;
}

STDMETHODIMP CMySite2::ShowUI( 
    /* [in] */ DWORD dwID,
    /* [in] */ IOleInPlaceActiveObject __RPC_FAR *pActiveObject,
    /* [in] */ IOleCommandTarget __RPC_FAR *pCommandTarget,
    /* [in] */ IOleInPlaceFrame __RPC_FAR *pFrame,
    /* [in] */ IOleInPlaceUIWindow __RPC_FAR *pDoc)
{
//	pCommandTarget->Exec(0,IDM_DISABLEMODELESS,OLECMDEXECOPT_DODEFAULT,0,0);
//	if (rep->style&SHOWUI) return S_FALSE;
	return S_OK;
}

STDMETHODIMP CMySite2::HideUI( void)
{
	return S_OK;
}
STDMETHODIMP CMySite2::UpdateUI( void) 
{
	return S_OK;
}

STDMETHODIMP CMySite2::OnDocWindowActivate( /* [in] */ BOOL fActivate) {return S_OK;}
STDMETHODIMP CMySite2::OnFrameWindowActivate( /* [in] */ BOOL fActivate){return S_OK;}

STDMETHODIMP CMySite2::ResizeBorder( 
    /* [in] */ LPCRECT prcBorder,
    /* [in] */ IOleInPlaceUIWindow __RPC_FAR *pUIWindow,
    /* [in] */ BOOL fRameWindow) {return S_OK;}

STDMETHODIMP CMySite2::TranslateAccelerator( 	//simon was here
    /* [in] */ LPMSG lpMsg,
    /* [in] */ const GUID __RPC_FAR *pguidCmdGroup,
    /* [in] */ DWORD nCmdID) 
{
//	printf("CMySite2::TranslateAccelerator\n");fflush(stdout);
	if (lpMsg && lpMsg->message == WM_KEYDOWN){// && pMsg->wParam == VK_TAB) {
		return S_FALSE;
	}	return E_NOTIMPL;
}

STDMETHODIMP CMySite2::GetOptionKeyPath( 
    /* [out] */ LPOLESTR __RPC_FAR *pchKey,
    /* [in] */ DWORD dw) {return E_NOTIMPL;}

STDMETHODIMP CMySite2::GetDropTarget( 
    /* [in] */ IDropTarget __RPC_FAR *pDropTarget,
    /* [out] */ IDropTarget __RPC_FAR *__RPC_FAR *ppDropTarget) {return E_NOTIMPL;}

STDMETHODIMP CMySite2::GetExternal( /* [out] */ IDispatch __RPC_FAR *__RPC_FAR *ppDispatch) {return -1;}

STDMETHODIMP CMySite2::TranslateUrl(
    /* [in] */ DWORD dwTranslate,
    /* [in] */ OLECHAR __RPC_FAR *pchURLIn,
    /* [out] */ OLECHAR __RPC_FAR *__RPC_FAR *ppchURLOut)
{
	return S_FALSE;
//	ppchURLOut=0;
//	return S_OK;
}

STDMETHODIMP CMySite2::GetHostInfo( 
    /* [out][in] */ DOCHOSTUIINFO __RPC_FAR *pInfo)
{
//	static DOCHOSTUIINFO	pi;
//	pi.cbSize=sizeof(pi);
//	pi.dwFlags|=DOCHOSTUIFLAG_SCROLL_NO;
//	pi.dwDoubleClick=0;
//	pInfo=&pi;
//	pinfo.dwFlags|=DOCHOSTUIFLAG_SCROLL_NO;
//	return S_OK;
	return E_NOTIMPL;
}

STDMETHODIMP CMySite2::FilterDataObject( 
    /* [in] */ IDataObject __RPC_FAR *pDO,
    /* [out] */ IDataObject __RPC_FAR *__RPC_FAR *ppDORet) {return S_FALSE;}


STDMETHODIMP CMyFrame2::QueryInterface(REFIID riid,void ** ppvObject){
	TODO
}
STDMETHODIMP_(ULONG) CMyFrame2::AddRef(void){
	return 1;
}
STDMETHODIMP_(ULONG) CMyFrame2::Release(void){
	return 1;
}
STDMETHODIMP CMyFrame2::GetWindow(HWND FAR* lphwnd){
	*lphwnd=rep->hwnd;
	return S_OK;
}
STDMETHODIMP CMyFrame2::ContextSensitiveHelp(BOOL fEnterMode){
	TODO
}
STDMETHODIMP CMyFrame2::GetBorder(LPRECT lprectBorder){
	TODO
}
STDMETHODIMP CMyFrame2::RequestBorderSpace(LPCBORDERWIDTHS pborderwidths){
	TODO
}
STDMETHODIMP CMyFrame2::SetBorderSpace(LPCBORDERWIDTHS pborderwidths){
	TODO
}
STDMETHODIMP CMyFrame2::SetActiveObject(IOleInPlaceActiveObject *pActiveObject,LPCOLESTR pszObjName){
	return S_OK;
}
STDMETHODIMP CMyFrame2::InsertMenus(HMENU hmenuShared,LPOLEMENUGROUPWIDTHS lpMenuWidths){
	TODO
}
STDMETHODIMP CMyFrame2::SetMenu(HMENU hmenuShared,HOLEMENU holemenu,HWND hwndActiveObject){
	return S_OK;
}
STDMETHODIMP CMyFrame2::RemoveMenus(HMENU hmenuShared){
	TODO
}
STDMETHODIMP CMyFrame2::SetStatusText(LPCOLESTR pszStatusText){
	return S_OK;
}
STDMETHODIMP CMyFrame2::EnableModeless(BOOL fEnable){
	return S_OK;
}
STDMETHODIMP CMyFrame2::TranslateAccelerator(LPMSG lpmsg,WORD wID){
	TODO
}



ULONG __stdcall DWebBrowserEventsImpl2::AddRef() { return 1;}
ULONG __stdcall DWebBrowserEventsImpl2::Release() { return 0;}

HRESULT __stdcall DWebBrowserEventsImpl2::QueryInterface(REFIID riid, LPVOID* ppv)
{
	*ppv = NULL;

	if (IID_IUnknown == riid || IID_DWebBrowserEvents2 == riid)	//__uuidof(DWebBrowserEventsPtr) == riid)	//was PTR
	{
		*ppv = (LPUNKNOWN)(DWebBrowserEventsPtr*)this;
		AddRef();
		return NOERROR;
	}
	else if (IID_IOleClientSite == riid)
	{
		*ppv = (IOleClientSite*)this;
		AddRef();
		return NOERROR;
	}
	else if (IID_IDispatch == riid)
	{
		*ppv = (IDispatch*)this;
		AddRef();
		return NOERROR;
	}
	else
	{
		return E_NOTIMPL;
	}
}

//	void BeforeNavigate2(IDispatch*, VARIANT*, VARIANT*, VARIANT*, VARIANT*, VARIANT*, VARIANT_BOOL*);


HRESULT __stdcall DWebBrowserEventsImpl2::Invoke(DISPID dispIdMember,
            REFIID riid,
            LCID lcid,
            WORD wFlags,
            DISPPARAMS __RPC_FAR *pDispParams,
            VARIANT __RPC_FAR *pVarResult,
            EXCEPINFO __RPC_FAR *pExcepInfo,
            UINT __RPC_FAR *puArgErr)
{
	switch (dispIdMember)
	{
	case DISPID_BEFORENAVIGATE2:		
		BeforeNavigate2(
			pDispParams->rgvarg[6].pdispVal,
			pDispParams->rgvarg[5].pvarVal,
			pDispParams->rgvarg[4].pvarVal,
			pDispParams->rgvarg[3].pvarVal,
			pDispParams->rgvarg[2].pvarVal,
			pDispParams->rgvarg[1].pvarVal,
			pDispParams->rgvarg[0].pboolVal);
		break;
	case DISPID_NEWWINDOW2:
		NewWindow2(
			pDispParams->rgvarg[1].ppdispVal,
			pDispParams->rgvarg[0].pboolVal);		//IDispatch**, VARIANT_BOOL*
		break;
	case DISPID_NAVIGATECOMPLETE2:
		NavigateComplete(pDispParams->rgvarg[1].pdispVal,pDispParams->rgvarg[0].pvarVal);
		break;
	case DISPID_DOCUMENTCOMPLETE:
		DocumentComplete(pDispParams->rgvarg[1].pdispVal,pDispParams->rgvarg[0].pvarVal);
		break;
	}
	return NOERROR;
}

// IDispatch methods
HRESULT __stdcall DWebBrowserEventsImpl2::GetTypeInfoCount(UINT* pctinfo)
{ 
	return E_NOTIMPL; 
}

HRESULT __stdcall DWebBrowserEventsImpl2::GetTypeInfo(UINT iTInfo,
            LCID lcid,
            ITypeInfo** ppTInfo)
{ 
	return E_NOTIMPL; 
}

HRESULT __stdcall DWebBrowserEventsImpl2::GetIDsOfNames(REFIID riid,
            LPOLESTR* rgszNames,
            UINT cNames,
            LCID lcid,
            DISPID* rgDispId)
{ 
	return E_NOTIMPL; 
}

// Methods:

void DWebBrowserEventsImpl2::NewWindow2(IDispatch**pdisp, VARIANT_BOOL*Cancel)
{
//	*pdisp=rep->iBrowser;
	*Cancel=VARIANT_TRUE;// was FALSE;
}

void DWebBrowserEventsImpl2::BeforeNavigate2(IDispatch*, VARIANT*URL, VARIANT*, VARIANT*TARGET, VARIANT*, VARIANT*, VARIANT_BOOL*Cancel)
{
	BBString	*url;
	*Cancel=VARIANT_FALSE;
	if (TARGET->bstrVal) {
		return;
	}
	if ((rep->viewstyle&NONAVIGATE) && (rep->navcount==0)){
		*Cancel=VARIANT_TRUE;
		url=bbStringFromVariant2(URL);
		bbSystemEmitEvent( BBEVENT_GADGETACTION,rep->owner,0,0,0,0,(BBObject*)url );
	}else{
		rep->navcount=0;
	}
}

void DWebBrowserEventsImpl2::NavigateComplete ( IDispatch* pDisp,VARIANT*URL )
{
//	printf("Navigate Complete!\n");fflush(stdout);
//		rep->setcurrenturl(URL);
//		rep->loading=0;
//	rep->owner->emit( BBEVENT_GADGETDONE );
//		bbSystemEmitEvent( BBEVENT_GADGETDONE,rep->owner,0,0,0,0,BBNULL );
}

void DWebBrowserEventsImpl2::DocumentComplete ( IDispatch* pDisp,VARIANT*URL )
{
//	printf("Document Complete!\n");fflush(stdout);
	rep->setcurrenturl(URL);
	rep->loading=0;
//	rep->owner->emit( BBEVENT_GADGETDONE );
	bbSystemEmitEvent( BBEVENT_GADGETDONE,rep->owner,0,0,0,0,BBNULL );
}

HRESULT DWebBrowserEventsImpl2::StatusTextChange ( _bstr_t Text ) { return S_OK; }

void DWebBrowserEventsImpl2::ProgressChange (long Progress,long ProgressMax )  {}
void DWebBrowserEventsImpl2::DownloadComplete()  {}
void DWebBrowserEventsImpl2::CommandStateChange (long Command,VARIANT_BOOL Enable ) {}
void DWebBrowserEventsImpl2::DownloadBegin () {}

HRESULT DWebBrowserEventsImpl2::NewWindow (
    _bstr_t URL,
    long Flags,
    _bstr_t TargetFrameName,
    VARIANT * PostData,
    _bstr_t Headers,
    VARIANT_BOOL * Processed ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::TitleChange ( _bstr_t Text ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::FrameBeforeNavigate (
    _bstr_t URL,
    long Flags,
    _bstr_t TargetFrameName,
    VARIANT * PostData,
    _bstr_t Headers,
    VARIANT_BOOL * Cancel ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::FrameNavigateComplete (
    _bstr_t URL ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::FrameNewWindow (
    _bstr_t URL,
    long Flags,
    _bstr_t TargetFrameName,
    VARIANT * PostData,
    _bstr_t Headers,
    VARIANT_BOOL * Processed ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::Quit (
    VARIANT_BOOL * Cancel ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::WindowMove ( ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::WindowResize ( ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::WindowActivate ( ) { return S_OK; }
HRESULT DWebBrowserEventsImpl2::PropertyChange (
    _bstr_t Property ) { return S_OK; }


// C style public interface
	
int msHtmlCreate( void *gadget,wchar_t *wndclass,int hwnd,int flags ){
	HTMLView *view;
	view=new HTMLView((BBObject *)gadget,wndclass,(HWND)hwnd,flags);
	return (int)view;
}

void msHtmlGo( int handle,wchar_t *url ){
	HTMLView *view;
	view=(HTMLView*)handle;
	view->go(url);
}

void msHtmlRun( int handle,wchar_t *script ){
	HTMLView *view;
	view=(HTMLView*)handle;
	view->run(script);
}

void msHtmlSetShape( int handle,int x,int y,int w,int h ){
	HTMLView *view;
	view=(HTMLView*)handle;
	view->setshape(x,y,w,h);
}

void msHtmlSetVisible( int handle,int visible ){
}

void msHtmlSetEnabled( int handle,int enabled ){
}

int msHtmlActivate(int handle,int cmd){
	HTMLView *view;
	view=(HTMLView*)handle;
	return view->activate(cmd);
}

int msHtmlStatus(int handle){
	HTMLView *view;
	view=(HTMLView*)handle;
	return view->status();
}

int msHtmlHwnd( int handle ){
	HTMLView *view;
	view=(HTMLView*)handle;
	return (int)view->hwnd;
}
	
void *msHtmlBrowser( int handle ){
	HTMLView *view;
	view=(HTMLView*)handle;
	return view->iBrowser;
}

