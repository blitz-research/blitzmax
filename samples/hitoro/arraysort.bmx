
' Create an array of (nonsense) strings, one for each letter of the alphabet...

Local drivel:String [26]

' Fill all 26 strings in (remember we include 0, so the last is 25)...

drivel [0] = "Hello"
drivel [1] = "Golly, Miss Lane"
drivel [2] = "I like whippets"
drivel [3] = "Oink"
drivel [4] = "Apparently not"
drivel [5] = "Tell me when, Lord, tell me when"
drivel [6] = "Flat Harry is alive and well"
drivel [7] = "North, Miss Teschmacher, north!"
drivel [8] = "Egg-shaped boy"
drivel [9] = "Say it again"
drivel [10] = "Krazy Kat is a heppy, heppy kitty"
drivel [11] = "Death to the Pixies!"
drivel [12] = "You're wrong"
drivel [13] = "Maybe tomorrow I'll wanna settle down"
drivel [14] = "Jumpin' junipers!"
drivel [15] = "Rock out!"
drivel [16] = "Brilliant!"
drivel [17] = "Victoria was my queen"
drivel [18] = "Leaving so soon?"
drivel [19] = "Quatermass rules"
drivel [20] = "C sucks"
drivel [21] = "Under the stars"
drivel [22] = "Xylophone solo"
drivel [23] = "Zebra hell"
drivel [24] = "Well I never"
drivel [25] = "Perhaps some other time?"

' Sort the array of strings (type String has a Sort method)...

drivel.Sort

' Print 'em out in alphabetical order...

For a = 0 Until Len (drivel)
    Print a + " : " + drivel [a]
Next

