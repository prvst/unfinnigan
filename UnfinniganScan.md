# uf-scan #

## SYNOPSIS ##

```
uf-scan [options] <file>
```

## OPTIONS ##

_**-help**_ Print a brief help message and exit.

_**-d`[`ump`]`**_ dump the scan header or the header and the profile (if the _**-profile**_ option is supplied)

_**-e`[`xtract`]`**_ extract the entire scan data as a binary chunk

_**-l`[`ist`]`**_ list the called peaks

_**-p`[`rofile`]`**_ print the scan profile as a 2-column table

_**-plot**_ plot the profile (along with the called peaks, if available) [required](required.md)

_**-v**_ convert _f → M/z_ `[`requires _**-profile**_`]`

_**-z**_ fill the gaps with empty bins `[`requires _**-profile**_`]`

_**-n`[`umber`]` `<n>`**_ select scan number _**n**_

_**-mz `<`low`>` .. `<`high`>`**_ select a range of _M/z_ values to plot `[`requires _**-plot**_`]`

_**`<`file`>`**_ input file


## DESCRIPTION ##

**uf-scan** can be used to list or plot the scan data in a single scan. The _**-profile**_ option instructs _**uf-scan**_ to print the profile data, the _**-list**_ option lists the peaks, and the _**-plot**_ option writes an R script to plot the profile overlaid by peak centroids, if both kinds of data are present in the raw file, or just the profile if the centroids are not present.

Options _**-profile**_, _**-list**_ and _**plot**_ are mutually exclusive.

To convert the raw scan data into the _M/z_ values, use the _**-v**_ option.

Option _**-z**_ fills the gaps between the profile peaks with zeroes, to create a continuous table.

## SEE ALSO ##

**[uf-mzxml](UnfinniganMzXML.md)**


### EXAMPLES ###

  * `uf-scan -p -n 1 sample.raw`

> (prints all raw profile bins in the 1st scan)

  * `uf-scan -ep -n 1 sample.raw`

> (extracts the entire scan profile in the binary form)

  * `uf-scan -pv -n 1 sample.raw`

> (same as above, except the bin values are converted into _M/z_)

  * `uf-scan -pvz -n 1 sample.raw`

> (same as above, but in addition, all empty bins are wirtten out as well)

  * `uf-scan -l -n 1 sample.raw`

> (will print the list of centroids in the 1st scan; note that **uf-scan** does not calculate the peak centroids from the profile; it only lists the existing centroids if they are present)

  * `uf-scan -plot -n 1 -mz 445.0 .. 445.2 sample.raw | R --vanilla --slave > plot.eps`

> This command will call R to plot the profile in the given range of _M/z_ values. If called peaks are present, they will be shown as dots on the graph.

  * `uf-scan -d -p -n 18588 sample.raw | grep fudge | cut -f 5`

> See the amount of correction applied to each bin in scan 18588.