# `Finnigan::ScanEventTemplate` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ScanEventTemplate.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $e = Finnigan::ScanEventTemplate->decode(\*INPUT, $version);
say $e->size;
say $e->dump;
say join(" ", $e->preamble->list(decode => 'yes'));
say $e->preamble->analyzer(decode => 'yes');
$e->fraction_collector->dump;
```

## Description ##

This is a template structure that apparently forms the core of each
ScanEvent structure corresponding to an individual scan. It is an
elment of _MSScanEvent_ hirerachy (that's the name used by Thermo),
which models the grouping of scan events into segments.

## Methods ##

  * **decode($stream, $version)**
> > The constructor method

  * **preamble**
> > Get the [Finnigan::ScanEventPreamble](FinniganScanEventPreamble.md) object

  * **controllerType**
> > Get the virtual controller type for this event (a guess; data not verified)

  * **controllerNumber**
> > Get the virtual controller number for this event (a guess; data not verified)

  * **fraction\_collector**
> > Get the [Finnigan::FractionCollector](FinniganFractionCollector.md) object

  * **stringify**
> > Make a short text representation of the object

## See Also ##

[ScanEventTemplate](ScanEventTemplate.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[ScanEventPreamble](ScanEventPreamble.md) (structure)

[Finnigan::ScanEventPreamble](FinniganScanEventPreamble.md) (decoder object)

[FractionCollector](FractionCollector.md) (structure)

[Finnigan::FractionCollector](FinniganFractionCollector.md) (decoder object)