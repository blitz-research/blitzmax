Strict

Type TGadgetItem
	
	Field text$, tip$, icon, flags
	Field extra:Object
	
	'Method Set:TGadgetItem(_text$,_tip$,_icon,_extra:Object,_flags)
	Method Set(_text$,_tip$,_icon,_extra:Object,_flags)
		text=_text
		tip=_tip
		icon=_icon
		flags=_flags
		extra=_extra
		'Return Self
	End Method
	
End Type
