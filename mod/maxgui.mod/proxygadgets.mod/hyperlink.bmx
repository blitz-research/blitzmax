Strict

Import MaxGUI.MaxGUI

' THyperlinkGadget Proxy Gadget
' Author: Seb Hollington

Rem
bbdoc: Creates a basic hyperlink gadget that opens the specified @url$ in the default browser when clicked.
about: The underlying gadget is a label, and so the @style parameter can take all the #CreateLabel flags apart from LABEL_SEPARATOR.

The normal and roll-over text color can be set individually using #SetGadgetTextColor and #SetGadgetColor respectively.

The optional @customtext$ parameter allows you to set user-friendly text that masks the URL in the label. If this is specified in #CreateHyperlink
then the label's tooltip is automatically set to the URL the link refers to. This masking text can be changed at any time by calling #SetGadgetText.
Finally, the @url$ that the hyperlink gadget opens can be modified/retrieved using #SetGadgetExtra and String( #GadgetExtra )
respectively (see code example).
End Rem
Function CreateHyperlink:TGadget( url$,x,y,w,h,group:TGadget,style=0,customtext$ = "" )
	
	Return New THyperlinkGadget.Create(url,x,y,w,h,group,style,customtext)
	
EndFunction

Type THyperlinkGadget Extends TProxyGadget
	
	Global lstHyperlinkGadgets:TList
	
	Global fntDefault:TGuiFont, fntHoverDefault:TGuiFont
	
	Field hyperlinkstyle%
	Field colors[][] = [[0,0,255],[255,0,0]]
	
	Field lastclick[] = [-1, -1]
	
	Method New()
		If Not lstHyperlinkGadgets Then Initialize()
		Local r:Byte, g:Byte, b:Byte
		LookupGuiColor( GUICOLOR_LINKFG, r, g, b )
		colors[0] = [Int r, Int g, Int b]
	EndMethod
	
	Method Create:THyperlinkGadget(pUrl$,x,y,w,h,group:TGadget,style,customtext$)
		
		If Not customtext Then customtext = pUrl$
		If (style&LABEL_SEPARATOR) = LABEL_SEPARATOR Then style:&~LABEL_SEPARATOR
		
		Local tmpLabel:TGadget = CreateLabel( customtext, x, y, w, h, group, style&31 )
		If Not tmpLabel Then Return Null Else SetGadgetSensitivity(tmpLabel, SENSITIZE_MOUSE)
		
		SetGadgetFont(tmpLabel,fntDefault)	
		
		If customtext <> pUrl Then SetGadgetToolTip( tmpLabel, pUrl )
		
		SetProxy( tmpLabel );Super.SetTextColor(colors[0][0], colors[0][1], colors[0][2])
		
		hyperlinkstyle = style;extra = pUrl
		lstHyperlinkGadgets.AddLast Self
		
		Return Self
		
	EndMethod
	
	Method EventHook:TEvent( pEvent:TEvent )
		
		Select pEvent.id
		
			Case EVENT_MOUSEENTER
				Super.SetTextColor(colors[1][0], colors[1][1], colors[1][2]);SetPointer(POINTER_HAND)
				Super.SetFont( fntHoverDefault )
			Case EVENT_MOUSELEAVE
				Super.SetTextColor(colors[0][0], colors[0][1], colors[0][2]);SetPointer(POINTER_DEFAULT)
				Super.SetFont( fntDefault )
			Case EVENT_MOUSEDOWN;If lastclick[0] <> pEvent.x Or lastclick[1] <> pEvent.y Then lastclick = [pEvent.x,pEvent.y];OpenURL(String(extra))
		
		EndSelect
		
		Return Null
	
	EndMethod
	
	Method SetFont( font:TGuiFont )
		fntDefault = font;fntHoverDefault = font
		Super.SetFont(font)
	EndMethod
	
	Method SetColor(r,g,b)
		colors[1][0] = r;colors[1][1] = g;colors[1][2] = b
	EndMethod
	
	Method SetTextColor(r,g,b)
		colors[0][0] = r;colors[0][1] = g;colors[0][2] = b
		Super.SetTextColor(colors[0][0], colors[0][1], colors[0][2])
	EndMethod
	
	Method CleanUp()
		lstHyperlinkGadgets.Remove(Self)
		Super.CleanUp()
	EndMethod
	
	Function Initialize()
		lstHyperlinkGadgets = New TList
		AddHook EmitEventHook, eventHandler, Null, -1
		fntDefault = LookupGuiFont( GUIFONT_SYSTEM, 0, 0 )
		fntHoverDefault = LookupGuiFont( GUIFONT_SYSTEM, 0, FONT_UNDERLINE )
	EndFunction
	
	Function eventHandler:Object( pID%, pData:Object, pContext:Object )
		Local pEvent:TEvent = TEvent(pData)
		
		If pEvent Then
			For Local tmpHyperlinkGadget:THyperlinkGadget = EachIn lstHyperlinkGadgets
				If tmpHyperlinkGadget = pEvent.source Then Return tmpHyperlinkGadget.EventHook( pEvent )
			Next
		EndIf
		
		Return pData
	EndFunction
	
EndType
