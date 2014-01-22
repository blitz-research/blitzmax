Strict
'Module PUB.PriorityQueue

'ModuleInfo "Author: Aaron Koolen"
'ModuleInfo "Version: 1.0"

Rem
This is an implementation of a priority queue implemented as
a heap stored in an array.
Note, it might not be the most optimised code, as I don't know some
of the BlitzMax tricks that I might be able to do here.
Let me know if you see anything simple too slow or crappy. 
End Rem


' You should derive your nodes from this class
'
Type PriorityQueueNode
	Method setKey(key:Float)
		_key = key;
	End Method
	Field _key:Float			' I don't think blitz max has the concept of templated types?
End Type


' Main PriorityQueue class
Type PriorityQueue
' private
	Field _contents:PriorityQueueNode[]
	Field _size:Int = 0
	Field _sizeSet:Int = 0

' public

' Must call this first before you do anything
	Method setMaxSize(newSize:Int)
		Assert newSize > 0, "Must set size of queue > 0"
		_contents = New PriorityQueueNode[newSize + 1]	' We don't add any, you have to add them
		_size = 0
		_sizeSet = newSize
	End Method

'---------------------------------------
' Queue manipulation
'---------------------------------------

' Insert a node into the queue
	Method insert(newNode:PriorityQueueNode)
		Assert _sizeSet > 0,"Must call setMaxSize first with size > 0"
		Assert _size < _sizeSet, "Queue is full" 
		_size = _size + 1
		_contents[_size] = newNode
		_reheapUp(_size)
	End Method

' Remove and return a node from the queue and re-sort queue
	Method remove:PriorityQueueNode(index:Int = 1)
		Local node:PriorityQueueNode = _contents[index]
		_contents[index] = _contents[_size]
		_size = _size - 1
		_reheapDown(index, _size)
		Return node
	End Method

'---------------------------------------
' Queue searching
'---------------------------------------
	Method find:Int(node:PriorityQueueNode)
		Local t
		For t = 1 To _size
			If node = _contents[t]
				Return t
			EndIf
		Next
		Return 0
	End Method
' Return the current size of the queue
	Method size:Int()
		Return _size
	End Method

' Helper function for returning the nodes as an ordered list
	Method returnList:TList()
		Local list:Tlist = New TList
		Local a:PriorityQueueNode
		For a = EachIn _contents
			list.AddLast(remove(1))		' The '1' here removes the top item
		Next
		Return list
	End Method

'------------------------------------------------
' PRIVATE
'------------------------------------------------
' Reheap an inserted item
' ARGUMENTS:
' index - The Index of the newly inserted item
	Method _reheapUp(index:Int)
		Local parentIndex = _parent(index)
		Local ok = False
		While( index > 1 And ok = False )
			If _contents[parentIndex]._key < _contents[index]._key Then
				ok = True
			Else
				Local temp:PriorityQueueNode = _contents[parentIndex]
				_contents[parentIndex] = _contents[index]
				_contents[index] = temp
				index = parentIndex
				parentIndex = _parent(index)
			EndIf
		Wend
		Return index
	End Method

' Reheaps downward - Called after a delete of a node
' ARGUMENTS:
' root 		- Index of the root (Top of tree) item
' bottom 	-  The index of the last item in the tree
	Method _reheapDown(root:Int, bottom:Int)
		Local ok = False
		Local maxChild = 0
		
		While _left(root) <= bottom And ok = False
			If _left(root) = bottom
				maxChild = _left(root)
			Else
				If _contents[_left(root)]._key < _contents[_right(root)]._key 
					maxChild = _left(root)
				Else
					maxChild = _right(root)
				EndIf				
			EndIf
			If Not (_contents[root]._key < _contents[maxChild]._key) Then
				Local t:PriorityQueueNode = _contents[root]
				_contents[root] = _contents[maxChild]
				_contents[maxChild] = t
				root = maxChild
			Else
				ok = True
			EndIf
		Wend		
		Return root
	End Method

' Returns the index of the parent node to a child node
	Method _parent:Int(childIndex:Int)
		Return childIndex / 2
	End Method

' Returns the index of the left child of a node
	Method _left:Int(siblingIndex:Int)
		Return siblingIndex * 2
	End Method

' Returns the index of the right child of a node
	Method _right:Int(siblingIndex:Int)
		Return siblingIndex * 2 +1
	End Method

End Type

