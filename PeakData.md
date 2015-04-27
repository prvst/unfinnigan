## Examples of use ##

### Xcalibur example files ###
```
  drugx_15.raw
```


## How it looks ##
![http://wiki.unfinnigan.googlecode.com/hg/images/screenshot-okteta-drugx_15.raw.png](http://wiki.unfinnigan.googlecode.com/hg/images/screenshot-okteta-drugx_15.raw.png)

This example was a good one to crack this structure on, because the scan was made in a narrow range of _M/z_ (420 .. 425), resulting in a nearly constant word in the _M/z_ encoding (0x01A3 .. 0x01A9), thus emphasising the 8-byte periodicity already hinted at by two columns of zeroes. The size of the `PeakData` stream in `drugx_15.raw`, 1096 bytes (a multiple of 8) reinforced the assumption of the structure size. The exact details were inferred by comparing the stream with the output of `readw`.

## Structure ##

This is the funniest way to store a pair of numbers I have ever encountered. `PeakData` is simply a stream of the `CalledPeak` structures:

```
typedef struct {
   UInt32 intensity, /* a 24-bit value with the LSB set to 0x00 */
   UInt16 mz_whole,  /* whole number of atomic units */
   UInt16 mz_frac    /* fractional number expressed in multiples of 1/2^16 */
} CalledPeak;
```

The peaks are grouped into scans, but no container structure exists at the scan level. The offset from the start of `PeakData` to the first peak in each scan and the number of peaks in the scan are indicated in the last two elements of the `Scan` structure in `Scan Data`

The total size of `PeakData` does not seem to be present anywhere in the file, but it can be calculated using the offset to next object in sequence. Here is how it is done in Hachoir:

```
class PeakData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        info = self["/run header/sample info"]
        size =  info["scan list addr"].value - info["raw data addr"].value
        npeaks = size/8 # each peak description is 8 bytes long
        for n in range(1, npeaks + 1):
            yield CalledPeak(self, "peak[%s]" % n, "CalledPeak %s" % n)

```

Calculating the total size is not necessary in normal use (_i.e._, while converting complete streams), because each `CalledPeak` is referenced via an offset and a count from a corresponding record in `ScanData`, but it is useful in making exploration tools, such as Hachoir parsers, which must cope with random access to all elements.

## Decoded stream ##

```
313088  420   9920
130816  420  20584
359680  420  52564
196352  420   5528
 31744  421  14480
160256  425  12520
 55296  424  12176
203520  419  46760
 37376  421  10264
 37632  425  14488
 31744  425  14480
 83200  420  25012
 31744  421   1376
 80640  425   2852
194048  424  42776
     .   .   .
```

## Final interpretation ##

```
420.1513671875     1223
420.314086914062    511
420.802062988281   1405
420.084350585938    767
421.220947265625    124
425.191040039062    626
424.185791015625    216
419.713500976562    795
421.156616210938    146
425.221069335938    147
425.220947265625    124
420.381652832031    325
421.02099609375     124
425.043518066406    315
424.652709960938    758
     .   .   .
```

<blockquote title='Note'>
<b>Note</b>: The decoded intensites are stored and passed around as floating point numbers. <i>Qualbrowser</i> adds a decimal point and a 0 when it displays them, making them look suspicious, but that is to be expected because they originate as 24-bit integers. I am not familiar with the detector whose designation in this example is <code>Finnigan MAT LCQ</code>, but it appears that it either has a 24-bit ADC or an array of 24-bit counters -- otherwise, I don't know how to explain it.<br>
</blockquote>

## Testing ##

This tool can be used to test whether a chunk of raw data has the structure of the `PeakData` type described here:

[decode\_peak\_data.pl](http://code.google.com/p/unfinnigan/source/browse/decode_peak_data.pl)

(Binary chunks can be easily saved using `hashoir-wx`: right-click on the object and select _Dump to Disk_)