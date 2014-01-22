Strict
'
' Simple demo program of an astar path finding algorithm
' The GUI is pretty crappy
' There are quite a few comments in the areas of importance. Sometimes this makes
' the code a little harder to read, but this was done for instructional purposes foremost

Import "astar_graph_walker.bmx"
Import "Callback.bmx"

Global nums:TImage

Local demo:AStarDemo = New AStarDemo
demo.run()
End


Private
' Small class that encapsulates a position on the map
Type MapPos
	Method isAtPos(otherX, otherY)
		Return otherX = x And otherY = y
	End Method
	Field x,y
End Type


' Class that defines the terrain types that the demo uses
Type Terrain
	Method set(weight:Int, filename:String)
		_weight = weight
		_image = LoadImage(filename)
	End Method
	Field _colour_r,_color_g,_color_b
	Field _weight:Int
	Field _image:TImage
End Type

' Main application class
Type AStarDemo

' Map stuff
	Const blockAreaWidth:Int = 600
	Const blockAreaHeight:Int = 600
	Const mapHeight:Int = 20
 	Const mapWidth:Int = 20
	Const blockWidth:Int = 600 / 20	
	Const blockHeight:Int = 600 / 20
' Block map
	Field map:Int[mapWidth, mapHeight]

' Node version of map
	Field nodeMap:AStarNode[mapWidth, mapHeight]
	Field startPos:MapPos
	Field endPos:MapPos
	Field currentMap = 0

' Terrain information
	Const numTerrainTypes = 4
	Field terrainFilenames:String[] = [ "road.png", "mountain.png", "water.png", "tree.png" ]
	Field terrainWeights:Int[] = [ 1, -1, 4, 2 ]
	Field terrains:Terrain[numTerrainTypes]
	Field currentTerrainIndex:Int = 1
	Field terrainLegendBlockX:Int
	Field terrainLegendBlockY:Int

' Path finding stuff
' Distance
	Const numDistanceFunctions = 4	
' Is there a DATA like statement in Blitz?
	Field distanceNames:String[] = [ 	"(D) Euclidean Sqr(dx*dx+dy*dy)", ..
									 	"(D) Pseudo Euclidean dx*dx+dy*dy", ..
										"(D) Manhatten dx+dy", ..
										"(D) Diagonal Shortcut dx>dy ? 1.4*dy + (dx-dy) : 1.4*dx + (dy-dx)" ]

	Field distanceFunction = AStarGraphWalker.distanceEuclidean	

' Whether we're allowed to chage the costs with the "Q" and "W" keys
	Field costChangeAllowed:Int 	= 0
' Is the pathfinder allowed to cruise diagonals?
	Field allowDiagonalPaths:Int 	= 0
	Field diagonalsAreLonger:Int = 1
' Time in millisecs that the last path fund took
	Field lastRunTime:Int = 0
	Field path:TList = Null			' The last path that was found

	Field heuristicMultiplier:Float = 1.0
	Field showProgress:Int = False	' Do we want to show the progress

' UI stuff
	Field mapButtonBlockX:Int = 0
	Field mapButtonBlockY:Int = mapHeight + 1

	Field showCosts:Int = 1
	Field flagRedraw:Int = 1
	Field textScale:Float = 800.0/1024.0
	Field message:String = ""				' Any stat messages that are to be displayed

' Input stuff
' Used to detect mouse movements
	Field oldBlockX:Int = -1
	Field oldBlockY:Int = -1
' Help
	Field help:String[] = [ ..
		"A - Allow/Disallow diagonals", ..
		"Q - Divide terrain costs by 5", ..
		"W - Multiply terrain costs by 5", ..
		"D - Cycle distance functions", ..
		"V - Toggle diagonal multiplier", ..
		"S - Point mouse and press to set start node", ..
		"E - Point mouse and press to set end node", ..
		"P - Run AStar, showing progress", ..
		"H - Click and drag on 'H' to change heuristic mult.", ..
		"Click white square to load map of that number", ..
		"Click red 'S' to save map as map # 'Current Map'", ..
		"ESC - Quit program", ..
		"", ..
		"In progress mode:", ..
		"Top Number    = Cost to get to that node", ..
		"Mid Number    = Heurisitc from node to end", ..
		"Bottom Number = Cost from start to end", ..
		"                Through that node", ..
		"Press 'P' to pause", ..
		"ESC to quit progress mode", ..
		"", ..
		"Handy Hints", ..
		"If DistanceFunc * heuristic Multiplier = ", ..
		"True distance to goal, fastest path generated", ..
		"", ..
		"Heuristic Mult = 0 then optimal path for", ..
		"chosen Distance Func "..
	]

' This is the main entry point for the class
	Method run()
	
' Setup the graphics stuff
		Graphics 1024,768,32
		
		nums = LoadAnimImage("nums.png",5,8,0,12)
		Assert nums<> Null,"Can't load number graphic nums.png"
		
' Initialise dimensions of maps and other useful data
		initialise()
		
' Load the first map by default
		loadMap(currentMap)
		
' Redraw 
		redraw()
		
		While Not KeyDown(27)

			Local m:Int = MouseDown(1)

			Local blockX = MouseX() / blockWidth
			Local blockY = MouseY() / blockHeight

			If m
				handleMouseDown(blockX, blockY)
			EndIf

			processStartPlaced(blockX, blockY)
			processEndPlaced(blockX, blockY)
			processAllowDiagonalPaths()
			processShowProgress()
			processCycleDistanceFunction()
			processDiagonalsAreLonger()
			processDecreaseTerrainCost()
			processIncreaseTerrainCost()

			If flagRedraw 
				oldBlockX = -1				' Mark for refresh of mouse movement
				lastRunTime = runAStar()
				redraw()
				flagRedraw = False
			EndIf

		Wend
		EndGraphics
	End Method

'-------------------------------------
' Input handling functions
'-------------------------------------

	Method processIncreaseTerrainCost()
		If KeyHit(KEY_W)
			Local t
			For t = 0 To numTerrainTypes - 1
				terrains[t]._weight = terrains[t]._weight * 5
			Next
			setRedraw(True)
			costChangeAllowed = costChangeAllowed + 1
		EndIf
	End Method

	Method processDecreaseTerrainCost()
		If KeyHit(KEY_Q) And costChangeAllowed > 0
			Local t
			For t = 0 To numTerrainTypes - 1
				terrains[t]._weight = terrains[t]._weight / 5
			Next
			setRedraw(True)
			costChangeAllowed = costChangeAllowed - 1
		EndIf
	End Method

	Method processDiagonalsAreLonger()
		If KeyHit(KEY_V)
			diagonalsAreLonger = 1 - diagonalsAreLonger
			setRedraw(True)
		EndIf
	End Method

' Cycling the distance function to use?
	Method processCycleDistanceFunction()
		If KeyHit(KEY_D)
			distanceFunction = (distanceFunction + 1) Mod numDistanceFunctions
			setRedraw(True);
		EndIf
	End Method

' Clear the last calculated path?
	Method processClearPath()
		If KeyHit(KEY_P)
			path = Null
			setRedraw(True)
		EndIf
	End Method

	Method processShowProgress()
		If KeyHit(KEY_P)
			showProgress = True
			runAStar()
			showProgress = False
		EndIf
	End Method

' Allow diagonal toggled?
	Method processAllowDiagonalPaths()
		If KeyHit(KEY_A)
			allowDiagonalPaths = 1 - allowDiagonalPaths
			setRedraw(True)
		EndIf
	End Method

' Check if they want to move the start node
	Method processStartPlaced(blockX:Int, blockY:Int)
			If KeyHit(KEY_S)
				If blockInMapArea(blockX, blockY)
'					setMapBlock(blockX, blockY,0)
					startPos.x = blockX
					startPos.y = blockY
					setRedraw(True)
				EndIf					
			EndIf
	End Method

' Check if they want to move the end node
	Method processEndPlaced(blockX:Int, blockY:Int)
			If KeyHit(KEY_E)
				If blockInMapArea(blockX, blockY)
'					setMapBlock(blockX, blockY,0)
					endPos.x = blockX
					endPos.y = blockY
					setRedraw(True)
				EndIf					
			EndIf
	End Method



' Call this to tell the main engine to redraw
	Method setRedraw(doRedraw:Int)
		flagRedraw = doRedraw
	End Method

' Use this to change a map block while editing, so that redraws are sped up
	Method setMapBlock(blockX, blockY, block)
		map[blockX, blockY] = block
	End Method

' Redraws the map and last found path. You can tell it to draw more than once for double buffer purposes
	Method redraw(times:Int = 1, flipIt:Int = 1)
		While times > 0
			drawMap()
			drawPath()
			drawTerrains()
			drawInfo()
			drawMapButtons()
			If flipIt Then Flip
			times :- 1
		Wend
	End Method

	Method saveMap:String(mapNumber:Int)
		Local stream:TStream = WriteStream("littleendian::map"+mapNumber)		
		If stream = Null
			Return "Error saving map"
		EndIf
		Local x,y;
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1
				WriteInt(stream,map[x,y])
			Next
		Next
		WriteInt stream, startPos.x
		WriteInt stream, startPos.y
		WriteInt stream, endPos.x
		WriteInt stream, endPos.y
		CloseStream stream
		Return "Done"
	End Method

	Method loadMap(mapNumber:Int)
		Local stream:TStream = ReadStream("littleendian::map"+mapNumber)
		If stream = Null
			Return
		EndIf
		Local x,y;
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1
				map[x,y] = Readint(stream)
			Next
		Next		
		startPos.x = Readint(stream)
		startPos.y = Readint(stream)
		endPos.x = Readint(stream)
		endPos.y = Readint(stream)
		CloseStream stream
	End Method


' Handle mouse click
	Method handleMouseDown(blockX:Int, blockY:Int)

		If blockX = oldBlockX And blockY = oldBLockY
			setRedraw(False)
			Return
		EndIf
		oldBlockX = blockX
		oldBlockY = blockY

' Make sure they can't edit over the start and end positions
		If startPos.isAtPos(blockX, blockY)
			setRedraw(False)
			Return
		EndIf
		If endPos.isAtPos(blockX, blockY)
			setRedraw(False)
			Return
		EndIf

' See if they are selecting a new terrain
		If blockX = terrainLegendBlockX And blockY >= terrainLegendBlockY And blockY < terrainLegendBlockY + numTerrainTypes
			currentTerrainIndex = blockY - terrainLegendBlockY 
			Return
		EndIf

		If blockInMapArea(blockX, blockY)
			map[blockX, blockY] = currentTerrainIndex
			setRedraw(True)
			Return
		EndIf

' See if we have selected a new map
		If blockX >= mapButtonBlockX And blockY = mapButtonBlockY
			Local block:Int = blockX - mapButtonBlockX
			Select block
				Case 8
					message = saveMap(currentMap)
				Case 9
					handleHeuristic()
				Default
					If block < 8 
						currentMap = block
						loadMap(currentMap)
					EndIf
			End Select
		EndIf
		setRedraw(True)
		Return			' Signal that we've moved the mouse and done something
	End Method


	Method handleHeuristic()
		Local oldX:Int = MouseX()
		Local oldY:Int = MouseY()

		While MouseDown(1)
			Local x:Int = MouseX()
			Local y:Int = MouseY()
			If  x <> oldX
				heuristicMultiplier = heuristicMultiplier + (x - oldX) / 10.0
				If heuristicMultiplier < 0 heuristicMultiplier = 0
				If heuristicMultiplier > 10 heuristicMultiplier = 10
				runAStar()
				redraw(2)
				oldX:Int = x
				oldY:Int = y
			EndIf
		Wend
	End Method

' Are the block coordinates with in the map area?
	Method blockInMapArea(blockX:Int, blockY:Int)
		Return blockX >= 0 And blockY >= 0 And blockX < mapWidth And blockY < mapHeight 
	End Method


	Method drawPath()
		If path <> Null
			Local a:Object
			For a:Object = EachIn path
				Local node:AStarNode = AStarNode(a)
				SetColor 255,255,0
				DrawRect node._x * blockWidth, node._y * blockHeight, blockWidth - 1, blockHeight - 1
			Next
		EndIf
	End Method

' Draw the information text in the editor
	Method drawInfo()
' Clear 
		Local y = mapButtonBlockY * blockHeight + blockHeight
		SetColor 0,0,0
		DrawRect 0, y, blockAreaWidth, blockHeight*5

' Draw the distance function used
		SetColor 255,255,255
		DrawText distanceNames[distanceFunction], 0, y 

' Whether diagonals are allowed or not
		Local path:String
		If allowDiagonalPaths
			path = "(A) Diagonals allowed"
		Else
			path = "(A) Diagonals not allowed"
		EndIf
		DrawText path, 0, y + TextHeight(path)
		
' How long last path walk took		
'		Local percentOfFrame:Float = lastRunTime * (60.0/1000.0) * 100.0
'		DrawText "Milli:" + lastRunTime + "   % of 60th:" + percentOfFrame, 0, y + FontHeight() * 5

'	
		Local diagonals:String;
		If diagonalsAreLonger 
			diagonals = "(V) Diagonals are longer than straights"
		Else
			diagonals = "(V) Diagonals are same as straights"
		EndIf
		DrawText diagonals, 0, y + TextHeight(diagonals) * 2

		DrawText "Heuristic:" + heuristicMultiplier, 0, y + TextHeight(heuristicMultiplier) * 4
		SetColor 255,0,0
		DrawText message, 0, y + TextHeight(message) * 5
		SetColor 255,255,255

' Draw help
		Local a:String
		Local count:Int = 0
		For a:String = EachIn help
			DrawText a, blockAreaWidth, blockAreaHeight / 4 + count * TextHeight(a)
			count = count + 1
		Next
	End Method

	Method drawMapButtons()
		Local y = mapButtonBlockY * blockHeight
		Local x = mapButtonBlockX * blockWidth
		Local startX = x
		Local t
		Local output:String
		For t = 0 To 9
			If t < 8 
				SetColor 255,255,255
				output = t
			Else If t = 8
				SetColor 255,0,0
				output = "S"
			Else If t = 9
				SetColor 0,255,0
				output = "H"
			EndIf
			DrawRect x, y, blockWidth - 1, blockHeight
			SetColor 0,0,0
			DrawText output, x, y
			x = x + blockWidth
		Next
' Current map
		y = mapButtonBlockY * blockHeight  - blockHeight
		x = mapButtonBlockX * blockWidth
		SetColor 0,0,0
		DrawRect x,y,blockAreaWidth,TextHeight(" ")
		SetColor 255,255,255
		DrawText "Current map:" +  currentMap, x, y

	End Method

	Method drawTerrains()
		Local t
		For t = 0 To numTerrainTypes - 1
			Local terrain:Terrain = terrains[t]
			Local x = terrainLegendBlockX * blockWidth
			Local y = (terrainLegendBlockY + t)* blockHeight

			SetColor 0,0,0
			DrawRect x, y, blockWidth * 5, blockHeight

			SetColor 255,255,255
			SetScale blockWidth / 32.0, blockHeight / 32.0
			DrawImage terrain._image, x, y
			SetScale 1,1
	
			If showCosts
				SetColor 255,255,255
				DrawText terrain._weight, x + blockWidth , y
			EndIf
	Next
	End Method

	Method drawMap()
		SetColor 0,0,0
		DrawRect 0, 0, blockAreaWidth, blockAreaHeight
		Local x,y;
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1
				drawMapBlock(x,y)
			Next
		Next		
	End Method

	Method drawMapBlock(x:Int, y:Int)
		SetColor 255,255,255
		If startPos.isAtPos(x,y)
			SetColor 255,255,0
		Else If endPos.isAtPos(x,y)
			SetColor 255,0,0
		Else
'			SetColor(terrains[map[x,y]]._colour)
		EndIf
		SetScale blockWidth / 32.0, blockHeight / 32.0
		DrawImage terrains[map[x,y]]._image, x * blockWidth, y * blockHeight
		SetScale 1,1
	End Method

	Method drawOnMap(x:Int, y:Int, r,g,b, margin:Int)
		SetColor r,g,b
		DrawRect x * blockWidth + margin, y * blockHeight + margin, blockWidth - margin * 2, blockHeight - margin * 2
	End Method

	Method printOnMap(x:Int, y:Int, text:String, offset:Int)
		SetColor 255,255,255
		SetScale textScale,textScale
		DrawText text, x * blockWidth, y * blockHeight + offset
		SetScale 1,1
	End Method

	Method printNums(s:String, x:Int, y:Int, offset:Int)
		x = x * blockWidth + blockWidth / 2 - (Len(s) * 5)/2
		y = y * blockHeight + offset
		SetColor 255,255,255
		SetMaskColor 255,0,255
		SetScale 1,1
		Local t
		For t = 0 To Len(s) - 1
			DrawImage nums, x, y, Byte(s[t]) - 46
			x:+5
		Next
	End Method


' Initialise the map and edit stuff
	Method initialise()
	
'		blockWidth = blockAreaWidth / mapWidth
'		blockHeight = blockAreaHeight / mapHeight

' Setup other interactive pieces
		terrainLegendBlockX = mapWidth + 1
		terrainLegendBlockY = 0
	
'		map = Array:Int[mapWidth, mapHeight]
'		nodeMap = Array:AStarNode[mapWidth, mapHeight]

' Initialise terrain types
		Local t
		For t = 0 To numTerrainTypes - 1
			Local newTerrain:Terrain = New Terrain
			newTerrain.set(terrainWeights[t], terrainFilenames[t])
			terrains[t] = newTerrain
		Next

		startPos = New MapPos
		startPos.x = 1
		startPos.y = 1
	
		endPos = New MapPos
		endPos.x = mapWidth - 2
		endPos.y = mapHeight - 2
		
' Initialise the map
		SeedRnd MilliSecs()
		Local y
		Local x
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1
				Local value:Int = 0'Rand(0,numTerrainTypes - 1)

				If y = 0 Or y = mapHeight - 1 Or x = 0 Or x = mapWidth - 1
					value = 1
				EndIf

				map[x,y] = value 'Readint(stream)
			Next
		Next
	End Method

' This runs AStar with the current setup

	Method runAStar()

' The first thing you need to do before using the AStarGraphWalker is to create your nodes, and link them up
' with edges. What I do is first make an array of the nodes, this makes it easy to map nodes to map blocks if
' I need to and other things.
' Then I go over the node array and create links to the neighbouring nodes.
'
' NOTE: In my implementation you will notice that between two blocks, two edges are created.
' Block 1 has an edge to block 2 (which is it's neighbour) and viceversa. If you wanted to
' simplify this, you could, but you'd have to change the datastructure a little. I prefer my way (Except of course 
' that more memory is consumed) because I can have different costs to get from A to B than from B to A, for example
' if A was at the top of a hill and B at the bottom. In that case, going from A to B is generally easier than B to A
		Local x:Int
		Local y:Int
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1
				nodeMap[x,y] = New AStarNode
				Local node:AStarNode = nodeMap[x,y]
				node._x = x			' AStar needs these positions for distance estimation
				node._y = y
			Next
		Next
' This is just an array of offsets to give us our neighbours
		Const offsetCount:Int = 8
		Local xOffset:Int[] = [ 0,1,1,1,0,-1,-1,-1 ]
		Local yOffset:Int[] = [ -1,-1,0,1,1,1,0,-1 ]

' How we move through the offsets, so we can support "no diagnoal" paths
		Local offsetStep:Int = 1
		If Not allowDiagonalPaths
			offsetStep = 2
		EndIf

' This loop builds up all the neighbour lists for a node		
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1		
				If map[x,y] = 1
					Continue		' We don't worry about this node if we aren't passable
				EndIf
				Local node:AStarNode = nodeMap[x,y]
' Now look around the map for neighbours and make nodes 
' Joining the current one with a neighbour
				Local off = 0
				While off < offsetCount
					Local neighbourX = x + xOffset[off]
					Local neighbourY = y + yOffset[off]		
' Check that the neighbour position is within the map bounds and is actually
' not block 1 which I've designated as a block we can't go through at all so no point
' making a neighbour of it
					If map[neighbourX, neighbourY] <> 1 And neighbourX >= 0 And neighbourX < mapWidth And neighbourY >=0 And neighbourY < mapHeight
						Local value:Int = terrains[map[x,y]]._weight
						Local neighbourValue:Int = terrains[map[neighbourX,neighbourY]]._weight

' Here is where you calculate the costs of the edge between two nodes. Because our map is square and the neighbour
' I'm looking at is adjacent to the current node, then I can just take an average of the costs of each block.
' E.G If the current block is water, and the neighbour is forest, I'd be walking half in water and half in forest
' This isn't really necessary but I do it anyway
						Local edgeCost:Float = (value + neighbourValue) / 2.0
' Now if it's a diagonal we might want to make the cost of this edge higher to signify that
' travelling diagonally in a suare environment like ours is a longer distance
						If diagonalsAreLonger And xOffset[off] <> 0 And yOffset[off] <> 0
							edgeCost = edgeCost * 1.4;
						EndIf		
						node.addNeighbour(nodeMap[neighbourX, neighbourY], edgeCost)
					EndIf		
					off = off + offsetStep
				Wend
			Next
		Next		

' We have our node, so we can set up our AStarGraphWalker now.
		Local walker:AStarGraphWalker = New AStarGraphWalker
		
		walker.setParameters(nodeMap[startPos.x,startPos.y], nodeMap[endPos.x,endPos.y], mapWidth * mapHeight)
		walker.setDistanceFunction(distanceFunction)		' If not called, default is distanceEuclidean
		walker.setHeuristicMultiplier(heuristicMultiplier)			' If not called, default to 1

' Set up our callback information. The callback is called after one node has been popped and processed
		Local callback:WalkerCallback = New WalkerCallback
		callback._walker = walker
		callback._application = Self
		If showProgress 
			walker.setCallback(callback)
		EndIf

		Local start:Int = MilliSecs()
		Local res:Int = walker.walk()		
		Local time:Int = MilliSecs() - start

		If res
			path = walker.getFinalPath()		
			If showProgress 
				drawPath()
				Flip
			EndIf
		Else
			path = Null
		EndIf
'EndRem

' Tidy up after ourselves
	walker.setCallback(Null)	

' Need to make sure memory gets freed because we have references to objects all over
' the place
		For y = 0 To mapHeight - 1
			For x = 0 To mapWidth - 1		
				Local node:AStarNode = nodeMap[x,y]				
				Local neighbour:AStarNeighbourInfo
				For neighbour:AStarNeighbourInfo = EachIn node.getNeighbours()
					neighbour.free()
				Next
				walker.resetNode(node)
				nodeMap[x,y] = Null
			Next
		Next
		Return time
	End Method
EndType

' This is our personal callback function so that we can draw the map. In a real implementation you might not have this
' or maybe the callback allows you to check to see if the algorithm is taking too long and so pause for a frame and continue
' next frame. You'd need some more work that though
Type WalkerCallback Extends AStarCallback

	Method New()
		_waitForKey = True			' If ever set to false, then we are ignoring the callback so we just return
	End Method

	Method callback()
			If _waitForKey = False 			' If not waiting for key, then we've finished
				While KeyDown(27) Wend
				_application.setRedraw(True)
				Return
			EndIf
			Local currentNode:AStarNode = node
		
			_application.redraw(1,0)
			Local x:Int
			Local y:Int

			For y = 0 To _application.mapHeight - 1
				For x = 0 To _application.mapWidth - 1
					Local node:AStarNode = _application.nodeMap[x,y]
					Local col_r=128,col_g=128,col_b=128
					Local do:Int = 0;
					If node.inClosed() Or Not node.inOpen() Then 
						Continue
					EndIf
					If node.inOpen() Then 
						col_r=0 ; col_g=0 ;col_b=255
						do = 1
					EndIf
					If do Then 
						_application.drawOnMap(node._x, node._y, col_r, col_g, col_b , 2 )
						_application.printNums(oneDec(node.costToGetHere()), node._x , node._y, 4 )
						_application.printNums(oneDec(node._goalDistance), node._x , node._y, 11 )
						_application.printNums(oneDec(node._key), node._x , node._y, 18 )
					EndIf
				Next
			Next	
			Flip
			
			If KeyHit(KEY_P)
				WaitKey
			EndIf
			If KeyDown(27)
				_waitForKey = False
			EndIf

	End Method

' Makes a single decimal place string from a number - ugly....
	Method oneDec:String(number:Float)
		Return String(Int(number)) + "." + Int((number-Int(number))*10)
	End Method

	Field _walker:AStarGraphWalker;
	Field _application:AStarDemo;
	Field _waitForKey:Int
EndType


