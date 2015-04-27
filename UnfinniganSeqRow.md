# uf-seqrow #

## SYNOPSIS ##

```
uf-seqrow [options] file
```

## OPTIONS ##

_**--help**_ Print a brief help message and exit.

_**--man**_ Print the manual page and exit.

_**--dump**_ Prints a table listing all header fields with their seek addresses, sizes, acess keys and values.

_**--html**_ Dump as html table.

_**--wiki**_ Dump as a wiki table.

_**--size**_ Show structure size in bytes.

_**--injection**_ Dump the contents of InjectionData, instead of the parent object.

_**--relative**_ Show relative addresses of all itmes. The default is to show the absolute seek address.


## DESCRIPTION ##

`uf-seqrow` will display the contents of the SeqRow (Sequence Table Row) structure or its component, InjectionData.

It will return an error message if its input is not a Finnigan raw file.

By default, it will dump the SeqRow object in a tabular format.


## EXAMPLES ##

```
uf-seqrow sample.raw
```

> (dumps the entire SeqRow structure with absolute addresses)

```
uf-seqrow -sri sample.raw
```

> (dumps the InjectionData substructure with relative addresses and prints its size)

## SEE ALSO ##

[SeqRow](SeqRow.md)