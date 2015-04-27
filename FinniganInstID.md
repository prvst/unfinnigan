# `Finnigan::InstID` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/InstID.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $inst = Finnigan::InstID->decode(\*INPUT);
say $inst->model;
say $inst->serial_number;
say $inst->software_version;
$inst->dump;
```

## Description ##

Decodes the static (fixed-size) structure containing several instrument identifiers and some unknown data.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **model**
> > Get the first copy of the `model` attribute (there always seem to be two of them)

  * **serial\_number**
> > Get the instrument's serial number

  * **software\_version**
> > Get the version of software that created the data file

  * **stringify**
> > Concatenate all IDs in a single line of text

## See Also ##

[InstID](InstID.md) (structure)