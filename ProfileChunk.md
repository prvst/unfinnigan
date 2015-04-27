## Purpose ##

This structure allows for compact storage of filtered scan profiles (see [Profile](Profile.md)). A filtered profile is formed by deleting the sub-threshold bins, leaving gaps in the bin sequence surrounding the isolated chunks of contiguous non-zero values. These chunks are stored using implicit reference to the first bin value in the profile (kept in the profile header).

Further, only the first bin number and the bin count are stored in the chunk structure. If _i_ is the bin index relative to the start of the chunk (_i = 0 .. nbins_), then the bin value at _i_ can be calculated using this formula:

> _value<sub>i</sub> = first\_profile\_value + step · (first\_bin + i)_

where _first\_profile\_value_ is the value of the leftmost bin in the profile and _step_ is the bin width, whose sign indicates the direction of change with the increase of the bin number. Both values are stored the profile header. The _first\_bin_ and _nbins_ are stored in the chunk.

## Structure ##

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 4 | UInt32 | `first bin` | `13554` |
| 4 | 4 | UInt32 | `nbins` | `7` |
| 8 | 4 | Float32 | `fudge` | `0.00013906808453612` |
| 12 | 28 | Float32 | `signal` | `1628.89855957031, 4409.759765625, 6416.55029296875, 6239.3828125, 3988.13525390625, 1267.3466796875, 0` |

Note that sometimes a zero bin can be included on either side of the chunk.