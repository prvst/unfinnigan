# uf-params #

## SYNOPSIS ##

```
uf-params [options] <file>
```

### OPTIONS ###

_**-help**_ Print a brief help message and exit.

_**-d`[`ump`]`**_ dump the requested feature showing file seek addresses

_**-a`[`ist`]`**_ detailed dump of all field descriptors (requires: _**-d**_)

_**-s`[`ize`]`**_ print record size (requires: _**-d**_)

_**-n`[`umber`]` `<n>`**_ extract the log entry number _**n**_

_**-h`[`tml`]`**_ format as html

_**-w`[`iki`]`**_ format as a wiki table

_**-r`[`elative`]`**_ show relative addersess in the dump (requires: _**-d**_)

_**`<`file`>`**_ input file


## DESCRIPTION ##

**uf-params** can be used to examine the ScanParameters records in a
Finnigan raw file. These records contain a miscellany of data pertaining to a single scan: ion injection time, retention time, charge state and _M/z_ of the precursor ion, _M/z_ conversion coefficients,  and other data.

## SEE ALSO ##

[ScanParameters](ScanParameters.md) (structure)

[Finnigan::ScanParameters](FinniganScanParameters.md) (decoder object)


### EXAMPLES ###

  * `uf-params sample.raw`

> (lists all ScanParameters records in the tabular form: <record number, label, value>)

  * `uf-params -n 5 sample.raw`

> (prints the parameters record for the fifth scan)

  * `uf-params -dswr -n 5 sample.raw`

> (dumps the fifth ScanParameters record in wiki format with total size and relative addresses)

  * `uf-params -header sample.raw`

> (prints the contents of the stream header in the tabular form: <type, length, label>)

  * `uf-params -header -dw sample.raw`

> (dumps the header in the compact wiki format, with a stringified
> GenericDataDescriptor list)

  * `uf-params -header -daw sample.raw`

> (dumps the header in the extended wiki format, showing the
> location of echa GenericDataDescriptor's element)