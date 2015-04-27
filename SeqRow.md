This object contains the details of the row in the sequencer table that commanded the injection of the sample whose spectra are encoded in this raw file.

The amount of data in this object appears to depend on what the user enters in Xcalibur's Sequence Setup, and it is often left blank or nearly blank.

## Structure ##

### Finnigan MAT LCQ ###

(or any file V.8 and earlier)

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 64 | InjectionData | `injection` | ... |
| 64 | 4 | PascalStringWin32 | `unknown text[a]` |  |
| 68 | 4 | PascalStringWin32 | `unknown text[b]` |  |
| 72 | 6 | PascalStringWin32 | `id` | 1 |
| 78 | 4 | PascalStringWin32 | `comment` | QC=10 pg/ml,IS=100 pg/ml |
| 82 | 4 | PascalStringWin32 | `user label[1]` |  |
| 86 | 4 | PascalStringWin32 | `user label[2]` |  |
| 90 | 4 | PascalStringWin32 | `user label[3]` |  |
| 94 | 4 | PascalStringWin32 | `user label[4]` |  |
| 98 | 4 | PascalStringWin32 | `user label[5]` |  |
| 102 | 82 | PascalStringWin32 | `inst method` | `C:\LCQ\Methods\\x007417_49srm_1050_open` |
| 184 | 4 | PascalStringWin32 | `proc method` |  |
| 188 | 68 | PascalStringWin32 | `file name` | `C:\LCQ\Data\mrw_27417\Sat_0504_WD1\27417_Sat_0504WD1_Plas_22.RAW` |
| 256 | 38 | PascalStringWin32 | `path` | `C:\LCQ\Data\mrw_27417\Sat_0504_WD1` |

<div></div>

### LTQ-FT ###

(version 57)

SeqRow in these files has three additional text fields (`vial` and `unknown text[c,d]`) and one long integer:

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 64 | InjectionData | `injection` | ... |
| 64 | 4 | PascalStringWin32 | `unknown text[a]` |  |
| 68 | 4 | PascalStringWin32 | `unknown text[b]` |  |
| 72 | 6 | PascalStringWin32 | `id` | `1` |
| 78 | 4 | PascalStringWin32 | `comment` |  |
| 82 | 4 | PascalStringWin32 | `user label[1]` |  |
| 86 | 4 | PascalStringWin32 | `user label[2]` |  |
| 90 | 4 | PascalStringWin32 | `user label[3]` |  |
| 94 | 4 | PascalStringWin32 | `user label[4]` |  |
| 98 | 4 | PascalStringWin32 | `user label[5]` |  |
| 102 | 126 | PascalStringWin32 | `inst method` | `C:\Xcalibur\methods\90min-10-02-2004-triplePlay3ionsJens.meth` |
| 228 | 4 | PascalStringWin32 | `proc method` |  |
| 232 | 36 | PascalStringWin32 | `file name` | `NucleoliY-14.RAW` |
| 268 | 38 | PascalStringWin32 | `path` | `C:\Xcalibur\Data\` |
| 306 | 6 | PascalStringWin32 | `vial` | `1` |
| 312 | 4 | PascalStringWin32 | `unknown text[c]` |  |
| 316 | 4 | PascalStringWin32 | `unknown text[d]` |  |
| 320 | 4 | UInt32 | `unknown long` | `0` |

<div></div>

### LTQ-Orbitrap ###
### LTQ-Orbitrap XL ###

(Versions 62 and 63)

SeqRow in these files begins with the same structure as in v.57, but has 15 additional text fields (`unknown text[e..s]`) following it:

| 0 | 64 | InjectionData | `injection` | ... |
|:--|:---|:--------------|:------------|:----|
| 64 | 4 | PascalStringWin32 | `unknown text[a]` |  |
| 68 | 4 | PascalStringWin32 | `unknown text[b]` |  |
| 72 | 4 | PascalStringWin32 | `id` |  |
| 76 | 72 | PascalStringWin32 | `comment` | `SILAC, Sec 1and2, 5 uL inj fr 50uL` |
| 148 | 16 | PascalStringWin32 | `user label[1]` | `043008` |
| 164 | 38 | PascalStringWin32 | `user label[2]` | `0.25uL C8 Optipak` |
| 202 | 90 | PascalStringWin32 | `user label[3]` | `Michrom 75um x 20cm C18aq 5u/200A spray tip` |
| 292 | 18 | PascalStringWin32 | `user label[4]` | `4/21/08` |
| 310 | 4 | PascalStringWin32 | `user label[5]` |  |
| 314 | 128 | PascalStringWin32 | `inst method` | `C:\Xcalibur\methods\orbi261_eksi2d_top5_1e6_20_nolm_90min.meth` |
| 442 | 4 | PascalStringWin32 | `proc method` |  |
| 446 | 74 | PascalStringWin32 | `file name` | `kj261_08apr30_05_silac_sec1and2.RAW` |
| 520 | 70 | PascalStringWin32 | `path` | `C:\XCALIBUR\DATA\ORBI261_APR2008\` |
| 590 | 8 | PascalStringWin32 | `vial` | `B1` |
| 598 | 4 | PascalStringWin32 | `unknown text[c]` |  |
| 602 | 4 | PascalStringWin32 | `unknown text[d]` |  |
| 606 | 4 | UInt32 | `unknown long` | `0` |
| 610 | 4 | PascalStringWin32 | `unknown text[e]` |  |
| 614 | 4 | PascalStringWin32 | `unknown text[f]` |  |
| 618 | 4 | PascalStringWin32 | `unknown text[g]` |  |
| 622 | 4 | PascalStringWin32 | `unknown text[h]` |  |
| 626 | 4 | PascalStringWin32 | `unknown text[i]` |  |
| 630 | 4 | PascalStringWin32 | `unknown text[j]` |  |
| 634 | 4 | PascalStringWin32 | `unknown text[k]` |  |
| 638 | 4 | PascalStringWin32 | `unknown text[l]` |  |
| 642 | 4 | PascalStringWin32 | `unknown text[m]` |  |
| 646 | 4 | PascalStringWin32 | `unknown text[n]` |  |
| 650 | 4 | PascalStringWin32 | `unknown text[o]` |  |
| 654 | 4 | PascalStringWin32 | `unknown text[p]` |  |
| 658 | 4 | PascalStringWin32 | `unknown text[q]` |  |
| 662 | 4 | PascalStringWin32 | `unknown text[r]` |  |
| 666 | 4 | PascalStringWin32 | `unknown text[s]` |  |