# `Finnigan::ScanIndexEntry` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ScanIndexEntry.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $entry = Finnigan::ScanIndexEntry->decode(\*INPUT);
say $entry->offset; # returns an offset from the start of scan data stream 
say $entry->data_size;
$entry->dump;
```

## Description ##

This decoder reads ScanIndexEntry, the static (fixed-size) structure containing the
pointer to a scan, the scan's data size and some auxiliary information
about the scan.

Scan index elements seem to form a linked list. Each
ScanIndexEntry contains the index of the next entry.

Although in all observed instances the scans were sequential and their
indices could be ignored, it may not always be the case.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **offset**
> > Get the address of the corresponding ScanDataPacket relative to the start of the data stream

  * **index**
> > Get this element's index (_a valid assumption if the scan data indices start at 0, otherwise this is the previous element's index_)

  * **next**
> > Get the next element's index(_a valid assumption if the scan data indices start at 0, otherwise this is the current element's index_)

  * **scan\_event**
> > Get the index of this element's ScanEventTemplate in the current scan segment

  * **scan\_segment**
> > Get the index of this element's scan segment in [Scan Event Hierarchy](ScanEventHierarchy.md)

  * **data\_size**
> > Get the size of the ScanDataPacket this index element is pointing to

  * **start\_time**
> > Get the current scan's start time

  * **total\_current**
> > Get the scan's total current (a rough indicator of how many ions were scanned)

  * **base\_intensity**
> > Get the intensity of the most abundant ion

  * **base\_mz**
> > Get the _M/z_ value of the most abundant ion

  * **low\_mz**
> > Get the low end of the scan range

  * **high\_mz**
> > Get the high end of the scan range

  * **unknown**
> > Get the only unknown UInt32 stored in the index entry. Its value (or some bits in it) seem to correspond to the type of scan, but its interpretation is uncertain.

**Note**: The "current/next" theory of the two ordinal numbers in this structure may be totally wrong. It may just be that one of these numbers is the 0-base index (0 .. _n_ -1), and the other is 1-based: (1 .. _n_). It is suspicious that in the last entry in every stream, the "next" value is not null, it simply _n_.

## See Also ##

[ScanDataPacket](ScanDataPacket.md) (structure)

[ScanEventHierarchy](ScanEventHierarchy.md) (structure)