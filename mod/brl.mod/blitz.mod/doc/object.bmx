Rem
Object is the base class of all BlitzMax types.

The following function attempts to cast from any object to
the custom type TImage and returns true if the given object
is an instance of TImage or an instance of a &Type derived
from TImage.
End Rem

Function IsImage(obj:Object)
	If TImage(obj) return True
	Return False
End Function
