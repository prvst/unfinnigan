## GenericDataHeader ##

This is a complete `hachoir-urwid` dump of the ScanHeader header object (I know, it sounds confusing, but I will continue to follow Thermo object naming where possible, until I am familiar enough with all these objects to give them more suitable and more descriptive names).

The header is showin in the context of its parent file. This example was taken from the file `LTQ-FTsampleDataSet1.RAW` available for [download](http://www.pil.sdu.dk/1/MSQuant/LTQ-FTsampleDataSet1,2004-02-14.zip) from the [MSQuant site](http://msquant.alwaysdata.net/docs/install/).

```
0) file:LTQ-FTsampleDataSet1.RAW
 + 0) file header: The root file header (magic 1)
 + 1356) seq row: SeqRow -- Sequence Table Row
 + 1680) CAS info
 + 1708) raw file info
 + 2622) method file: Embedded method file
 + 23050) spectrum 1
   45258) unparsed spectra= "\x01\x00\x00\x00\x52\x0f\x00\x00\x49\x03\x00\x00\x00\x00(...)": This is where the spectra are found
 + 63385974) run header: Information about the scans and related streams
 + 63393382) inst id: Instrument ID
 + 63393502) inst log: Instrument status log
 + 64877078) error log: Error Log File
 + 64931682) ms scan events: MS Scan Events
 - 64932622) status log: Status log
    - 0) scan header: Generic Data Header
         0) n= 16: Number of entries
       - 4) entry[1]
            0) type= 4
            4) length= 0
          + 8) label= AGC:
       - 24) entry[2]
            0) type= 6
            4) length= 0
          + 8) label= Micro Scan Count:
       - 70) entry[3]
            0) type= 10
            4) length= 3
          + 8) label= Ion Injection Time (ms):
       - 130) entry[4]
            0) type= 1
            4) length= 0
          + 8) label= Scan Segment:
       - 168) entry[5]
            0) type= 1
            4) length= 0
          + 8) label= Scan Event:
       - 202) entry[6]
            0) type= 6
            4) length= 0
          + 8) label= Master Index:
       - 240) entry[7]
            0) type= 10
            4) length= 2
          + 8) label= Elapsed Scan Time (sec):
       - 300) entry[8]
            0) type= 10
            4) length= 2
          + 8) label= API Source CID Energy:
       - 356) entry[9]
            0) type= 12
            4) length= 6
          + 8) label= Resolution:
       - 390) entry[10]
            0) type= 3
            4) length= 0
          + 8) label= Average Scan by Inst:
       - 444) entry[11]
            0) type= 6
            4) length= 0
          + 8) label= Charge State:
       - 482) entry[12]
            0) type= 10
            4) length= 4
          + 8) label= Monoisotopic M/Z:
       - 528) entry[13]
            0) type= 11
            4) length= 3
          + 8) label= Conversion Parameter A:
       - 586) entry[14]
            0) type= 11
            4) length= 3
          + 8) label= Conversion Parameter B:
       - 644) entry[15]
            0) type= 11
            4) length= 3
          + 8) label= Conversion Parameter C:
       - 702) entry[16]
            0) type= 0
            4) length= 0
          + 8) label
    + 714) tune file header
    + 9444) tune file[1]
    + 10589) tune file[2]
    + 11734) scan list
    + 504574) trailer scan event
    + 1517638) scan headers
   66833580) trailer= "\0\0\0\0"
```

<blockquote>Note that the last descriptor in the instance of GenericDataHeader shown here (<code>entry[16]</code>) contains a null heading. Apparently, its purpose is to introduce a gap in parameter listings rendered in the GUI applications.<br>
</blockquote>

## GenericRecord ##

When the above header is applied to the stream of [ScanHeader](ScanHeader.md)'s in the same file, it reveals the following data (also shown within the entire file):

```
0) file:LTQ-FTsampleDataSet1.RAW: (63.7 MB)
 + 0) file header: The root file header (magic 1) (1356 bytes)
 + 1356) seq row: SeqRow -- Sequence Table Row (324 bytes)
 + 1680) CAS info: (28 bytes)
 + 1708) raw file info: (914 bytes)
 + 2622) method file: Embedded method file (19.9 KB)
 + 23050) spectrum 1 (21.7 KB)
   45258) unparsed spectra= "\1\0\0\0R\x0f\0\0I\3\0\0\0\0(...)": (60.4 MB)
 + 63385974) run header: (7408 bytes)
 + 63393382) inst id: Instrument ID (120 bytes)
 + 63393502) inst log: Instrument status log (1.4 MB)
 + 64877078) error log: Error Log File (53.3 KB)
 + 64931682) ms scan events: MS Scan Events (940 bytes)
 - 64932622) status log: Status log (1.8 MB)
    + 0) scan header: Generic Data Header (714 bytes)
    + 714) tune file header: Generic Data Header (8730 bytes)
    + 9444) tune file[1]: Tune File data (1145 bytes)
    + 10589) tune file[2]: Tune File data (1145 bytes)
    + 11734) scan list: A set of ShortScanHeader records (not to be confused with ScanHeader records)
    + 504574) trailer scan event: (989.3 KB)
    - 1517638) scan headers: A stream of ScanHeader records (374.3 KB)
       - 0) scan header[1]: ScanHeader 1 (56 bytes)
            0) AGC:= 1
            1) Micro Scan Count:= 1
          + 3) Ion Injection Time (ms):= 2000.0
            7) Scan Segment:= 1
            8) Scan Event:= 1
            9) Master Index:= 0
          + 11) Elapsed Scan Time (sec):= 2.24699997902
          + 15) API Source CID Energy:= 0.0
            19) Resolution:= "High"
            25) Average Scan by Inst:= 0
            26) Charge State:= 1
          + 28) Monoisotopic M/Z:= 445.109100342
          + 32) Conversion Parameter A:= 0.0
          + 40) Conversion Parameter B:= 107461.273438
          + 48) Conversion Parameter C:= -1492.03918457
         56) . . .= "\1\1\0\0\0\xfaD\1\1\0\0\xd9\xce\x0f(...)": records skipped for speed (374.2 KB)
       + 383264) scan header[6845]: ScanHeader 6845 (56 bytes)
   66833580) trailer= "\0\0\0\0" (4 bytes)
```