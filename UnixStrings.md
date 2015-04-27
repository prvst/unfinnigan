_**Note:**_ In OSX, there is a bastardised version of `strings` without the `-e` option. Instead, better alias `strings` to `/opt/local/bin/gstrings` installed from MacPorts.

Because most instances of text data in Finnigan files are encoded using the wide character format (16-bit), `strings` will not find them without the "l" encoding option:

```
strings -t x -e l examples/drugx_15.raw
```

This gives:

```
      2 Finnigan
     30 linda
     62 linda
     a0 linda
     d2 linda
    148 QC=10 pg/ml,IS=100 pg/ml
    5dc 27417_Sat_0504WD1_Plas_22
    634 5/5/96
    65c linda
    7a0 C:\LCQ\Data\mrw_27417\Sat_0504_WD1\27417_Sat_0504WD1_Plas_22.RAW
        . . .
```

The first thing you see will be the Finnigan signature in the header.

Some data, usually the items received directly from the instrument, are left untranslated (as asciiz) and so can be fished out with the default encoding:

```
strings -t x 100225.raw
  . . .
  cefad T=5e5 PvR=2e4 iWf
  cefbf DAC=0.99
  cefcb  LM=(445.12)
  cefd8 (445.12)
  ceffd Ufill=0.62 MCal=2d RF=2300V
  cf019 1ppm)
  cf01f nj445.1, 1/1, -2ppm)
  cf035 5s, -2ppm)
```

Don't forget that some of the file records containing strings may not be perfectly clean. While one part of the program may treat a memory area as an asciiz (zero-terminated) string, another may treat it as a fixed-size buffer. In this example, the last three items picked up by `string` are leftovers from earlier data that were overwritten by the final string, `Ufill=0.62 MCal=2d RF=2300V`. Because the earlier instances were longer, their tails still lingered in the buffer when it was written to the file. Don't think much of these things; they are garbage left from a reused communication packet or some such thing.