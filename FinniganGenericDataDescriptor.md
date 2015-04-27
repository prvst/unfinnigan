# `Finnigan::GenericDataDescriptor` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/GenericDataDescriptor.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $d = Finnigan::GenericDataDescriptor->decode(\*INPUT);
say d->type;
say d->label;
```

## Description ##

GenericDataDescriptor stores information on the type, size and name of a data element in a GenericRecord.


## Methods ##

  * **decode($stream)**
> > The constructor method

  * **type**
> > Get the element type (see [Known data types](GenericDataDescriptor#Known_data_types.md))

  * **length**
> > Get the size of the element represented by this descriptor

  * **label**
> > Get the element's label. It is the same label that Thermo uses in their GUI, such as Xcalibur.

  * **definition**
> > Returns an appropriate decoder template based on descriptor type

  * **stringify**
> > Make a short string representation of the descriptor

## See Also ##

[GenericData](GenericData.md) (the explanation of the term)

[GenericRecord](GenericRecord.md) (structure)

[GenericDataHeader](GenericDataHeader.md) (GenericDataDescriptor's parent structure)

[Finnigan::GenericDataHeader](FinniganGenericDataHeader.md) (decoder object)