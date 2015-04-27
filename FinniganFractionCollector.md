# `Finnigan::FractionCollector` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/FractionCollector.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $f = Finnigan::FractionCollector->decode(\*INPUT);
say "$f";
```

## Description ##

[FractionCollector](FractionCollector.md) object is just a container for a pair of double-precision floating point
numbers that define the _M/z_ range of ions collected during a scan.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **low**
> > Get the low _M/z_

  * **high**
> > Get the high _M/z_

  * **stringify**
> > Make a string representation of the object: "`[`low-high`]`", as in Thermo's "filter line"

## See Also ##

[FractionCollector](FractionCollector.md) (structure)

[ScanEvent](ScanEvent.md) (containing structure)

[Finnigan::ScanEvent](FinniganScanEvent.md) (containing object)