' requestfile.bmx

filter$="Image Files:png,jpg,bmp;Text Files:txt;All Files:*"
filename$=RequestFile( "Select graphic file to open",filter$ )

Print filename
