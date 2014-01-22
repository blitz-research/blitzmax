Rem
Type marks the beginning of a BlitzMax custom type.

Standard BlitzMax types use a preceeding "T" naming
convention to differentiate themselves from standard
BlitzMax variable names.
End Rem

Type TVector
	Field	x,y,z
End Type

Local a:TVector=new TVector

a.x=10
a.y=20
a.z=30
