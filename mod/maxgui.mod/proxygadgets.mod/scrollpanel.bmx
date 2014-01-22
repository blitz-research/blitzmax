Strict

Import MaxGUI.MaxGUI

' TScrollPanel Proxy Gadget
' Author: Seb Hollington

Const SCROLLPANEL_SUNKEN:Int = 1
Const SCROLLPANEL_HALWAYS:Int = 2
Const SCROLLPANEL_VALWAYS:Int = 4

Const SCROLLPANEL_HSCALING:Int = 8
Const SCROLLPANEL_VSCALING:Int = 16

Const SCROLLPANEL_HNEVER:Int = 32
Const SCROLLPANEL_VNEVER:Int = 64

Rem
bbdoc: Creates a scrollable panel.
about: A scroll panel can be used to present a large number of gadgets in a small area.  Scrollbars are displayed to allow the
user to move around a client-area that is viewed through a, typically smaller, viewport.  The #ScrollPanelX and #ScrollPanelY functions
can be used to retrieve the current scroll position, and the #ScrollScrollPanel command, to set the scroll position.  A @TScrollPanel gadget
emits the following event when %{the user} scrolls around the scroll area:

[ @{Event} | @{EventX} | @{EventY}
* EVENT_GADGETACTION | New value of #ScrollPanelX. | New value of #ScrollPanelY.
]

Any combination of the following style flags are supported:

[ @Constant | @Meaning
* SCROLLPANEL_SUNKEN | The scroll-panel will be drawn with a sunken border.
* SCROLLPANEL_HALWAYS | The horizontal scroll-bar will be shown at all times (even if not necessary).
* SCROLLPANEL_VALWAYS | The vertical scroll-bar will be shown at all times (even if not necessary).
* SCROLLPANEL_HNEVER | The horizontal scroll-bar will never be shown (even if client-area width is greater than viewport's).
* SCROLLPANEL_VNEVER | The vertical scroll-bar will never be shown (even if client-area height is greater than viewport's).
]

The above can also be combined with any of the following behavioural flags which determine how the scrollable client-area resizes with the viewport:

[ @Constant | @Meaning
* SCROLLPANEL_HSCALING | The client area's width grows uniformly as the viewport is sized.
* SCROLLPANEL_VSCALING | The client area's height grows uniformly as the viewport is sized.
]

[
* The @TScrollPanel instance itself represents the viewport of the scroll-panel, which can be manipulated (e.g. resized/shown/hidden) using the
standard MaxGUI commands.
* The client area is the panel that will actually be scrolled and is retrieved using the #ScrollPanelClient command.  This is the panel
whose dimensions determine the total scrollable area, and is also the panel that all your child gadgets should be added to.
]

<img src="scroll_dimensions.png" />

The dimensions given above can each be retrieved programatically:

{{
GadgetWidth( myScrollPanel )                           'Gadget Width
GadgetHeight( myScrollPanel )                          'Gadget Height

ClientWidth( myScrollPanel )                           'Viewport Width
ClientHeight( myScrollPanel )                          'Viewport Height

ClientWidth( ScrollPanelClient( myScrollPanel ) )      'Client Area Width
ClientHeight( ScrollPanelClient( myScrollPanel ) )     'Client Area Height
}}

And the gadget and client dimensions can be set programatically using (viewport sizing is handled automatically):

{{
'Set Gadget dimensions (and position).
SetGadgetShape( myScrollPanel, x, y, w, h )

'Set Client Area dimensions (position parameters are ignored).
SetGadgetShape( ScrollPanelClient( myScrollPanel ), 0, 0, w, h )
}}

See Also: #ScrollPanelClient, #FitScrollPanelClient, #ScrollScrollPanel, #ScrollPanelX, #ScrollPanelY and #FitScrollPanelClient.
End Rem
Function CreateScrollPanel:TScrollPanel( x,y,w,h,group:TGadget,flags=0 )
	
	Return New TScrollPanel.Create(x,y,w,h,group,flags)
	
EndFunction

Rem
bbdoc: Retrieves the panel that is scrolled.
about: This panel represents the total scrollable region of the gadget.  As such, use #SetGadgetShape on this panel to alter the
scrollable region (the xpos and ypos parameters will be ignored) or use the helper function #FitScrollPanelClient to resize the client area to
common dimensions.  In either case, it is important to note that, contrary to typical MaxGUI behaviour, resizing the client panel
%{will not alter the position or dimensions of the children}, irrespective of any sizing behaviour previously defined using #SetGadgetLayout.

See #CreateScrollPanel for more information.
End Rem
Function ScrollPanelClient:TGadget( scrollpanel:TScrollPanel )
	Return scrollpanel.pnlClientArea
EndFunction

Const SCROLLPANEL_SIZETOKIDS:Int = 0
Const SCROLLPANEL_SIZETOVIEWPORT:Int = 1

Rem
bbdoc: Helper function that resizes the client area to common dimensions.
about: This function resizes the scrollable area of a @TScrollPanel widget.  Any child gadgets will retain their current
position and dimensions, irrespective of any sizing behaviour previously defined using #SetGadgetLayout. This function will
also reset the current visible area, to the furthest top-left.

[
* @scrollpanel: The scrollpanel whose client you want to resize.
* @fitType: Should be one of the following constants:
]

[ @Constant | @Meaning
* SCROLLPANEL_SIZETOKIDS | The client area will be resized so that its width and height are just enough to enclose all child gadgets.
* SCROLLPANEL_SIZETOVIEWPORT | The client area will be resized so that it is the same size that the viewport is currently (effectively removing the scrollbars).
]

See #CreateScrollPanel and #ScrollPanelClient for more information.
End Rem
Function FitScrollPanelClient( scrollpanel:TScrollPanel, fitType% = SCROLLPANEL_SIZETOKIDS )
	Select fitType
		Case SCROLLPANEL_SIZETOKIDS
			scrollpanel.FitToChildren()
		Case SCROLLPANEL_SIZETOVIEWPORT
			scrollpanel.FitToViewport()
	EndSelect
EndFunction

Const SCROLLPANEL_HOLD:Int = -1
Const SCROLLPANEL_TOP:Int = 0
Const SCROLLPANEL_LEFT:Int = 0
Const SCROLLPANEL_BOTTOM:Int = 2147483647
Const SCROLLPANEL_RIGHT:Int = 2147483647

Rem
bbdoc: Scrolls the current viewport to a new position.
about: This function moves the client area of the scroll panel so that the the top-left corner of the viewport is as close
as possible to the specified @{pX}, @{pY} position in the client-area.

<img src="scroll_position.png" />

There are 4 position constants provided:

[ @Constant | @{Position}
* SCROLLPANEL_TOP | Top-most edge.
* SCROLLPANEL_LEFT | Left-most edge.
* SCROLLPANEL_BOTTOM | Bottom-most edge.
* SCROLLPANEL_RIGHT | Right-most edge.
* SCROLLPANEL_HOLD | Current position.
]

For example, both of these commands...

{{
ScrollScrollPanel( myScrollPanel, SCROLLPANEL_LEFT, SCROLLPANEL_TOP )
ScrollScrollPanel( myScrollPanel, 0, 0 )
}}
...would scroll to the top-leftmost section of the client area. Conversely, we can scroll to the bottom-right most
region of the client area by calling:
{{
ScrollScrollPanel( myScrollPanel, SCROLLPANEL_RIGHT, SCROLLPANEL_BOTTOM )
}}

If we only want to change just the horizontal or just the vertical scroll position, we can use the SCROLLPANEL_HOLD constant. E.g.
to scroll to the left most side without changing the current vertical scroll position, we could use:
{{
ScrollScrollPanel( myScrollPanel, SCROLLPANEL_LEFT, SCROLLPANEL_HOLD )
}}

See #CreateScrollPanel, #ScrollPanelX, #ScrollPanelY and #ScrollPanelClient for more information.
EndRem
Function ScrollScrollPanel( scrollpanel:TScrollPanel, pX = SCROLLPANEL_TOP, pY = SCROLLPANEL_LEFT )
	scrollpanel.ScrollTo( pX, pY )
	scrollpanel.Update()
EndFunction

Rem
bbdoc: Returns the x position of the client-area that is currently at the top-left of the viewport.
about: Complementary function to #ScrollPanelY and #ScrollScrollPanel.  See #ScrollScrollPanel for a visual representation
of this value.

See #CreateScrollPanel for more information.
EndRem
Function ScrollPanelX:Int( scrollpanel:TScrollpanel )
	Return scrollpanel.GetXScroll()
EndFunction

Rem
bbdoc: Returns the y position of the client-area that is currently at the top-left of the viewport.
about: Complementary function to #ScrollPanelX and #ScrollScrollPanel.  See #ScrollScrollPanel for a visual representation
of this value.

See #CreateScrollPanel for more information.
EndRem
Function ScrollPanelY:Int( scrollpanel:TScrollpanel )
	Return scrollpanel.GetYScroll()
EndFunction

Type TScrollPanel Extends TProxyGadget
	
	Field flags:Int
	
	Field pnlEntire:TGadget
	Field pnlViewport:TGadget
	Field pnlClientArea:TScrollClient
	Field scrHorizontal:TGadget
	Field scrVertical:TGadget
	
	Field currentH%, currentV%, clientW%, clientH%
	
	Const SCROLL_WIDTH% = 18
	
	Method New()
		
		AddHook EmitEventHook,eventHandler,Self, -1
		RemoveVerticalScroll();RemoveHorizontalScroll()
		
	EndMethod
	
	Method Create:TScrollPanel(pX%, pY%, pWidth%, pHeight%, pParent:TGadget, pFlags% = 0)
		
		Local tmpPanelFlags:Int
		
		flags = pFlags
		
		If flags & (SCROLLPANEL_SUNKEN) Then tmpPanelFlags:|PANEL_SUNKEN
		
		pnlEntire = CreatePanel(pX,pY,pWidth,pHeight,pParent,tmpPanelFlags);HideGadget(pnlEntire);SetProxy(pnlEntire)
		pnlViewport = CreatePanel(0,0,pnlEntire.ClientWidth(),pnlEntire.ClientHeight(), pnlEntire)
		pnlClientArea = New TScrollClient
		pnlClientArea.SetProxy(CreatePanel(0,0,pnlViewport.ClientWidth(),pnlViewport.ClientHeight(), pnlViewport))
		scrHorizontal = CreateSlider(0,pnlEntire.ClientHeight()-SCROLL_WIDTH,pnlEntire.ClientWidth()-SCROLL_WIDTH,SCROLL_WIDTH, pnlEntire, SLIDER_HORIZONTAL|SLIDER_SCROLLBAR )
		scrVertical = CreateSlider(pnlEntire.ClientWidth()-SCROLL_WIDTH,0,SCROLL_WIDTH,pnlEntire.ClientHeight()-SCROLL_WIDTH, pnlEntire, SLIDER_VERTICAL|SLIDER_SCROLLBAR )
		
		SetGadgetLayout(pnlViewport, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetGadgetLayout(scrHorizontal, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED )
		SetGadgetLayout(scrVertical, EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		Select (flags & (SCROLLPANEL_HSCALING|SCROLLPANEL_VSCALING))
			Case 0
				SetGadgetLayout(pnlClientArea.GetProxy(), EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_CENTERED )
			Case SCROLLPANEL_HSCALING
				SetGadgetLayout(pnlClientArea.GetProxy(), EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED )
			Case SCROLLPANEL_VSCALING
				SetGadgetLayout(pnlClientArea.GetProxy(), EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED )
			Case SCROLLPANEL_HSCALING|SCROLLPANEL_VSCALING
				SetGadgetLayout(pnlClientArea.GetProxy(), EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		EndSelect
		
		HideGadget(scrHorizontal);HideGadget(scrVertical)
		
		ShowGadget(pnlEntire)
		
		Return Self
	
	EndMethod
	
	Method SetShape(x,y,w,h)
		Super.SetShape(x,y,w,h)
		Update()
	EndMethod
	
	Method ClientWidth:Int()
		Return pnlViewport.ClientWidth()
	EndMethod
	
	Method ClientHeight:Int()
		Return pnlViewport.ClientHeight()
	EndMethod
	
	Method GetXScroll:Int()
		Return currentH
	EndMethod
	
	Method GetYScroll:Int()
		Return currentV
	EndMethod
	
	Method ScrollTo(pHSlider%, pVSlider%)
		
		Local tmpRight:Int = Max( pnlClientArea.ClientWidth()-pnlViewport.ClientWidth(), 0 )
		Local tmpBottom:Int = Max( pnlClientArea.ClientHeight()-pnlViewport.ClientHeight(), 0 )
		
		If (pHSlider > tmpRight) Then pHSlider = tmpRight
		If (pVSlider > tmpBottom) Then pVSlider = tmpBottom
		
		If (pHSlider >= 0) Then currentH = pHSlider
		If (pVSlider >= 0) Then currentV = pVSlider
		
		SetGadgetShape(pnlClientArea.GetProxy(),-currentH,-currentV,pnlClientArea.GetWidth(),pnlClientArea.GetHeight())
		
	EndMethod
	
	Method FitToChildren( pRightMargin:Int = 0, pBottomMargin:Int = 0 )
		
		Local tmpRight:Int, tmpBottom:Int
		
		For Local tmpChild:TGadget = EachIn pnlClientArea.proxy.kids
			tmpRight = Max(tmpRight,GadgetX(tmpChild)+GadgetWidth(tmpChild))
			tmpBottom = Max(tmpBottom,GadgetY(tmpChild)+GadgetHeight(tmpChild))
		Next
		
		HideGadget( pnlViewport )
		pnlClientArea.SetShape(0,0,tmpRight + pRightMargin,tmpBottom + pBottomMargin)
		ScrollTo(0,0)
		ShowGadget( pnlViewport )
		
	EndMethod
	
	Method FitToViewport()
		
		HideGadget( pnlViewport )
		pnlClientArea.SetShape(0,0,pnlViewport.ClientWidth(),pnlViewport.ClientHeight())
		ScrollTo(0,0)
		ShowGadget( pnlViewport )
		
	EndMethod
	
	Method Update()
		
		Local tmpDiff:Int, tmpPos:Int
		
		If Not pnlClientArea Then Return
		
		If pnlViewport.ClientWidth() < pnlClientArea.GetWidth() Then
			AddHorizontalScroll(pnlViewport.ClientWidth(),pnlClientArea.GetXPos(),pnlClientArea.GetWidth())
		Else
			RemoveHorizontalScroll()
		EndIf
		
		If pnlViewport.ClientHeight() < pnlClientArea.GetHeight() Then
			AddVerticalScroll(pnlViewport.ClientHeight(),pnlClientArea.GetYPos(),pnlClientArea.GetHeight())
		Else
			RemoveVerticalScroll()
		EndIf
		
		If pnlViewport.ClientWidth() < pnlClientArea.GetWidth() Then
			
			tmpDiff = Max(pnlViewport.ClientWidth()-(pnlClientArea.GetXpos() + pnlClientArea.GetWidth()),0)
			tmpPos = Min(pnlClientArea.GetXPos()+tmpDiff,0)
			
			AddHorizontalScroll(pnlViewport.ClientWidth(),tmpPos,pnlClientArea.GetWidth())
			ScrollTo( -tmpPos, currentV )
			
		Else
		
			RemoveHorizontalScroll()
			
		EndIf
		
		If pnlViewport.ClientHeight() < pnlClientArea.GetHeight() Then
			
			tmpDiff = Max(pnlViewport.ClientHeight()-(pnlClientArea.GetYPos() + pnlClientArea.GetHeight()),0)
			tmpPos = Min(pnlClientArea.GetYPos()+tmpDiff,0)
			
			AddVerticalScroll(pnlViewport.ClientHeight(),tmpPos,pnlClientArea.GetHeight())
			ScrollTo( currentH, -tmpPos )
			
		Else
		
			RemoveVerticalScroll()
			
		EndIf
		
	EndMethod
	
	Method AddVerticalScroll(pVisible%, pY%, pHeight%)
		
		If scrVertical And Not (flags&SCROLLPANEL_VNEVER) Then
			
			SetGadgetShape(pnlViewport, 0, 0, pnlEntire.ClientWidth() - SCROLL_WIDTH, GadgetHeight(pnlViewport))
			SetGadgetShape(scrVertical, pnlEntire.ClientWidth()-SCROLL_WIDTH, 0, SCROLL_WIDTH, GadgetHeight(pnlViewport))
			
			SetSliderRange(scrVertical, pVisible, pHeight);SetSliderValue(scrVertical,-pY)
			EnableGadget(scrVertical);ShowGadget(scrVertical)
		
		EndIf
		
	EndMethod
	
	Method RemoveVerticalScroll()
	
		If scrVertical And Not GadgetDisabled(scrVertical) Then
			
			If Not (flags&SCROLLPANEL_VALWAYS) Then
				HideGadget(scrVertical)
				SetGadgetShape(pnlViewport, 0, 0, pnlEntire.ClientWidth(), GadgetHeight(pnlViewport))
			EndIf
			
			DisableGadget(scrVertical)
			
			ScrollTo(currentH,0)
			
		EndIf
	
	EndMethod
	
	Method AddHorizontalScroll(pVisible%, pX%, pWidth%)
	
		If scrHorizontal And Not (flags&SCROLLPANEL_HNEVER) Then
			
			SetGadgetShape(pnlViewport, 0, 0, GadgetWidth(pnlViewport), pnlEntire.ClientHeight()-SCROLL_WIDTH )
			SetGadgetShape(scrHorizontal, 0, pnlEntire.ClientHeight()-SCROLL_WIDTH, GadgetWidth(pnlViewport), SCROLL_WIDTH)
			
			SetSliderRange(scrHorizontal, pVisible, pWidth);SetSliderValue(scrHorizontal,-pX)
			EnableGadget(scrHorizontal);ShowGadget(scrHorizontal)
		
		EndIf
		
	EndMethod
	
	Method RemoveHorizontalScroll()
	
		If scrHorizontal And Not GadgetDisabled(scrHorizontal) Then
			
			If Not (flags&SCROLLPANEL_HALWAYS) Then
				SetGadgetShape(pnlViewport, 0, 0, GadgetWidth(pnlViewport), pnlEntire.ClientHeight())
				HideGadget(scrHorizontal)
			EndIf
			
			DisableGadget(scrHorizontal)
			
			ScrollTo(0,currentV)
			
		EndIf
	
	EndMethod
	
	Method eventHook:Object(pID%, pData:Object, pContext:Object)
	
		Local tmpEvent:TEvent = TEvent(pData)
		If tmpEvent = Null Then Return pData
		
		Select tmpEvent.id
			
			Case EVENT_WINDOWSIZE
			
				If CheckParent(pnlEntire, TGadget(tmpEvent.source)) Then Update()
			
			Case EVENT_GADGETACTION
				
				Local tmpH:Int = currentH, tmpV:Int = currentV
				
				Select tmpEvent.source
				
					Case scrHorizontal
						tmpH = SliderValue(scrHorizontal)
					Case scrVertical
						tmpV = SliderValue(scrVertical)
					Default
						Return pData
				
				EndSelect
			
				ScrollTo(tmpH, tmpV)
				EmitEvent CreateEvent( EVENT_GADGETACTION, Self, 0, 0, currentH, currentV, Null )
				pData = Null
				
		EndSelect
		
		Return pData
		
	EndMethod
	
	Method CleanUp()
	
		RemoveHook EmitEventHook, eventHandler, Self
		SetProxy(Null)
		If pnlClientArea Then pnlClientArea.SetProxy(Null);pnlClientArea = Null
		If pnlEntire Then HideGadget(pnlEntire);FreeGadget(pnlEntire)
	
	EndMethod
	
	Function eventHandler:Object(pID%, pData:Object, pContext:Object)
	
		Local tmpSuperPanel:TScrollPanel = TScrollPanel(pContext)
		If tmpSuperPanel Then pData = tmpSuperPanel.eventHook(pID%, pData:Object, pContext:Object)
		Return pData
	
	EndFunction
	
	Function CheckParent%( pGadget:TGadget, pParentToCheck:TGadget )
		
		If pGadget = pParentToCheck Then Return True
		If pGadget.parent Then Return CheckParent(pGadget.parent, pParentToCheck)
		
	EndFunction
	
EndType

Private

Type TScrollClient Extends TProxyGadget
	
	Method SetShape(x,y,w,h)
		
		Local i:Int, arrDimensions:Int[][], tmpDimensions:Int[]
		
		For Local tmpChild:TGadget = EachIn proxy.kids
			tmpDimensions = [GadgetX(tmpChild),GadgetY(tmpChild),GadgetWidth(tmpChild),GadgetHeight(tmpChild)]
			arrDimensions:+[tmpDimensions]
		Next
		
		Super.SetShape(GetXPos(),GetYPos(),w,h)
		TScrollPanel(proxy.parent.parent.source).Update()
		
		For Local tmpChild:TGadget = EachIn proxy.kids
			tmpDimensions = arrDimensions[i];i:+1
			SetGadgetShape( tmpChild, tmpDimensions[0], tmpDimensions[1], tmpDimensions[2], tmpDimensions[3] )
		Next

	EndMethod
	
	Method SetLayout(lft,rht,top,bot)
		'Do nothing
	EndMethod
	
EndType
