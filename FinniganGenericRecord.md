# `Finnigan::GenericRecord` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/GenericRecord.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $record = Finnigan::GenericRecord->decode(\*INPUT, $header->field_templates);
my $record = Finnigan::GenericRecord->decode(\*INPUT, $header->ordered_field_templates);
```

## Description ##

`Finnigan::GenericRecord` is a pass-through decorder that only passes
the field definitions it obtains from the header
([Finnigan::GenericDataHeader](FinniganGenericDataHeader.md)) to [Finnigan::Decoder](FinniganDecoder.md).

Because Thermo's GenericRecord objects are odered and may have
"virtual" gaps and section titles in them, the [Finnigan::Decoder](FinniganDecoder.md)'s
method of stashing the decoded data into a hash is not directly
applicable. A GenericRecord may have duplicate keys and the key order
needs to be preserved. The **ordered\_field\_templates** method of [Finnigan::GenericDataHeader](FinniganGenericDataHeader.md) can be used where the order of the fields is important. It prevents key collisions by inserting ordinal numbers into the keys.

## Methods ##

  * **decode($stream)**
> > The constructor method

## See Also ##

[Finnigan::GenericDataHeader](FinniganGenericDataHeader.md) (decoder object)

[Finnigan::GenericDataDescriptor](FinniganGenericDataDescriptor.md) (decoder object)

[GenericRecord](GenericRecord.md) (structure)

[GenericDataHeader](GenericDataHeader.md) (structure)

[GenericDataDescriptor](GenericDataDescriptor.md) (structure)