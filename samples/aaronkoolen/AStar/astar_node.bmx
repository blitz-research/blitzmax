' This is an implementation of an AStar Algorithm

Strict
Import "priority_queue.bmx"

'Private
' Each AStar node has a list of neighbours that it connects to
' This is the AStarNeighbourInfo type. AStarNeighbourInfo
' holds both a reference to the neighbouring nodes, but also information
' about the cost to get to that node
Type AStarNeighbourInfo
	Method getNode:AStarNode()
		Return _neighbour
	End Method

	Method edgeCost:Float()
		Return _edgeCost
	End Method

	Method free()
		_neighbour = Null
	End Method
' private
	Field _neighbour:AStarNode
	Field _edgeCost:Float			' Cost to get to this neighbour	
EndType

Public
' These are the nodes in the AStar graph
Type AStarNode Extends PriorityQueueNode
' public

' Call this to add a fully constructed neighbour node to this node
	Method addNeighbour(neighbourNode:AStarNode, edgeCost:Float)
		Local neighbourInfo:AStarNeighbourInfo = New AStarNeighbourInfo

		neighbourInfo._neighbour 	= neighbourNode
		neighbourInfo._edgeCost 	= edgeCost

		_neighbours.AddLast(neighbourInfo)
	End Method

	Method getNeighbours:TList()
		Return _neighbours
	End Method

	Method setGoalDistance(goalDistance:Float)
		_goalDistance = goalDistance
	End Method

	Method goalDistance:Float()
		Return _goalDistance
	End Method

	Method setCostToGetHere(cost:Float)
		_costFromStart = cost
	End Method

	Method costToGetHere:Float()
		Return _costFromStart
	End Method

' Yes using PTR here is what we want
	Method setParent(parent:AStarNode)
		_parentNode = parent
	End Method

	Method getParent:AStarNode()
		Return _parentNode
	End Method

' Sets whether the node is in the open list or not
	Method setInOpen(inOpen:Int)
		_inOpen = inOpen
	End Method

	Method inOpen()
		Return _inOpen
	End Method

' Sets whether the node is in the closed list or not
	Method setInClosed(inClosed:Int)
		_inClosed = inClosed
	End Method

	Method inClosed()
		Return _inClosed
	End Method

' Initialise new nodes to default values
	Method New()
		_costFromStart 	= 0
		_parentNode		= Null
		_neighbours 	= New TList
		_inOpen	 		= False
		_inClosed 		= False
		_goalDistance   = 0
	End Method

' private
	Field _costFromStart:Float			' We keep track of cost to get to this node
	Field _goalDistance:Float			' Goal to distance
	Field _parentNode:AStarNode			' Used to trace back from the end to the start of the finished path
	Field _neighbours:TList				' The neighbours of this node

	Field _inOpen:Int					' Keep track of what list the node is in
	Field _inClosed:Int

' TODO:
' These are required in order to calculate distance
' What would be better is to provide something like an AStarPos object
' with a method to get distance between them that way you could provide a more
' generic mechanism for distanc calculation
	Field _x:Int
	Field _y:Int		

End Type
