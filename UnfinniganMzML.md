# uf-mzml #

## Purpose ##

The data conversion tool **uf-mzml** uses the [Finnigan](FileStructureTOC.md) decoder to read the binary data acquired from Thermo instruments using proprietary software (Xcalibur) and generates [mzML](http://www.psidev.info/index.php?q=node/257), a structured text format that can be shared among several mass spec and proteomics tools.

## Implementation ##

The decoder is entirely written in perl, so **uf-mzml** should run on any system that has perl installed and where package dependencies are satisfied.

## Usage ##

```
uf-mzml [options] <file>
```

**Options:**

> `-a[ctivationMethod] <symbol>`
> > specify ion activation method (CID by default)


> Since the native storage location of the data element corresponding to the activation method is unknown at this time, the required mzml attribute is set to `collision-induced dissociation` by default. It is a valid assumption in most Orbitrap experiments. The `-a` option overrides this default value. The symbol specified on the command line is simply copied into the `<activation>` element, provided it exists in the mzML controlled vocabulary. A small fragment of the vocabulary included in **uf-mzml** will recognize the following choices:
```
      collision-induced dissociation
      surface-induced dissociation
      electron capture dissociation
      electron transfer dissociation
      photodissociation
      multiphoton dissociation
      infrared multiphoton dissociation
```
> `-c[entroids] `
> > prefer centroids to raw profiles

  * **Note:** presently, **uf-mzml** does not do its own centroiding. If a scan contains no centroid data, the profile is written. Also, profiles are chosen by default in those scans where both the profile and the centroid list are present.


> `-r[ange] <from> .. <to>`
> > write only scans with numbers between `<from>` and `<to>`

  * **Note:** in order to establish valid references within the mzML file, the first scan in the selected range has be an MS1 scan. Otherwise, the program will exit with the following message:
> > `Range error: cannot form valid mzml starting with the dependent scan ###`
> > > To determine the appropriate range of scans, list all scans in the file using **[uf-trailer](UnfinniganTrailer.md)**.


> `-q[uiet] `
> > Suppress the instrument error messages stored in the input file. Without this option, the error messages will be printed to STDERR.


> `-u[nencoded] `
> > Dump the contents of each `<binary>` element in human-readable decimal encoding.


> `-s[tructure] `
> > Do not output scan data, preserving the overall structure of the XML document. This option is useful in troubleshooting the structure of the output file and its metadata.


> `<file>`
> > input file


> The converted mzml data is written to STDOUT.
## Examples ##

```
 uf-mzml sample.raw > sample.mzML
```
> (convert the entire file, using profiles from those scans where both profiles and centroids are present and centroids where there are no profiles)

```
 uf-mzml -c sample.raw > sample.mzML
```
> (convert the entire file, extracting precomputed centroids from every scan containing centroids; where there are no centroids, the profile will be used)

```
 uf-mzml -c -r 350 .. 352 20070522_NH_Orbi2_HelaEpo_05.RAW > test.xml
```
> (extract peak centroids from scans 350 through 352)