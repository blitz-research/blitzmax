' Class for walking an astar graph
' It's up to you to make the graph yourself.


Import "astar_node.bmx"
Import "priority_queue.bmx"
Import "Callback.bmx"

' Customised callback class
Type AStarCallback Extends Callback
	Field node:AStarNode;
	Field queue:PriorityQueue
End Type

Type AStarGraphWalker

' public
' Constructor
	Method New()
		_queue = New PriorityQueue
		_finalPath = New TList
	End Method

' public
' Sets the parameters for walking
' startNode - The first node in the graph where searching will start from
' endNode 	- The node you're trying to find the path to
' maxNodes 	- The maximum number of nodes in the graph you want to walk

	Method setParameters(startNode:AStarNode, endNode:AStarNode, maxNodes:Int )
		Assert startNode <> Null,"startNode Null"
		Assert endNode <> Null,"endNode Null"
		Assert maxNodes > 0,"maxNodes <= 0"
		_start = startNode;				' The start of the graph
		_end = endNode;				' The start of the graph
		_queue.setMaxSize(maxNodes)
		_parametersSet = True;
	End Method

' public
' Sets the callback function
' callback - A object with a callback() mtehod. Derive from Callback Type
	Method setCallback(callback:AStarCallback)
		_callback = callback
	End Method

	Method setDistanceFunction(func:Int)
		_distanceFunction = func
	End Method

	Method setHeuristicMultiplier(heuristic:Float)
		_heuristicMultiplier = heuristic
	End Method

' public
' Returns the final path after a path find
	Method getFinalPath:TList()
		Assert _lastWalkSucceeded, "Can't return path as last path walk failed"
		Return _finalPath
	End Method

' private
' Makes the list of successors that will be searched next
' ARGUMENTS:
' node 		- The node who's successors we're looking at
' endNode	- The destination node we're trying to get to
	Method _makeSuccessors(node:AStarNode, endNode:AStarNode)
		Local done:Int = False
		For neighbour:AStarNeighbourInfo = EachIn node.getNeighbours()
			Local neighbourNode:AStarNode = neighbour.getNode()
			Assert neighbourNode,"Node is NULL"

' Only look at neighbours that aren't the start node and also aren't in 
' the closed list (We'd be backtracking)
			If neighbourNode <> _start And Not neighbourNode.inClosed()
' Calculate total cost to get to this neighbour based on edge cost to neighbour +
' current cost to get to us
				Local cost:Float = neighbour.edgeCost() + node.costToGetHere()
' Estimate a distance to the goal from the neighbour
				Local goalDistance:Float = _distanceTo(neighbourNode, endNode)
' If heuristic was 0 then we'd have an optimal search...
				goalDistance = goalDistance * _heuristicMultiplier
' What we guess the total cost would be to get from start to finish through
' this neighbour
				Local totalCostOfNeighbourPath:Float = goalDistance + cost

' If we haven't visited this neighbour node yet at all, save it for later visiting				
' This line used to be	If Not neighbourNode.inClosed() And Not neighbourNode.inOpen()
' Don't need it as now we have the optimisation above that doesn't enter here if they
' neighbour is in the closed list
'				If Not neighbourNode.inClosed()And  Not neighbourNode.inOpen()
				If Not neighbourNode.inOpen()
' Assume we'll go from us to neighbour by setting us as the parent
					neighbourNode.setParent(node)
' Set the PQueue key as the total cost of this path to the goal
' Queue is sorted smallest first so we always look at shortest distances
					neighbourNode.setKey(totalCostOfNeighbourPath)	' Goes in queue based on total distance
' Save what we calculated that the cost was to get to this neighbour
					neighbourNode.setCostToGetHere(cost)						' What we consider it's cost is
					neighbourNode.setGoalDistance(goalDistance)						' What we consider it's cost is
					neighbourNode.setInOpen(True)
					_queue.insert(neighbourNode)
				Else
' OK, neighbour is in a list (Actually must be in Open list at this point)
' so see if we have a better path to it by seeing if the cost to get 
' to this neighbour the other way is more than the cost from our node 
' to this neighbour. 
' If it is, then our path is better 
					If neighbourNode.costToGetHere() > cost 
' If it was in the closed list, then we're going to put it in the open list
' cause we want to now be able to look at it again as a possible path
'						If neighbourNode.inClosed()
'							neighbourNode.setInClosed(False)
'						EndIf
' Above is removed because of optimisation
						neighbourNode.setParent(node)
						neighbourNode.setKey(totalCostOfNeighbourPath)	' Goes in queue based on total distance
						neighbourNode.setGoalDistance(goalDistance)		' Estimate to get to goal
						neighbourNode.setCostToGetHere(cost)			' What we consider it's cost is
'TODO: Optimise this. Rather than remove and add, we could shift in the queue if
' we knew it's index.
' Removed if below because optimisation allows us to know that we must be in the open list to get here
'						If neighbourNode.inOpen()
							pos:Int = _queue.find(neighbourNode)
							Assert pos > 0, "Was going to remove item that wasn't in queue!"
							_queue.remove(pos)
							neighbourNode.setInOpen(False)
'						EndIf
						_queue.insert(neighbourNode)
						neighbourNode.setInOpen(True)						
					EndIf
				EndIf
			EndIf
'			If _callback <> Null
'				_callback.node = node
'				_callback.queue = _queue
'				_callback.callback()
'				Flip;WaitKey
'			EndIf
		Next
	End Method


' public
' Method to walk the graph, finding the shortest path
' 
' RETURNS:
' False - Failed to find path to the end node
' True 	- Found a path to the end
' PRE: Must have called setParameters first
	Method walk()
		Assert _parametersSet,"Must call setParameters() first"

		_lastWalkSucceeded = False

		Local startNode:AStarNode = _start
		Local endNode:AStarNode =_end
		
		' Initialise starting node's information
		Local distanceToGoal:Float = _distanceTo(_start, _end)
		startNode.setCostToGetHere(0)
		startNode.setKey(distanceToGoal * _heuristicMultiplier + startNode.costToGetHere())
		startNode.setParent(Null)
		startNode.setInOpen(True)
		_queue.insert(startNode)
		
		While _queue.size() > 0
			Local node:AStarNode = AStarNode(_queue.remove())
'			node.setInOpen(False)
			node.setInClosed(True)

' Have we found our destination???
			If node = endNode Then
				Local currentNode:AStarNode = node
				While currentNode <> Null
					_finalPath.AddFirst(currentNode)
					currentNode = currentNode.getParent()
				Wend
				_lastWalkSucceeded = True
				_queue = Null
				Return True
			EndIf

			_makeSuccessors(node, endNode)
			If _callback <> Null
				_callback.node = node
				_callback.queue = _queue
				_callback.callback()
			EndIf
' temp

		Wend
		Return False
	End Method

' Resets a node so that it's ready for a new path find. Call this from whatever manages the nodes 
' as AStarGraphWalker, doesn't actually know how many, or what nodes you have, but it does know how
' to reset one
	Method resetNode(node:AStarNode)
		node._parentNode = Null
		node.setInClosed(False)
		node.setInOpen(False)
	End Method

'private

' Returns an estimated distance between two nodes
	Method _distanceTo:Float(startNode:AStarNode, endNode:AStarNode)
		Local startX = startNode._x
		Local startY = startNode._y
		Local endX = endNode._x
		Local endY = endNode._y
		Local dx = Abs(endX - startX)
		Local dy = Abs(endY - startY)
'TODO: I had distanceFunction without the _ below and Blitz Didn't complain
		Select _distanceFunction
			Case distanceEuclidean
				Return Sqr( dx * dx + dy * dy )
			Case distancePseudoEuclidean
				Return dx * dx + dy * dy
			Case distanceManhatten
				Return dx + dy
			Case distanceDiagonalShortcut
				If dx > dy
				     Return 1.4*dy + (dx-dy)
				Else
				     Return 1.4*dx + (dy-dx)
				End If
			Default
				Assert 0,"Bad distance function"
		End Select
	End Method

' Fields

' Possible ways to calculate distance. It's good to specify the edge costs between nodes
' relative to your distance calculations because as they are related. For instance, if you calculate edge costs
' using simple Euclidean distance, so that two adjacent blocks would be 1 away or 1.4 (if diagonal)
' multiplied by some small "difficulty factor", say 1 for normal roads, or 2 for water
' Then distanceEuclidean is a good estimator of distance and distancePseudoEuclidean
' tends to override the edgecosts and the pathfinder sort of busts through them. 
' This can be a good thing as it could provide a simple way to make a unit "dumber"
	Const distanceEuclidean = 0
	Const distancePseudoEuclidean = 1
	Const distanceManhatten = 2
	Const distanceDiagonalShortcut = 3

	Field _heuristicMultiplier = 1			' 0 should generate "optimal" path
	Field _start:AStarNode
	Field _end:AStarNode
	Field _distanceMode:Int = distanceEuclidean
	Field _queue:PriorityQueue
	Field _parametersSet = False
	Field _finalPath:TList
	Field _callback:AStarCallback = Null
	Field _distanceFunction = distanceEuclidean
	Field _lastWalkSucceeded = False

EndType
