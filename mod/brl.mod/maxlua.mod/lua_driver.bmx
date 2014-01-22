
Strict

Import Pub.Lua
Import BRL.StandardIO

Global LuaState:Byte Ptr=luaL_newstate()
luaL_openlibs LuaState

Function LuaRegInt( name$,value )
	lua_pushinteger LuaState,value
	lua_setfield LuaState,LUA_GLOBALSINDEX,name
End Function

Function LuaRegFunc( name$,value:Byte Ptr )
	lua_pushcclosure LuaState,value,0
	lua_setfield LuaState,LUA_GLOBALSINDEX,name
End Function

Function LuaDumpErr()
	WriteStdout "ERROR~n"
	WriteStdout lua_tostring( LuaState,-1 )
End Function


