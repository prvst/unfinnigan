# `Finnigan::ASInfoPreamble` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ASInfoPreamble.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $object = Finnigan::ASInfoPreamble->decode(\*INPUT);
$object->dump;
```

## Description ##

[ASInfoPreamble](ASInfoPreamble.md) is a fixed-length structure with some unknown data about the autosampler. It is a component of [ASInfo](ASInfo.md), which consists of this numeric descriptor and and a text string following it.

## Methods ##

  * **decode($stream)**
> > The constructor method

## See also ##

[ASInfo](ASInfo.md) (structure)