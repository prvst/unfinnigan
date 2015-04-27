# `Finnigan::Profile` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Profile.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $profile = Finnigan::Profile->decode( \*INPUT, $packet_header->layout );
say $profile->first_value;
say $profile->peak_count;
say $profile->nbins;
$profile->set_converter( $func_ref );
my $bins = $profile->bins; # calls the converter
my ($mz, $abundance) = @{$bins->[0]} # data in the first bin
```

## Description ##

`Finningan::Profile` is a full-featured decoder for Finnigan scan profiles. The data it generates contain the seek addresses, sizes and types of all decoded elements, no matter how small. That makes it very handy in the exploration of the file format and in writing new code, but it is not very efficient in production work.

In performance-sensitive applications, the more lightweight [Finnigan::Scan](FinniganScan.md) module should be used, which includes [Finnigan::Scan::Profile](FinniganScanProfile.md) and other related submodules. It can be used as a drop-in replacement for the full-featured modules, but it does not store the seek addresses and object types, greatly reducing the overhead.

Every scan done in the _profile mode_ has a profile, which is either a time-domain signal or a frequency spectrum accumulated in histogram-like bins.

A profile can be either raw or filtered. Filtered profiles are sparse; they consist of separate data chunks. Each chunk consists of a contiguous range of bins containing the above-threshold signal. The bins whose values fall below a cerain threshold are simply discarded, leaving gaps in the profile -- the reason for the ProfileChunk structure to exist.

One special case is raw profile, which preserves all data. Since there are no gaps in a raw profile, it is represented by a single chunk covering the entire range of bins, so the same container structure is suitable for complete profiles, as well as for sparse ones.

The bins store the signal intensity, and the bin co-ordinates are typically the frequencies of Fourier-transformed signal. Since the bins are equally spaced in the frequency domain, only the first bin frequency is stored in each profile header. The bin width is common for all bins and it is also stored in the same header. With these data, it is possible to calculate the bin values based on the bin indices.

The programs reading these data must convert the frequencies into the M/z values using the conversion function specific to the type of analyser used to acquire the signal. The calibrated coefficients for this convesion function are stored in the ScanEvent structure (one instance of this structure exists for every scan).

The **bins** method of **Finnigan::Profile** returns the converted bins, optionally filling the gaps with zeroes.

## Methods ##

  * **decode($stream, $layout)**
> > The constructor method

  * **nchunks**
> > Get the number of chunks in the profile

  * **nbins**
> > Get the total number of bins in the profile

  * **first\_value**
> > Get the the value of the first bin in the profile

  * **step**
> > Get the bin width and direction of change (the frequency step needed to go from one bin to the next is a negative value)

  * **chunk**, **chunks**
> > Get the list of [Finnigan::ProfileChunk](FinniganProfileChunk.md) objects representing the profile data

  * **set\_converter($func\_ref)**
> > Set the converter function (_f_ → _M/z_)

  * **set\_inverse\_converter($func\_ref)**
> > Set the inverse converter function (_M/z_ → _f_)

  * **bins**
> > Get the reference to an array of bin values. Each array element contains an (_M/z_, abundance) pair.

  * **print\_bins**
> > Lists the bin contents to STDOUT

## See Also ##

[Profile](Profile.md) (structure)

[ProfileChunk](ProfileChunk.md) (structure)

[Finnigan::ProfileChunk](FinniganProfileChunk.md) (decoder object)

[Finnigan::PacketHeader](FinniganPacketHeader.md) (decoder object)

[Finnigan::Scan::Profile](FinniganScanProfile.md) (lightweight decoder)

[Finnigan::Scan](FinniganScan.md) (lightweight decoder)

[ScanEvent](ScanEvent.md) (structure containing conversion coefficients)

[Finnigan::ScanEvent](FinniganScanEvent.md) (decoder object)