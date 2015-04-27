# Finnigan::OLE2DIF #
[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2DIF.pm)]
## SYNOPSIS ##

```
use Finnigan;
my $dif = Finnigan::OLE2DIF->decode(\*INPUT, [$start, $count]);
say $dif->stringify
say $dif->sect->[0]; # must be 0 if used
```


## Description ##

This is an auxiliary decoder used by [Finnigan::OLE2File](FinniganOLE2File.md); it is of no use on its own. It reads a specified number of 4-byte intergers into an array that is to be interpreted as a sector allocation table by the caller of the **sect** method.

DIF == Double-Indirect File Allocation Table


## Methods ##
  * **`decode($stream, [$start, $count])`**
> > The constructor method. The start and count parameters are reserved for possible future use. Although they are not used at the moment (because Finnigan files do not use non-trivial FAT arrangements), these parameters must still be provided by the caller to avoid the unidentified value errors.

  * **sect**
> > Get the array containing the sector allocation table. In this application (embedded method files in the Finnigan data file), it is very likely that only the first of the 109 entries (address 0) will be used.

  * **stringify**
> > Get a short text description of the data, e.g.,
```
Double-Indirect FAT; 1/109 entries used
```

## See Also ##

[Finnigan::OLE2File](FinniganOLE2File.md) (decoder object)