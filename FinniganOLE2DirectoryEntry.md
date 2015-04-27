# `Finnigan::OLE2DirectoryEntry` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2DirectoryEntry.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $dir = new Finnigan::OLE2DirectoryEntry($file, 0);
$dir->list();
```

## Description ##

This is an auxiliary decoder used by [Finnigan::OLE2File](FinniganOLE2File.md); it is of no use on its own.

The OLE2 directory entries are organized in a _red-black tree_ (for efficiency of access). The directory entry's constructor method **new** is called recursively starting from the root directory contained in the file's 0-th property.

## Methods ##

  * **new($file, $propertyIndex)**
> > The constructor method. Its first argument is a reference to [Finnigan::OLE2File](FinniganOLE2File.md), and the second argument is the index of the file's property ([Finnigan::OLE2Property](FinniganOLE2Property.md)) to be decoded as a directory entry. The root directory is always found in property number 0.

  * **list($style)**
> > Lists the directory's contents to STDOUT. A typical listing of a file's root directory may look like this:
```
LTQ 
  Data (7512 bytes)
  Text (9946 bytes)
  Header (1396 bytes)
EksigentNanoLcCom_DLL 
  Data (2898 bytes)
  Text (1924 bytes)
NanoLC-AS1 Autosampler 
  Data (154 bytes)
EksigentNanoLc_Channel2 
  Data (3028 bytes)
  Text (2398 bytes)
```


> The style argument can have three values: `wiki`, `html`, and `plain` (or undefined). The wiki and html styles have not been implemented yet.

> This method is not useful as part of the API (directory listings are better understood by humans). But once the path to a node is known, it can be retrieved with the **find** method.

  * **find($path)**
> > Get the directory entry ([Finnigan::OLE2DirectoryEntry](FinniganOLE2DirectoryEntry.md)) matching the path supplied in the only argument. The directory entry's **data** method needs to be called in order to extract the node data.

## See Also ##

[Finnigan::OLE2File](FinniganOLE2File.md) (decoder object)

[Finnigan::OLE2Property](FinniganOLE2Property.md) (decoder object)