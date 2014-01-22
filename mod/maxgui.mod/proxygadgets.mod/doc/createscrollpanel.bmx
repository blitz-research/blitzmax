Strict

Import MaxGUI.Drivers
Import MaxGUI.ProxyGadgets

AppTitle = "Scroll Panel Example"
SeedRnd MilliSecs()

Global wndMain:TGadget = CreateWindow(AppTitle,100,100,400,300,Null,WINDOW_TITLEBAR|WINDOW_RESIZABLE|WINDOW_CENTER|WINDOW_CLIENTCOORDS|WINDOW_STATUS)
	
	' Create a scroll-panel
	Global scrlMain:TScrollPanel = CreateScrollPanel( 0, 0, ClientWidth(wndMain), ClientHeight(wndMain)-30, wndMain, SCROLLPANEL_SUNKEN )
	SetGadgetLayout scrlMain,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
	
	' Retrieve the panel that is scrolled
	Local tmpClient:TGadget = ScrollPanelClient(scrlMain)
	
	' Draw some buttons on the scroll-panel
	Local tmpButton:TGadget
	
	For Local i:Int = 1 To 50
		tmpButton = CreateButton( "Button " + i, 0, (i-1)*35, ClientWidth(scrlMain)-20, 30, tmpClient, BUTTON_PUSH )
		SetGadgetTextColor tmpButton,Rand(0,255),Rand(0,255),Rand(0,255)
		SetGadgetLayout tmpButton,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_CENTERED
	Next
	
	' Resize the scrollable region tight around the buttons
	FitScrollPanelClient( scrlMain, SCROLLPANEL_SIZETOKIDS )
	
	' Add some buttons for testing the ScrollScrollPanel function.
	Global btnTopLeft:TGadget = CreateButton( "Top Left", 0, ClientHeight(wndMain)-30, ClientWidth(wndMain)/4, 30, wndMain, BUTTON_PUSH )
	SetGadgetLayout( btnTopLeft, EDGE_ALIGNED, EDGE_RELATIVE, EDGE_CENTERED, EDGE_ALIGNED )
	SetGadgetToolTip( btnTopLeft, "ScrollScrollPanel( scrlMain, SCROLLPANEL_LEFT, SCROLLPANEL_TOP )" )
	
	Global btnTopRight:TGadget = CreateButton( "Top Right", ClientWidth(wndMain)/4, ClientHeight(wndMain)-30, ClientWidth(wndMain)/4, 30, wndMain, BUTTON_PUSH )
	SetGadgetLayout( btnTopRight, EDGE_RELATIVE, EDGE_RELATIVE, EDGE_CENTERED, EDGE_ALIGNED )
	SetGadgetToolTip( btnTopRight, "ScrollScrollPanel( scrlMain, SCROLLPANEL_RIGHT, SCROLLPANEL_TOP )" )
	
	Global btnBottomLeft:TGadget = CreateButton( "Bottom Left", 2*ClientWidth(wndMain)/4, ClientHeight(wndMain)-30, ClientWidth(wndMain)/4, 30, wndMain, BUTTON_PUSH )
	SetGadgetLayout( btnBottomLeft, EDGE_RELATIVE, EDGE_RELATIVE, EDGE_CENTERED, EDGE_ALIGNED )
	SetGadgetToolTip( btnBottomLeft, "ScrollScrollPanel( scrlMain, SCROLLPANEL_LEFT, SCROLLPANEL_BOTTOM )" )
	
	Global btnBottomRight:TGadget = CreateButton( "Bottom Right", 3*ClientWidth(wndMain)/4, ClientHeight(wndMain)-30, ClientWidth(wndMain)/4, 30, wndMain, BUTTON_PUSH )
	SetGadgetLayout( btnBottomRight, EDGE_RELATIVE, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED )
	SetGadgetToolTip( btnBottomRight, "ScrollScrollPanel( scrlMain, SCROLLPANEL_RIGHT, SCROLLPANEL_BOTTOM )" )
	
Repeat
	Select WaitEvent()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
		Case EVENT_GADGETACTION
			Select EventSource()
				Case btnTopLeft
					ScrollScrollPanel( scrlMain, SCROLLPANEL_LEFT, SCROLLPANEL_TOP )
				Case btnTopRight
					ScrollScrollPanel( scrlMain, SCROLLPANEL_RIGHT, SCROLLPANEL_TOP )
				Case btnBottomLeft
					ScrollScrollPanel( scrlMain, SCROLLPANEL_LEFT, SCROLLPANEL_BOTTOM )
				Case btnBottomRight
					ScrollScrollPanel( scrlMain, SCROLLPANEL_RIGHT, SCROLLPANEL_BOTTOM )
			EndSelect
	EndSelect
	SetStatusText wndMain, "ScrollPanelX(): " + ScrollPanelX( scrlMain ) + ", ScrollPanelY():" + ScrollPanelY( scrlMain )
Forever
