' appdir.bmx
' requests the user to select a file from the application's directory

Print "Application Directory="+AppDir$

file$=RequestFile("Select File to Open","",False,AppDir$)

Print "file selected was :"+file