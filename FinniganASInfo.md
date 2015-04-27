# `Finnigan::ASInfo` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ASInfo.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $cas_info = Finnigan::ASInfo->decode(\*INPUT);
$cas_info->dump;
```

## Description ##

[ASInfo](ASInfo.md) is a structure with uncertain purpose that contains a binary
preamble with autosampler co-ordinates ([ASInfoPreamble](ASInfoPreamble.md)), followed by a
text string. The text string is apparently a comment; in one
instance where it was non-null, it contained this text:

`  384 Well Plate`

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **preamble**
> > Get the [Finnigan::ASInfoPreamble](FinniganASInfoPreamble.md) object

## See also ##

[ASInfo](ASInfo.md) (structure)

[ASInfoPreamble](ASInfoPreamble.md) (structure)