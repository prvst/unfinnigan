This object contains a couple of double-precision floating point numbers that define the precursor ion M/z and, apparently, the enrgy with which it was whacked (both are conjectures at this point, but very plausible
ones).

It is part of ScanEvent.

## Structure ##
### Static size: 32 bytes ###

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 8 | Float64 | `precursor mz` | `445.121063232422` |
| 8 | 8 | Float64 | `unknown double` | `1` |
| 16 | 8 | Float64 | `energy` | `35` |
| 24 | 4 | UInt32 | `unknown long[1]` | `1` |
| 28 | 4 | UInt32 | `unknown long[2]` | `0` |

## The unknowns ##

  * The unknown double seems to be set to 1.0 in all observations