Rem
IncBin embeds an external data file in a BlitzMax program that can 
then be read using the "incbin::" device name.
End Rem

' code snippet from demos/firepaint/firepaint.bmx

Incbin "stars.png"

Local stars=LoadImage( "incbin::stars.png" )
