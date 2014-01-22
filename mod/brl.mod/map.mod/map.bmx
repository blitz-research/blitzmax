
Strict

Rem
bbdoc: Data structures/Maps
End Rem
Module BRL.Map

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Fixed MapKeys/MapValues functions to return enumerators"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Restored KeyValue enumerator"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added Copy method"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Fixed Clear memleak"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Finally changed to red/back tree!"
ModuleInfo "History: Added procedural interface"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Fixed TMap.Remove:TNode not returning node"

Private

Global nil:TNode=New TNode

nil._color=TMap.BLACK
nil._parent=nil
nil._left=nil
nil._right=nil

Public

Type TKeyValue

	Method Key:Object()
		Return _key
	End Method
	
	Method Value:Object()
		Return _value
	End Method
	
	'***** PRIVATE *****

	Field _key:Object,_value:Object

End Type

Type TNode Extends TKeyValue

	Method NextNode:TNode()
		Local node:TNode=Self
		If node._right<>nil
			node=_right
			While node._left<>nil
				node=node._left
			Wend
			Return node
		EndIf
		Local parent:TNode=_parent
		While node=parent._right
			node=parent
			parent=parent._parent
		Wend
		Return parent
	End Method
	
	Method PrevNode:TNode()
		Local node:TNode=Self
		If node._left<>nil
			node=node._left
			While node._right<>nil
				node=node._right
			Wend
			Return node
		EndIf
		Local parent:TNode=node._parent
		While node=parent._left
			node=parent
			parent=node._parent
		Wend
		Return parent
	End Method
	
	Method Clear()
		_parent=Null
		If _left<>nil _left.Clear
		If _right<>nil _right.Clear
	End Method
	
	Method Copy:TNode( parent:TNode )
		Local t:TNode=New TNode
		t._key=_key
		t._value=_value
		t._color=_color
		t._parent=parent
		If _left<>nil t._left=_left.Copy( t )
		If _right<>nil t._right=_right.Copy( t )
		Return t
	End Method
	
	Method Key:Object()
		Return _key
	End Method
	
	Method Value:Object()
		Return _value
	End Method

	'***** PRIVATE *****
	
	Field _color,_parent:TNode=nil,_left:TNode=nil,_right:TNode=nil

End Type

Type TNodeEnumerator
	Method HasNext()
		Return _node<>nil
	End Method
	
	Method NextObject:Object()
		Local node:TNode=_node
		_node=_node.NextNode()
		Return node
	End Method

	'***** PRIVATE *****
		
	Field _node:TNode	
End Type

Type TKeyEnumerator Extends TNodeEnumerator
	Method NextObject:Object()
		Local node:TNode=_node
		_node=_node.NextNode()
		Return node._key
	End Method
End Type

Type TValueEnumerator Extends TNodeEnumerator
	Method NextObject:Object()
		Local node:TNode=_node
		_node=_node.NextNode()
		Return node._value
	End Method
End Type

Type TMapEnumerator
	Method ObjectEnumerator:TNodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TNodeEnumerator
End Type

'***** PUBLIC *****

Type TMap

?Not Threaded
	Method Delete()
		Clear
	End Method
?
	Method Clear()
		If _root=nil Return
		_root.Clear
		_root=nil
	End Method
	
	Method IsEmpty()
		Return _root=nil
	End Method
	
	Method Insert( key:Object,value:Object )

		Assert key Else "Can't insert Null key into map"

		Local node:TNode=_root,parent:TNode=nil,cmp
		
		While node<>nil
			parent=node
			cmp=key.Compare( node._key )
			If cmp>0
				node=node._right
			Else If cmp<0
				node=node._left
			Else
				node._value=value
				Return
			EndIf
		Wend
		
		node=New TNode
		node._key=key
		node._value=value
		node._color=RED
		node._parent=parent
		
		If parent=nil
			_root=node
			Return
		EndIf
		If cmp>0
			parent._right=node
		Else
			parent._left=node
		EndIf
		
		_InsertFixup node
	End Method
	
	Method Contains( key:Object )
		Return _FindNode( key )<>nil
	End Method

	Method ValueForKey:Object( key:Object )
		Local node:TNode=_FindNode( key )
		If node<>nil Return node._value
	End Method
	
	Method Remove( key:Object )
		Local node:TNode=_FindNode( key )
		If node=nil Return 0
		 _RemoveNode node
		Return 1
	End Method
	
	Method Keys:TMapEnumerator()
		Local nodeenum:TNodeEnumerator=New TKeyEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TMapEnumerator=New TMapEnumerator
		mapenum._enumerator=nodeenum
		Return mapenum
	End Method
	
	Method Values:TMapEnumerator()
		Local nodeenum:TNodeEnumerator=New TValueEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TMapEnumerator=New TMapEnumerator
		mapenum._enumerator=nodeenum
		Return mapenum
	End Method
	
	Method Copy:TMap()
		Local map:TMap=New TMap
		map._root=_root.Copy( nil )
		Return map
	End Method
	
	Method ObjectEnumerator:TNodeEnumerator()
		Local nodeenum:TNodeEnumerator=New TNodeEnumerator
		nodeenum._node=_FirstNode()
		Return nodeenum
	End Method
	
	'***** PRIVATE *****
	
	Method _FirstNode:TNode()
		Local node:TNode=_root
		While node._left<>nil
			node=node._left
		Wend
		Return node
	End Method
	
	Method _LastNode:TNode()
		Local node:TNode=_root
		While node._right<>nil
			node=node._right
		Wend
		Return node
	End Method
	
	Method _FindNode:TNode( key:Object )
		Local node:TNode=_root
		While node<>nil
			Local cmp=key.Compare( node._key )
			If cmp>0
				node=node._right
			Else If cmp<0
				node=node._left
			Else
				Return node
			EndIf
		Wend
		Return node
	End Method
	
	Method _RemoveNode( node:TNode )
		Local splice:TNode,child:TNode
		
		If node._left=nil
			splice=node
			child=node._right
		Else If node._right=nil
			splice=node
			child=node._left
		Else
			splice=node._left
			While splice._right<>nil
				splice=splice._right
			Wend
			child=splice._left
			node._key=splice._key
			node._value=splice._value
		EndIf
		Local parent:TNode=splice._parent
		If child<>nil
			child._parent=parent
		EndIf
		If parent=nil
			_root=child
			Return
		EndIf
		If splice=parent._left
			parent._left=child
		Else
			parent._right=child
		EndIf
		
		If splice._color=BLACK _DeleteFixup child,parent
	End Method
	
	Method _InsertFixup( node:TNode )
		While node._parent._color=RED And node._parent._parent<>nil
			If node._parent=node._parent._parent._left
				Local uncle:TNode=node._parent._parent._right
				If uncle._color=RED
					node._parent._color=BLACK
					uncle._color=BLACK
					uncle._parent._color=RED
					node=uncle._parent
				Else
					If node=node._parent._right
						node=node._parent
						_RotateLeft node
					EndIf
					node._parent._color=BLACK
					node._parent._parent._color=RED
					_RotateRight node._parent._parent
				EndIf
			Else
				Local uncle:TNode=node._parent._parent._left
				If uncle._color=RED
					node._parent._color=BLACK
					uncle._color=BLACK
					uncle._parent._color=RED
					node=uncle._parent
				Else
					If node=node._parent._left
						node=node._parent
						_RotateRight node
					EndIf
					node._parent._color=BLACK
					node._parent._parent._color=RED
					_RotateLeft node._parent._parent
				EndIf
			EndIf
		Wend
		_root._color=BLACK
	End Method
	
	Method _RotateLeft( node:TNode )
		Local child:TNode=node._right
		node._right=child._left
		If child._left<>nil
			child._left._parent=node
		EndIf
		child._parent=node._parent
		If node._parent<>nil
			If node=node._parent._left
				node._parent._left=child
			Else
				node._parent._right=child
			EndIf
		Else
			_root=child
		EndIf
		child._left=node
		node._parent=child
	End Method
	
	Method _RotateRight( node:TNode )
		Local child:TNode=node._left
		node._left=child._right
		If child._right<>nil
			child._right._parent=node
		EndIf
		child._parent=node._parent
		If node._parent<>nil
			If node=node._parent._right
				node._parent._right=child
			Else
				node._parent._left=child
			EndIf
		Else
			_root=child
		EndIf
		child._right=node
		node._parent=child
	End Method
	
	Method _DeleteFixup( node:TNode,parent:TNode )
	
		While node<>_root And node._color=BLACK
			If node=parent._left
			
				Local sib:TNode=parent._right

				If sib._color=RED
					sib._color=BLACK
					parent._color=RED
					_RotateLeft parent
					sib=parent._right
				EndIf
				
				If sib._left._color=BLACK And sib._right._color=BLACK
					sib._color=RED
					node=parent
					parent=parent._parent
				Else
					If sib._right._color=BLACK
						sib._left._color=BLACK
						sib._color=RED
						_RotateRight sib
						sib=parent._right
					EndIf
					sib._color=parent._color
					parent._color=BLACK
					sib._right._color=BLACK
					_RotateLeft parent
					node=_root
				EndIf
			Else	
				Local sib:TNode=parent._left
				
				If sib._color=RED
					sib._color=BLACK
					parent._color=RED
					_RotateRight parent
					sib=parent._left
				EndIf
				
				If sib._right._color=BLACK And sib._left._color=BLACK
					sib._color=RED
					node=parent
					parent=parent._parent
				Else
					If sib._left._color=BLACK
						sib._right._color=BLACK
						sib._color=RED
						_RotateLeft sib
						sib=parent._left
					EndIf
					sib._color=parent._color
					parent._color=BLACK
					sib._left._color=BLACK
					_RotateRight parent
					node=_root
				EndIf
			EndIf
		Wend
		node._color=BLACK
	End Method
	
	Const RED=-1,BLACK=1
	
	Field _root:TNode=nil
	
End Type

Rem
bbdoc: Create a map
returns: A new map object
End Rem
Function CreateMap:TMap()
	Return New TMap
End Function

Rem
bbdoc: Clear a map
about:
#ClearMap removes all keys and values from @map
End Rem
Function ClearMap( map:TMap )
	map.Clear
End Function

Rem
bbdoc: Check if a map is empty
returns: True if @map is empty, otherwise false
End Rem
Function MapIsEmpty( map:TMap )
	Return map.IsEmpty()
End Function

Rem
bbdoc: Insert a key/value pair into a map
about:
If @map already contained @key, it's value is overwritten with @value. 
End Rem
Function MapInsert( map:TMap,key:Object,value:Object )
	map.Insert key,value
End Function

Rem
bbdoc: Find a value given a key
returns: The value associated with @key
about:
If @map does not contain @key, a #Null object is returned.
End Rem
Function MapValueForKey:Object( map:TMap,key:Object )
	Return map.ValueForKey( key )
End Function

Rem
bbdoc: Check if a map contains a key
returns: True if @map contains @key
End Rem
Function MapContains( map:TMap,key:Object )
	Return map.Contains( key )
End Function

Rem
bbdoc: Remove a key/value pair from a map
End Rem
Function MapRemove( map:TMap,key:Object )
	map.Remove key
End Function

Rem
bbdoc: Get map keys
returns: An iterator object
about:
The object returned by #MapKeys can be used with #EachIn to iterate through 
the keys in @map.
End Rem
Function MapKeys:TMapEnumerator( map:TMap )
	Return map.Keys()
End Function

Rem
bbdoc: Get map values
returns: An iterator object
about:
The object returned by #MapValues can be used with #EachIn to iterate through 
the values in @map.
End Rem
Function MapValues:TMapEnumerator( map:TMap )
	Return map.Values()
End Function

Rem
bbdoc: Copy a map
returns: A copy of @map
End Rem
Function CopyMap:TMap( map:TMap )
	Return map.Copy()
End Function
