
Strict

Rem
bbdoc: Events/Hook functions
End Rem
Module BRL.Hook

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Added Context parameter to RemoveHook function"

Private

Type THook
	Field succ:THook
	Field priority
	Field func:Object( id,data:Object,context:Object )
	Field context:Object
End Type

Global hooks:THook[256]

Public

Rem
bbdoc: Allocate a hook id
returns: An integer hook id
about:
The returned hook id can be used with #AddHook, #RunHooks and #RemoveHook.
end rem
Function AllocHookId()
	Global id=-1
	id:+1
	If id>255 Throw "Too many hook ids"
	Return id
End Function

Rem
bbdoc: Add a hook function
returns: A hook object that can be used with the #RemoveHook command.
about:
Add a hook function to be executed when #RunHooks is called with the specified hook @id.
End Rem
Function AddHook( id,func:Object( id,data:Object,context:Object ),context:Object=Null,priority=0 )

	Local t:THook=New THook
	t.priority=priority
	t.func=func
	t.context=context
	
	Local pred:THook
	Local hook:THook=hooks[id]
	
	While hook
		If priority>hook.priority Exit
		pred=hook
		hook=hook.succ
	Wend
	
	If pred
		t.succ=pred.succ
		pred.succ=t
	Else
		t.succ=hooks[id]
		hooks[id]=t
	EndIf
	
End Function

Rem
bbdoc: Run hook functions
returns: The data produced by the last hook function
about:
#RunHooks runs all hook functions that have been added for the specified hook @id.

The first hook function is called with the provided @data object. The object returned by
this function is then passed as the @data parameter to the next hook function and so on. 
Therefore, hook functions should generally return the @data parameter when finished.
End Rem
Function RunHooks:Object( id,data:Object )

	Local hook:THook=hooks[id]
	While hook
		data=hook.Func( id,data,hook.context )
		hook=hook.succ
	Wend
	Return data

End Function

Rem
bbdoc:Remove a hook function
about:
Removes the hook function specified by @id, @func and @context.
End Rem
Function RemoveHook( id,func:Object( id,data:Object,context:Object ),context:Object=Null )

	Local pred:THook
	Local hook:THook=hooks[id]
	
	While hook And (hook.func<>func Or hook.context<>context)
		pred=hook
		hook=hook.succ
	Wend
	
	If Not hook Return
	
	If pred
		pred.succ=hook.succ
	Else
		hooks[id]=hook.succ
	EndIf

End Function

