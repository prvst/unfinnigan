# uf-trailer #

## SYNOPSIS ##

```
uf-trailer [options] <file>
```

### OPTIONS ###

_**-help**_ print a brief help message and exit.

_**-a`[`ll`]`**_ process all scan event entries, ignoring the range specified in RunHeader

_**-n`[`umber`]` `<n>`**_ extract ScanEvent number _**n**_

_**-range `<`from`>` .. `<`to`>`**_ extract ScanEvent objects with numbers between <`from`> and <`to`>

_**-d`[`ump`]`**_ dump all data in each ScanEvent

_**-h`[`tml`]`**_ format as html

_**-w`[`iki`]`**_ format as a wiki table

_**-r`[`elative`]`**_ show relative addersess in the dump (requires: _**-d**_)

_**-p`[`reamble`]`**_ include the translated listing of ScanEventPreamble

_**`<`file`>`**_ input file


## DESCRIPTION ##

**uf-trailer** can be used to list or dump the ScanEvent records in a
Finnigan raw file. These records are stored in a stream Thermo calls a
"trailer", which occurs near the end of the file. Now, the "trailer"
containing scan event descriptions is not the only stream trailing the
data; apparently, new ones were added as the format evolved, but the
name stuck. The code in Thermo libraries refers to this stream as
"TrailerScanEvent".

## SEE ALSO ##

[ScanEventsStream](ScanEventsStream.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[RunHeader](RunHeader.md) (primary index structure)

[Finnigan::ScanEvent](FinniganScanEvent.md) (decoder object)


### EXAMPLES ###

  * `uf-trailer sample.raw`

> (lists all scan events in the file using Thermo's short-hand notation known as "filter line")

  * `uf-index -range 1..5 sample.raw`

> (lists the first five records)

  * `uf-index -range 1..5 -format bin sample.raw`

> (shows individual bits in the unknown 'scan type' word)

  * `uf-index -drn 5 sample.raw`

> (dumps the fifth ScanEvent with relative addresses)