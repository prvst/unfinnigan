This structure seems to be an element in a linked list enumerating all scans.

Each ScanIndexEntry is a static (fixed-size) structure containing the
pointer to a scan, the scan's data size and some auxiliary information
about the scan.

## Structure ##
### Static size: 72 bytes ###
### MS1 Scan ###

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 4 | UInt32 | `offset` | `2202924` |
| 4 | 4 | UInt32 | `index` | `103` |
| 8 | 2 | UInt16 | `scan event` | `0` |
| 10 | 2 | UInt16 | `scan segment` | `0` |
| 12 | 4 | UInt32 | `next` | `104` |
| 16 | 4 | UInt32 | `unknown long` | `21` |
| 20 | 4 | UInt32 | `data size` | `19752` |
| 24 | 8 | Float64 | `start time` | `2.197725` |
| 32 | 8 | Float64 | `total current` | `2664515.25` |
| 40 | 8 | Float64 | `base intensity` | `391502.125` |
| 48 | 8 | Float64 | `base mass` | `391.284149169922` |
| 56 | 8 | Float64 | `low mz` | `300` |
| 64 | 8 | Float64 | `high mz` | `1700` |

### MS2 Scan ###

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 4 | UInt32 | `offset` | `2222676` |
| 4 | 4 | UInt32 | `index` | `104` |
| 8 | 2 | UInt16 | `scan event` | `1` |
| 10 | 2 | UInt16 | `scan segment` | `0` |
| 12 | 4 | UInt32 | `next` | `105` |
| 16 | 4 | UInt32 | `unknown long` | `18` |
| 20 | 4 | UInt32 | `data size` | `2092` |
| 24 | 8 | Float64 | `start time` | `2.20920833333333` |
| 32 | 8 | Float64 | `total current` | `11653.5556640625` |
| 40 | 8 | Float64 | `base intensity` | `1732.13220214844` |
| 48 | 8 | Float64 | `base mass` | `397.318511962891` |
| 56 | 8 | Float64 | `low mz` | `105` |
| 64 | 8 | Float64 | `high mz` | `880` |

## The unknowns ##

  * It is not clear whether scan index numbers start at 0 or at 1. If they start at 0, the list link index must point to the next item. If they start at 1, then `index` will become `previous` and `next` becomes `index` -- the list will be linked from tail to head. Although observations are lacking, I am inclined to interpret it as a forward-linked list, simply from common sense.

  * The `unknown long` seems to be indicating the type of scan. I am not sure how to interpret it; here are the only three different values I have seen in it:
| Type of scan | value (decimal) | bits |
|:-------------|:----------------|:-----|
| MS1 | `21` | `10101` |
| MS2 in centroid mode | `18` | `10010` |
| MS2 in profile mode | `19` | `10011` |