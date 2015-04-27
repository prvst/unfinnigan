# Finnigan::OLE2File #
[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2File.pm)]
## SYNOPSIS ##

```
use Finnigan;
my $container = Finnigan::OLE2File->decode(\*INPUT);
my $analyzer_method_text = $container->find("LTQ/Text")->data;
```


## Description ##

Thermo uses the Microsoft OLE2 container to store the instrument
method files. This container has a hirerachical structure based on a
FAT filesystem. It seems like there are always two levels of hierarchy
used in the method container: one directory node for each istrument,
each directory containing one to three leaf nodes (files) named Data,
Text, or Header. The Header file exists only in the first directory
corresponding to the mass analyser. Other directories contain either
Text and Data, or just Data. It seems like Text is simply a
human-readable representation of Data, but this conjectures has not
been verified because the structure of the Data files remains unknown.

Finnigan::OLE2File decodes the container structure and allows the
extraction of the leaf nodes -- Header, Data, and Text.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **list**
> > Prints the directory listing of the entire OLE2 container to STDOUT. A typical output may look like this:
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
> > This method is not useful as part of the API (directory listings are better understood by humans). But once the path to a node is known, it can be retrieved with the **find** method.

  * **find($path)**
> > Get the directory entry ([Finnigan::OLE2DirectoryEntry](FinniganOLE2DirectoryEntry.md)) matching the path supplied in the only argument. The directory entry's **data** method needs to be called in order to extract the node data.

  * **stringify**
> > Make a short string representation of the object, naming the file type and the number of nodes it contains

## See Also ##

[Method file structure overview](MethodFileStructure.md)

[Finnigan::MethodFile](FinniganMethodFile.md) (decoder object)

[Finnigan::OLE2DIF](FinniganOLE2DIF.md) (decoder object)

[Finnigan::OLE2DirectoryEntry](FinniganOLE2DirectoryEntry.md) (decoder object)

[Finnigan::OLE2FAT](FinniganOLE2FAT.md) (decoder object)

[Finnigan::OLE2Header](FinniganOLE2Header.md) (decoder object)

[Finnigan::OLE2Property](FinniganOLE2Property.md) (decoder object)