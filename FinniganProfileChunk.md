# `Finnigan::ProfileChunk` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ProfileChunk.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $chunk = Finnigan::ProfileChunk->decode( \*INPUT, $packet_header->layout );
say $chunk->first_bin;
say $chunk->fudge;
my $nbins = $chunk->nbins;
foreach my $i ( 0 .. $nbins - 1) {
  say $chunk->signal->[$i];
}
```

## Description ##

`Finningan::ProfileChunk` is a full-featured decoder for the ProfileChunk structure, a segment of a [Profile](Profile.md). The data it generates contain the seek addresses, sizes and types of all decoded elements, no matter how small. That makes it very handy in the exploration of the file format and in writing new code, but it is not very efficient in production work.

In performance-sensitive applications, the more lightweight [Finnigan::Scan](FinniganScan.md) module should be used, which includes [Finnigan::Scan::ProfileChunk](FinniganScanProfileChunk.md) and other related submodules. It can be used as a drop-in replacement for the full-featured modules, but it does not store the seek addresses and object types, greatly reducing the overhead.

Every scan done in the _profile mode_ has a profile, which is either a time-domain signal or a frequency spectrum accumulated in histogram-like bins.

A profile can be either raw or filtered. Filtered profiles are sparse; they consist of separate data chunks. Each chunk consists of a contiguous range of bins containing the above-threshold signal. The bins whose values fall below a cerain threshold are simply discarded, leaving gaps in the profile -- the reason for the ProfileChunk structure to exist.

One special case is raw profile, which preserves all data. Since there are no gaps in a raw profile, it is represented by a single chunk covering the entire range of bins, so the same container structure is suitable for complete profiles, as well as for sparse ones.

The bins store the signal intensity, and the bin co-ordinates are typically the frequencies of Fourier-transformed signal. Since the bins are equally spaced in the frequency domain, only the first bin frequency is stored in each profile header. The bin width is common for all bins and it is also stored in the same header. With these data, it is possible to calculate the bin values based on the bin indices.

Each ProfileChunk structure stores the first bin index, the number of bins, and a list of bin intensities. Additionally, in some layouts, it stores a small floating-point value that most probably represents the instrument drift relative to its calibrated value; this "fudge" value is added to the result of the the frequency to _M/z_ conversion. The chunk layout (the presence or absence of the fudge value) is determined by the layout flag in PacketHeader.

## Methods ##

  * **decode**
> > The constructor method

  * **nbins**
> > Get the number of bins chunks in the chunk

  * **first\_bin**
> > Get the index of the first bin in the chunk

  * **fudge**
> > Get the the value of conversion bias

  * **signal**
> > Get the list of bin values

## See Also ##

[Profile](Profile.md) (structure)

[ProfileChunk](ProfileChunk.md) (structure)

[PacketHeader](PacketHeader.md) (structure)

[Finnigan::PacketHeader](FinniganPacketHeader.md) (decoder object)

[Finnigan::Scan::ProfileChunk](FinniganScanProfileChunk.md) (lightweight decoder)

[Finnigan::Scan](FinniganScan.md) (lightweight decoder)

[ScanEvent](ScanEvent.md) (structure containing conversion coefficients)

[Finnigan::ScanEvent](FinniganScanEvent.md) (decoder object)