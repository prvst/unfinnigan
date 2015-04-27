# Finnigan::OLE2FAT #
[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2FAT.pm)]
## SYNOPSIS ##

```
use Finnigan;
my $fat = Finnigan::OLE2FAT->decode(\*INPUT, [$start, $count]);
say join(' ', @{$fat->sect})
```


## Description ##

This is an auxiliary decoder used by [Finnigan::OLE2File](FinniganOLE2File.md); it is of no use on its own. It reads a specified number of 4-byte intergers into an array that is to be interpreted as a sector allocation table by the caller of the **sect** method.


## Methods ##
  * **`decode($stream, [$start, $count])`**
> > The constructor method. The start and count parameters are reserved for possible future use. Although they are not used at the moment (because Finnigan files do not use non-trivial FAT arrangements), these parameters must still be provided by the caller to avoid the unidentified value errors.

  * **sect**
> > Return the array containing the sector allocation table

## See Also ##

[Finnigan::OLE2File](FinniganOLE2File.md) (decoder object)