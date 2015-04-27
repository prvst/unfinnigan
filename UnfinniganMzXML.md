# uf-mzxml #

## Purpose ##

The data conversion tool **uf-mzxml** uses the [Finnigan](FileStructureTOC.md) decoder to read the binary data acquired from Thermo instruments using proprietary software (Xcalibur) and generates [mzXML](http://tools.proteomecenter.org/wiki/index.php?title=Formats:mzXML), a structured text format that can be shared among several mass spec and proteomics tools.

## Implementation ##

The decoder is entirely written in perl, so **uf-mzxml** should run on any system that has perl installed and where package dependencies are satisfied. It runs fairly fast but it creates a large temporary file where it stores frozen scan data to be thawed during XML generation. The reason for this is that the mzXML output is structured to reflect scan dependency (each MS1 object _contains_ all dependent MS2 objects, and so on), and the first implementation of **uf-mzxml** works in two passes: first read all scans, then use the look-up table of scans to form the output. Storing scan data in a temporary file reduces RAM requirement. With the new monolithic Scan decoder, RAM usage is no longer a significant constraint, so this design is subject to further optimisation.

## Usage ##

```
uf-mzxml [options] <file>
```

**Options:**

> `-a[ctivationMethod] <symbol>`
> > specify ion activation method (CID by default)


> Since the native storage location of the data element corresponding to the activation method is unknown at this time, the required mzXML attribute is set to `CID` (Collision-Induced Dissociation). It is a valid assumption in most Orbitrap experiments. The `-a` option overrides this default value. The symbol specified on the command line is simply copied into the **activationMethod** attribute of the **precursorMz** element, and there is no constraint on what it can be.

> `-c[entroids] `
> > prefer centroids to raw profiles

  * **Note:** presently, **uf-mzxml** does not do its own centroiding. If a scan contains no centroid data, it is skipped.


> `-r[ange] <from> .. <to>`
> > write only scans with numbers between `<from>` and `<to>`

  * **Note:** in order to form the nested structure of dependent scans required in mzXML, the first scan in the selected range has be an MS1 scan. Otherwise, the program will crash with the following message:
> > `Range error: cannot form valid mzXML starting with the dependent scan ###`
> > > To determine the appropriate range of scans, list all scans in the file using **[uf-trailer](UnfinniganTrailer.md)**.


> `-q[uiet] `
> > Suppress the instrument error messages stored in the input file. Without this option, the error messages will be printed to STDERR.


> `<file>`
> > input file


> The converted mzXML data is written to STDOUT.
## Examples ##

```
 uf-mzxml -c 20070522_NH_Orbi2_HelaEpo_05.RAW > 20070522_NH_Orbi2_HelaEpo_05.mzXML
```
> (convert the entire file, extracting precomputed centroids from every scan)

```
 uf-mzxml -c -r 350 .. 352 20070522_NH_Orbi2_HelaEpo_05.RAW > test.xml
```
> (extract peak centroids from scans 350 through 352)

## Relationship to readw ##

While **uf-mzxml**, like **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)**, can generate mzXML, it is not a full equivalent. The purpose of **uf-mzxml** was not as much to provide a free equivalent to **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)**, as it was to test the validity of the Finnigan decoder using **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** as a benchmark. However, it is a viable alternative to **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** where mzXML is a satisfactory form of encoding.

## Point-by-point comparison to readw output ##

**Note:** to facilitate comparison, the base64-encoded peak data were unpacked in both outputs using **[mzxml-unpack](MzXMLUnpack.md)**.

  * **msRun.endTime**: A difference in the floating-point format. Not an issue; this happens almost always when the underlying data is encoded as a 64-bit floating-point number. Apparently, it undergoes conversion to 32-bit either in **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** or in Thermo library.

  * **parentFile.fileSha1**: I do not know the purpose of this signature, nor how it is calculated. Running **shasum** on the entire file yields a different result. Probably not an issue either.

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-1.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-1.png)

  * **msInstrument.msDetector**: '`undefined`' or '`unknown`'? Should I worry about it?

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-2.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-2.png)

  * **dataProcessing.software**: Just so we know what we are comparing:

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-3.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-3.png)

  * **scan.peaksCount**: This is where things become interesting. For no reason I can imagine, **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** discarded some of the most prominent peaks along with their immediate surroundings. More details below.

_Note_: in this test file, only the MS1 scans suffered from deletions by **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)**. I am not sure yet whether the effect is limited to this file or to its MS1 scans, or whether this is something to be expected in general. I will post an update as soon as I have examined more files from different sources.

  * **scan.lowMz**, **scan.highMz**: This is a difference between points of view. A scan range can arguably be defined as the difference between the highest mass and the lowest mass in the peak list, or it can be defined as the sweep range commanded for by the instrument settings. I took the latter view and simply copied the stated range values from the scan data. It is clear from the screenshot that **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** calculated these values instead of querying the data: the smallest mass (300.061096191406) can be seen at the bottom of the screen.

  * **scan.{basePeakMz,basePeakIntensity,totIonCurrent}**: floating-point formatting

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-4.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-4.png)

  * **scan.peaks**: This screenshot highlights peak suppression in **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** output; the missing peaks are also shown in red in the plot following the screenshot:

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-6.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-6.png)

![http://wiki.unfinnigan.googlecode.com/hg/images/readw-missing-peaks.png](http://wiki.unfinnigan.googlecode.com/hg/images/readw-missing-peaks.png)

Having compared the outputs from multiple tools, I can say it is a feature of the Thermo library. These peaks are also missing in mzXML generated by **msconvert** and they are not shown on the graph plotted in **Xcalibur**'s **Qual Browser**.

It is curious that sometimes this peak suppression is incomplete:

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-6a.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-6a.png)

  * **scan.precursorMz**: Strange precursors (scans 5216, 9314, 10119, 10385, 10777, 11465, 11787, 13340 in `20070522_NH_Orbi2_HelaEpo_05`). From the data, these appear to be the cases where the [search for the precursor peak à la  readw](Problems#Known_to_be_absent.md) should turn up nothing (setting the value of **precursorIntensity** to 0). But in scan 5216, for example, the stated precursor _M/z_ of 529.30 was substituted for an existing peak of at 528.80, exactly one atomic unit lighter (note the precursor charge of 2). Similarly, in scan 9314, the precursor _M/z_ of  623.29 was substituted for the lighter isotope 622.79. In the next instance, in scan 10119, a similar substitution occurred (618.830 → 619.330), but to no avail: the resulting precursor intensity was left at 0. That is doubly strange because the parent scan 10114 has a very strong peak right at 619.330. The same effect in scans 10385 and 10777. In 11465, it went for a lighter charge 3 isotope and fetched nothing. Scan 16651 tells the same story about a charge 5 isotope.

> The first screenshot shows scan 5216, where **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** went for an isotope and fetched it, followed by scan 10119, where it also went for the isotope but fetched nothing, while the stated mass was, indeed, found in the profile:

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-5216.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-5216.png)

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-10119.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-10119.png)

I am not sure whether I should copy this behaviour in **uf-mzxml**. It seems like a bug.

  * **Which side of the bin?** Having decoded the version 60 files for the first time, I noticed this new discrepancy. When decoding this file version, which is no different in the way it encodes the profiles, **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** decides to assign the abundance value to the other side of the frequency bin (the left panel shows the output from **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)**, the right panel is from `uf-mzxml`):

![http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-7.png](http://wiki.unfinnigan.googlecode.com/hg/images/uf-mzxml-readw-diff-7.png)

Because the bin size is the smallest unit in this world and it is determined by the instrument's resolution, assigning abundance to the left-hand side, to the right-hand side or to the centre of the bin may be a matter of preference, but all three are valid choices. What is a bit annoying is that **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** (or the underlying Thermo library) do not make the same choice in all situations. Does it mean anything?  I don't know.

Here is how the relevant fragment of the raw file is encoded:

```
 - 2544) packet 1 (75.1 KB)
    - 0) header (40 bytes)
         0) unknown long[1]= 1 (4 bytes)
         4) profile size= 19208: Size of the profile object, in 4-byte words (4 bytes)
         8) peak list size= 0: Size of the peak list, in 4-byte words (4 bytes)
         12) layout= 0: This is believed to be the packet layout indicator (4 bytes)
         16) descriptor list size= 0: Size of the peak descriptor list in 4-byte words (co-incides with the number of peaks) (4 bytes)
         20) size of unknown stream= 0: Size of the unknown stream in 4-byte words (4 bytes)
         24) size of unknown triplet stream= 0: Size of the stream of unknown triplets in 4-byte words (4 bytes)
         28) unknown long[2]= 0: Seems to be zero everywhere (4 bytes)
       + 32) low mz= 400.0: Scan low M/z; appears in filterLine in mzXML (4 bytes)
       + 36) high mz= 2000.0: Scan high M/z; appears in filterLine in mzXML (4 bytes)
    - 40) profile: Raw or filtered profile (depending on scan mode) (75.0 KB)
       + 0) first bin value= 400.0: in the case of spectra, this will be the highest frequency (8 bytes)
       + 8) bin step= 0.0833333358169: the amount each bin value differs from the previous one (8 bytes)
         16) peak count= 1 (4 bytes)
         20) nbins= 19200: Number of bins in scan (4 bytes)
         24) first bin[1]= 0: Starting bin number in peak (4 bytes)
         28) nbins[1]= 19200: Peak width in bins (4 bytes)
       + 32) peak[1][1]= 2913.87768555 (4 bytes)
       + 36) peak[1][2]= 2607.97119141 (4 bytes)
       + 40) peak[1][3]= 2156.13427734 (4 bytes)
       + 44) peak[1][4]= 1714.91845703 (4 bytes)
```

There is really no room for error in the encoding; what may vary is its interpretation. It clearly states that the highest frequency of the scan corresponds to the _M/z_ value of **400** (`low mz`), the next bin is 1/12th of a kHz lower (**0.083333(3)**), and so forth. So I place the first value (**2913.87768555**) _in_ the first bin marked 400 _M/z_, the second value _in_ the bin marked 400.0833435 M/Z (after conversion), and so forth. To me it is a one-to-one relationship: a bin links a value of _M/z_ to the signal at or around that frequency. The output from **[readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW)** seems to suggest that the low _M/z_ value does not exist -- that is, it wants the abundance to be assigned to the right-hand side of the first bin, or to sit right between the first and the second bins. That is a bit strange, and even more so, given that it does not always do this.