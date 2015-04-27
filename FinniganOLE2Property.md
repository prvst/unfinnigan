# Finnigan::OLE2Property #
[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2Property.pm)]
## SYNOPSIS ##

```
use Finnigan;
my $p = Finnigan::OLE2Property->decode(\*INPUT, [9, 'UTF-16-LE']);
say $p->name;
```


## Description ##

This is an auxiliary decoder used by [Finnigan::OLE2File](FinniganOLE2File.md); it is of no use on its own.

The OLE2 Properties are roughly equivalent to index nodes in other filesystems.


## Methods ##
  * **`decode($stream, [$big_block_log_size, $charset])`**
> > The constructor method

  * **name**
> > Returns the property name (equivalent to file name in a regular filesystem). This method overloads the double-quote operator.

## See Also ##

[Finnigan::OLE2File](FinniganOLE2File.md) (decoder object)

[Finnigan::OLE2Header](FinniganOLE2Header.md) (decoder object)