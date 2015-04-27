# uf-log #

## SYNOPSIS ##

```
uf-log [options] <file>
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

**uf-log** can be used to examine the instrument log stream in a
Finnigan raw file. The instrument log records typically contain more
than a hundred parameters, including operational data on the pumps,
power supplies, ion optics and injectors -- everything that may be
useful in the auditing of the instrument's performance.

Each record is timestamped with the current retention time of the
sample.

## SEE ALSO ##

[InstrumentLog](InstrumentLog.md) (structure)

[Finnigan::InstrumentLogRecord](FinniganInstrumentLogRecord.md) (decoder object)


### EXAMPLES ###

  * `uf-log sample.raw`

> (lists all log records in the tabular form: <record number, time, label, value>)

  * `uf-log -n 5 sample.raw`

> (prints the fifth log record)

  * `uf-log -dswr -n 5 sample.raw`

> (dumps the fifth log record in wiki format with total size and relative addresses)

  * `uf-log -header sample.raw`

> (prints the contents of the stream header in the tabular form: <type, length, label>)

  * `uf-log -header -dw sample.raw`

> (dumps the header in the compact wiki format, with a stringified
> GenericDataDescriptor list)

  * `uf-log -header -daw sample.raw`

> (dumps the header in the extended wiki format, showing the
> location of echa GenericDataDescriptor's element)