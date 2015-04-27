## Decoding Finnigan raw files ##

This project has reached the stage at which it can deliver useful code. The file structure and the meaning of its most important elements, with the exception of the embedded method file, has been largely understood.

One of the Unfinnigan tools, [uf-mzxml](UnfinniganMzXML.md), can already replace readw where [mzXML](http://tools.proteomecenter.org/wiki/index.php?title=Formats:mzXML) is a suitable encoding. Unlike [readw](http://tools.proteomecenter.org/wiki/index.php?title=Software:ReAdW) and other tools that depend on the closed-source I/O library by Thermo, [uf-mzxml](UnfinniganMzXML.md) and other Unfinnigan tools read the data file directly and thus reduce the [confusion](http://www.mail-archive.com/spctools-discuss@googlegroups.com/msg01683.html) surrounding the provenance of important data elements.

Speed is another advantage gained by direct access to the data. The native Finnigan file format provides a more efficient storage than converted text-based formats.

### Supported versions ###

The Unfinnigan tools have been tested with the file versions **57**, **62**, **63** and **64**. The [Hachoir](http://bitbucket.org/haypo/hachoir/wiki/hachoir-core) parser, [finnigan.py](HachoirParser.md), can also read version **8** found among Xcalibur example files, but Hachoir can not do useful work; its purpose was to aid in the exploration of the file structure -- the role in which it has performed marvellously. Version 8 is probably only a historical curiosity, although some of its elements helped to unravel the structure of the present file formats.

If there is any interest in decoding early file versions, the information already available can be used to create decoder variants to support these versions. A variety of sample files for each version will be necessary to make that possible.

### News ###

I have received a few stripped-down samples of the new <b>v.64</b> Finnigan format. It seems to be essentially the same as <b>v.63</b>, with the only difference that the 32-bit seek addresses and offsets used in the earlier format are now replaced with the 64-bit ones. I have updated both the  [finnigan.py](HachoirParser.md) and the [Perl API](DecoderTOC.md) to work with the new format, but it may be too early to claim success, without further testing. If you would like to contribute a sample, please put it somewhere I can grab it.