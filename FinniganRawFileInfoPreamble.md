# `Finnigan::RawFileInfoPreamble` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/RawFileInfoPreamble.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $file_info = Finnigan::RawFileInfo->decode(\*INPUT);
say $file_info->preamble->run_header_addr;
say $file_info->preamble->data_addr;
$file_info->preamble->dump;
```

## Description ##

This this object decodes the binary preamble to RawFileInfo, which
contains an unpacked representation of a UTC date (apparently, the
file creation date), a set of unknown numbers, and most importantly,
the more modern versions of this structure contain the pointers to the
ScanDataPacket stream and to RunHeader, which stores the pointers
to all other data streams in the file.

The older versions of this structure did not contain anything except the date stamp.

## Methods ##

  * **decode($stream, $version)**
> > The constructor method

  * **timestamp**
> > Get the timestamp in text form:  `Wkd Mmm DD YYYY hh:mm:ss.ms`

  * **xmlTimestamp**
> > Get the timestamp in text form, in the format adopted in mzML:  `YYYY-MM-DDThh:mm:ssZ`

  * **data\_addr**
> > Get the pointer to the first ScanDataPacket

  * **run\_header\_addr**
> > Get the pointer to RunHeader (which contains further pointers)

  * **stringify**
> > Make a concise string representation of the structure

## See also ##

[RawFileInfo](RawFileInfo.md) (structure)

[RawFileInfoPreamble](RawFileInfoPreamble.md) (structure)

[Finnigan::RawFileInfo](FinniganRawFileInfo.md) (decoder object)