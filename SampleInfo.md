SampleInfo is a static (fixed-size) binary preamble to RunHeader
containing data stream lengths and addresses, as well as some
unidentified data. All data streams in the file, except for the list
of ScanHeader records and TrailerScanEvent stream have their addresses
stored in SampleInfo.

The addresses of the ScanHeader and TrailerScanEvent streams are
stored in the parent structure, RunHeader.

It appears as though RunHeader is a recently introduced wrapper around
the older SampleInfo structure.

## Structure ##
### Static size: 592 bytes ###

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 4 | UInt32 | `unknown_long[1]` | `1` |
| 4 | 4 | UInt32 | `unknown_long[2]` | `0` |
| 8 | 4 | UInt32 | `first scan number` | `1` |
| 12 | 4 | UInt32 | `last scan number` | `33` |
| 16 | 4 | UInt32 | `inst log length` | `17` |
| 20 | 4 | UInt32 | `unknown_long[3]` | `0` |
| 24 | 4 | UInt32 | `unknown_long[4]` | `0` |
| 28 | 4 | UInt32 | `scan index addr` | `829706` |
| 32 | 4 | UInt32 | `data addr` | `24950` |
| 36 | 4 | UInt32 | `inst log addr` | `792726` |
| 40 | 4 | UInt32 | `error log addr` | `803810` |
| 44 | 4 | UInt32 | `unknown_long[5]` | `0` |
| 48 | 8 | Float64 | `max ion current` | `11508917` |
| 56 | 8 | Float64 | `low mz` | `100` |
| 64 | 8 | Float64 | `high mz` | `2000` |
| 72 | 8 | Float64 | `scan start time` | `0.00581833333333333` |
| 80 | 8 | Float64 | `scan end time` | `0.242753333333333` |
| 88 | 56 | RawBytes | `unknown area` | `0` |
| 144 | 88 | UTF16LE | `tag[1]` | `00 00 00 00 00 00 00 00 00 00 ...` |
| 232 | 40 | UTF16LE | `tag[2]` | `00 00 00 00 00 00 00 00 00 00 ...` |
| 272 | 320 | UTF16LE | `tag[3]` | `00 00 00 00 00 00 00 00 00 00 ...` |

### The unknowns ###

  * The unknown long integers, all expect for the first one, are set to zero in all observed files, and so is the unknown area.
  * The first unknown long was seen set to 0 or 1.
  * In the old LCQ files, the tags can be seen set like this:
```
  144) tag[1]= "27417_Sat_0504WD1_Plas_22" (88 bytes)
  232) tag[2]= "5/5/96" (40 bytes)
  272) tag[3]= "linda" (320 bytes)
```
  * The item named `max ion current` is named so because its value co-incides with the value named "Total Ion Current" in one of the scans -- in which it has the highest value. But I do know know what it is useful for.