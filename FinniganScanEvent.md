# `Finnigan::ScanEvent` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ScanEvent.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $e = Finnigan::ScanEventTemplate->decode(\*INPUT, $version);
say $e->size;
say $e->dump;
say join(" ", $e->preamble->list(decode => 'yes'));
say $e->preamble->analyzer(decode => 'yes');
$e->fraction_collector->dump;
$e->reaction->dump if $e->preamble->ms_power > 1 # Reaction will not be present in MS1
```

## Description ##

This decoder reads the ScanEvent structure corresponding to an individual scan. It consists of  a ScanEventTemplate augmented with the list of conversion coefficients (empty for scans done in peak mode) and the list of precursor ions (empty for base-level scans).

## Methods ##

  * **decode($stream, $version)**
> > The constructor method

  * **purge\_unused\_data**
> > Delete the location, size and type data for all structure elements. Calling this method will free some memory when no introspection is needeed (the necessary measure in production-grade code)

  * **np**
> > Get the number of precursor ions

  * **preamble**
> > Get the [Finnigan::ScanEventPreamble](FinniganScanEventPreamble.md) object

  * **fraction\_collector**
> > Get the  [Finnigan::FractionCollector](FinniganFractionCollector.md) object

  * **precursors**
> > Get the list full list of precursor descriptors [Finnican::Reaction](FinniganReaction.md) objects

  * **reaction($n)**
> > Get the precursor number _n_ (a [Finnigan::Reaction](FinniganReaction.md) object). In the absence of the number argument, it returns the first precursor.

  * **nparam**
> > Get the number of conversion coefficients

  * **unknown\_double**
> > Get the value of the unknown first coefficient (0 in all known cases)

  * **I**
> > Get the value of the coefficient _I_ (0 in all known cases, Orbitrap data only)

  * **A**
> > Get the value of the coefficient _A_ (0 in all known cases)

  * **B**
> > Get the value of the coefficient _B_ (LTQ-FT, Orbitrap)

  * **C**
> > Get the value of the coefficient _C_ (LTQ-FT, Orbitrap)

  * **D**
> > Get the value of the coefficient _D_ (Orbitrap only)

  * **E**
> > Get the value of the coefficient _E_ (Orbitrap only)

  * **converter**
> > Returns the pointer to the function for the forward conversion _f_ → _M/z_

  * **inverse\_converter**
> > Returns the pointer to the function for the inverse conversion _M/z_ → _f_

  * **stringify**
> > Make a short text representation of the object

## See Also ##

[ScanEventTemplate](ScanEventTemplate.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[ScanEventPreamble](ScanEventPreamble.md) (structure)

[Finnigan::ScanEventPreamble](FinniganScanEventPreamble.md) (decoder object)

[FractionCollector](FractionCollector.md) (structure)

[Finnigan::FractionCollector](FinniganFractionCollector.md) (decoder object)

[Reaction](Reaction.md) (structure)

[Finnigan::Reaction](FinniganReaction.md) (decoder object)