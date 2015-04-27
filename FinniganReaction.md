# `Finnigan::Reaction` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Reaction.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $r = Finnigan::Reaction->decode(\*INPUT);
say $r->precursor;
say $r->enengy;
```

## Description ##

This object contains a couple of double-precision floating point
numbers that define the precursor ion M/z and the energy
of the fragmentation reaction.

There are other elements that currently remain unknown: a double (set
to 1.0 in all observations) and a couple longs.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **precursor**
> > Get the precursor _M/z_

  * **energy**
> > Get the fragmentation energy

  * **stringify**
> > Make a short text representation of the object (found inside Therom's "filter line")

## See Also ##

[ScanEvent](ScanEvent.md) (containing structure)