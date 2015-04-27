# uf-header #

## SYNOPSIS ##

```
 uf-header [options] <file>
```

## OPTIONS ##

_**--help**_ Print a brief help message and exit.

_**--man**_ Print the manual page and exit.

_**--dump**_ Prints the table listing all header fields with their seek addresses, sizes, acess keys and values.

_**--html**_ Dump as an html table

_**--wiki**_ Dump as a wiki table

_**--size**_ Show header size in bytes.

_**--atag**_ Dump the contents of the first AuditTag object, rather than the header itself.

_**--relative**_ Show relative addresses of all elements. The default is to show the absolute seek address.


## DESCRIPTION ##

`uf-header` will read the given input file and display the contents of its header or the AuditTag structures embedded into it.

It will return an error message if the file is not a Finnigan raw file.

By default, it prints a few header items (version number and parts of its AuditTag) on a single line.


## SEE ALSO ##

[FileHeader](FileHeader.md) (structure)

[Finnigan::FileHeader](FinniganFileHeader.md) (decoder)


## EXAMPLES ##


```
 uf-header sample.raw
```

> (will print the file version and creation date)

```
 uf-header -d sample.raw
```

> (will dump all header fields)

```
 uf-header -d --atag sample.raw
```

> (will dump the contents of the first [AuditTag](AuditTag.md)) uf-header -d --atag sample.raw
}}}```