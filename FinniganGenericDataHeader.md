# `Finnigan::GenericDataHeader` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/GenericDataHeader.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $h = Finnigan::GenericDataHeader->decode(\*INPUT);
say $h->n;
say $h->dump;
```

## Description ##

GenericDataHeader drives the decoding of a GenericRecord. It stores a
list of GenericDataDescriptor objects, each describing a field in the
record.


## Methods ##

  * **decode($stream)**
> > The constructor method

  * **n**
> > Get the number of fields in each record

  * **fields**
> > Get the list of [Finnigan::GenericDataDescriptor](FinniganGenericDataDescriptor.md) objects. Each descriptor object corresponds to a field in the GenericRecord structure to be decoded with this header.

  * **labels**
> > Get the list of descriptor labels in the order they occur in the header

  * **field\_templates**
> > Get the list of unpack templates for the entire record in the form that can be passed to [Finnigan::Decoder](FinniganDecoder.md).

  * **ordered\_field\_templates**
> > Get the list of unpack templates whose keys are tagged with ordinal numbers to disambiguate possible duplicate keys and to preserve the order of fields. This is necessary for decoding the InstrumentLogRecord structures.

## See Also ##

[GenericData](GenericData.md) (the explanation of the term)

[GenericRecord](GenericRecord.md) (structure)

[GenericDataDescriptor](GenericDataDescriptor.md) (structure)

[Finnigan::GenericDataDescriptor](FinniganGenericDataDescriptor.md) (decoder object)