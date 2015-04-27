# `Finnigan::Scan::ProfileChunk` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Scan.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $chunk = new Finnigan::Scan::ProfileChunk($buffer, $offset, $packet_header->layout);
$offset += $chunk->{size};

say $chunk->{"first bin"} ;
say $chunk->{fudge};
my $nbins = $chunk->{nbins};
foreach my $i ( 0 .. $nbins - 1) {
  say $chunk->signal->[$i];
}
```

## Description ##

`Finningan::Scan::ProfileChunk` is a lightweight decoder for the ProfileChunk structure, a segment of a [Profile](Profile.md). It does not save the location and type information for the individual list elements, nor does it provide element-level accessor methods. That makes it fast, at the cost of a slight reduction in convenience of access to the data.

It does not do file reads either, decoding part of the stream of profile chunks it receives as a constructor argument from the caller. Its full-featured equivalent, [Finnigan::Peaks](FinniganPeaks.md), does a file read for every data element down to a single integer of floating-point number, which makes it very slow.

`Finnigan::Scan::ProfileChunk` is good for use in production-level programs that need extensive debugging. In a situation that calls for detailed exploration (_e.g._, a new file format), better use [Finnigan::Peaks](FinniganPeaks.md), which has an equivalent interface.

Every scan done in the _profile mode_ has a profile, which is either a time-domain signal or a frequency spectrum accumulated in histogram-like bins.

A profile can be either raw or filtered. Filtered profiles are sparse; they consist of separate data chunks. Each chunk consists of a contiguous range of bins containing the above-threshold signal. The bins whose values fall below a cerain threshold are simply discarded, leaving gaps in the profile -- the reason for the ProfileChunk structure to exist.

One special case is raw profile, which preserves all data. Since there are no gaps in a raw profile, it is represented by a single chunk covering the entire range of bins, so the same container structure is suitable for complete profiles, as well as for sparse ones.

The bins store the signal intensity, and the bin co-ordinates are typically the frequencies of Fourier-transformed signal. Since the bins are equally spaced in the frequency domain, only the first bin frequency is stored in each profile header. The bin width is common for all bins and it is also stored in the same header. With these data, it is possible to calculate the bin values based on the bin indices.

Each ProfileChunk structure stores the first bin index, the number of bins, and a list of bin intensities. Additionally, in some layouts, it stores a small floating-point value that most probably represents the instrument drift relative to its calibrated value; this "fudge" value is added to the result of the the frequency to _M/z_ conversion. The chunk layout (the presence or absence of the fudge value) is determined by the layout flag in PacketHeader.

## Methods ##


  * **new($buffer, $offset, $layout)**
> > The constructor method

This module defines no accessor method because doing so would defeat its goal of being a fast decoder.

## See Also ##

[Profile](Profile.md) (structure)

[ProfileChunk](ProfileChunk.md) (structure)

[PacketHeader](PacketHeader.md) (structure)

[Finnigan::PacketHeader](FinniganPacketHeader.md) (decoder object)

[Finnigan::ProfileChunk](FinniganProfileChunk.md) (full-featured decoder)

[Finnigan::Scan](FinniganScan.md) (lightweight decoder)

[ScanEvent](ScanEvent.md) (structure containing conversion coefficients)

[Finnigan::ScanEvent](FinniganScanEvent.md) (decoder object)