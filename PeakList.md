## Description ##

The peak list is an optional part of the [ScanDataPacket](ScanDataPacket.md) structure. It starts with the peak count value, which determines the number of (_M/z_, intensity) pairs in the list, both of which are floating-point values.

## Structure ##

| Number of peaks (UInt32) |
|:-------------------------|
| Peak 1 (M/z: Float32, Intensity: Float32) |
| . . . |
| Peak _n_ (M/z: Float32, Intensity: Float32) |

## Location ##

The peak list immediately follows the [Profile](Profile.md) structure in [ScanDataPacket](ScanDataPacket.md). Either structure (peak list or profile) can be NULL, in which case it is represented by a zero count.

## See Also ##

[ScanDataPacket](ScanDataPacket.md) (structure)