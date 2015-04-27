# `Finnigan::InjectionData` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/InjectionData.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $param = Finnigan::InjectionData->decode(\*INPUT);
$param->dump;
```

## Description ##

Decodes the data describing the injection that delivered the sample for
analysis to the mass specrometer. The data includes the vial label,
sample volume, weight, internal standard (ISTD) amount, and dilution factor.


## Methods ##

  * **decode**
> > The constructor method

  * **n**
> > Get the sequence table row number

### Methods to be added ###

Since I had not seen this object used by the programs, I did not worry about providing the complete interface for it. Accessors may be added for:

  * volume
  * injected volume (what's the difference between "volume" and "injected volume"?
  * weight
  * internal standard amount
  * dilution factor
  * a couple other numbers of unknown meaning

## See Also ##

[InjectionData](InjectionData.md) (structure)

[Finnigan::SeqRow](FinniganSeqRow.md) (containing object)