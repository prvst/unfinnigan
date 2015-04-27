## Description ##

The stream is a simple sequence of text messages timestamped with the current retention time of the sample.

## Structure ##

| Number of records (UInt32) |
|:---------------------------|
| Message 1  = {timestamp,  PascalStringWin32} |
| . . . |
| Message _n_ = {timestamp, PascalStringWin32} |

The pointer to the stream is contained in SampleInfo (part of RunHeader).