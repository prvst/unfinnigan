This object is just a container for a pair of double-precision floating point numbers that define the M/z range of ions collected during a scan. It is found in ScanEvent objects.

## Structure ##
### Static size: 16 bytes ###
| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 8 | Float64 | low mz | 400 |
| 8 | 8 | Float64 | high mz | 2000 |