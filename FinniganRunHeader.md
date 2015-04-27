# `Finnigan::RunHeader` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/RunHeader.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $rh = Finnigan::RunHeader->decode(\*INPUT, $version);
my $first_scan_number = $rh->first_scan;
my $last_scan_number = $rh->last_scan;
my $scan_index_addr = $rh->sample_info->scan_index_addr;
```

## Description ##

Decodes RunHeader, the static (fixed-size) structure containing data stream
lengths and addresses, as well as some unidentified data. Every data
stream in the file has its address stored in RunHeader or in its
historical antecedent SampleInfo, which it now includes.

## Methods ##

  * **decode($stream, $version)**
> > The constructor method

  * **sample\_info**
> > Get the [Finnigan::SampleInfo](FinniganSampleInfo.md) object

  * **self\_addr**
> > Get own address

  * **trailer\_addr**
> > Get the "trailer" address -- the pointer to the stream of ScanEvent structures

  * **params\_addr**
> > Get the pointer to the stream of ScanPrarameters structures

  * **ntrailer**
> > Get the length of the ScanEvent stream

  * **nparams**
> > Get the length of the ScanParameters stream

  * **nsegs**
> > Get the number of scan segments
## See Also ##

[RunHeader](RunHeader.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[ScanParameters](ScanParameters.md) (structure)

[Finnigan::SampleInfo](FinniganSampleInfo.md) (decoder object)