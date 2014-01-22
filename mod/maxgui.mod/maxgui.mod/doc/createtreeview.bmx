' createtreeview.bmx

Import MaxGui.Drivers

Strict 

Local window:TGadget=CreateWindow("My Window",50,50,240,240,Null,WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
Local treeview:TGadget=CreateTreeView(5,5,ClientWidth(window)-10,ClientHeight(window)-10,window)

SetGadgetLayout treeview, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED

Local root:TGadget=TreeViewRoot(treeview)

Local help:TGadget=AddTreeViewNode("Help",root)
AddTreeViewNode "Topic 1",help
AddTreeViewNode "Topic 2",help
AddTreeViewNode "Topic 3",help

Local projects:TGadget=AddTreeViewNode("Projects",root)
AddTreeViewNode("Sub Project",AddTreeViewNode("Project 1",projects))
AddTreeViewNode("Project 2",projects)
AddTreeViewNode("Project 3",projects)

While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
	End Select
Wend
