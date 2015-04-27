# `Finnigan::ScanEventPreamble` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ScanEventPreamble.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $e = Finnigan::ScanEventPreamble->decode(\*INPUT, $version);
say join(" ", $p->list);
say join(" ", $p->list('decode'));
say p->analyzer;
say p->analyzer('decode');
```

## Description ##

ScanEventPreamble is a fixed-size (but version-dependent) structure. It
is a byte array located at the head of each ScanEvent. It contains
various boolean flags an enumerated types. For example, it's 41st byte
contains the analyzer type in all versions:

```
%ANALYZER = (
  0 => "ITMS",
  1 => "TQMS",
  2 => "SQMS",
  3 => "TOFMS",
  4 => "FTMS",
  5 => "Sector",
  6 => "undefined"
);
```

The ScanEventPreamble decoder provides a number of accessors that interpret the enumerated and boolean values.

The meaning of some values in ScanEventPreamble remains unknown.

The structure seems to have grown historically: to the 41 bytes in
v.57, 39 more were added in v.62, and 8 further bytes were added in
v.63. That does not affect the decoder interface; those values it
knows about have not changed, but the version number still has to be
passed into it so it knows how many bytes to read.


## Methods ##

  * **decode($stream, $version)**
> > The constructor method

All of the following accessor methods will replace the byte value of the flag they access with a symbolic value representing that flag's meaning if given a truthy argument. The word 'decode' is a good one to use because it makes the code more readable, but any truthy value will work.

  * **list(bool)**
> > Returns an array containing all byte values of [ScanEventPreamble](ScanEventPreamble.md)

  * **corona(bool)**
> > Get the corona status (_0:off_ or _1:on_).

  * **detector(bool)**
> > Get the detector flag (_0:valid_ or _1:undefined_).

  * **polarity(bool)**
> > Get the polarity value (_0:negative_, _1:positive_,  _2:undefined_)

  * **scan\_mode(bool)**
> > Get the scan mode (_0:centroid_, _1:profile_,  _2:undefined_)

  * **ms\_power(bool)**
> > Get the MS power number (_0:undefined_, _1:MS1_,  _2:MS2_, _3:MS3_, _4:MS4_, _5:MS5_, _6:MS6_, _7:MS7_, _8:MS8_)

  * **scan\_type(bool)**
> > Get the scan type (_0:Full_, _1:Zoom_,  _2:SIM_, _3:SRM_, _4:CRM_, _5:undefined_, _6:Q1_, _7:Q3_)

  * **dependent(bool)**
> > Get the dependent flag (0 for primary MS1 scans, 1 for dependent scan types)

  * **ionization(bool)**
> > Get the scan type (_0:EI,_1:CI,  _2:FABI,_3:ESI, _4:APCI,_5:NSI, _6:TSI_, _7:FDI_, _8:MALDI_, _9:GDI_, _10:undefined_)

  * **wideband(bool)**
> > Get the wideband flag (_0:off_, _1:on_, _2:undefined_).

  * **analyzer(bool)**
> > Get the scan type (_0:ITMS,_1:TQMS,  _2:SQMS,_3:TOFMS, _4:FTMS,_5:Sector, _6:undefined_)

  * **stringify**


> Makes a short text representation of the set of flags (known as "filter line" to the users of Thermo software)

## See Also ##

[ScanEventTemplate](ScanEventTemplate.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[ScanEventPreamble](ScanEventPreamble.md) (structure)

[Finnigan::ScanEventTemplate](FinniganScanEventTemplate.md) (decoder object)

[Finnigan::ScanEvent](FinniganScanEvent.md) (decoder object)