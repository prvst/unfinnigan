# uf-tune #

## SYNOPSIS ##

```
uf-tune [options] <file>
```

### OPTIONS ###

_**-help**_ Print a brief help message and exit.

_**-d`[`ump`]`**_ dump the requested feature showing file seek addresses

_**-a`[`ist`]`**_ detailed dump of all field descriptors (requires: _**-d**_)

_**-s`[`ize`]`**_ print object size (requires: _**-d**_)

_**-h`[`tml`]`**_ format as html

_**-w`[`iki`]`**_ format as a wiki table

_**-r`[`elative`]`**_ show relative addersess in the dump (requires: _**-d**_)

_**`<`file`>`**_ input file


## DESCRIPTION ##

**uf-tune** can be used to examine the  embedded tune file, either by
listing its entries (which were intended for human consumption), or by
dumping the details of its encoding.

## SEE ALSO ##

[TuneFile](TuneFile.md) (structure)

[GenericRecord](GenericRecord.md) (structure)

[Finnigan::GenericRecord](FinniganGenericRecord.md) (decoder object)


### EXAMPLES ###

  * `uf-tune sample.raw`

> (lists the tune file in the tabular form: <label, value>)

  * `uf-tune -d sample.raw`

> (dumps the tune file with absolute addresses)

  * `uf-tune -header sample.raw`

> (prints the contents of the tune file header in the tabular form: <type, length, label>)

  * `uf-tune -header -dw sample.raw`

> (dumps the header in the compact wiki format, with a stringified
> GenericDataDescriptor list)

  * `uf-tune -header -daw sample.raw`

> (dumps the header in the extended wiki format, showing the
> location of echa GenericDataDescriptor's element)