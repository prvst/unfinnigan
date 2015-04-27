## Typical file layout ##

![http://wiki.unfinnigan.googlecode.com/hg/images/structure-overview.png](http://wiki.unfinnigan.googlecode.com/hg/images/structure-overview.png)

> [image source (svg)](http://wiki.unfinnigan.googlecode.com/hg/images/structure-overview.svg)

This diagram summarises the recent file layouts (versions 57 and up, and maybe some earlier ones as well, which I have not seen).

Most of the differences between file versions are concentrated at the stream record level. The overall structure remains the same.

Also, because I have not seen more than one file version recorded by a single instrument, it is possible that the differences are more related to the capabilities of instruments and recording modes selected in the software.

### Addressing data streams in the modern layouts ###

It looks like there is no way to reach the interesting data in these files without completely parsing the FileHeader, SeqRow and [ASInfo](ASInfo.md) structures. FileHeader and [ASInfo](ASInfo.md) could be skipped because they are fixed-size structures (1356 and 28 bytes, respectively), but SeqRow is a variable-size structure, whose length can only be determined by reading it all.

After that, RawFileInfo can be read, which contains the first two pointers into the data. It points to ScanData and to RunHeader, which in turn contains pointers to all data streams in the file.

Note that in the earlier file formats, RawFileInfo was preceded by RunHeader, so it did not contain the pointer to it (besause RunHeader could be reached at a static offset). Also, in the earlier formats, RunHeader did not contain stream pointers outside its SampleInfo component (it contains two now).

To read the InstrumentLog stream, it is necessary to consume every object up to the start of of the log header, because there is no direct reference to the header itself anywhere in the index structures. The only [InstrumentLog](InstrumentLog.md) reference points to the first InstrumentLogRecord.

### Instrument method data ###

One of the key differences between the modern layouts and the earlier file formats the embedded MethodFile based on the Microsoft Compound Binary File Format (OLE2). It stores a hierarchy of objects representing the method data for various instruments (pumps, detectors, &c.) used during the scan. In the earlier formats, these objects were more haphazardly arranged among the data streams.