# `Finnigan::SampleInfo` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/SampleInfo.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $rh = Finnigan::RunHeader->decode(\*INPUT, $version);
my $si = $rh->sample_info; # calls Finnigan::SampleInfo->decode
say $si->first_scan;
say $si->last_scan;
say $si->tot_ion_current;
my $scan_index_addr = $si->scan_index_addr;
. . .
```

## Description ##

This decoder reads SampleInfo, a static (fixed-size) binary preamble to RunHeader containing data stream lengths and addresses, as well as some unidentified data. Four out of six data streams in the file have their addresses stored in SampleInfo. The other two, ScanHeader and ScanEvent streams, are addressed through RunHeader.

The SampleInfo structure also a few numeric values describing the run (the fact that vaguely justifies its name).

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **first\_scan**
> > Get the first scan number

  * **last\_scan**
> > Get the last scan number

  * **inst\_log\_length**
> > Get the number of instrument log records

  * **max\_ion\_current**
> > Get the pointer to the stream of ScanPrarameters structures

  * **low\_mz**
> > Get the low end of the _M/z_ range

  * **high\_mz**
> > Get the high end of the _M/z_ range

  * **start\_time**
> > Get the start time (retention time in seconds)

  * **end\_time**
> > Get the end time (retention time in seconds)

  * **scan\_index\_addr**
> > Get the address of the ScanIndex stream

  * **data\_addr**
> > Get the address of the [ScanDataPacket](ScanDataPacket.md) stream

  * **inst\_log\_addr**
> > Get the address of the instrument log records (of GenericRecord type)

  * **error\_log\_addr**
> > Get the address of the [Error](Error.md) stream

## See Also ##

[RunHeader](RunHeader.md) (parent structure)

[ScanDataPacket](ScanDataPacket.md) (structure)

[ScanIndex](ScanIndex.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[ScanParameters](ScanParameters.md) (structure)

[Error](Error.md) (structure)