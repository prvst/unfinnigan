This structure encodes the output of the Fourier transform-based mass analysers and can (possibly) be used to encode the time-domain transient as well. Each scan done in the _profile mode_ generates one Profile structure; multiple scans are stored in a continuous stream of ScanDataPacket structures, in which Profile is an optional element (that is, a data packet may contain no profile -- as is the case of the _centroid-mode_ scans).

The spectra can be encoded either in the frequency domain or in the M/z domain. The scans encoded as frequency spectra are accompanied by a set of conversion coefficients (to be found in the corresponding ScanEvent and ScanParameters records, each containing a copy). These coefficients determine the transform converting the frequency values into the M/z values.

The spectra can be raw or filtered, but it they are customarily subject to severe threshold filtering (the unfiltered spectra can consume storage space at a rate of several gigabytes per minute, while the filtered ones take only a few hundred megabytes per hour). Further, the filtered spectra can be compressed by discarding the empty bins.

One single Profile format supports all these variations.

## Overall Structure ##

A typical filtered profile is compressed -- it contains only non-empty bins. Because the filtering applied to spectra in some instruments (most notably, in Orbitrap) leaves many bins empty, eliminating these bins from storage may achieve a fair degree of compression.

So a compressed spectrum can be viewed as a set of "chunks" containing the tops of the peaks (the bins whose values jumped the threshold), interspersed with zeroes. Thus, each profile chunk is a continuous range of non-empty bins. Adding two numbers to each chunk -- the index of its first bin and the number of bins it occupies -- allows to reconstruct the entire spectrum from a list of chunks. Normally, each chunk contains a single peak, suggesting that the chunks may be a product of a peak-calling routine. Some chunks may have a slightly distorted shape, perhaps due to the above-threshold noise.

This layout is common to all file versions except those made with Orbitrap, which adds one (now unknown) element to each chunk (see below)

## Example 1: LTQ-FT, FTMS ##

This example Profile is shown in the context of its parent file with the data packet header. The header and the two peaks at the start of the Profile shown here are set out with vertical space for visibility.

`hachoir-urwid LTQ-FTsampleDataSet1.RAW`

```
0) file:LTQ-FTsampleDataSet1.RAW
 + 0) file header
 + 1356) seq row
 + 1680) CAS info
 + 1708) raw file info
 + 2622) method file
 - 23050) packet 1 

    - 0) header 
         0) unknown long[1]= 1 
         4) profile size= 3865             (the length of the profile data in 32-bit words)
         8) peak list size= 825
         12) layout= 0
         16) descriptor list size= 412
         20) size of unknown stream= 413
         24) size of unknown triplet stream= 27
         28) unknown long[2]= 0
         32) low mz= 300.0
         36) high mz= 1500.0

    - 40) profile

         0) first bin value= 358.192708333 (in frequency spectra, it is the highest frequency, in kHz)
         8) bin step= -0.00260416666667    (bin width, in kHz)
         16) peak count= 412               (the number of chunks)
         20) nbins= 110042                 (the width of the spectrum in bins)

         24) first bin[1]= 38              (position of the first chunk)
         28) nbins[1]= 6                   (the number of bins in the chunk)
         32) peak[1][1]= 109.012367249 
         36) peak[1][2]= 165.352355957 
         40) peak[1][3]= 211.77935791 
         44) peak[1][4]= 222.406280518 
         48) peak[1][5]= 184.560577393 
         52) peak[1][6]= 109.913993835 

         56) first bin[2]= 133             (position of the second chunk)
         60) nbins[2]= 7                   (the number of bins)
         64) peak[2][1]= 81.5089950562 
         68) peak[2][2]= 143.513031006 
         72) peak[2][3]= 203.443603516 
         76) peak[2][4]= 230.587615967 
         80) peak[2][5]= 219.200469971 
         84) peak[2][6]= 183.298278809 
         88) peak[2][7]= 136.274200439 

         . . .
```

### Frequency-to-M/z conversion ###

This plot shows the range of bins carrying the peaks in the above example: Between the peaks, the sub-threshold signal has been zeroed out and the corresponding bins were not included in the profile.

![http://chart.apis.google.com/chart?chxt=y,x,x,y&chd=s%3A___bo02tb_________________________________________________________________________________________Ujy41th___&chxp=0%2C0%2C100%2C200%7C1%2C38.5%2C43.5%2C132.5%2C139&chxr=0%2C0%2C250%7C1%2C35%2C142&chco=a0a0d0&chbh=a&chs=500x150&cht=bvg&chxl=0%3A%7C0%7C100%7C200%7C1%3A%7C38%7C43%7C133%7C139|2:|||||||||||||||||||||||||||||||||||||||||||||||||||bins||3:||||||||intensity|&nonsense=.png](http://chart.apis.google.com/chart?chxt=y,x,x,y&chd=s%3A___bo02tb_________________________________________________________________________________________Ujy41th___&chxp=0%2C0%2C100%2C200%7C1%2C38.5%2C43.5%2C132.5%2C139&chxr=0%2C0%2C250%7C1%2C35%2C142&chco=a0a0d0&chbh=a&chs=500x150&cht=bvg&chxl=0%3A%7C0%7C100%7C200%7C1%3A%7C38%7C43%7C133%7C139|2:|||||||||||||||||||||||||||||||||||||||||||||||||||bins||3:||||||||intensity|&nonsense=.png)


The following is the dump of the ScanEvent structure corresponding to scan number 1 (the second ScanEvent is, in this case, identical):

`uf-trailer -drw -n 1 LTQ-FTsampleDataSet1.RAW`

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI Full ms` |
| 80 | 4 | UInt32 | `np` | `0` |
| 84 | 4 | UInt32 | `unknown long[1]` | `1` |
| 88 | 16 | FractionCollector | `fraction collector` | `[300.00-1500.00]` |
| 104 | 4 | UInt32 | `nparam` | `4` |
| 108 | 8 | Float64 | `unknown double` | `5.56270586622591e-309` |
| 116 | 8 | Float64 | `A` | `0` |
| 124 | 8 | Float64 | `B` | `107461.2734375` |
| 132 | 8 | Float64 | `C` | `-1492.03918457031` |
| 140 | 4 | UInt32 | `unknown long[2]` | `0` |
| 144 | 4 | UInt32 | `unknown long[3]` | `0` |

The following formula has been verified to transform the frequency spectra into the M/z values in those files having both the profiles and the centroided peaks in each scan:

> ![http://chart.apis.google.com/chart?cht=tx&chl=M/z%20=%20A%20%2B%20\frac{B}{f}%20%2B%20\frac{C}{f^2}&nonsense=.png](http://chart.apis.google.com/chart?cht=tx&chl=M/z%20=%20A%20%2B%20\frac{B}{f}%20%2B%20\frac{C}{f^2}&nonsense=.png)

> <b>Note</b>: To be precise, I was only able to verify this formula with respect to B and C, because A was either 0 or an infinitesimal number in all files I could lay my hands on.

## Example 2: LTQ Orbitrap, FTMS ##

The Orbitrap profiles are almost identical to those obtained with the [LTQ-FT](#Example_1:_LTQ-FT,_FTMS.md). The only novelty here is that every chunk in the compressed Orbitrap profiles includes a small number, whose meaning remains unknown.

As in the previous example, two leading chunks are shown in the context of their parent file.

`hachoir-urwid 20070522_NH_Orbi2_HelaEpo_05.RAW`
```
0) file:20070522_NH_Orbi2_HelaEpo_05.RAW 
 + 0) file header 
 + 1356) seq row 
 + 1728) CAS info 
 + 1756) raw file info 
 + 2666) method file 
 - 26694) packet 1
 
    - 0) header 
         0) unknown long[1]= 1 
         4) profile size= 2867              (the length of the profile data in 32-bit words) 
         8) peak list size= 609 
         12) layout= 128 
         16) descriptor list size= 304 
         20) size of unknown stream= 305 
         24) size of unknown triplet stream= 33 
         28) unknown long[2]= 0 
         32) low mz= 300.0 
         36) high mz= 1700.0

    - 40) profile 
         0) first bin value= 398.024739583  (the highest frequency, in kHz)
         8) bin step= -0.000651041666667    (bin width, in kHz)
         16) peak count= 304                (the number of chunks)
         20) nbins= 355041                  (the width of the spectrum in bins)

         24) first bin[1]= 60 
         28) nbins[1]= 8 
         32) unknown float[1]= -0.000364631763659 
         36) peak[1][1]= 354.015106201 
         40) peak[1][2]= 805.391601562 
         44) peak[1][3]= 1646.03991699 
         48) peak[1][4]= 2307.25244141 
         52) peak[1][5]= 2310.85253906 
         56) peak[1][6]= 1657.51745605 
         60) peak[1][7]= 788.1875 
         64) peak[1][8]= 190.546295166
 
         68) first bin[2]= 1075 
         72) nbins[2]= 6 
         76) unknown float[2]= -0.000363715807907 
         80) peak[2][1]= 629.66418457 
         84) peak[2][2]= 1701.94104004 
         88) peak[2][3]= 2323.00756836 
         92) peak[2][4]= 2030.39611816 
         96) peak[2][5]= 1049.92529297 
         100) peak[2][6]= 281.980133057 
       . . .
```

The unknown Orbitrap-specific element (unless it is file-version specific) is a small negative or positive number, but sometimes it is set to zero.

### Frequency-to-M/z conversion ###

The following is the dumps of the two ScanEvent structures corresponding to scans 1 and 2 above:

`uf-trailer -drw -n 1 20070522_NH_Orbi2_HelaEpo_05.RAW`

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 120 | ScanEventPreamble | `preamble` | `FTMS + p NSI Full ms` |
| 120 | 4 | UInt32 | `np` | `0` |
| 124 | 4 | UInt32 | `unknown long[1]` | `1` |
| 128 | 16 | FractionCollector | `fraction collector` | `[300.00-1700.00]` |
| 144 | 4 | UInt32 | `nparam` | `7` |
| 148 | 8 | Float64 | `unknown double` | `0` |
| 156 | 8 | Float64 | `I` | `0` |
| 164 | 8 | Float64 | `A` | `0` |
| 172 | 8 | Float64 | `B` | `47527012.2351007` |
| 180 | 8 | Float64 | `C` | `-6940504.35579257` |
| 188 | 8 | Float64 | `D` | `47526784.5198909` |
| 196 | 8 | Float64 | `E` | `7026562.36244185` |
| 204 | 4 | UInt32 | `unknown long[2]` | `0` |
| 208 | 4 | UInt32 | `unknown long[3]` | `0` |

`uf-trailer -drw -n 2 20070522_NH_Orbi2_HelaEpo_05.RAW`

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 120 | ScanEventPreamble | `preamble` | `FTMS + p NSI Full ms` |
| 120 | 4 | UInt32 | `np` | `0` |
| 124 | 4 | UInt32 | `unknown long[1]` | `1` |
| 128 | 16 | FractionCollector | `fraction collector` | `[300.00-1700.00]` |
| 144 | 4 | UInt32 | `nparam` | `7` |
| 148 | 8 | Float64 | `unknown double` | `nan` |
| 156 | 8 | Float64 | `I` | `0` |
| 164 | 8 | Float64 | `A` | `0` |
| 172 | 8 | Float64 | `B` | `47526997.4342686` |
| 180 | 8 | Float64 | `C` | `-6940504.35579257` |
| 188 | 8 | Float64 | `D` | `47526784.5198909` |
| 196 | 8 | Float64 | `E` | `7026562.36244185` |
| 204 | 4 | UInt32 | `unknown long[2]` | `0` |
| 208 | 4 | UInt32 | `unknown long[3]` | `0` |

In this case, there is a difference between the values of B, which illustrates the typical scan-to-scan variation of this parameter.

> <b>Note:</b> In one experiment, a colleague has shown that the conversion parameter B absorbs the variation caused by the run-time lock mass correction.

The following formula has been verified to transform the Orbitrap frequency spectra into the M/z values in those files having both the profiles and the centroided peaks in each scan:

> ![http://chart.apis.google.com/chart?cht=tx&chl=M/z%20=%20A%20%2B%20\frac{B}{f^2}%20%2B%20\frac{C}{f^4}&nonsense=.png](http://chart.apis.google.com/chart?cht=tx&chl=M/z%20=%20A%20%2B%20\frac{B}{f^2}%20%2B%20\frac{C}{f^4}&nonsense=.png)

> <b>Note</b>: As in the case of the LTQ-FT data, The formula could only be verified with respect to B and C, because A was consistently set to 0 in all availbale data files.

It is interesting to observe that the second pair of coefficients, C and D, apparently works just as well:

> ![http://chart.apis.google.com/chart?cht=tx&chl=M/z%20=%20\frac{C}{f^2}%20%2B%20\frac{D}{f^4}&nonsense=.png](http://chart.apis.google.com/chart?cht=tx&chl=M/z%20=%20\frac{C}{f^2}%20%2B%20\frac{D}{f^4}&nonsense=.png)

There was no significant difference between the two versions of the transform in a few randomly picked samples. It may be that B and C define the transform that takes into account the lock mass correction, while the transform defined by D and E does not, but this is just a conjecture at this point.

The meaning of 'I' is not certain. It is tempting to think of it as 'intercept', but that is, too, the function of 'A', if our guess is correct. It may be that A and I are the intercept co-ordinates in the two alternative transforms, but to know that for sure, samples with non-zero A and I must be examined.

## Example 3: LTQ Orbitrap, ITMS ##

In this example, the profile comes from the linear trap analyzer (which is typically used in the MS2 scans). I am not sure whether the analyzer is always calibrated in the M/z values, or the software at the receiving end was configured to do the transform just in this case, but the result is a transformed spectrum.

There is nothing but the profile in this scan data packet -- just the header and the profile. No peak calls.

`hachoir-urwid sample4.raw`

```
0) file:sample4.raw 
 + 0) file header 
 + 1356) seq row 
 + 1616) CAS info 
 + 1644) raw file info 
 + 2488) method file 
 + 24950) packet 1 
 - 56882) packet 2 
    - 0) header 
         0) unknown long[1]= 1
         4) profile size= 4208          (the size of the profile data in 32-bit words)
         8) peak list size= 0 
         12) layout= 0 
         16) descriptor list size= 0 
         20) size of unknown stream= 0 
         24) size of unknown triplet stream= 0 
         28) unknown long[2]= 0 
         32) low mz= 110.0 
         36) high mz= 460.0 
    - 40) profile 
         0) first bin value= 110.0      (low M/z)
         8) bin step= 0.0833333358169   (bin width in M/z)
         16) peak count= 1              (the entire profile is written in one chunk)
         20) nbins= 4200                (spectrum width in bins: 110 + 0.0833333358169*4200 = 460)

         24) first bin[1]= 0            (the first and only chunk starts at 0 ...)
         28) nbins[1]= 4200             (and ends at 4200)
         32) peak[1][1]= 0.0 
         36) peak[1][2]= 0.0            (empty bins are not discarded)
         40) peak[1][3]= 0.0 
         . . .

         2088) peak[1][515]= 0.0
         2092) peak[1][516]= 0.877256572247
         2096) peak[1][517]= 2.24449658394
         2100) peak[1][518]= 0.904506921768
         2104) peak[1][519]= 0.115356951952
         2108) peak[1][520]= 0.0
         . . .

         16820) peak[1][4198]= 0.0
         16824) peak[1][4199]= 0.0
         16828) peak[1][4200]= 0.0

   73754) packet 3
   91106) packet 4
   . . .

```