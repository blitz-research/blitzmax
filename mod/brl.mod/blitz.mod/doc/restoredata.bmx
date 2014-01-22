' restoredata.bmx

For i=1 To 5
	RestoreData mydata	'reset the data pointer everly loop so we don't read past the end
	ReadData name$,age,skill
	Print "name="+name+" age="+age+" skill="+skill
Next

#mydata	'program label that can be used with the RestoreData command

DefData "Simon",37,5000
