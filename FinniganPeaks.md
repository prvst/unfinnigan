# `Finnigan::Peaks` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Peaks.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $c = Finnigan::Peaks->decode(\*INPUT);
say $c->count;
say $c->peak->[0]->mz;
say $c->peak->[0]->abundance;
```

## Description ##

This is a simple but full-featured decoder for the PeakList structure, part of ScanDataPacket. The data it generates contain the seek addresses, sizes and types of all decoded elements, no matter how small. That makes it very handy in the exploration of the file format and in writing new code, but it is not very efficient in production work.

It decodes the stream of floating-point numbers into a list of [Finnigan::Peak](FinniganPeak.md) objects, each containing an (_M/z_, abundance) pair.

In performance-sensitive applications, the more lightweight [Finnigan::Scan](FinniganScan.md) module should be used, which includes [Finnigan::Scan::CentroidList](FinniganScanCentroidList.md) and other related submodules. It can be used as a drop-in replacement for the full-featured modules, but it does not store the seek addresses and object types, greatly reducing the overhead.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **count**
> > Get the number of peaks in the list

  * **peaks**
> > Get the list of [Finnigan::Peak](FinniganPeak.md) objects

  * **peak**
> > Same as **peaks**. I find the dereference expressions easier to read when the reference name is singular: `$scan->peak->[0]` (rather than `$scan->peaks->[0]`). However, I prefer the plural form when there is no dereferencing: `$peaks = $scan->peaks;

  * **all**
> > Get the reference to an array containing the pairs of [_M/z_, abundance] values of each centroided peak. This method avoids the expense of calling the [Finnigan::Peak](FinniganPeak.md) accessors.

  * **list**
> > Print the entire peak list to STDOUT

## See Also ##

[PeakList](PeakList.md) (structure)

[ScanDataPacket](ScanDataPacket.md) (structure)

[Finnigan::Peak](FinniganPeak.md)  (decoder object)

[Finnigan::Scan](FinniganScan.md)  (lightweight decoder object)

[Finnigan::Scan::CentroidList](FinniganScanCentroidList.md) (lightweight decoder object)