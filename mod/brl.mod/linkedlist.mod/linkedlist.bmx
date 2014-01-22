
Strict

Rem
bbdoc: Data structures/Linked lists
End Rem
Module BRL.LinkedList

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Changed Reverse to maintain TLink stability"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added optional CompareFunc parameter to Sort"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Sort now swaps links instead of values"

Function CompareObjects( o1:Object,o2:Object )
	Return o1.Compare( o2 )
End Function

Rem
bbdoc: Link Object used by TList
End Rem
Type TLink

	Field _value:Object
	Field _succ:TLink,_pred:TLink
	
	Rem
	bbdoc: Returns the Object associated with this Link.
	End Rem
	Method Value:Object()
		Return _value
	End Method

	Rem
	bbdoc: Returns the next link in the List.
	End Rem
	Method NextLink:TLink()
		If _succ._value<>_succ Return _succ
	End Method

	Rem
	bbdoc: Returns the previous link in the List.
	End Rem
	Method PrevLink:TLink()
		If _pred._value<>_pred Return _pred
	End Method

	Rem
	bbdoc: Removes the link from the List.
	End Rem
	Method Remove()
		_value=Null
		_succ._pred=_pred
		_pred._succ=_succ
	End Method

End Type

Rem
bbdoc: Enumerator Object use by TList in order to implement Eachin support. 
End Rem
Type TListEnum

	Field _link:TLink

	Method HasNext()
		Return _link._value<>_link
	End Method

	Method NextObject:Object()
		Local value:Object=_link._value
		Assert value<>_link
		_link=_link._succ
		Return value
	End Method

End Type

Rem
bbdoc: Linked List 
End Rem
Type TList

	Field _head:TLink
	
	Method _pad()
	End Method

	Method New()
		_head=New TLink
		_head._succ=_head
		_head._pred=_head
		_head._value=_head
	End Method
	
?Not Threaded
	Method Delete()
		Clear
		_head._value=Null
		_head._succ=Null
		_head._pred=Null
	End Method
?
	Rem
	bbdoc: Clear a linked list
	about: Removes all objects from @list.
	End Rem
	Method Clear()
		While _head._succ<>_head
			_head._succ.Remove
		Wend
	End Method

	Rem
	bbdoc: Check if list is empty
	returns: True if list is empty, else false
	end rem
	Method IsEmpty()
		Return _head._succ=_head
	End Method
	
	Rem
	bbdoc: Check if list contains a value
	returns: True if list contains @value, else false
	end rem
	Method Contains( value:Object )
		Local link:TLink=_head._succ
		While link<>_head
			If link._value.Compare( value )=0 Return True
			link=link._succ
		Wend
		Return False
	End Method

	Rem
	bbdoc: Add an object to the start of the list
	returns: A link object
	End Rem
	Method AddFirst:TLink( value:Object )
		Assert value Else "Can't insert Null object into list"
		Return InsertAfterLink( value,_head )
	End Method

	Rem
	bbdoc: Add an object to the end of the list
	returns: A link object
	End Rem
	Method AddLast:TLink( value:Object )
		Assert value Else "Can't insert Null object into list"
		Return InsertBeforeLink( value,_head )
	End Method

	Rem
	bbdoc: Returns the first object in the list
	about: Returns Null if the list is empty.
	End Rem
	Method First:Object()
		If IsEmpty() Return
		Return _head._succ._value
	End Method

	Rem
	bbdoc: Returns the last object in the list
	about: Returns Null if the list is empty.
	End Rem
	Method Last:Object()
		If IsEmpty() Return
		Return _head._pred._value
	End Method

	Rem
	bbdoc: Removes and returns the first object in the list.
	about: Returns Null if the list is empty.
	End Rem
	Method RemoveFirst:Object()
		If IsEmpty() Return
		Local value:Object=_head._succ._value
		_head._succ.remove
		Return value
	End Method

	Rem
	bbdoc: Removes and returns the last object in the list.
	about: Returns Null if the list is empty.
	End Rem
	Method RemoveLast:Object()
		If IsEmpty() Return
		Local value:Object=_head._pred._value
		_head._pred.remove
		Return value
	End Method

	Rem
	bbdoc: Returns the first link the list or null if the list is empty.
	End Rem
	Method FirstLink:TLink()
		If _head._succ<>_head Return _head._succ
	End Method

	Rem
	bbdoc: Returns the last link the list or null if the list is empty.
	End Rem
	Method LastLink:TLink()
		If _head._pred<>_head Return _head._pred
	End Method

	Rem
	bbdoc: Inserts an object before the specified list link.
	End Rem
	Method InsertBeforeLink:TLink( value:Object,succ:TLink )
		Assert value Else "Can't insert Null object into list"
		Local link:TLink=New TLink
		link._value=value
		link._succ=succ
		link._pred=succ._pred
		link._pred._succ=link
		succ._pred=link
		Return link
	End Method

	Rem
	bbdoc: Inserts an object after the specified list link.
	End Rem
	Method InsertAfterLink:TLink( value:Object,pred:TLink )
		Assert value Else "Can't insert Null object into list"
		Local link:TLink=New TLink
		link._value=value
		link._pred=pred
		link._succ=pred._succ
		link._succ._pred=link
		pred._succ=link
		Return link
	End Method

	Rem
	bbdoc: Returns the first link in the list with the given value, or null if none found.
	End Rem
	Method FindLink:TLink( value:Object )
		Local link:TLink=_head._succ
		While link<>_head
			If link._value.Compare( value )=0 Return link
			link=link._succ
		Wend
	End Method

	Rem
	bbdoc: Returns the value of the link at the given index.
	about: Throws an exception if the index is out of range (must be 0..list.Count()-1 inclusive).
	End Rem
	Method ValueAtIndex:Object( index )
		Assert index>=0 Else "Object index must be positive"
		Local link:TLink=_head._succ
		While link<>_head
			If Not index Return link._value
			link=link._succ
			index:-1
		Wend
		RuntimeError "List index out of range"
	End Method

	Rem
	bbdoc: Count list length
	returns: The numbers of objects in @list.
	end rem
	Method Count()
		Local link:TLink=_head._succ,count
		While link<>_head
			count:+1
			link=link._succ
		Wend
		Return count
	End Method

	Rem
	bbdoc: Remove an object from a linked list
	about: Remove scans a list for the specified value and removes its link.
	End Rem
	Method Remove( value:Object )
		Local link:TLink=FindLink( value )
		If Not link Return False
		link.Remove
		Return True
	End Method
	
	Rem
	bbdoc: Swap contents with the list specified.
	End Rem
	Method Swap( list:TList )
		Local head:TLink=_head
		_head=list._head
		list._head=head
	End Method
	
	Rem
	bbdoc: Creates an identical copy of the list.
	End Rem
	Method Copy:TList()
		Local list:TList=New TList
		Local link:TLink=_head._succ
		While link<>_head
			list.AddLast link._value
			link=link._succ
		Wend
		Return list
	End Method

	Rem
	bbdoc: Reverse the order of the list.
	End Rem
	Method Reverse()
		Local pred:TLink=_head,succ:TLink=pred._succ
		Repeat
			Local link:TLink=succ._succ
			pred._pred=succ
			succ._succ=pred
			pred=succ
			succ=link
		Until pred=_head
	End Method
	
	Rem
	bbdoc: Creates a new list that is the reversed version of this list.
	End Rem
	Method Reversed:TList()
		Local list:TList=New TList
		Local link:TLink=_head._succ
		While link<>_head
			list.AddFirst link._value
			link=link._succ
		Wend
		Return list
	End Method

	Rem
	bbdoc: Sort a list in either ascending (default) or decending order.
	about: User types should implement a Compare method in order to be sorted.
	End Rem
	Method Sort( ascending=True,compareFunc( o1:Object,o2:Object )=CompareObjects )
		Local ccsgn=-1
		If ascending ccsgn=1
		
		Local insize=1
		Repeat
			Local merges
			Local tail:TLink=_head
			Local p:TLink=_head._succ

			While p<>_head
				merges:+1
				Local q:TLink=p._succ,qsize=insize,psize=1
				
				While psize<insize And q<>_head
					psize:+1
					q=q._succ
				Wend

				Repeat
					Local t:TLink
					If psize And qsize And q<>_head
						Local cc=CompareFunc( p._value,q._value ) * ccsgn
						If cc<=0
							t=p
							p=p._succ
							psize:-1
						Else
							t=q
							q=q._succ
							qsize:-1
						EndIf
					Else If psize
						t=p
						p=p._succ
						psize:-1
					Else If qsize And q<>_head
						t=q
						q=q._succ
						qsize:-1
					Else
						Exit
					EndIf
					t._pred=tail
					tail._succ=t
					tail=t
				Forever
				p=q
			Wend
			tail._succ=_head
			_head._pred=tail

			If merges<=1 Return

			insize:*2
		Forever
	End Method
		
	Method ObjectEnumerator:TListEnum()
		Local enum:TListEnum=New TListEnum
		enum._link=_head._succ
		Return enum
	End Method

	Rem
	bbdoc: convert a list to an array
	returns: An array of objects
	end rem
	Method ToArray:Object[]()
		Local arr:Object[Count()],i
		Local link:TLink=_head._succ
		While link<>_head
			arr[i]=link._value
			link=link._succ
			i:+1
		Wend
		Return arr
	End Method

	Rem
	bbdoc: Create a list from an array
	returns: A new linked list
	end rem
	Function FromArray:TList( arr:Object[] )
		Local list:TList=New TList
		For Local i=0 Until arr.length
			list.AddLast arr[i]
		Next
		Return list
	End Function

End Type

Rem
bbdoc: Create a linked list
returns: A new linked list object
end rem
Function CreateList:TList()
	Return New TList
End Function

Rem
bbdoc: Clear a linked list
about: Removes all objects from @list.
end rem
Function ClearList( list:TList )
	list.Clear
End Function

Rem
bbdoc: Count list length
returns: The numbers of objects in @list.
end rem
Function CountList( list:TList )
	Return list.Count()
End Function

Rem
bbdoc: Check if list is empty
returns: True if list is empty, else false
end rem
Function ListIsEmpty( list:TList )
	Return list.IsEmpty()
End Function

Rem
bbdoc: Check if list contains a value
returns: True if list contains @value, else false
end rem
Function ListContains( list:TList,value:Object )
	Return list.Contains( value )
End Function

Rem
bbdoc: Sort a list
end rem
Function SortList( list:TList,ascending=True,compareFunc( o1:Object,o2:Object )=CompareObjects )
	list.Sort ascending,compareFunc
End Function

Rem
bbdoc: Create a list from an array
returns: A new linked list
end rem
Function ListFromArray:TList( arr:Object[] )
	Return TList.FromArray( arr )
End Function

Rem
bbdoc: convert a list to an array
returns: An array of objects
end rem
Function ListToArray:Object[]( list:TList )
	Return list.ToArray()
End Function

Rem
bbdoc: Swap the contents of 2 lists
end rem
Function SwapLists( list_x:TList,list_y:TList )
	list_x.Swap list_y
End Function

Rem
bbdoc: Reverse the order of elements of a list
end rem
Function ReverseList( list:TList )
	list.Reverse
End Function

Rem
bbdoc: Find a link in a list
returns: The link containting @value
end rem
Function ListFindLink:TLink( list:TList,value:Object )
	Return list.FindLink( value )
End Function

Rem
bbdoc: Add an object to a linked list
returns: A link object
end rem
Function ListAddLast:TLink( list:TList,value:Object )
	Return list.AddLast( value )
End Function

Rem
bbdoc: Add an object to a linked list
returns: A link object
end rem
Function ListAddFirst:TLink( list:TList,value:Object )
	Return list.AddFirst( value )
End Function

Rem
bbdoc: Remove an object from a linked list
about: #ListRemove scans a list for the specified value and removes its link.
end rem
Function ListRemove( list:TList,value:Object )
	list.Remove value
End Function

Rem
bbdoc: Remove an object from a linked list
about: #RemoveLink is more efficient than #ListRemove.
end rem
Function RemoveLink( link:TLink )
	link.Remove
End Function
