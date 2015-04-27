# `Finnigan::InstrumentLogRecord` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/InstrumentLogRecord.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $entry = Finnigan::InstrumentLogRecord->decode(\*INPUT, $header->ordered_field_templates);
say $entry->time;
foreach my $key (@{$header->labels}) {
  say $key  . "\t" . $entry->{data}->{$key}->{value};
}
```

## Description ##

This decoder is prototype on [Finnigan::GenericRecord](FinniganGenericRecord.md), which is a pass-through decorder that only passes the field definitions it obtains from the header ([Finnigan::GenericDataHeader](FinniganGenericDataHeader.md)) to [Finnigan::Decoder](FinniganDecoder.md). It is essentially a copy of the
[Finnigan::GenericRecord](FinniganGenericRecord.md) code with one specific field (retention time)
prepended to the template list.

Because the InstrumentLogRecord keys are ordered and may have "virtual" gaps and section titles among them, with duplicate keys occurring in multiple sections, the order must be preserved and keys disambiguated. Because [Finnigan::Decoder](FinniganDecoder.md) stashes the decoded data into a hash, the keys must be disambiguated by adding the ordinal numbers to them. That is what the **ordered\_field\_templates** method of [Finnigan::GenericDataHeader](FinniganGenericDataHeader.md) does.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **time**
> > Get the timestamp. The timestamp is retention time measured in seconds and stored as floating-point value.

  * **fields**
> > Get the list of all fields in the record. Each field is decoded with the [Finnigan::GenericRecord](FinniganGenericRecord.md) decoder using the definitions from [Finnigan::GenericDataHeader](FinniganGenericDataHeader.md), and it contains, for example, the following data:

```
{
   value => '8.1953125',
   type => 'Float32',
   addr => 803445,
   seq => 70,
   size => 4
}
```

## See Also ##

[Finnigan::GenericDataHeader](FinniganGenericDataHeader.md) (decoder object)

[Finnigan::GenericDataDescriptor](FinniganGenericDataDescriptor.md) (decoder object)

[Finnigan::GenericRecord](FinniganGenericRecord.md) (decoder object)

[GenericRecord](GenericRecord.md) (structure)

[GenericDataHeader](GenericDataHeader.md) (structure)

[GenericDataDescriptor](GenericDataDescriptor.md) (structure)