SuperStrict

Import MaxGUI.MaxGUI

' TSplitter Proxy Gadget
' Author: Seb Hollington

Rem
bbdoc: Creates a gadget consisting of two panels separated by a draggable divider.
about: A splitter is made up of two panels: a main panel (identified using SPLITPANEL_MAIN) which acts as the main working area; and a side pane
(identified using SPLITPANEL_SIDEPANE) which is typically used to display additional information. Both of these panels are contained within a
parent panel that is represented by the @TSplitter instance. The two panels are separated by a split handle/divider, the behavior of which can be
queried and altered using the #SplitterBehavior and #SetSplitterBehavior functions respectively. 

The size of the split handle is determined using the optional @pHandleSize parameter.  The default size of 10 pixels should work well in most 
situations, and the minimum value that this can be is 4.

After creating a splitter gadget, you can start adding gadgets to it by retrieving the appropriate panel with the #SplitterPanel command.

The @TSplitter type instance can be used with most of the standard MaxGUI commands, allowing you to change the properties of the entire splitter
gadget. There are, however, a few exceptions:

#SetGadgetSensitivity and #GadgetSensitivity will have no effect on the splitter gadget. If you want to use active panels, create your own
sub-panel within each splitter panel.

#SetGadgetTooltip and #GadgetTooltip will set/retrieve a tooltip for when the user is hovering over the splitter handle/divider.

#SetGadgetColor will modify the split handle/divider background color.

See Also: #SplitterPanel, #SetSplitterPosition, #SplitterPosition, #SetSplitterBehavior, #SplitterBehavior, #SetSplitterOrientation and #SplitterOrientation.
End Rem
Function CreateSplitter:TSplitter( pX%, pY%, pW%, pH%, pParent:TGadget, pOrientation% = SPLIT_VERTICAL, pHandleSize% = 10 )
	Return New TSplitter.Create( pX, pY, pW, pH, pParent, pOrientation, pHandleSize )
EndFunction

Const SPLITPANEL_MAIN% = 0, SPLITPANEL_SIDEPANE% = 1, SPLITPANEL_HANDLE% = 2

Rem
bbdoc: Retrieves either one of the two panels which make up a TSplitter gadget.
about: This function is used to return a standard MaxGUI panel that you can add your gadgets to.

The panels available are SPLITPANEL_MAIN and SPLITPANEL_SIDEPANE. See #CreateSplitter for more information
about the differences between the two panels.

See Also: #CreateSplitter, #SetSplitterPosition, #SplitterPosition, #SetSplitterBehavior, #SplitterBehavior, #SetSplitterOrientation and #SplitterOrientation.
End Rem
Function SplitterPanel:TGadget( splitter:TSplitter, panel% = SPLITPANEL_MAIN )
	Return splitter.GetPanel(panel)
EndFunction

Rem
bbdoc: Sets the position of the splitter (in pixels) from the edge of a TSplitter gadget.
about: This function's most common use is to restore a split position previously returned by #SplitterPosition.

The optional @save% parameter determines whether or not the position supplied is restored when the splitter returns from it's hidden state.
In most circumstances, this should be left as #True.

See Also: #CreateSplitter, #SplitterPanel, #SplitterPosition, #SetSplitterBehavior, #SplitterBehavior, #SetSplitterOrientation and #SplitterOrientation.
End Rem
Function SetSplitterPosition( splitter:TSplitter, position%, save% = True )
	splitter.SetPanelSpace( position, save )
EndFunction

Rem
bbdoc: Returns the position of the splitter (in pixels) from the edge of a TSplitter gadget.
about: This function's most common use is probably for saving the current splitter position to restore at a later time using #SetSplitterPosition.

See Also: #CreateSplitter, #SplitterPanel, #SetSplitterPosition, #SetSplitterBehavior, #SplitterBehavior, #SetSplitterOrientation and #SplitterOrientation.
End Rem
Function SplitterPosition:Int( splitter:TSplitter )
	Return splitter.GetPanelSpace( SPLITPANEL_SIDEPANE )
EndFunction

Const SPLIT_HORIZONTAL% = 0, SPLIT_VERTICAL% = 1, SPLIT_FLIPPED% = 2

Rem
bbdoc: Sets the splitter orientation.
about: The two orientations available are (both of which can be combined with SPLIT_FLIPPED):

[ @Orientation | @Description
* -1 | Toggles the SPLIT_FLIPPED flag.
* SPLIT_VERTICAL | The splitter consists of a main left panel with a side-pane along the right edge.
* SPLIT_HORIZONTAL | The splitter consists of a main top panel with a side-pane along the bottom edge.
* SPLIT_VERTICAL ~| SPLIT_FLIPPED | The splitter consists of a main right panel with a side-pane along the left edge.
* SPLIT_HORIZONTAL ~| SPLIT_FLIPPED | The splitter consists of a main bottom with a side-pane along the top edge.
]

See Also: #CreateSplitter, #SplitterPanel, #SetSplitterPosition, #SplitterPosition, #SetSplitterBehavior and #SplitterOrientation.
End Rem
Function SetSplitterOrientation( splitter:TSplitter, orientation% = -1 )
	splitter.ChangeOrientation( orientation )
EndFunction

Rem
bbdoc: Returns the orientation of the splitter.
about: The two orientations available are (both of which can be combined with SPLIT_FLIPPED):

[ @Orientation | @Description
* SPLIT_VERTICAL | The splitter consists of a main left panel with a side-pane along the right edge.
* SPLIT_HORIZONTAL | The splitter consists of a main top panel with a side-pane along the bottom edge.
* SPLIT_VERTICAL ~| SPLIT_FLIPPED | The splitter consists of a main right panel with a side-pane along the left edge.
* SPLIT_HORIZONTAL ~| SPLIT_FLIPPED | The splitter consists of a main bottom with a side-pane along the top edge.
]

See Also: #CreateSplitter, #SplitterPanel, #SetSplitterPosition, #SplitterPosition, #SetSplitterBehavior and #SetSplitterOrientation.
End Rem
Function SplitterOrientation:Int( splitter:TSplitter )
	Return splitter.GetOrientation()
EndFunction

Const SPLIT_RESIZABLE% = %1, SPLIT_LIMITPANESIZE% = %10, SPLIT_CANFLIP% = %100, SPLIT_CANORIENTATE% = %1000, SPLIT_CLICKTOTOGGLE% = %100000, SPLIT_ALL% = -1

Rem
bbdoc: Sets the behavior of a splitter.
about: Any combination of the following are available:

[ @{Behavior Flag} | @Description
* 0 | The splitter does none of the actions listed below.
* SPLIT_RESIZABLE | The splitter can be resized by dragging.
* SPLIT_LIMITPANESIZE | The splitter side-pane is not allowed to take up more than half the splitted dimensions.
* SPLIT_CANFLIP | The splitter can switch between opposite edges by dragging to the edge.
* SPLIT_CANORIENTATE | The splitter can switch between vertical and horizontal modes by dragging to right/bottom edges.
* SPLIT_CLICKTOTOGGLE | The splitter will hide/show when the drag-bar is clicked.
* SPLIT_ALL | A shorthand flag for representing all of the above.
]

The default behavior of a splitter is SPLIT_ALL&~~SPLIT_LIMITPANESIZE (i.e. everything but SPLIT_LIMITPANESIZE).

See Also: #CreateSplitter, #SplitterPanel, #SplitterPosition, #SplitterBehavior, #SetSplitterOrientation and #SplitterOrientation.
End Rem
Function SetSplitterBehavior( splitter:TSplitter, flags%=SPLIT_ALL )
	splitter.SetBehavior( flags )
EndFunction

Rem
bbdoc: Returns the value previously set using #SetSplitterBehavior.
returns: An integer composed of a combination of bitwise flags that describe the behavior of the splitter.
about: See #SetSplitterBehavior for more information.
End Rem
Function SplitterBehavior:Int( splitter:TSplitter )
	Return splitter.GetBehavior()
EndFunction


Type TSplitter Extends TProxyGadget
	
	Const JUMP% = 200
	
								'	SPLITPANEL_MAIN                                          SPLITPANEL_SIDEPANE                                       SPLITPANEL_HANDLE
	Global intOrientationLocks%[][][] =	[[	[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED],[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED],[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED]	], ..	'SPLIT_HORIZONTAL
								 [	[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED],[EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED],[EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED]	], .. 'SPLIT_VERTICAL
								 [	[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED],[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED],[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_CENTERED]	], ..	'SPLIT_HORIZONTAL|SPLIT_FLIPPED
								 [	[EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED],[EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED],[EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED]	]]	'SPLIT_VERTICAL|SPLIT_FLIPPED
	
	Field strToggleTooltip$ = "Click to toggle!"
	
	Field intOrientation%, intMinPanelSpace% = 0, intSavePanelSpace% = 220, intBehavior% = 0, intGutterSize%
	Field intPanelSpace% = intMinPanelSpace, intMouseDown%[2], intHasMoved% = False, intShouldUpdate% = False
	
	Field pnlPanes:TGadget[]
	Field pnlSplitHandle:TGadget, divSplitHandle1:TGadget, divSplitHandle2:TGadget
	Field gadParent:TGadget
	
	Field pixHandle:TPixmap[] = [TPixmap(Null), TPixmap(Null)]
	
	Method Create:TSplitter( pX%, pY%, pW%, pH%, pParent:TGadget, pOrientation% = SPLIT_VERTICAL, pHandleSize% = 10 )
		
		gadParent = CreatePanel(pX, pY, pW, pH, pParent);SetProxy( gadParent )
		
		intGutterSize = Max(pHandleSize, 4)
		DrawHandle();DrawPanes();ChangeOrientation(pOrientation)
		
		SetBehavior(SPLIT_ALL&~SPLIT_LIMITPANESIZE)
		
		AddHook EmitEventHook, eventHandler, Self, -1
		
		Return Self
		
	EndMethod
	
	'Interface
	
	Method GetOrientation:Int()
		Return intOrientation
	EndMethod
	
	Method SetOrientation(pOrientation%)
		ChangeOrientation(pOrientation)
	EndMethod
	
	Method SetBehavior( pBehavior% )
		intBehavior = pBehavior
		If (intBehavior&SPLIT_CLICKTOTOGGLE) Then
			If strToggleTooltip Then SetGadgetToolTip(pnlSplitHandle,strToggleTooltip)
		Else
			If strToggleTooltip Then SetGadgetToolTip(pnlSplitHandle,"")
		EndIf
	EndMethod
	
	Method GetBehavior%()
		Return intBehavior
	EndMethod
	
	Method GetPanel:TGadget(pPane%)
		Return pnlPanes[pPane]
	EndMethod
	
	Method GetPanelSpace%(pPane%)
			Select pPane
				Case SPLITPANEL_SIDEPANE
					Return intPanelSpace
				Case SPLITPANEL_MAIN
					If intOrientation&SPLIT_VERTICAL Then
						Return (ClientWidth()-intPanelSpace-intGutterSize)
					Else
						Return (ClientHeight()-intPanelSpace-intGutterSize)
					EndIf
			EndSelect
	EndMethod
	
	Method SetPanelSpace( pPanelSpace%, flgSave% = True )
		
		Local tmpOldPanelSpace% = intPanelSpace
		
		If (intBehavior & SPLIT_LIMITPANESIZE) Then
			pPanelSpace = Min(pPanelSpace, [ClientHeight(), ClientWidth()][intOrientation&SPLIT_VERTICAL] Shr 1)
		EndIf
		
		pPanelSpace = Max(pPanelSpace, intMinPanelSpace)
		
		intPanelSpace = pPanelSpace
		If GetPanelSpace(SPLITPANEL_MAIN) < intMinPanelSpace Then intPanelSpace = tmpOldPanelSpace
		
		If flgSave And intPanelSpace > Min(intGutterSize,intMinPanelSpace) Then intSavePanelSpace = intPanelSpace
		
		DrawHandle();DrawPanes()
		
	EndMethod
	
	'Proxy Gadget Methods
	
	Method CleanUp()
		RemoveHook EmitEventHook, eventHandler, Self
		gadParent = Null
		Super.CleanUp()
	EndMethod
	
	Method SetTooltip%( pTooltip$ )
		strToggleTooltip = ""
		divSplitHandle1.SetTooltip( pTooltip )
		divSplitHandle2.SetTooltip( pTooltip )
		Return pnlSplitHandle.SetTooltip( pTooltip )
	EndMethod
	
	Method GetTooltip$()
		Return pnlSplitHandle.GetTooltip()
	EndMethod
	
	Method SetTextColor%( pRed%, pGreen%, pBlue%)
		pixHandle[0] = MakeColourHandlePixmap( pRed, pGreen, pBlue, intGutterSize )
		If intOrientation & SPLIT_VERTICAL Then pixHandle[0] = RotatePixmap(pixHandle[0])
		pixHandle[1] = BrightenPixmap(pixHandle[0])
		HideGadget(divSplitHandle1);HideGadget(divSplitHandle2)
		SetPanelPixmap(pnlSplitHandle, pixHandle[0])
	EndMethod
	
	Method SetColor%( pRed%, pGreen%, pBlue%)
		Return SetPanelColor( pnlSplitHandle, pRed, pGreen, pBlue )
	EndMethod
	
	Method SetSensitivity%(pSensitivity%)
		Return 0
	EndMethod
	
	Method GetSensitivity%()
		Return 0
	EndMethod
	
	'Internal Methods
	
	Method ReapplyLocks()
		Local tmpLocks%[][] = intOrientationLocks[intOrientation]
		If pnlPanes And pnlPanes.length > 1 Then
			SetGadgetLayout( pnlPanes[SPLITPANEL_MAIN], tmpLocks[SPLITPANEL_MAIN][0], tmpLocks[SPLITPANEL_MAIN][1], tmpLocks[SPLITPANEL_MAIN][2], tmpLocks[SPLITPANEL_MAIN][3] )
			SetGadgetLayout( pnlPanes[SPLITPANEL_SIDEPANE], tmpLocks[SPLITPANEL_SIDEPANE][0], tmpLocks[SPLITPANEL_SIDEPANE][1], tmpLocks[SPLITPANEL_SIDEPANE][2], tmpLocks[SPLITPANEL_SIDEPANE][3] )
		EndIf
		If pnlSplitHandle Then SetGadgetLayout( pnlSplitHandle, tmpLocks[SPLITPANEL_HANDLE][0], tmpLocks[SPLITPANEL_HANDLE][1], tmpLocks[SPLITPANEL_HANDLE][2], tmpLocks[SPLITPANEL_HANDLE][3] )
	EndMethod
	
	Const SPLITSIDE_LEFT% = 0, SPLITSIDE_RIGHT% = 1, SPLITSIDE_TOP% = 0, SPLITSIDE_BOTTOM% = 1
	Global intSideToPanelMapping%[][] = 	[[	SPLITPANEL_MAIN, SPLITPANEL_SIDEPANE	], ..	'SPLIT_HORIZONTAL
								 [	SPLITPANEL_MAIN, SPLITPANEL_SIDEPANE	], .. 'SPLIT_VERTICAL
								 [	SPLITPANEL_SIDEPANE, SPLITPANEL_MAIN	], ..	'SPLIT_HORIZONTAL|SPLIT_FLIPPED
								 [	SPLITPANEL_SIDEPANE, SPLITPANEL_MAIN	]]	'SPLIT_VERTICAL|SPLIT_FLIPPED
	
	Method GetSideSpace%( pSide% )
		Return GetPanelSpace(intSideToPanelMapping[intOrientation][pSide])
	EndMethod
	
	Method DrawHandle()
	
		Local tmpDimensions%[]	'0: X, 1: Y, 2: W, 3: H
		
		Select intOrientation&SPLIT_VERTICAL
		
			Case SPLIT_HORIZONTAL;tmpDimensions = [0, GetSideSpace(SPLITSIDE_TOP), ClientWidth(), intGutterSize]
			Case SPLIT_VERTICAL;tmpDimensions = [GetSideSpace(SPLITSIDE_LEFT), 0, intGutterSize, ClientHeight()]
			
		EndSelect
		
		If pnlSplitHandle Then
			SetGadgetShape(pnlSplitHandle, tmpDimensions[0], tmpDimensions[1], tmpDimensions[2], tmpDimensions[3])
			Select intOrientation&SPLIT_VERTICAL
				Case SPLIT_HORIZONTAL
					SetGadgetShape( divSplitHandle1,0,Ceil(tmpDimensions[3]/2.0)-2,tmpDimensions[2],2 )
					SetGadgetShape( divSplitHandle2,0,Ceil(tmpDimensions[3]/2.0),tmpDimensions[2],2 )
				Case SPLIT_VERTICAL
					SetGadgetShape( divSplitHandle1,Ceil(tmpDimensions[2]/2.0)-2,0,2,tmpDimensions[3] )
					SetGadgetShape( divSplitHandle2,Ceil(tmpDimensions[2]/2.0),0,2,tmpDimensions[3] )
			EndSelect
			If pixHandle[0] Then
				HideGadget(divSplitHandle1)
				HideGadget(divSplitHandle2)
			Else
				ShowGadget(divSplitHandle1)
				ShowGadget(divSplitHandle2)
			EndIf
		Else
			pnlSplitHandle = CreatePanel(tmpDimensions[0], tmpDimensions[1], tmpDimensions[2], tmpDimensions[3], gadParent, PANEL_ACTIVE)
			
			SetPanelPixmap( pnlSplitHandle, pixHandle[0]);SetGadgetToolTip(pnlSplitHandle,strToggleTooltip)
			
			Select intOrientation&SPLIT_VERTICAL
				Case SPLIT_HORIZONTAL
					divSplitHandle1 = CreateLabel("",0,Ceil(tmpDimensions[3]/2.0)-2,tmpDimensions[2],2,pnlSplitHandle,LABEL_SEPARATOR)
					divSplitHandle2 = CreateLabel("",0,Ceil(tmpDimensions[3]/2.0),tmpDimensions[2],2,pnlSplitHandle,LABEL_SEPARATOR)
				Case SPLIT_VERTICAL
					divSplitHandle1 = CreateLabel("",Ceil(tmpDimensions[2]/2.0)-2,0,2,tmpDimensions[3],pnlSplitHandle,LABEL_SEPARATOR)
					divSplitHandle2 = CreateLabel("",Ceil(tmpDimensions[2]/2.0),0,2,tmpDimensions[3],pnlSplitHandle,LABEL_SEPARATOR)
			EndSelect
			SetGadgetSensitivity(divSplitHandle1,SENSITIZE_MOUSE);SetGadgetSensitivity(divSplitHandle2,SENSITIZE_MOUSE)
			
			?Win32
			DisableGadget( divSplitHandle1 );DisableGadget( divSplitHandle2 )
			?
			
			SetGadgetToolTip( divSplitHandle1, strToggleTooltip );SetGadgetToolTip( divSplitHandle2, strToggleTooltip )
			SetGadgetLayout( divSplitHandle1, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
			SetGadgetLayout( divSplitHandle2, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
			If pixHandle[0] Then HideGadget(divSplitHandle1);HideGadget(divSplitHandle2)
			
		EndIf
	
	EndMethod
	
	Method DrawPanes()
	
		Local tmpDimensions%[][]	'0: X, 1: Y, 2: W, 3: H
		
		Select intOrientation&SPLIT_VERTICAL
			Case SPLIT_HORIZONTAL
				tmpDimensions = [[0, 0, ClientWidth(), GetSideSpace(SPLITSIDE_TOP)], [0, GetSideSpace(SPLITSIDE_TOP)+intGutterSize, ClientWidth(), GetSideSpace(SPLITSIDE_BOTTOM)]]
			Case SPLIT_VERTICAL
				tmpDimensions = [[0,0,GetSideSpace(SPLITSIDE_LEFT),ClientHeight()], [GetSideSpace(SPLITSIDE_LEFT)+intGutterSize,0,GetSideSpace(SPLITSIDE_RIGHT),ClientHeight()]]
		EndSelect
		
		If intOrientation & SPLIT_FLIPPED Then tmpDimensions = [tmpDimensions[1],tmpDimensions[0]]
		
		If pnlPanes.length <> 2 Then
			pnlPanes = [CreatePanel(0,0,1,1,gadParent,0), CreatePanel(0,0,1,1,gadParent,0)]
			ReapplyLocks()
		EndIf
		
		SetGadgetShape(pnlPanes[SPLITPANEL_MAIN], tmpDimensions[SPLITPANEL_MAIN][0], tmpDimensions[SPLITPANEL_MAIN][1], tmpDimensions[SPLITPANEL_MAIN][2], tmpDimensions[SPLITPANEL_MAIN][3])
		SetGadgetShape(pnlPanes[SPLITPANEL_SIDEPANE], tmpDimensions[SPLITPANEL_SIDEPANE][0], tmpDimensions[SPLITPANEL_SIDEPANE][1], tmpDimensions[SPLITPANEL_SIDEPANE][2], tmpDimensions[SPLITPANEL_SIDEPANE][3])
	
	EndMethod
	
	Method ChangeOrientation(pOrientation% = -1)
		If pOrientation = intOrientation Then Return
		If pOrientation < 0 Then
			intOrientation:~SPLIT_FLIPPED
		Else
			If pixHandle[0] And intOrientation&SPLIT_VERTICAL <> pOrientation&SPLIT_VERTICAL Then
				pixHandle[0] = RotatePixmap(pixHandle[0]);pixHandle[1] = RotatePixmap(pixHandle[1])
			EndIf
			intOrientation = pOrientation
		EndIf
		SetPanelPixmap(pnlSplitHandle, pixHandle[0]);DrawHandle();DrawPanes();ReapplyLocks();RedrawGadget(gadParent)
	EndMethod
	
	Method Toggle()
		If intPanelSpace > intMinPanelSpace Then SetPanelSpace( intMinPanelSpace ) Else SetPanelSpace( intSavePanelSpace )
	EndMethod
	
	Method eventHook:Object( pID%, pData:Object )
		
		Local tmpEvent:TEvent = TEvent(pData)
		If (Not tmpEvent) Or (Not TGadget(tmpEvent.source)) Then Return pData
		
		Select tmpEvent.source
			
			Case pnlSplitHandle, divSplitHandle1, divSplitHandle2
				
				If (tmpEvent.source = divSplitHandle1) Or (tmpEvent.source = divSplitHandle2) Then
					tmpEvent.x:+GadgetX(TGadget(tmpEvent.source))
					tmpEvent.y:+GadgetY(TGadget(tmpEvent.source))
					tmpEvent.source = pnlSplitHandle
				EndIf
				
				Select tmpEvent.id
					
					Case EVENT_MOUSEDOWN
						
						If (tmpEvent.data <> MOUSE_LEFT) Then Return Null
						intMouseDown = [tmpEvent.x, tmpEvent.y]
						intHasMoved = False
						
					Case EVENT_MOUSEMOVE
						
						intHasMoved = True
						
						If tmpEvent.data Then
							
							If intMouseDown Or (tmpEvent.data = MOUSE_LEFT And intShouldUpdate) Then
								
								'Update our mouse pointer and re-set our drag-point (if needed).
								ShowDragPointer()
								If intShouldUpdate Or Not intMouseDown Then
									intMouseDown = [tmpEvent.x,tmpEvent.y]
									intShouldUpdate = False
								EndIf
								
								'New values that are updated once everything has been checked
								Local tmpOrientation% = GetOrientation(), tmpPanelSpace% = -1, tmpPanelSave% = False
								
								'New size of panel if resized with mouse cursor
								Local tmpDraggedSpace% = -[tmpEvent.y-intMouseDown[1],tmpEvent.x-intMouseDown[0]][intOrientation&SPLIT_VERTICAL]
								If tmpOrientation&SPLIT_FLIPPED Then tmpDraggedSpace:*-1
								tmpDraggedSpace:+intPanelSpace
								
								'Update intPanelSpace if we can drag as any calls to GetPanelSpace() need to return an accurate value
								If (intBehavior&SPLIT_RESIZABLE) And tmpDraggedSpace <> intPanelSpace Then
									
									'Simulate a snap-closed action for the splitter
									If tmpDraggedSpace < intGutterSize Then tmpDraggedSpace = intMinPanelSpace
									
									tmpPanelSpace = tmpDraggedSpace
									intPanelSpace = tmpDraggedSpace
								EndIf
								
								'Limit the pane-size to half the client-area if SPLIT_LIMITPANESIZE is set.
								If (intBehavior&SPLIT_LIMITPANESIZE) Then
									Local tmpDimensions%[] = [ClientHeight(),ClientWidth()]
									If GetPanelSpace(SPLITPANEL_SIDEPANE) > (tmpDimensions[(tmpOrientation&SPLIT_VERTICAL)])/2 Then
										If (intBehavior&SPLIT_CANFLIP) Then
											tmpOrientation:~SPLIT_FLIPPED
											tmpPanelSpace = GetPanelSpace(SPLITPANEL_MAIN)
										Else
											tmpPanelSpace = (tmpDimensions[(tmpOrientation&SPLIT_VERTICAL)])/2
										EndIf
										tmpPanelSave = True
									EndIf
								EndIf
								
								'Update the splitter's orientation if needed.
								If (intBehavior&(SPLIT_CANORIENTATE|SPLIT_CANFLIP)) Then
									
									'Drag test conditions
									Local tmpLeftCond% = (GadgetX(pnlSplitHandle)+tmpEvent.x < 1)
									Local tmpRightCond% = (GadgetX(pnlSplitHandle)+tmpEvent.x > ClientWidth()-intGutterSize)
									Local tmpTopCond% = (GadgetY(pnlSplitHandle)+tmpEvent.y < 1)
									Local tmpBottomCond% = (GadgetY(pnlSplitHandle)+tmpEvent.y > ClientHeight()-intGutterSize)
									
									Select True
										Case (tmpRightCond And Not (tmpTopCond|tmpBottomCond)), (tmpLeftCond And Not (tmpTopCond|tmpBottomCond)), ..
										     (tmpBottomCond And Not (tmpLeftCond|tmpRightCond)), (tmpTopCond And Not (tmpLeftCond|tmpRightCond))
											If (intBehavior&SPLIT_CANFLIP) Or ((tmpLeftCond|tmpTopCond)=(tmpOrientation&SPLIT_FLIPPED)) Then
												If (intBehavior&SPLIT_CANORIENTATE) Then
													If (tmpLeftCond|tmpRightCond) Then tmpOrientation:|SPLIT_VERTICAL Else tmpOrientation:&~SPLIT_VERTICAL
												Else
													Select (tmpOrientation&SPLIT_VERTICAL)
														Case SPLIT_VERTICAL;tmpTopCond = 0;tmpBottomCond = 0
														Case SPLIT_HORIZONTAL;tmpLeftCond = 0;tmpRightCond = 0
													EndSelect
												EndIf
												'Let's determine whether our side-panel should be flipped or not.
												If (tmpLeftCond|tmpTopCond) Then tmpOrientation:|SPLIT_FLIPPED ElseIf (tmpRightCond|tmpBottomCond) Then tmpOrientation:&~SPLIT_FLIPPED
												'If we are resizable and the orientation has changed, let's reset the side-pane size.
												If (intBehavior&SPLIT_RESIZABLE) And (tmpOrientation <> intOrientation) Then tmpPanelSpace = intMinPanelSpace;tmpPanelSave = True
											EndIf
									EndSelect
									
								EndIf
								
								'Apply our newly calculated values to the splitter.
								If (tmpOrientation <> GetOrientation()) Then
									If (tmpOrientation&SPLIT_VERTICAL <> GetOrientation()&SPLIT_VERTICAL) Then
										intMouseDown = Null
										intShouldUpdate = True
									EndIf
									ChangeOrientation( tmpOrientation )
									ShowActivePointer()
								EndIf
								
								If tmpPanelSpace > -1 Then SetPanelSpace( tmpPanelSpace, tmpPanelSave )
								
							EndIf
							
						Else
							
							intMouseDown = Null
							
						EndIf
						
					Case EVENT_MOUSEUP
						
						If (intMouseDown And tmpEvent.data = MOUSE_LEFT) Then
						
							If Not intHasMoved Then
								If (intBehavior&SPLIT_CLICKTOTOGGLE) Then Toggle()
							Else
								SetPanelSpace( intPanelSpace, True )
							EndIf
							
							intMouseDown = Null
							
							ShowNormalPointer()
							
						EndIf
						
					Case EVENT_MOUSELEAVE
						
						If (intBehavior&(SPLIT_RESIZABLE|SPLIT_CLICKTOTOGGLE)) Then
							SetPanelPixmap(pnlSplitHandle, pixHandle[0])
						EndIf
						
						ShowNormalPointer()
						
					Case EVENT_MOUSEENTER
						
						If (intBehavior&(SPLIT_RESIZABLE|SPLIT_CLICKTOTOGGLE)) Then
							SetPanelPixmap(pnlSplitHandle, pixHandle[1])
						EndIf
						
						ShowActivePointer()
				
				EndSelect
				
			Case pnlPanes[SPLITPANEL_MAIN], pnlPanes[SPLITPANEL_SIDEPANE], gadParent
				
				'Don't show these events to the other hooks!
				
			Default
			
				Select tmpEvent.id
					Case EVENT_WINDOWSIZE
						If (intBehavior&SPLIT_RESIZABLE) And TGadget(tmpEvent.source).HasDescendant(gadParent) Then
							Local tmpLimit% = [ClientHeight(),ClientWidth()][intOrientation&SPLIT_VERTICAL]
							If (intBehavior&SPLIT_LIMITPANESIZE) Then tmpLimit:Shr 1 Else tmpLimit:-intGutterSize
							If GetPanelSpace(SPLITPANEL_SIDEPANE) > tmpLimit Then SetPanelSpace( tmpLimit, True )
						EndIf
				EndSelect
				
				Return pData
		EndSelect
	
	EndMethod	
	
	'Mouse Cursor
	Function ShowNormalPointer()
		SetPointer(POINTER_DEFAULT)
	EndFunction
	
	Method ShowActivePointer()
		If (intBehavior&SPLIT_RESIZABLE) Then
			Select intOrientation&SPLIT_VERTICAL
				Case SPLIT_HORIZONTAL;SetPointer(POINTER_SIZENS)
				Case SPLIT_VERTICAL;SetPointer(POINTER_SIZEWE)
			EndSelect
		ElseIf (intBehavior&SPLIT_CLICKTOTOGGLE) Then
			SetPointer(POINTER_HAND)
		Else
			SetPointer(POINTER_DEFAULT)
		EndIf
	EndMethod
	
	Method ShowDragPointer()
		If (intBehavior&SPLIT_RESIZABLE) Then
			Select intOrientation&SPLIT_VERTICAL
				Case SPLIT_HORIZONTAL;SetPointer(POINTER_SIZENS)
				Case SPLIT_VERTICAL;SetPointer(POINTER_SIZEWE)
			EndSelect
		ElseIf (intBehavior&(SPLIT_CANFLIP|SPLIT_CANORIENTATE))
			SetPointer(POINTER_SIZEALL)
		Else
			SetPointer(POINTER_DEFAULT)
		EndIf
	EndMethod
	
	'Helper Functions
	
	Function eventHandler:Object( pID%, pData:Object, pContext:Object)
		If TSplitter(pContext) Then Return TSplitter(pContext).eventHook( pID, pData ) Else Return pData
	EndFunction
	
	Function RotatePixmap:TPixmap( pSrcPixmap:TPixmap )
		Local tmpDestPixmap:TPixmap = CreatePixmap(pSrcPixmap.height, pSrcPixmap.width, pSrcPixmap.format)
		For Local y% = 0 Until pSrcPixmap.height
			For Local x% = 0 Until pSrcPixmap.width
				WritePixel( tmpDestPixmap, y, x, ReadPixel(pSrcPixmap, x, y) )
			Next
		Next
		Return tmpDestPixmap
	EndFunction
	
	Function BrightenPixmap:TPixmap( pSrcPixmap:TPixmap, pBrightness# = 1.05 )
		Local tmpDestPixmap:TPixmap = CreatePixmap(pSrcPixmap.width, pSrcPixmap.height, pSrcPixmap.format)
		For Local y% = 0 Until pSrcPixmap.height
			For Local x% = 0 Until pSrcPixmap.width
				WritePixel( tmpDestPixmap, x, y, BrightenPixel(ReadPixel(pSrcPixmap, x, y), pBrightness) )
			Next
		Next
		Return tmpDestPixmap
	EndFunction
	
	Function BrightenPixel%( pARGB%, pBrightness# = 1.05 )
		Local tmpHSV:TColorHSV = New TColorHSV.fromARGB(pARGB)
		tmpHSV.v=Min(tmpHSV.v*pBrightness,1)
		Return tmpHSV.toARGB()
	EndFunction
	
	Function WhitenPixel%( pARGB%, pWhiteness# = 0.8 )
		Local tmpHSV:TColorHSV = New TColorHSV.fromARGB(pARGB)
		tmpHSV.s=Min(tmpHSV.s*pWhiteness,1)
		Return tmpHSV.toARGB()	
	EndFunction
	
	Function MakeColourHandlePixmap:TPixmap( pRed%, pGreen%, pBlue%, pWidth% )
		Local tmpPixmap:TPixmap = CreatePixmap(1,pWidth,PF_RGB888)
		Local tmpPixel% = (pRed Shl 16)|(pGreen Shl 8)|pBlue
		For Local i% = 0 To pWidth/2
			Local tmpCalculatedPixel% = BrightenPixel(tmpPixel,1.05^i)
			WritePixel(tmpPixmap,0,i,tmpCalculatedPixel)
			WritePixel(tmpPixmap,0,pWidth-1-i,tmpCalculatedPixel)
		Next
		Return tmpPixmap
	EndFunction
	
EndType

Private

'Some type declarations from fredborg's pub.color module
'http://www.blitzbasic.com/codearcs/codearcs.php?code=1749

Type TColor
	Method toARGB:Int() Abstract	
End Type

Type TColorHSV Extends TColor
	
	Field h:Float,s:Float,v:Float,a:Float=1.0
	
	Method toRGB:TColorRGB()

		Local temph:Float = Self.h
		Local temps:Float = Self.s
		Local tempv:Float = Self.v
	
		Local rgb:TColorRGB = New TColorRGB
	
		If temph=>360.0 Or temph<0.0 Then temph = 0.0
	
		If temps = 0 Then
			rgb.r = v
			rgb.g = v
			rgb.b = v
		Else
			temph = temph / 60.0
			
			Local i:Int   = Floor(temph)
			Local f:Float = temph - i
			Local p:Float = tempv * (1 - temps)
			Local q:Float = tempv * (1 - temps * f)
			Local t:Float = tempv * (1 - temps * (1 - f))

			Select i
				Case 0
					rgb.r = v
					rgb.g = t
					rgb.b = p
				Case 1
					rgb.r = q
					rgb.g = v
					rgb.b = p
				Case 2
					rgb.r = p
					rgb.g = v
					rgb.b = t
				Case 3
					rgb.r = p
					rgb.g = q
					rgb.b = v
				Case 4
					rgb.r = t
					rgb.g = p
					rgb.b = v
				Default
					rgb.r = v
					rgb.g = p
					rgb.b = q
			End Select		
		EndIf

		rgb.a = a

		Return rgb
	
	EndMethod
	
	Function fromARGB:TColorHSV(argb:Int)
		Return TColorRGB.fromARGB(argb).toHSV()
	EndFunction
	
	Method toARGB:Int()
		Return Self.toRGB().toARGB()
	EndMethod
	
EndType

Type TColorRGB Extends TColor

	Field r:Float,g:Float,b:Float,a:Float=1.0
	
	Method toHSV:TColorHSV()
		
		Local tempr:Float = Min(1.0,Max(0.0,Self.r))
		Local tempg:Float = Min(1.0,Max(0.0,Self.g))
		Local tempb:Float = Min(1.0,Max(0.0,Self.b))

		Local minVal:Float = Min(Min(tempr,tempg),tempb)
		Local maxVal:Float = Max(Max(tempr,tempg),tempb)
		
		Local diff:Float = maxVal - minVal
	
		Local hsv:TColorHSV = New TColorHSV
		hsv.v = maxVal
	
		If maxVal = 0.0 Then
			hsv.s = 0.0
			hsv.h = 0.0
		Else
			hsv.s = diff / maxVal
	
			If tempr = maxVal
				hsv.h = (tempg - tempb) / diff
			ElseIf tempg = maxVal
				hsv.h = 2.0 + (tempb - tempr) / diff
			Else
				hsv.h = 4.0 + (tempr - tempg) / diff
			EndIf
	
			hsv.h = hsv.h * 60.0
			If hsv.h < 0 Then hsv.h = hsv.h + 360.0
		EndIf

		If hsv.h<  0.0 Then hsv.h = 0.0
		If hsv.h>360.0 Then hsv.h = 0.0
		
		hsv.a = a
		
		Return hsv
		
	EndMethod

	Function fromARGB:TColorRGB(argb:Int,alpha:Int=True)
	
		Local rgb:TColorRGB = New TColorRGB
	
		If alpha	
			rgb.a = ((argb Shr 24) & $FF)/255.0
		EndIf
		
		rgb.r = ((argb Shr 16) & $FF)/255.0
		rgb.g = ((argb Shr 8) & $FF)/255.0
		rgb.b = (argb & $FF)/255.0
	
		Return rgb
		
	EndFunction

	Function fromBGR:TColorRGB(argb:Int)
	
		Local rgb:TColorRGB = New TColorRGB
	
		rgb.r = (argb & $000000FF)/255.0
		rgb.g = ((argb Shr 8) & $000000FF)/255.0
		rgb.b = ((argb Shr 16) & $000000FF)/255.0
	
		Return rgb
		
	EndFunction

	Method toARGB:Int()
		
		Local tempr:Int = Min(255,Max(0,Int(Self.r*255)))
		Local tempg:Int = Min(255,Max(0,Int(Self.g*255)))
		Local tempb:Int = Min(255,Max(0,Int(Self.b*255)))
		Local tempa:Int = Min(255,Max(0,Int(Self.a*255)))
						
		Return (tempa Shl 24) | (tempr Shl 16) | (tempg Shl 8) | tempb

	EndMethod
	
EndType

