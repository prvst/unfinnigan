# uf-instrument #

## SYNOPSIS ##

```
uf-instrument [options] <file>
```

### OPTIONS ###

_**-help**_ Print a brief help message and exit.

_**-d`[`ump`]`**_ dump the InstID structure showing file seek addresses

_**-s`[`ize`]`**_ print object size (requires _**-d**_)

_**-h`[`tml`]`**_ format as html (requires _**-d**_)

_**-w`[`iki`]`**_ format as a wiki table (requires _**-d**_)

_**-r`[`elative`]`**_ show relative addersess in the dump (requires _**-d**_)

_**`<`file`>`**_ input file


## DESCRIPTION ##

If called without options, **uf-instrument** prints all instrument ID
information on one line.

For more detailed information about all instruments involved in the
acquisition of the data, use **[uf-meth](UnfinniganMethodFile.md)**, the method file tool.

## SEE ALSO ##

[InstID](InstID.md) (structure)

[Finnigan::InstID](FinniganInstID.md) (decoder object)

**[uf-meth](UnfinniganMethodFile.md)**, the method file tool

### EXAMPLES ###

  * `uf-instrument sample.raw`

> (prints all IDS on one line)

  * `uf-log -dswr sample.raw`

> (dumps the InstID structure in wiki format with size and using relative addresses)