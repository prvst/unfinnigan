# uf-meth #

## SYNOPSIS ##

`uf-meth [options] <file>`

## OPTIONS ##

_**-help**_ Print a brief help message and exit.

_**-e`[`xtract`]`**_ extract the entire OLE2 container (Microsoft Compound File)

_**-l`[`ist`]`**_ list the container contents

_**-d`[`ump`]`**_ Prints a table listing all structure elements with their seek addresses, sizes, acess keys and values. Complex sub-structures are represented by short summaries and their contents can be examined separately (see the**_-H''' and_**-p''' options}

_**-h`[`tml`]`**_ Dump as html table.

_**-w`[`iki`]`**_ Dump as a wiki-style table.

_**-s`[`ize`]`**_ Show overall structure size in bytes.

_**-r`[`elative`]`**_ Show relative addresses of all itmes. The default is to show the absolute seek address.

_**-H`[`eader`]`**_ Dump the contents of [FileHeader](FileHeader.md), instead of the parent object.

_**-p`[`ath`]`** `<`path`>`_ Give the full path to extract a single component from the compound OLE2 container.


## DESCRIPTION ##

`uf-meth` displays the contents of the [MethodFile](MethodFile.md) structure, its component [FileHeader](FileHeader.md). and the compound file (OLE2) storage embedded within.

By default, it lists the instrument methods comtained in the compound file, along with with their directory names.


## SEE ALSO ##

[MethodFile](MethodFile.md)


### EXAMPLES ###

  * `uf-meth sample.raw`

> (names all instruments described in the file, one name per line)

> _Example output_:
```
Surveyor Sample Pump -> Surveyor Sample Pump
Surveyor MS Pump -> Surveyor MS Pump
Micro AS -> Micro AS
LTQ-FT MS -> LTQ
```

  * `uf-meth -l sample.raw`

> (lists the compound file's directory, one node per line)

> _Example output_:
```
LTQ 
  Data (2560 bytes)
  Text (11742 bytes)
  Header (1396 bytes)
Micro AS 
  Data (641 bytes)
  Text (1164 bytes)
Surveyor MS Pump 
  Data (228 bytes)
  Text (1176 bytes)
  Comments (4 bytes)
Surveyor Sample Pump 
  Data (228 bytes)
  Text (1176 bytes)
  Comments (4 bytes)
```

  * `uf-meth sample.raw -p LTQ/Text > method.ltq`

> (writes the text description of the analyzer method)

  * `uf-meth sample.raw -p LTQ/Data > method.ltq.data`

> (writes the raw binary data of the analyzer method)

  * `uf-meth sample.raw -dp LTQ/Header`

> (prints the hex dump of LTQ/Header)

> _Example output_:

```
  0x0000 : 05 A1 54 00 68 00 65 00 72 00 6D 00 6F 00 20 00 : ..T.h.e.r.m.o...
  0x0010 : 46 00 69 00 6E 00 6E 00 69 00 67 00 61 00 6E 00 : F.i.n.n.i.g.a.n.
  0x0020 : 20 00 4C 00 54 00 51 00 00 00 00 00 00 00 00 00 : ..L.T.Q.........
  0x0030 : 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 : ................
  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
```

  * `uf-meth -dr sample.raw`

> (dumps the MethodFile structure with relative addresses)

  * `uf-meth -drH sample.raw`

> (dumps the Finnigan header residing in the MethodFile, with relative addresses)