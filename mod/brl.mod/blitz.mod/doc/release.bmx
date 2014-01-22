Rem
Release removes the internal reference caused by creating an integer handle to a type.
End Rem

Type MyType
	Field bigmap[1024*1024]
End Type

GCCollect
Print GCMemAlloced()

a=New MyType
GCCollect
Print GCMemAlloced()

Release a
GCCollect
Print GCMemAlloced()
