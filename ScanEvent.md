This is a variable-length structure contaning several key details about the scan. Most of those details are concentrated in its lead element, ScanEventPreamble.

The length of the structure depends on the number of precursor ions selected for the scan. Each precursor ion is described by the structure named [Reaction](Reaction.md), containing the ion's M/z, its fragmentation energy and some other data, possibly related to the reaction type. Obviously, the number of precursor ions will be 0 in all MS1 scans.

All variants contain a structure named FractionCollector, which is just a pair of double-precision numbers indicating the M/z range of the scan.

Those ScanEvent descriptors which correspond to the raw profile scans requiring conversion of the spectra to the M/z domain also include a set of conversion coefficients that determine the transform. Another copy of these coefficients can be found in the corresponding ScanParameterSet -- a somewhat overlapping structure in a parallel data stream. But unlike ScanEvent, which stores these coefficients as a simple list, ScanParameterSet is a GenericRecord, in which all elements have descriptive names.

### Relationship between ScanEventTemplate and  ScanEvent ###

ScanEvent is derived from ScanEventTemplate. It has two fewer UInt32 elements (the meaning of the 5 UInt32 elements in ScanEventTemplate and the remaining 3 in ScanEvent is unknown, and it is not even obvious that the original 5 and the remaining 3 are related). The ScanEventPreamble is copied verbatim, and two additional variable lists are added in ScanEvent: the list of conversion parameters (with element count) and the precursor ion list (with count).

<table>
<tr valign='top'>
<td>
<table><thead><th> <b>ScanEventTemplate</b> </th></thead><tbody>
<tr><td> ScanEventPreamble </td></tr>
<tr><td> unknown UInt32 (1) </td></tr>
<tr><td> unknown UInt32 (2) </td></tr>
<tr><td> FractionCollector </td></tr>
<tr><td> unknown UInt32 (3) </td></tr>
<tr><td> unknown UInt32 (4) </td></tr>
<tr><td> unknown UInt32 (5) </td></tr>
<blockquote></td>
<blockquote><td>
<tr><td> <b>ScanEvent</b> </td></tr>
<tr><td> ScanEventPreamble (<i>identical</i>)</td></tr>
<tr><td> <i>n</i>: number of precursor ions (<i>the first unknown?</i>) </td></tr>
<tr><td> unknown UInt32 (<i>the second unknown?</i>) </td></tr>
<tr><td> FractionCollector (<i>identical</i>) </td></tr>
<tr><td> <i>m</i>: number of conversion coefficients (<i>the third unknown</i>?) </td></tr>
<tr><td> Coefficients (1 .. <i>m</i>) </td></tr>
<tr><td> unknown UInt32 (<i>the fourth unknown?</i>) </td></tr>
<tr><td> unknown UInt32 (<i>the fifth unknown?</i>) </td></tr>
<tr><td> Precursors (1 .. <i>n</i>) </td></tr>
</td>
</tr>
</table></blockquote></blockquote></tbody></table>

Not knowing the code, this alignment is just a conjecture. The important point is that the ScanEventTemplate structure seems to donate some values that do not change; the only variable components are the conversion coefficients and precursor lists.

**Note**: There is probably no relationship between the first two longs in ScanEventTemplate and ScanEvent. The controlled vocabulary in mzML refers to ScanEventTemplate (via msconvert) as _"preset scan configuration"_, so it should not have anything like the number of precursor ions in it.

I would rather venture a guess that the first two values in ScanEventTemplate are `controllerType` and `controllerNumber`. With no variation in the data, it is just a wild guess, but I will stick by it until proven wrong.


### Structure examples ###
#### MS1 scan (Orbitrap) ####
##### Size: 220 bytes #####
`uf-trailer -drwn 1 sample4.raw`
| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 128 | ScanEventPreamble | `preamble` | `FTMS + p ESI Full ms` |
| 128 | 4 | UInt32 | `np` | `0` |
| 132 | 4 | UInt32 | `unknown long[1]` | `1` |
| 136 | 16 | FractionCollector | `fraction collector` | `[400.00-2000.00]` |
| 152 | 4 | UInt32 | `nparam` | `7` |
| 156 | 8 | Float64 | `unknown double` | `0` |
| 164 | 8 | Float64 | `I` | `0` |
| 172 | 8 | Float64 | `A` | `0` |
| 180 | 8 | Float64 | `B` | `47484051.4356993` |
| 188 | 8 | Float64 | `C` | `-8965970.02086826` |
| 196 | 8 | Float64 | `D` | `47484202.5016058` |
| 204 | 8 | Float64 | `E` | `-19381160.2659158` |
| 212 | 4 | UInt32 | `unknown long[2]` | `0` |
| 216 | 4 | UInt32 | `unknown long[3]` | `0` |


#### MS2 scan (Orbitrap) ####
##### Size: 196 bytes #####
`uf-trailer -drwn 2 sample4.raw`
| 0 | 128 | ScanEventPreamble | `preamble` | `ITMS + p ESI d Full ms2` |
|:--|:----|:------------------|:-----------|:--------------------------|
| 128 | 4 | UInt32 | `np` | `1` |
| 164 | 4 | UInt32 | `unknown long[1]` | `1` |
| 132 | 32 | Reaction`[]` | `reaction` | `445.12@cid35.00` |
| 168 | 16 | FractionCollector | `fraction collector` | `[110.00-460.00]` |
| 184 | 4 | UInt32 | `nparam` | `0` |
| 188 | 4 | UInt32 | `unknown long[2]` | `0` |
| 192 | 4 | UInt32 | `unknown long[3]` | `0` |