' RndSeed.bmx and SeedRnd.bmx ( one example for both )
' Get/Set random number seed.

SeedRnd MilliSecs()

seed=RndSeed()

Print "Initial seed="+seed

For k=1 To 10
Print Rand(10)
Next

Print "Restoring seed"

SeedRnd seed

For k=1 To 10
Print Rand(10)
Next
