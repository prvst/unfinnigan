## Microsoft Compound Binary File format ##

The recent versions of Finnigan raw format encapsulate the instrument method data in a Windows compound binary format known as CDF or OLE2. This format is designed to allow a hierarchical storage of unencoded binary structures. It is essentially a file system within a file, and it is implemented using Microsoft FAT technology, optimised to allow efficient storage of small objects.

The official documentation of the format is found [here](http://download.microsoft.com/download/0/b/e/0be8bdd7-e5e8-422a-abfd-4342ed7ad886/windowscompoundbinaryfileformatspecification.pdf). It is not bad; however, I falls a bit short of being a complete specification. For example, it explains everything about the addressing of sectors and mini-sectors, but it fails to say where the mini-sectors are to be found. I had to read [this somewhat cryptic document](http://user.cs.tu-berlin.de/~schwartz/pmh/guide.html) by Martin Schwartz to find out that the mini-sectors (a.k.a. _small block depot_) are stored in the data file of the root entry. Another helpful resource is this very compact (and also cryptic, coded assembly-language style) [python implementation by Fredrik Lundh](http://svn.effbot.org/public/tags/pil-1.1.3/PIL/OleFileIO.py). With all this information on hand, it was relatively easy to write a perl decoder ([Finnigan::OLE2File](FinniganOLE2File.md)), which is now part of the **Unfinnigan** project.

## Method file structure ##

In a Finnigan raw file, the Microsoft CDF file containing the method data is itself encapsulated in an adapter structure. Apparently, the purpose of this structure is to allow the method data to be extracted as a stand-alone file (to that end, it starts with a [file header](FileHeader.md)) and to provide a translation table between the instrument names and the CDF directory names. Additionally, the file header allows the structure to have its own date stamp and attribution.

### Structure diagram ###

![http://wiki.unfinnigan.googlecode.com/hg/images/method_file_structure.png](http://wiki.unfinnigan.googlecode.com/hg/images/method_file_structure.png)

### Name translation table ###

The names of the data files in the method container are not necessarily the same as the instrument names to which the correspond. One reason for this may be the need to preserve generality of those methods that apply to multiple interests. For example, the files acquired with LTQ-FT and with LTQ Orbitrap will have the analyser method files in the directory named `LTQ`.

Whatever the reason, there is always a translation table in the method immediately preceding the container file.

### Example ###
`uf-meth -drw sample5.raw`
| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 1356 | [FileHeader](FileHeader.md) | `header` | `V.63; 2008-04-30 14:12:52; LTQ Orbitrap` |
| 1356 | 4 | UInt32 | `file size` | `34304` |
| 1360 | 86 | PascalStringWin32 | `orig file name` | `C:\DOCUME~1\LTQ\LOCALS~1\Temp\MTH1F5E.tmp` |
| 1446 | 4 | UInt32 | `n` | `4` |
| 1450 | 346 | PascalStringWin32 | `name trans` | `LTQ Orbitrap MS, LTQ, Eksigent LC Channel 1, EksigentNanoLcCom_DLL, Eksigent LC Channel 2, EksigentNanoLc_Channel2, Eksigent NanoLC-AS1 Autosampler, NanoLC-AS1 Autosampler` |
| 1796 | 3712 | [OLE2File](FinniganOLE2File.md) | `container` | `Windows Compound Binary File: 13 nodes` |

## Container structure ##

The method files found inside the [Finnigan::OLE2File OLE2File] container are apparently organised in a 2-level structure: at the top level, there is a directory entry for each instrument, and each directory directory contains a few files; typically two of the files found there are named `Text` and `Data`. The `Text` file contains the information displayed (unprocessed) by Thermo tools; the `Data` file contains the method parameters that were used to control the run.

### Example ###

`uf-meth -l sample5.raw`

```
LTQ 
  Data (7512 bytes)
  Text (9946 bytes)
  Header (1396 bytes)
EksigentNanoLcCom_DLL 
  Data (2898 bytes)
  Text (1924 bytes)
NanoLC-AS1 Autosampler 
  Data (154 bytes)
EksigentNanoLc_Channel2 
  Data (3028 bytes)
  Text (2398 bytes)
```