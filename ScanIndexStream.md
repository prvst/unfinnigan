## Purpose ##

The ScanDataPacket structures can be hefty, and reading through possibly thousands of them in sequence to reach a particular scan may not be very efficient. Presumably, the purpose of the ScanIndexEntry stream is to provide a shortcut to scan data. Each index entry stores the pointer to the start of the scan and the scan data size.

Another possible purpose may be to serve as a means to manipulate the scan sequence; for example, to delete certain scans. Each scan index entry has what sees to be the index of the next entry, suggesting a linked-list structure. This would not be necessary if all scans were always contiguous (which they were in all cases studied, but there is no guarantee).

## Structure and location ##

The scan index stream is located near the end of the file (between the Tune File and the [ScanEvent stream](ScanEventStream.md). It does not have a header or a counter in front of it (obviously because there are as many scan index entries as there are scan data packets); the length of the stream is apparently determined as the difference between the last and the first scan numbers store in the SampleInfo structure.

## See Also ##

[ScanIndexEntry](ScanIndexEntry.md) (structure)

[SampleInfo](SampleInfo.md) (structure)

[ScanDataPacket](ScanDataPacket.md) (structure)