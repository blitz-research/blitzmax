
Strict

Rem
bbdoc: System/Lua scripting
End Rem
Module BRL.MaxLua

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.00"

Import Pub.Lua
Import BRL.Reflection

Import "lua_object.c"

Private

Extern

Function lua_boxobject( L:Byte Ptr,obj:Object )
Function lua_unboxobject:Object( L:Byte Ptr,index )
Function lua_pushlightobject( L:Byte Ptr,obj:Object )
Function lua_tolightobject:Object( L:Byte Ptr,index )
Function lua_gcobject( L:Byte Ptr )

End Extern

Function LuaState:Byte Ptr()
	Global _luaState:Byte Ptr
	If Not _luaState
		_luaState=luaL_newstate()
		luaL_openlibs _luaState
	EndIf
	Return _luaState
End Function

Function LuaRegInt( name$,value )
	lua_pushinteger LuaState(),value
	lua_setfield LuaState(),LUA_GLOBALSINDEX,name
End Function

Function LuaRegFunc( name$,value:Byte Ptr )
	lua_pushcclosure LuaState(),value,0
	lua_setfield LuaState(),LUA_GLOBALSINDEX,name
End Function

Function LuaDumpErr()
	WriteStdout "ERROR~n"
	WriteStdout lua_tostring( LuaState(),-1 )
End Function

Function Invoke( L:Byte Ptr )
	Local obj:Object=lua_unboxobject( L,LUA_GLOBALSINDEX-1 )
	Local meth:TMethod=TMethod( lua_tolightobject( L,LUA_GLOBALSINDEX-2 ) )
	Local tys:TTypeId[]=meth.ArgTypes(),args:Object[tys.length]
	For Local i=0 Until args.length
		Select tys[i]
		Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
			args[i]=String.FromInt( lua_tointeger( L,i+1 ) )
		Case FloatTypeId
			args[i]=String.FromFloat( lua_tonumber( L,i+1 ) )
		Case DoubleTypeId
			args[i]=String.FromDouble( lua_tonumber( L,i+1 ) )
		Case StringTypeId
			args[i]=lua_tostring( L,i+1 )
		Default
			args[i]=lua_unboxobject( L,i+1 )
		End Select
	Next
	Local t:Object=meth.Invoke( obj,args )
	Select meth.TypeId()
	Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
		lua_pushinteger L,t.ToString().ToInt()
	Case FloatTypeId
		lua_pushnumber L,t.ToString().ToFloat()
	Case DoubleTypeId
		lua_pushnumber L,t.ToString().ToDouble()
	Case StringTypeId
		Local s$=t.ToString()
		lua_pushlstring L,s,s.length
	Default
		lua_pushobject L,t
	End Select
	Return 1
End Function

Function Index( L:Byte Ptr )
	Local obj:Object=lua_unboxobject( L,1 )
	Local typeId:TTypeId=TTypeId.ForObject( obj )
	Local ident$=lua_tostring( L,2 )
	
	Local mth:TMethod=typeId.FindMethod( ident )
	If mth
		lua_pushvalue L,1
		lua_pushlightobject L,mth
		lua_pushcclosure L,Invoke,2
		Return True
	EndIf
	
	Local fld:TField=typeId.FindField( ident )
	If fld
		Select fld.TypeId() ' BaH - added more types
		Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
			lua_pushinteger L,fld.GetInt( obj )
		Case FloatTypeId
			lua_pushnumber L,fld.GetFloat( obj )
		Case DoubleTypeId
			lua_pushnumber L,fld.GetDouble( obj )
		Case StringTypeId
			Local t$=fld.GetString( obj )
			lua_pushlstring L,t,t.length
		Default
			lua_pushobject L,fld.Get( obj )
		End Select
		Return True
	EndIf
End Function

Function NewIndex( L:Byte Ptr )
	Local obj:Object=lua_unboxobject( L,1 )
	Local typeId:TTypeId=TTypeId.ForObject( obj )
	Local ident$=lua_tostring( L,2 )

	Local mth:TMethod=typeId.FindMethod( ident )
	If mth
		Throw "ERROR"
	EndIf
	
	Local fld:TField=typeId.FindField( ident )
	If fld
		Select fld.TypeId()
		Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
			fld.SetInt obj,lua_tointeger( L,3 )
		Case FloatTypeId
			fld.SetFloat obj,lua_tonumber( L,3 )
		Case DoubleTypeId
			fld.SetDouble obj,lua_tonumber( L,3 )
		Case StringTypeId
			fld.SetString obj,lua_tostring( L,3 )
		Default
			fld.Set obj,lua_unboxobject( L,3 )
		End Select
		Return True
	EndIf
End Function

Function IndexObject( L:Byte Ptr )
	If Index( L ) Return 1
End Function

Function NewIndexObject( L:Byte Ptr )
	If NewIndex( L ) Return
	Throw "ERROR"
End Function

Function IndexSelf( L:Byte Ptr )
	lua_getfield( L,1,"super" )
	lua_replace L,1
	If Index( L ) Return 1
	lua_remove L,1
	lua_gettable L,LUA_GLOBALSINDEX
	Return 1
End Function

Function NewIndexSelf( L:Byte Ptr )
	lua_rawset L,1
End Function

Function ObjMetaTable()
	Global _objMetaTable,done
	If Not done
		lua_newtable LuaState()
		lua_pushcfunction LuaState(),lua_gcobject
		lua_setfield LuaState(),-2,"__gc"
		lua_pushcfunction LuaState(),IndexObject
		lua_setfield LuaState(),-2,"__index"
		lua_pushcfunction LuaState(),NewIndexObject
		lua_setfield LuaState(),-2,"__newindex"
		_objMetaTable=luaL_ref( LuaState(),LUA_REGISTRYINDEX )
		done=True
	EndIf
	Return _objMetaTable
End Function

Function lua_pushobject( L:Byte Ptr,obj:Object )
	lua_boxobject L,obj
	lua_rawgeti L,LUA_REGISTRYINDEX,ObjMetaTable()
	lua_setmetatable L,-2
End Function

' create a table and load with array contents
Function lua_pusharray( L:Byte Ptr,obj:Object )
	Local typeId:TTypeId=TTypeId.ForObject( obj )
	Local size:Int = typeId.ArrayLength(obj)
	
	lua_createtable L,size,0
	
	For Local i:Int = 0 Until size
		
		' the index
		lua_pushinteger L, i
		
		Select typeId.ElementType()
			Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
				lua_pushinteger L, typeId.GetArrayElement(obj, i).ToString().ToInt()
			Case FloatTypeId
				lua_pushnumber L, typeId.GetArrayElement(obj, i).ToString().ToFloat()
			Case DoubleTypeId
				lua_pushnumber L, typeId.GetArrayElement(obj, i).ToString().ToDouble()
			Case StringTypeId
				Local s:String = typeId.GetArrayElement(obj, i).ToString()
				lua_pushlstring L, s, s.length
			Case ArrayTypeId
				lua_pusharray(L, typeId.GetArrayElement(obj, i))
			Default ' for everything else, we just push the object..
				lua_pushobject L, typeId.GetArrayElement(obj, i)
		End Select
		
		lua_settable L, -3
	Next
	
End Function

Function lua_registerobject( L:Byte Ptr,obj:Object,name$ )
	lua_pushobject L,obj
	lua_setglobal L,name
End Function

Type TDummyLuaSuper
End Type

Global DummyLuaSuper:TDummyLuaSuper=New TDummyLuaSuper

Public

Rem
bbdoc: A Lua 'object'
End Rem
Type TLuaObject

	Rem
	bbdoc: Initialize the lua object
	about:
	Sets the object's class and super object.
	
	If the object was created with the TLuaObject.Create function, you do not need to call 
	this method.
	End Rem
	Method Init:TLuaObject( class:TLuaClass,supr:Object )
		Local L:Byte Ptr=LuaState()
		
		'Currently needs a super object
		If Not supr supr=DummyLuaSuper

		'push class block
		If Not class.lua_pushchunk() Return
		
		'create fenv table
		lua_newtable L
		
		'saveit
		lua_pushvalue L,-1
		_fenv=luaL_ref( L,LUA_REGISTRYINDEX )
		_class=class
		
		If supr
			'set self/super object
			lua_pushvalue L,-1
			lua_setfield L,-2,"self"
			lua_pushobject L,supr
			lua_setfield L,-2,"super"
			'set meta indices
			lua_pushcfunction L,IndexSelf
			lua_setfield L,-2,"__index"
			lua_pushcfunction L,NewIndexSelf
			lua_setfield L,-2,"__newindex"
		EndIf
		
		'set fenv metatable
		lua_pushvalue L,-1
		lua_setmetatable L,-2
		
		'ready!
		lua_setfenv L,-2
		If lua_pcall( L,0,0,0 ) LuaDumpErr
	
		Return Self
	End Method

	Rem
	bbdoc: Invoke an object method
	about:
	@name should refer to a function within the object's classes' source code.
	End Rem
	Method Invoke:Object( name$,args:Object[] )
		Local L:Byte Ptr=LuaState()
	
		lua_pushfenv
		lua_getfield L,-1,name
		If lua_isnil( L,-1 )
			lua_pop L,2
			Return
		EndIf
		For Local i=0 Until args.length
			Local typeId:TTypeId=TTypeId.ForObject( args[i] )
			Select typeId
				Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
					lua_pushinteger L, args[i].ToString().ToInt()
				Case FloatTypeId
					lua_pushnumber L, args[i].ToString().ToFloat()
				Case DoubleTypeId
					lua_pushnumber L, args[i].ToString().ToDouble()
				Case StringTypeId
					Local s:String = args[i].ToString()
					lua_pushlstring L,s,s.length
				Case ArrayTypeId
					lua_pusharray(L, args[i])
				Default
					lua_pushobject L,args[i]
			End Select
		Next
		If lua_pcall( L,args.length,1,0 ) LuaDumpErr
		
		
		Local ret:Object
		If Not lua_isnil( L,-1 ) Then
			' TODO: returning arrays from tables might be nice!
			ret = lua_tostring( L, -1 )
		End If
		' pop the result
		lua_pop L,1
		
		' pop the fenv ?
		lua_pop L,1
		
		Return ret
	End Method
	
	Rem
	bbdoc: Create a lua object
	about:
	Once a lua object has been created, object methods (actually lua functions defined in the 
	class) can be invoked using the #Invoke method.
	End Rem
	Function Create:TLuaObject( class:TLuaClass,supr:Object )
		Return New TLuaObject.Init( class,supr )
	End Function
	
	Method lua_pushfenv()
		Local L:Byte Ptr=LuaState()

		lua_rawgeti L,LUA_REGISTRYINDEX,_fenv
	End Method
	
	Method Delete()
		Local L:Byte Ptr=LuaState()
		luaL_unref L,LUA_REGISTRYINDEX,_fenv
	End Method
	
	
	Field _fenv
	Field _class:TLuaClass

End Type

Rem
bbdoc: A Lua 'class'
about:
The TLuaClass type is used to contain lua source code.

The source code should consist of a series of one or more lua functions.

To actually invoke these functions a lua object must first be created - see #TLuaObject.
End Rem
Type TLuaClass

	Rem
	bbdoc: Get source code
	returns: The lua source code for the class.
	End Rem
	Method SourceCode$()
		Return _source
	End Method

	Rem
	bbdoc: Set source code
	about:
	Sets the class source code.

	If the class was created with the TLuaClass.Create function, you do not need to call this
	method.
	End Rem
	Method SetSourceCode:TLuaClass( source$ )
		Local L:Byte Ptr=LuaState()
		_source=source
		If _chunk
			luaL_unref L,LUA_REGISTRYINDEX,_chunk
			_chunk=0
		EndIf
		Return Self
	End Method

	Rem
	bbdoc: Create a lua class
	returns: A new lua class object.
	about:
	The @source parameter must be valid Lua source code, and should contain a series of one or
	more lua function definitions.
	
	These functions can later be invoked by using the TLuaObject.Invoke method.
	End Rem	
	Function Create:TLuaClass( source$ )
		Return New TLuaClass.SetSourceCode( source )
	End Function
	
	Method lua_pushchunk()
		Local L:Byte Ptr=LuaState()

		If Not _chunk
			If luaL_loadstring( L,_source ) 
				WriteStdout "Error loading script :~n" + lua_tostring( L,-1 ) + "~n"
				lua_pop L,1
				Return False
			EndIf
			_chunk=luaL_ref( L,LUA_REGISTRYINDEX )
		EndIf
		lua_rawgeti L,LUA_REGISTRYINDEX,_chunk
		Return True
	End Method
	
	Method Delete()
		Local L:Byte Ptr=LuaState()

		luaL_unref L,LUA_REGISTRYINDEX,_chunk
	End Method
	
	Field _source$
	Field _chunk

End Type

Rem
bbdoc: Register a global object with Lua
about:
Once registered, the object can be accessed from within Lua scripts using the @name identifer.
End Rem
Function LuaRegisterObject( obj:Object,name$ )
	lua_registerobject LuaState(),obj,name
End Function
