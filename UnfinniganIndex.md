# uf-index #

## SYNOPSIS ##

```
uf-index [options] <file>
```

### OPTIONS ###

_**-help**_ print a brief help message and exit.

_**-a`[`ll`]`**_ process all index entries, ignoring the range specified in RunHeader

_**-n`[`umber`]` `<n>`**_ extract the index entry number _**n**_

_**-range `<`from`>` .. `<`to`>`**_ extract all entries with numbers between <`from`> and <`to`>

_**-d`[`ump`]`**_ dump all data in each entry

_**-s`[`ize`]`**_ print object size (requires: _**-d**_)

_**-h`[`tml`]`**_ format as html

_**-w`[`iki`]`**_ format as a wiki table

_**-r`[`elative`]`**_ show relative addersess in the dump (requires: _**-d**_)

_**-f`[`ormat`]` <`type: bin|hex|ms`>**_	format the unknown long using the binary or hexadecimal encoding, or attempt to extract the MS power. The MS power interpretation is probably incorrect and only seems to work by co-incidence.

_**`<`file`>`**_ input file


## DESCRIPTION ##

**uf-index** can be used to examine the [scan index stream](ScanIndexStream.md) in a
Finnigan raw file. Scan index is a set of auxiliary structures (ScanIndexEntry) containing pointers to ScanDataPacket structures and their sizes.

Without options, **uf-index** lists all entries in tabular format, one row per entry.

The only unknown element in the ScanEvent structure can be interpreted in a number of ways; to aid in its interpretation, the _**-format**_ option allows it to be printed in different formats when the structure is rendered in the tabular form. The default format is decimal.
## SEE ALSO ##

[ScanIndexStream](ScanIndexStream.md) (structure)

[ScanIndexEntry](ScanIndexEntry.md) (structure)

[RunHeader](RunHeader.md) (primary index structure)

[ScanDataPacket](ScanDataPacket.md) (main data structure)

[Finnigan::ScanIndexEntry](FinniganScanIndexEntry.md) (decoder object)


### EXAMPLES ###

  * `uf-index sample.raw`

> (prints all index entries in the file in the tabular form)

  * `uf-index -range 1 .. 5 sample.raw`

> (prints the first five records)

  * `uf-index -range 1 .. 5 -format bin sample.raw`

> (shows individual bits in the unknown 'scan type' word)

  * `uf-index -rdsn 5 sample.raw`

> (dumps the fifth index entry with relative addresses and shows its size)