RunHeader is presently a static (fixed-size) structure containing data
stream lengths and addresses, as well as some unidentified data. Every
data stream in the file has its address stored in RunHeader or in its
historical antecendent SampleInfo, which it now includes.

The earlier version of RunHeader was much smaller and contained a few
variable-length strings.

## Present Structure ##
### Static size: 7408 bytes ###
| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 592 | SampleInfo | `sample info` | ... |
| 592 | 520 | UTF16LE | `file name[1]` | `C:\WINDOWS\TEMP\LCQ6A.tmp` |
| 1112 | 520 | UTF16LE | `file name[2]` | `C:\WINDOWS\TEMP\LCQ6C.tmp` |
| 1632 | 520 | UTF16LE | `file name[3]` | `C:\Xcalibur\Data\20070522_NH_Orbi2_HelaEpo_05.RAW` |
| 2152 | 520 | UTF16LE | `file name[4]` | `C:\WINDOWS\TEMP\LCQ6D.tmp` |
| 2672 | 520 | UTF16LE | `file name[5]` | `C:\WINDOWS\TEMP\LCQ68.tmp` |
| 3192 | 520 | UTF16LE | `file name[6]` | `C:\WINDOWS\TEMP\LCQ69.tmp` |
| 3712 | 8 | Float64 | `unknown double[1]` | `0.5` |
| 3720 | 8 | Float64 | `unknown double[2]` | `140` |
| 3728 | 520 | UTF16LE | `file name[7]` | `C:\WINDOWS\TEMP\LCQ66.tmp` |
| 4248 | 520 | UTF16LE | `file name[8]` | `00 00 00 00 00 00 00 00 00 00 ...` |
| 4768 | 520 | UTF16LE | `file name[9]` | `C:\WINDOWS\TEMP\LCQ6E.tmp` |
| 5288 | 520 | UTF16LE | `file name[a]` | `C:\WINDOWS\TEMP\LCQ6F.tmp` |
| 5808 | 520 | UTF16LE | `file name[b]` | `C:\WINDOWS\TEMP\LCQ70.tmp` |
| 6328 | 520 | UTF16LE | `file name[c]` | `C:\WINDOWS\TEMP\LCQ67.tmp` |
| 6848 | 520 | UTF16LE | `file name[d]` | `C:\WINDOWS\TEMP\LCQ6B.tmp` |
| 7368 | 4 | UInt32 | `scan trailer addr` | `236665370` |
| 7372 | 4 | UInt32 | `scan params addr` | `240299442` |
| 7376 | 4 | UInt32 | `unknown length[1]` | `18615` |
| 7380 | 4 | UInt32 | `unknown length[2]` | `18615` |
| 7384 | 4 | UInt32 | `nsegs` | `1` |
| 7388 | 4 | UInt32 | `unknown long[1]` | `0` |
| 7392 | 4 | UInt32 | `unknown long[2]` | `0` |
| 7396 | 4 | UInt32 | `own addr` | `229809694` |
| 7400 | 4 | UInt32 | `unknown long[3]` | `2` |
| 7404 | 4 | UInt32 | `unknown long[4]` | `2` |

<div>
</div>

### The unknowns ###

  * The observed values of the four unknown longs were the same in all files, except in the early ones, where they did not exist.

  * The reason for the duplication of the value in the two instances of `unknown length` is uncertain. The first and the last scan numbers are already present in SampleInfo. Can these two unknowns be the _numbers of records_ in some parallel streams, rather than the _number of the last record_ in them? The fact that the numbers are equal to each other and to the number of the last scan given in SampleInfo does not mean they are always the same. I am guessing what those streams might be, and for now I will wager on the first stream being the "trailer" stream, and "params" stream the second. It looks like the purpose of RunHeader was to introduce these streams later in history, when SampleInfo was already packed with data. I will not be sure until I see a case in which these streams differ in length. One that raises doubt is that the TrailerScanEvent stream begins with its own length prefix.

  * The unknown doubles always contain simple-looking numbers, such as 0.25, 0.5, 90, 140.

## Early Structure ##

(to be filled when the alternative parse path is established)