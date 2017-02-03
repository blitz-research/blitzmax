SuperStrict

Rem
bbdoc: Lua Core
end rem
Module Pub.Lua

ModuleInfo "Version: 1.27"
ModuleInfo "Author: Tecgraf,PUC-Rio"
ModuleInfo "License: MIT License"
ModuleInfo "Modserver: BRL"
ModuleInfo "Credit: Adapted for BlitzMax by Thomas Mayer, Noel Cower, Andreas Rozek and Simon Armstrong"

ModuleInfo "History: 1.27"
ModuleInfo "History: Modified luaconf.h (line 14) to autodetect LUA_USE_LINUX and LUA_USE_MACOSX"
ModuleInfo "History: 1.26"
ModuleInfo "History: Removed BRL.Retro dependancy & replaced Left() with [..1]"
ModuleInfo "History: 1.25"
ModuleInfo "History: Updated to Lua 5.1.4 - Htbaa"
ModuleInfo "History: 1.24"
ModuleInfo "History: fixed int<->long discrepancies between Lua and BlitzMAX"
ModuleInfo "History: 1.23"
ModuleInfo "History: several bugfixes and extensions"
ModuleInfo "History: support for strings with embedded ~0 (and byte arrays)"
ModuleInfo "History: modifications for Lua 5.1.2"
ModuleInfo "History: source code is now 'superstrict'-compliant"
ModuleInfo "History: added some documentation"
ModuleInfo "History: 1.22"
ModuleInfo "History: added lots of definitions to support most of the official Lua 5.1.1 API"
ModuleInfo "History: 1.21"
ModuleInfo "History: removed luac.c from build list"
ModuleInfo "History: 1.20"
ModuleInfo "History: fixed missing paramters in lua_createtable definition"
ModuleInfo "History: 1.19"
ModuleInfo "History: updated with lua5.1.1 source"
ModuleInfo "History: 1.18"
ModuleInfo "History: added extra Imports and luaL_openlibs decl"
ModuleInfo "History: 1.17"
ModuleInfo "History: added luaL_loadstring fixed missing lua_dostring"
ModuleInfo "History: 1.16"
ModuleInfo "History: Added lua_newtable as a BMax function"
ModuleInfo "History: Changed extern'd lua_newtable to lua_createtable"
ModuleInfo "History: Added lua_load, lua_dostring and lua_dobuffer."
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: New LUA 5.1 based build"
ModuleInfo "History: Modified constants and added new wrappers for 5.1 compatability"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: Added luaopen_debug and ldblib.c"
ModuleInfo "History: Replaced byte ptr with $z (CString) where a C string is expected"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Removed lua.h import"

Import "lua-5.1.4/src/lstate.c"
Import "lua-5.1.4/src/llex.c"
Import "lua-5.1.4/src/ltm.c"
Import "lua-5.1.4/src/lstring.c"
Import "lua-5.1.4/src/ltable.c"
Import "lua-5.1.4/src/lfunc.c"
Import "lua-5.1.4/src/ldo.c"
Import "lua-5.1.4/src/lgc.c"
Import "lua-5.1.4/src/lzio.c"
Import "lua-5.1.4/src/lobject.c"
Import "lua-5.1.4/src/lparser.c"
Import "lua-5.1.4/src/lvm.c"
Import "lua-5.1.4/src/lundump.c"
Import "lua-5.1.4/src/lmem.c"
Import "lua-5.1.4/src/lcode.c"
Import "lua-5.1.4/src/ldebug.c"
Import "lua-5.1.4/src/lopcodes.c"
Import "lua-5.1.4/src/lapi.c"
Import "lua-5.1.4/src/ldump.c"
Import "lua-5.1.4/src/lbaselib.c"
Import "lua-5.1.4/src/lauxlib.c"
Import "lua-5.1.4/src/liolib.c"
Import "lua-5.1.4/src/lmathlib.c"
Import "lua-5.1.4/src/lstrlib.c"
Import "lua-5.1.4/src/ltablib.c"
Import "lua-5.1.4/src/ldblib.c"

Import "lua-5.1.4/src/linit.c"
Import "lua-5.1.4/src/loadlib.c"
Import "lua-5.1.4/src/loslib.c"
'import "lua-5.1.4/src/lua.c"
'Import "lua-5.1.4/src/luac.c"
Import "lua-5.1.4/src/print.c"

?Linux
Import "-ldl"
?

' ******************************************************************************
' *                                                                            *
' *                            Constant Definitions                            *
' *                                                                            *
' ******************************************************************************

  Const LUA_IDSIZE:Int = 60

' **** (lua.h) some basic definitions - just to be complete ****

  Const LUA_VERSION:String   = "Lua 5.1"
  Const LUA_RELEASE:String   = "Lua 5.1.4"
  Const LUA_VERSION_NUM:Int  = 501
  Const LUA_COPYRIGHT:String = "Copyright (C) 1994-2008 Lua.org, PUC-Rio"
  Const LUA_AUTHORS:String   = "R. Ierusalimschy, L. H. de Figueiredo & W. Celes"

' **** (lua.h) option for multiple returns in `lua_pcall' and `lua_call' ****

  Const LUA_MULTRET:Int = -1

' **** (lua.h) pseudo-indices ****

  Const LUA_REGISTRYINDEX:Int = -10000
  Const LUA_ENVIRONINDEX:Int  = -10001
  Const LUA_GLOBALSINDEX:Int  = -10002

' **** (lua.h) thread status (0 is OK) ****

  Const LUA_YIELD_:Int    = 1   ' added _ after LUA_YIELD because of lua_yield function
  Const LUA_ERRRUN:Int    = 2
  Const LUA_ERRSYNTAX:Int = 3
  Const LUA_ERRMEM:Int    = 4
  Const LUA_ERRERR:Int    = 5

' **** (lua.h) basic types ****

  Const LUA_TNONE:Int          = -1
  Const LUA_TNIL:Int           =  0
  Const LUA_TBOOLEAN:Int       =  1
  Const LUA_TLIGHTUSERDATA:Int =  2
  Const LUA_TNUMBER:Int        =  3
  Const LUA_TSTRING:Int        =  4
  Const LUA_TTABLE:Int         =  5
  Const LUA_TFUNCTION:Int      =  6
  Const LUA_TUSERDATA:Int      =  7
  Const LUA_TTHREAD:Int        =  8

' **** (lua.h) garbage-collection options ****

  Const LUA_GCSTOP:Int       = 0
  Const LUA_GCRESTART:Int    = 1
  Const LUA_GCCOLLECT:Int    = 2
  Const LUA_GCCOUNT:Int      = 3
  Const LUA_GCCOUNTB:Int     = 4
  Const LUA_GCSTEP:Int       = 5
  Const LUA_GCSETPAUSE:Int   = 6
  Const LUA_GCSETSTEPMUL:Int = 7

' **** (lua.h) event codes ****

  Const LUA_HOOKCALL:Int    = 0
  Const LUA_HOOKRET:Int     = 1
  Const LUA_HOOKLINE:Int    = 2
  Const LUA_HOOKCOUNT:Int   = 3
  Const LUA_HOOKTAILRET:Int = 4

' **** (lua.h) event masks ****

  Const LUA_MASKCALL:Int  = (1 Shl LUA_HOOKCALL)
  Const LUA_MASKRET:Int   = (1 Shl LUA_HOOKRET)
  Const LUA_MASKLINE:Int  = (1 Shl LUA_HOOKLINE)
  Const LUA_MASKCOUNT:Int = (1 Shl LUA_HOOKCOUNT)

' ******************************************************************************
' *                                                                            *
' *                          The Lua API (Functions)                           *
' *                                                                            *
' ******************************************************************************

Extern
  Type lua_Debug
    Field event:Int
    Field name:Byte Ptr                                         ' no ~0 expected
    Field namewhat:Byte Ptr                                               ' dto.
    Field what:Byte Ptr                                                   ' dto.
    Field source:Byte Ptr                                                 ' dto.
    Field currentline:Int
    Field nups:Int
    Field linedefined:Int
    Field lastlinedefined:Int
'   field short_src:byte[LUA_IDSIZE]         ' we use padding to occupy 60 bytes
    Field short_src:Byte, short_src_01:Byte, short_src_02:Byte, short_src_03:Byte
    Field short_src_04:Long, short_src_12:Long, short_src_20:Long
    Field short_src_28:Long, short_src_36:Long, short_src_44:Long
    Field short_src_52:Long
    Field i_ci:Int      ' "private" field - mentioned here to get the right size
  End Type
End Extern

Extern
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_atpanic">Lua Reference Manual</a>
end rem
  Function lua_atpanic:Byte Ptr (lua_state:Byte Ptr, panicf:Int(ls:Byte Ptr))
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_call">Lua Reference Manual</a>
end rem
  Function lua_call (lua_state:Byte Ptr, nargs:Int, nresults:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_checkstack">Lua Reference Manual</a>
end rem
  Function lua_checkstack:Int (lua_state:Byte Ptr, extra:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_close">Lua Reference Manual</a>
end rem
  Function lua_close (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_concat">Lua Reference Manual</a>
end rem
  Function lua_concat (lua_state:Byte Ptr, n:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_cpcall">Lua Reference Manual</a>
end rem
  Function lua_cpcall:Int (lua_state:Byte Ptr, func:Int(ls:Byte Ptr), ud:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_createtable">Lua Reference Manual</a>
end rem
  Function lua_createtable (lua_state:Byte Ptr, narr:Int, nrec:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_dump">Lua Reference Manual</a>
end rem
  Function lua_dump:Int (lua_state:Byte Ptr, writer:Int(ls:Byte Ptr,p:Byte Ptr,sz:Int,ud:Byte Ptr), data:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_equal">Lua Reference Manual</a>
end rem
  Function lua_equal:Int (lua_state:Byte Ptr, index1:Int, index2:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_error">Lua Reference Manual</a>
end rem
  Function lua_error:Int (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_gc">Lua Reference Manual</a>
end rem
  Function lua_gc:Int (lua_state:Byte Ptr, what:Int, data:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getallocf">Lua Reference Manual</a>
end rem
  Function lua_getallocf:Byte Ptr (lua_state:Byte Ptr, ud:Byte Ptr Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getfenv">Lua Reference Manual</a>
end rem
  Function lua_getfenv (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getfield">Lua Reference Manual</a>
end rem
  Function lua_getfield (lua_state:Byte Ptr, index:Int, k$z)              ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_gethook">Lua Reference Manual</a>
end rem
  Function lua_gethook:Byte Ptr (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_gethookcount">Lua Reference Manual</a>
end rem
  Function lua_gethookcount:Int (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_gethookmask">Lua Reference Manual</a>
end rem
  Function lua_gethookmask:Int (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getinfo">Lua Reference Manual</a>
end rem
  Function lua_getinfo:Int (lua_state:Byte Ptr, what$z, ar:lua_Debug Ptr)    ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getlocal">Lua Reference Manual</a>
end rem
  Function lua_getlocal$z (lua_state:Byte Ptr, ar:lua_Debug Ptr, n:Int)     ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getmetatable">Lua Reference Manual</a>
end rem
  Function lua_getmetatable:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getstack">Lua Reference Manual</a>
end rem
  Function lua_getstack:Int (lua_state:Byte Ptr, level:Int, ar:lua_Debug Ptr) ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_gettable">Lua Reference Manual</a>
end rem
  Function lua_gettable (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_gettop">Lua Reference Manual</a>
end rem
  Function lua_gettop:Int (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getupvalue">Lua Reference Manual</a>
end rem
  Function lua_getupvalue$z (lua_state:Byte Ptr, funcindex:Int, n:Int)        ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_insert">Lua Reference Manual</a>
end rem
  Function lua_insert (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_iscfunction">Lua Reference Manual</a>
end rem
  Function lua_iscfunction:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isnumber">Lua Reference Manual</a>
end rem
  Function lua_isnumber:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isstring">Lua Reference Manual</a>
end rem
  Function lua_isstring:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isuserdata">Lua Reference Manual</a>
end rem
  Function lua_isuserdata:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_lessthan">Lua Reference Manual</a>
end rem
  Function lua_lessthan:Int (lua_state:Byte Ptr, index1:Int, index2:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_load">Lua Reference Manual</a>
end rem
  Function lua_load:Int (lua_state:Byte Ptr, reader:Byte Ptr(ls:Byte Ptr,data:Byte Ptr,sz:Int Ptr), data:Byte Ptr, chunkname$z) ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_newstate">Lua Reference Manual</a>
end rem
  Function lua_newstate:Byte Ptr (f:Byte Ptr(ud:Byte Ptr, p:Byte Ptr, osize:Int, nsize:Int), ud:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_newthread">Lua Reference Manual</a>
end rem
  Function lua_newthread:Byte Ptr (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_newuserdata">Lua Reference Manual</a>
end rem
  Function lua_newuserdata:Byte Ptr (lua_state:Byte Ptr, size:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_next">Lua Reference Manual</a>
end rem
  Function lua_next:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_objlen">Lua Reference Manual</a>
end rem
  Function lua_objlen:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pcall">Lua Reference Manual</a>
end rem
  Function lua_pcall:Int (lua_state:Byte Ptr, nargs:Int, nresults:Int, errfunc:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushboolean">Lua Reference Manual</a>
end rem
  Function lua_pushboolean (lua_state:Byte Ptr, b:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushcclosure">Lua Reference Manual</a>
end rem
  Function lua_pushcclosure (lua_state:Byte Ptr, fn:Int(ls:Byte Ptr), n:Int)
' function lua_pushfstring$z (lua_state:byte ptr, fmt$z, ...)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushinteger">Lua Reference Manual</a>
end rem
  Function lua_pushinteger (lua_state:Byte Ptr, n:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushlightuserdata">Lua Reference Manual</a>
end rem
  Function lua_pushlightuserdata (lua_state:Byte Ptr, p:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushlstring">Lua Reference Manual</a>
end rem
  Function lua_pushlstring (lua_state:Byte Ptr, s:Byte Ptr, size:Int)    ' without any conversion!
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushnil">Lua Reference Manual</a>
end rem
  Function lua_pushnil (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushnumber">Lua Reference Manual</a>
end rem
  Function lua_pushnumber (lua_state:Byte Ptr, n:Double)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushstring">Lua Reference Manual</a>
end rem
  Function lua_pushstring (lua_state:Byte Ptr, s$z)                         ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushthread">Lua Reference Manual</a>
end rem
  Function lua_pushthread:Int (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushvalue">Lua Reference Manual</a>
end rem
  Function lua_pushvalue (lua_state:Byte Ptr, index:Int)
' function lua_pushvfstring$z (lua_state:byte ptr, fmt$z, argp:???)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_rawequal">Lua Reference Manual</a>
end rem
  Function lua_rawequal:Int (lua_state:Byte Ptr, index1:Int, index2:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_rawget">Lua Reference Manual</a>
end rem
  Function lua_rawget (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_rawgeti">Lua Reference Manual</a>
end rem
  Function lua_rawgeti (lua_state:Byte Ptr, index:Int, n:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_rawset">Lua Reference Manual</a>
end rem
  Function lua_rawset (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_rawseti">Lua Reference Manual</a>
end rem
  Function lua_rawseti (lua_state:Byte Ptr, index:Int, n:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_remove">Lua Reference Manual</a>
end rem
  Function lua_remove (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_replace">Lua Reference Manual</a>
end rem
  Function lua_replace (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_resume">Lua Reference Manual</a>
end rem
  Function lua_resume:Int (lua_state:Byte Ptr, narg:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setallocf">Lua Reference Manual</a>
end rem
  Function lua_setallocf (lua_state:Byte Ptr, f:Byte Ptr(ud:Byte Ptr, p:Byte Ptr, osize:Int, nsize:Int), ud:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setfenv">Lua Reference Manual</a>
end rem
  Function lua_setfenv:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setfield">Lua Reference Manual</a>
end rem
  Function lua_setfield (lua_state:Byte Ptr, index:Int, k$z)              ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_sethook">Lua Reference Manual</a>
end rem
  Function lua_sethook:Int (lua_state:Byte Ptr, f(ls:Byte Ptr,ar:lua_Debug Ptr), mask:Int, count:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setlocal">Lua Reference Manual</a>
end rem
  Function lua_setlocal$z (lua_state:Byte Ptr, ar:lua_Debug Ptr, n:Int)     ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setmetatable">Lua Reference Manual</a>
end rem
  Function lua_setmetatable:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_settable">Lua Reference Manual</a>
end rem
  Function lua_settable (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_settop">Lua Reference Manual</a>
end rem
  Function lua_settop (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setupvalue">Lua Reference Manual</a>
end rem
  Function lua_setupvalue$z (lua_state:Byte Ptr, funcindex:Int, n:Int)        ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_status">Lua Reference Manual</a>
end rem
  Function lua_status:Int (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_toboolean">Lua Reference Manual</a>
end rem
  Function lua_toboolean:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_tocfunction">Lua Reference Manual</a>
end rem
  Function lua_tocfunction:Byte Ptr (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_tointeger">Lua Reference Manual</a>
end rem
  Function lua_tointeger:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_tolstring">Lua Reference Manual</a>
end rem
  Function lua_tolstring:Byte Ptr (lua_state:Byte Ptr, index:Int, size:Int Ptr) ' without any conversion!
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_tonumber">Lua Reference Manual</a>
end rem
  Function lua_tonumber:Double (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_topointer">Lua Reference Manual</a>
end rem
  Function lua_topointer:Byte Ptr (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_tothread">Lua Reference Manual</a>
end rem
  Function lua_tothread:Byte Ptr (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_touserdata">Lua Reference Manual</a>
end rem
  Function lua_touserdata:Byte Ptr (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_type">Lua Reference Manual</a>
end rem
  Function lua_type:Int (lua_state:Byte Ptr, index:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_typename">Lua Reference Manual</a>
end rem
  Function lua_typename$z (lua_state:Byte Ptr, tp:Int)                      ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_xmove">Lua Reference Manual</a>
end rem
  Function lua_xmove                (fromState:Byte Ptr, toState:Byte Ptr, n:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_yield">Lua Reference Manual</a>
end rem
  Function lua_yield:Int (lua_state:Byte Ptr, nresults:Int)
End Extern

' ******************************************************************************
' *                                                                            *
' *                            The Lua API (Macros)                            *
' *                                                                            *
' ******************************************************************************

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_getglobal">Lua Reference Manual</a>
end rem
  Function lua_getglobal (lua_state:Byte Ptr, name:String)
    lua_getfield(lua_state, LUA_GLOBALSINDEX, name)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isboolean">Lua Reference Manual</a>
end rem
  Function lua_isboolean:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TBOOLEAN)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isfunction">Lua Reference Manual</a>
end rem
  Function lua_isfunction:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TFUNCTION)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_islightuserdata">Lua Reference Manual</a>
end rem
  Function lua_islightuserdata:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TLIGHTUSERDATA)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isnil">Lua Reference Manual</a>
end rem
  Function lua_isnil:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TNIL)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isnone">Lua Reference Manual</a>
end rem
  Function lua_isnone:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TNONE)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isnoneornil">Lua Reference Manual</a>
end rem
  Function lua_isnoneornil:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) <= 0)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_istable">Lua Reference Manual</a>
end rem
  Function lua_istable:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TTABLE)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_isthread">Lua Reference Manual</a>
end rem
  Function lua_isthread:Int (lua_state:Byte Ptr, index:Int)
    Return (lua_type(lua_state,index) = LUA_TTHREAD)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_newtable">Lua Reference Manual</a>
end rem
  Function lua_newtable (lua_state:Byte Ptr)
    lua_createtable(lua_state,0,0)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pop">Lua Reference Manual</a>
end rem
  Function lua_pop (lua_state:Byte Ptr, n:Int)
    lua_settop(lua_state,-(n)-1)
  End Function

  Function lua_pushbytearray (lua_state:Byte Ptr, Buffer:Byte[])
    lua_pushlstring(lua_state, Varptr Buffer[0], Buffer.length)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_pushcfunction">Lua Reference Manual</a>
end rem
  Function lua_pushcfunction (lua_state:Byte Ptr, fn:Int(ls:Byte Ptr))
    lua_pushcclosure(lua_state, fn, 0)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_register">Lua Reference Manual</a>
end rem
  Function lua_register (lua_state:Byte Ptr, name:String, f:Int(ls:Byte Ptr))
    lua_pushcfunction(lua_state, f)
    lua_setglobal    (lua_state, name)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_setglobal">Lua Reference Manual</a>
end rem
  Function lua_setglobal (lua_state:Byte Ptr, name:String)
    lua_setfield(lua_state, LUA_GLOBALSINDEX, name)
  End Function

  Function lua_tobytearray:Byte[] (lua_state:Byte Ptr, index:Int)
    Local Length:Int
    Local DataPtr:Byte Ptr = lua_tolstring(lua_state, index, Varptr Length)
    If (DataPtr = Null) Then
      Return Null
    Else
      Local Result:Byte[] = New Byte[Length]
        MemCopy(Varptr Result[0], DataPtr, Length);
      Return Result
    End If
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#lua_tostring">Lua Reference Manual</a>
end rem
  Function lua_tostring:String (lua_state:Byte Ptr, index:Int)
    Local Length:Int
    Local StringPtr:Byte Ptr = lua_tolstring(lua_state, index, Varptr Length)
    If (StringPtr = Null) Then
      Return Null
    Else
      Return String.fromBytes(StringPtr,Length)
    End If
  End Function

' ******************************************************************************
' *                                                                            *
' *                     The Auxiliary Library (Functions)                      *
' *                                                                            *
' ******************************************************************************

Extern
  Type lua_Reg
    Field name:Byte Ptr                                         ' no ~0 expected
    Field func:Int(ls:Byte Ptr)
  End Type
End Extern

Extern
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_addlstring">Lua Reference Manual</a>
end rem
  Function luaL_addlstring (B:Byte Ptr, s:Byte Ptr, l:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_addsize">Lua Reference Manual</a>
end rem
  Function luaL_addsize (B:Byte Ptr, size:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_addstring">Lua Reference Manual</a>
end rem
  Function luaL_addstring (B:Byte Ptr, s$z)                                 ' no ~0 allowed!
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_addvalue">Lua Reference Manual</a>
end rem
  Function luaL_addvalue (B:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_argerror">Lua Reference Manual</a>
end rem
  Function luaL_argerror:Int (lua_state:Byte Ptr, narg:Int, extramsg$z)     ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_buffinit">Lua Reference Manual</a>
end rem
  Function luaL_buffinit (lua_state:Byte Ptr, B:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_callmeta">Lua Reference Manual</a>
end rem
  Function luaL_callmeta:Int (lua_state:Byte Ptr, obj:Int, e$z)             ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checkany">Lua Reference Manual</a>
end rem
  Function luaL_checkany (lua_state:Byte Ptr, narg:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checkinteger">Lua Reference Manual</a>
end rem
  Function luaL_checkinteger:Int (lua_state:Byte Ptr, narg:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checklstring">Lua Reference Manual</a>
end rem
  Function luaL_checklstring:Byte Ptr (lua_state:Byte Ptr, narg:Int, size:Int Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checknumber">Lua Reference Manual</a>
end rem
  Function luaL_checknumber:Double (lua_state:Byte Ptr, narg:Int)
' function luaL_checkoption:int (lua_state:byte ptr, narg:int, def$z, lst$z[])
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checkstack">Lua Reference Manual</a>
end rem
  Function luaL_checkstack (lua_state:Byte Ptr, sz:Int, msg$z)                     ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checktype">Lua Reference Manual</a>
end rem
  Function luaL_checktype (lua_state:Byte Ptr, narg:Int, t:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checkudata">Lua Reference Manual</a>
end rem
  Function luaL_checkudata:Byte Ptr (lua_state:Byte Ptr, narg:Int, tname$z)        ' no ~0 expected
' function luaL_error:int (lua_state:byte ptr, fmt$z, ...)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_getmetafield">Lua Reference Manual</a>
end rem
  Function luaL_getmetafield:Int (lua_state:Byte Ptr, obj:Int, e$z)                ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_gsub">Lua Reference Manual</a>
end rem
  Function luaL_gsub$z (lua_state:Byte Ptr, s$z, p$z, r$z)                         ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_loadbuffer">Lua Reference Manual</a>
end rem
  Function luaL_loadbuffer:Int (lua_state:Byte Ptr, buff:Byte Ptr, sz:Int, name$z) ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_loadfile">Lua Reference Manual</a>
end rem
  Function luaL_loadfile:Int (lua_state:Byte Ptr, filename$z)                      ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_loadstring">Lua Reference Manual</a>
end rem
  Function luaL_loadstring:Int (lua_state:Byte Ptr, s$z)                           ' no ~0 allowed!
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_newmetatable">Lua Reference Manual</a>
end rem
  Function luaL_newmetatable:Int (lua_state:Byte Ptr, tname$z)                     ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_newstate">Lua Reference Manual</a>
end rem
  Function luaL_newstate:Byte Ptr ()
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_openlibs">Lua Reference Manual</a>
end rem
  Function luaL_openlibs (lua_state:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_optinteger">Lua Reference Manual</a>
end rem
  Function luaL_optinteger:Int (lua_state:Byte Ptr, narg:Int, d:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_optlstring">Lua Reference Manual</a>
end rem
  Function luaL_optlstring:Byte Ptr (lua_state:Byte Ptr, narg:Int, d$z, size:Int Ptr) ' no ~0 expected in "d"
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_optnumber">Lua Reference Manual</a>
end rem
  Function luaL_optnumber:Double (lua_state:Byte Ptr, narg:Int, d:Double)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_prepbuffer">Lua Reference Manual</a>
end rem
  Function luaL_prepbuffer:Byte Ptr (B:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_pushresult">Lua Reference Manual</a>
end rem
  Function luaL_pushresult (B:Byte Ptr)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_ref">Lua Reference Manual</a>
end rem
  Function luaL_ref:Int (lua_state:Byte Ptr, t:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_register">Lua Reference Manual</a>
end rem
  Function luaL_register (lua_state:Byte Ptr, libname$z, l:lua_Reg Ptr)            ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_typerror">Lua Reference Manual</a>
end rem
  Function luaL_typerror:Int (lua_state:Byte Ptr, narg:Int, tname$z)               ' no ~0 expected
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_unref">Lua Reference Manual</a>
end rem
  Function luaL_unref (lua_state:Byte Ptr, t:Int, ref:Int)
Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_where">Lua Reference Manual</a>
end rem
  Function luaL_where (lua_state:Byte Ptr, lvl:Int)
End Extern

' ******************************************************************************
' *                                                                            *
' *                       The Auxiliary Library (Macros)                       *
' *                                                                            *
' ******************************************************************************

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_addchar">Lua Reference Manual</a>
end rem
  Function luaL_addchar (B:Byte Ptr, c:String)
'    luaL_addstring(B,Left$(c,1))     ' not really efficient, just to be complete
	luaL_addstring( B,c[..Min(c.Length,1)] )	'functionally equivalent?
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_argcheck">Lua Reference Manual</a>
end rem
  Function luaL_argcheck (lua_state:Byte Ptr, cond:Int, narg:Int, extramsg:String)
    If (Not cond) Then luaL_argerror(lua_state, narg, extramsg)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checkint">Lua Reference Manual</a>
end rem
  Function luaL_checkint:Int (lua_state:Byte Ptr, narg:Int)
    Return Int(luaL_checkinteger(lua_state, narg))   ' Lua itself does the same!
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checklong">Lua Reference Manual</a>
end rem
  Function luaL_checklong:Long (lua_state:Byte Ptr, narg:Int)
    Return luaL_checkinteger(lua_state, narg)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_checkstring">Lua Reference Manual</a>
end rem
  Function luaL_checkstring:String (lua_state:Byte Ptr, narg:Int)
    Local Size:Int
    Local StringPtr:Byte Ptr = luaL_checklstring(lua_state, narg, Varptr Size)
    If (StringPtr = Null) Then
      Return Null
    Else
      Return String.fromBytes(StringPtr,Size)
    End If
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_dofile">Lua Reference Manual</a>
end rem
  Function luaL_dofile:Int (lua_state:Byte Ptr, filename:String)
    If (luaL_loadfile(lua_state,filename) <> 0) Then
      Return 1
    Else
      Return lua_pcall(lua_state, 0, LUA_MULTRET, 0)
    End If
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_dostring">Lua Reference Manual</a>
end rem
  Function luaL_dostring:Int (lua_state:Byte Ptr, str:String)
    If (luaL_loadstring(lua_state,str) <> 0) Then
      Return 1
    Else
      Return lua_pcall(lua_state, 0, LUA_MULTRET, 0)
    End If
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_getmetatable">Lua Reference Manual</a>
end rem
  Function luaL_getmetatable (lua_state:Byte Ptr, tname:String)
    lua_getfield(lua_state, LUA_REGISTRYINDEX, tname)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_optint">Lua Reference Manual</a>
end rem
  Function luaL_optint:Int (lua_state:Byte Ptr, narg:Int, d:Int)
    Return luaL_optinteger(lua_state, narg, d)
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_optlong">Lua Reference Manual</a>
end rem
  Function luaL_optlong:Long (lua_state:Byte Ptr, narg:Int, d:Long)
    If ((Abs(narg) > lua_gettop(lua_state)) Or lua_isnil(lua_state,narg)) Then
      Return d
    Else
      Return luaL_checklong(lua_state,narg)
    End If
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_optstring">Lua Reference Manual</a>
end rem
  Function luaL_optstring:String (lua_state:Byte Ptr, narg:Int, d:String)
    Local Size:Int
    Local StringPtr:Byte Ptr = luaL_optlstring(lua_state, narg, d, Varptr Size)
    If (StringPtr = Null) Then
      Return Null
    Else
      Return String.fromBytes(StringPtr,Size)
    End If
  End Function

Rem
bbdoc: see <a href="../lua-5.1.4/doc/manual.html#luaL_typename">Lua Reference Manual</a>
end rem
  Function luaL_typename:String (lua_state:Byte Ptr, idx:Int)
    Return lua_typename(lua_state, lua_type (lua_state,idx))
  End Function

' ******************************************************************************
' *                                                                            *
' *     compatibility extensions (not to break existing axe.lua programs)      *
' *                                                                            *
' ******************************************************************************

Extern
  Function luaopen_base:Int    (lua_state:Byte Ptr)
  Function luaopen_debug:Int   (lua_state:Byte Ptr)
  Function luaopen_io:Int      (lua_state:Byte Ptr)
  Function luaopen_math:Int    (lua_state:Byte Ptr)
  Function luaopen_os:Int      (lua_state:Byte Ptr)
  Function luaopen_package:Int (lua_state:Byte Ptr)
  Function luaopen_string:Int  (lua_state:Byte Ptr)
  Function luaopen_table:Int   (lua_state:Byte Ptr)
End Extern

  Function lua_dobuffer:Int (lua_state:Byte Ptr, buff:String, sz:Int, name:String)
    If (luaL_loadbuffer(lua_state,buff,sz,name) <> 0) Then
      Return 1
    Else
      Return lua_pcall(lua_state, 0, LUA_MULTRET, 0)
    End If
  End Function

  Function lua_dofile:Int (lua_state:Byte Ptr, filename:String)
    Return luaL_dofile(lua_state,filename)
  End Function

  Function lua_dostring:Int (lua_state:Byte Ptr, str:String)
    Return luaL_dostring(lua_state,str)
  End Function

  Function lua_strlen:Int (lua_state:Byte Ptr, index:Int)
    Return lua_objlen(lua_state,index)
  End Function
