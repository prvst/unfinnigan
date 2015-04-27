# `Finnigan::ScanParameters` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ScanParameters.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $p = Finnigan::ScanParameters->decode(\*INPUT, $generic_header_ref);
say $p->charge_state;
```

## Description ##

This decoder augments the GenericRecord decoder with the `charge_state()` method.

Copies of all other elements in this structure can be found in other streams, so there is no need in making accessors for them.

The purpose of this stream is to provide pre-formatted human-readable messages describing the scan data; The `charge_state` element seems to be unique in that it either does not exist anywhere
else, or has not been discovered so far.

The entire set can be printed in the following manner:

```
foreach my $key (@{$header->labels}) {
  say $key  . "\t" . $p->{data}->{$key}->{value};
}
```

## Methods ##

  * **decode($stream, $header->field\_templates)**
> > The constructor method. It needs a previously decoded header to work.

  * **charge\_state**
> > Get the charge state of the base ion

  * **injection\_time**
> > Get ion injection time in milliseconds

  * **monoisotopicMz**
> > Get the monoisotopic mass of the precursor ion

## See Also ##

[Finnigan::GenericDataHeader](FinniganGenericDataHeader.md) (decoder object)

[Finnigan::GenericDataDescriptor](FinniganGenericDataDescriptor.md) (decoder object)

[Finnigan::GenericRecord](FinniganGenericRecord.md) (decoder object)

[GenericRecord](GenericRecord.md) (structure)

[GenericDataHeader](GenericDataHeader.md) (structure)

[GenericDataDescriptor](GenericDataDescriptor.md) (structure)