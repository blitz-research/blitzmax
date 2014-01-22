Strict

Import MaxGUI.Drivers
Import MaxGUI.ProxyGadgets

Global wndMain:TGadget = CreateWindow("Splitter Example",100,100,400,300,Null,WINDOW_TITLEBAR|WINDOW_RESIZABLE|WINDOW_CENTER|WINDOW_CLIENTCOORDS|WINDOW_STATUS)
	
	'Create a splitter gadget
	Global spltMain:TSplitter = CreateSplitter( 0, 0, ClientWidth(wndMain), ClientHeight(wndMain), wndMain )
	SetGadgetLayout spltMain,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
	
	Local tmpSplitPanel:TGadget
		
		'Add a gadget to our left pane
		tmpSplitPanel = SplitterPanel(spltMain,SPLITPANEL_MAIN)
		Global txtEditor:TGadget = CreateTextArea(0,0,ClientWidth(tmpSplitPanel),ClientHeight(tmpSplitPanel),tmpSplitPanel,TEXTAREA_WORDWRAP)
		SetGadgetLayout(txtEditor,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED)
		
			AddTextAreaText(txtEditor, "The quick brown fox jumped over the lazy dogs.~n~n")
			AddTextAreaText(txtEditor, "The quick brown fox jumped over the lazy dogs.~n~n")
			AddTextAreaText(txtEditor, "The quick brown fox jumped over the lazy dogs.~n~n")
		
		'Add a gadget to our right pane
		tmpSplitPanel = SplitterPanel(spltMain,SPLITPANEL_SIDEPANE)
		Global treeView:TGadget = CreateTreeView(0,0,ClientWidth(tmpSplitPanel),ClientHeight(tmpSplitPanel),tmpSplitPanel)
		SetGadgetLayout(treeView,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED)
		
			AddTreeViewNode("Child", AddTreeViewNode("Parent Node", TreeViewRoot(treeView)))
			AddTreeViewNode("Other", TreeViewRoot(treeView))
	
Repeat
	WaitEvent()
	SetStatusText wndMain, CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
	EndSelect
Forever