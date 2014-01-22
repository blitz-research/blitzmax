Rem
Double is a 64 bit floating point BlitzMax primitive type.
End Rem

Local speedoflight:Double
Local distance:Double
Local seconds:Double

speedoflight=299792458:Double	'meters per second
distance=149597890000:Double	'average distance in meters from earth sun

seconds=distance/speedoflight

Print "Number of seconds for light to travel from earth to sun="+seconds