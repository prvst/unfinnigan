## Purpose ##

I do not fully understand the purpose of this structure, but based on the labels it contains, it seems to have been intended for human consumption. It does not seem to contain any data that wouldn't be stored somewhere else in the file.

One possible exception is the **Charge State** attribute that I needed to fill the precursor data while writing out the XML for the MS2 scans in [UnfinniganMzXML](UnfinniganMzXML.md).

The content of ScanParameters records is designed to be decoded with the GenericDataHeader mechanism.

## Structure ##

| GenericDataHeader (loaded with `ScanParmeters` descriptors) |
|:------------------------------------------------------------|
| . . . |
| _a few intervening data structures and streams_ |
| . . . |
| ScanParameters record 1 |
| . . . |
| ScanParameters record _n_ |

Each ScanParameters record corresponds to a ScanDataPacket, so there is no need for a separate object counter. The seek address of the first ScanParameters record is contained in RunHeader, but the stream's header (a GenericDataHeader) can only be reached by starting from the ErrorLog (the nearest object with a known seek address) and reading through it, then reading through. [Scan Event Hierarchy](ScanEventHierarchy.md).