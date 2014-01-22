
' Ported from another Basic for benchmarking purposes...

Const ITERATIONS = 10000

Local Flags [8191]
Print "SIEVE OF ERATOSTHENES - " + ITERATIONS + " iterations"

X = MilliSecs ()

For Iter = 1 To ITERATIONS

  Count = 0

  For I = 0 To 8190
    Flags[I] = 1
  Next

  For I = 0 To 8190
    If Flags[I]=1 Then
       Prime = I + I
       Prime = Prime + 3
       K = I + Prime
       While K <= 8190
         Flags[K] = 0
         K = K + Prime
       Wend
       Count = Count + 1
    EndIf
  Next

Next

X = MilliSecs () - X

Print "1000 iterations took "+(X/1000.0)+" seconds."
Print "Primes: "+Count
End

