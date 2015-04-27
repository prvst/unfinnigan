## Description ##

The stream contains fixed-size ScanEvent structures loaded with the detailed information about scan type (ScanEventPreamble) and containing conversion coefficients for profile-type scans. The steam begins with the record counter, although it seems to be redundant, given that there are exactly the same number of ScanEvent structures as there are [scan data packets](ScanDataPacket.md).

Thermo calls this stream a "trailer", apparently because it was added to the end of the file at one time in the history of the format. It no longer is that, as there are a couple more streams trailing it today.

## Structure ##

| Number of scan events (UInt32) |
|:-------------------------------|
| ScanEvent 1 |
| . . . |
| ScanEvent _n_ |

The pointer to the stream is contained in Run Header.

## See Also ##

[ScanEvent](ScanEvent.md) (structure)

[ScanEventPreamble](ScanEventPreamble.md) (structure)

[Scan Event Hierarchy](ScanEventHierarchy.md) (structure)

[ScanEventTemplate](ScanEventTemplate.md) (structure)

[RunHeader](RunHeader.md) (index structure)