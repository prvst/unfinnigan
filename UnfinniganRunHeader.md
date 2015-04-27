# uf-runheader #

## SYNOPSIS ##

```
 uf-runheader [options] <file>
```

## OPTIONS ##

_**--help**_ print a brief help message and exit.

_**--man**_ print the manual page and exit.

_**--html**_ format as HTML

_**--wiki**_ format as a wiki table

_**--size**_ tell object size

_**--sample\_info**_ dump the contents of the SampleInfo substructure

_**--relative**_ Show relative addresses of all elements. The default is to show the absolute seek address.


## DESCRIPTION ##

Displays the contents of the RunHeader structure, or its component SampleInfo.

If invoked with no arguments, **uf-runheader** prints a summary of the object's data on a single line.


## SEE ALSO ##

[RunHeader](RunHeader.md) (structure)

[SampleInfo](SampleInfo.md) (structure)

[Finnigan::RunHeader](FinniganRunHeader.md) (decoder)


## EXAMPLES ##


`uf-runheader sample.raw`

> (prints a single line listing a few important numbres in RunHeader)

`uf-runheader -d sample.raw`

> (dumps the entire RunHeader structure with absolute addresses)

`uf-header -isdrw sample.raw`

> (dumps the contents of the SampleInfo structure in the wiki format with relative addresses and shows its size)