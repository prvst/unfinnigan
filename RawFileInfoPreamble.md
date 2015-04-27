This fixed-size structure is a binary preamble to RawFileInfo, and it contains an unpacked representation of a UTC date (apparently, the file creation date), a set of unknown numbers, and most importantly, the more modern versions of this structure contain the pointers to ScanData and to RunHeader, which in turn stores pointers to all data streams in the file.

The older version of this structure did not extend beyond the date stamp.

## Structure ##
### Static size: 804 bytes ###

| 0 | 4 | UInt32 | `unknown long[1]` | `1` |
|:--|:--|:-------|:------------------|:----|
| 4 | 2 | UInt16 | `year` | `2008` |
| 6 | 2 | UInt16 | `month` | `4` |
| 8 | 2 | UInt16 | `day of the week` | `3` |
| 10 | 2 | UInt16 | `day` | `30` |
| 12 | 2 | UInt16 | `hour` | `19` |
| 14 | 2 | UInt16 | `minute` | `12` |
| 16 | 2 | UInt16 | `second` | `52` |
| 18 | 2 | UInt16 | `millisecond` | `187` |
| 20 | 4 | UInt32 | `unknown_long[2]` | `0` |
| 24 | 4 | UInt32 | `data addr` | `39084` |
| 28 | 4 | UInt32 | `unknown_long[3]` | `1` |
| 32 | 4 | UInt32 | `unknown_long[4]` | `1` |
| 36 | 4 | UInt32 | `unknown_long[5]` | `0` |
| 40 | 4 | UInt32 | `unknown_long[6]` | `0` |
| 44 | 4 | UInt32 | `run header addr` | `393568276` |
| 48 | 756 | RawBytes | `unknown_area` | `0` |

## The unknowns ##

Quite a few fields remain unknown in this structure. The `unknown_area` at the end may simply be padding (I have only seen it filled with zeroes), but it can also be reserved for text (which is likely, given its large size).