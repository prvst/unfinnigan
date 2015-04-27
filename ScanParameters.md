**Note**: _Thermo calls these structures `ScanHeader`. There are many enough header-like structures in the file, and these particular ones don't really look like headers, so I chose a different name to avoid confusion._

## Purpose ##

I do not fully understand the purpose of this structure, but based on the labels it contains, it seems to have been intended for human consumption. It does not seem to contain any data that wouldn't be stored somewhere else in the file.

One possible exception is the **Charge State** attribute that I needed to fill the precursor data while writing out the XML for the MS2 scans in [UnfinniganMzXML](UnfinniganMzXML.md). I may be able to find it somewhere else, but for now, I am satisfied that I can pull it from this stream.

The content of ScanParameters records is designed to be decoded with the GenericDataHeader mechanism.


## Structure ##

### Example 1: full MS1 scan ###

```
FTMS + p NSI Full ms [300.00-1700.00]
```

```
uf-params -w -n 104 20070522_NH_Orbi2_HelaEpo_05.RAW 
```

| seq | label | value |
|:----|:------|:------|
| 104 | AGC: | 1 |
| 104 | Micro Scan Count: | 1 |
| 104 | Ion Injection Time (ms): | 140.916687011719 |
| 104 | Scan Segment: | 1 |
| 104 | Scan Event: | 1 |
| 104 | Master Index: | 0 |
| 104 | Elapsed Scan Time (sec): | 1.10809993743896 |
| 104 | API Source CID Energy: | 0 |
| 104 | Average Scan by Inst: | 0 |
| 104 | Charge State: | 1 |
| 104 | Monoisotopic M/Z: | 391.284142832766 |
| 104 | MS2 Isolation Width: | 0 |
| 104 | MS3 Isolation Width: | 0 |
| 104 | MS4 Isolation Width: | 0 |
| 104 | MS5 Isolation Width: | 0 |
| 104 | MS6 Isolation Width: | 0 |
| 104 | MS7 Isolation Width: | 0 |
| 104 | MS8 Isolation Width: | 0 |
| 104 | MS9 Isolation Width: | 0 |
| 104 | MS10 Isolation Width: | 0 |
| 104 | FT Analyzer Settings: | T=1e6 PsIT=5 PvR=2e4 iWf LM=(429.0887,445.12,503.1075,519.1388) |
| 104 | FT Analyzer Message: | MCal=2d Lock(4/4, +0ppm) |
| 104 | FT Resolution: | 60000 |
| 104 | Conversion Parameter I: | 0 |
| 104 | Conversion Parameter A: | 0 |
| 104 | Conversion Parameter B: | 47526997.8054239 |
| 104 | Conversion Parameter C: | -6940504.35579257 |
| 104 | Conversion Parameter D: | 47526784.5198909 |
| 104 | Conversion Parameter E: | 7026562.36244185 |

### Example 2: dependent MS3 scan ###

```
ITMS + c NSI d w Full ms2 433.29@cid35.00 [105.00-880.00]
```

```
uf-params -w -n 105 20070522_NH_Orbi2_HelaEpo_05.RAW 
```

| seq | label | value |
|:----|:------|:------|
| 105 | AGC: | 1 |
| 105 | Micro Scan Count: | 1 |
| 105 | Ion Injection Time (ms): | 149.999984741211 |
| 105 | Scan Segment: | 1 |
| 105 | Scan Event: | 2 |
| 105 | Master Index: | 1 |
| 105 | Elapsed Scan Time (sec): | 0.316199988126755 |
| 105 | API Source CID Energy: | 0 |
| 105 | Average Scan by Inst: | 0 |
| 105 | Charge State: | 2 |
| 105 | Monoisotopic M/Z: | 433.288482666016 |
| 105 | MS2 Isolation Width: | 2 |
| 105 | MS3 Isolation Width: | 0 |
| 105 | MS4 Isolation Width: | 0 |
| 105 | MS5 Isolation Width: | 0 |
| 105 | MS6 Isolation Width: | 0 |
| 105 | MS7 Isolation Width: | 0 |
| 105 | MS8 Isolation Width: | 0 |
| 105 | MS9 Isolation Width: | 0 |
| 105 | MS10 Isolation Width: | 0 |
| 105 | FT Analyzer Settings: |  |
| 105 | FT Analyzer Message: |  |
| 105 | FT Resolution: | 0 |
| 105 | Conversion Parameter I: | 0 |
| 105 | Conversion Parameter A: | 0 |
| 105 | Conversion Parameter B: | 0 |
| 105 | Conversion Parameter C: | 0 |
| 105 | Conversion Parameter D: | 0 |
| 105 | Conversion Parameter E: | 0 |