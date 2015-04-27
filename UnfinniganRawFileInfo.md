# uf-rfi #

## SYNOPSIS ##

```
 uf-rfi [options] <file>
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

Displays the contents of the RawFileInfo structure, or its component RawFileInfoPreamble.

If invoked with no arguments, **uf-rfi** prints a summary of the object's data on a single line.


## SEE ALSO ##

[RawFileInfo](RawFileInfo.md) (structure)

[RawFileInfoPreamble](RawFileInfoPreamble.md) (structure)

[RunHeader](RunHeader.md) (structure)

[Finnigan::RawFileInfo](FinniganRawFileInfo.md) (decoder)


## EXAMPLES ##


`uf-rfi sample.raw`

> (prints a single line with file creation date, followed by the data and  RunHeader addresses)

`uf-rfi -d sample.raw`

> (dumps the file's RawFileInfo structure with absolute addresses)

`uf-rfi -dpr sample.raw`

> (dumps the contents of RawFileInfoPreamble with relative addresses)