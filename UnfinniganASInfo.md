# uf-asinfo #

## SYNOPSIS ##

```
 uf-asinfo [options] <file>
```

## OPTIONS ##

_**--help**_ print a brief help message and exit.

_**--man**_ print the manual page and exit.

_**--html**_ format as HTML

_**--wiki**_ format as a wiki table

_**--size**_ tell object size

_**--preamble**_ Dump the contents of ASInfoPreamble

_**--relative**_ Show relative addresses of all elements. The default is to show the absolute seek address.


## DESCRIPTION ##

Prints the table listing all fields in the structure with their seek addresses, sizes, names and values.


## SEE ALSO ##

[ASInfo](ASInfo.md) (structure)

[ASInfoPreamble](ASInfoPreamble.md) (structure)

[Finnigan::ASInfo](FinniganASInfo.md) (decoder)


## EXAMPLES ##


`uf-asinfo sample.raw`

> (shows the location and size of the preamble and the text following it
> with absolute addresses)

`uf-asinfo --preamble --relative sample.raw`

> (dumps the contents of the preamble with relative addresses)