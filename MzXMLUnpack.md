# mzxml-unpack #

## SYNOPSIS ##

```
 mzxml-unpack [-range <from> .. <to>] <file>
```

## OPTIONS ##

`-r[ange] <from> .. <to>`

> extract only scans with numbers between `<from>` and `<to>`

  * **Note**: this option breaks the structure of the output file (the parts preceding and following the selected range of scans are not written). It is mainly useful in checking the XML syntax and the contents of a small number of scans. For extracting the scan data in tabular format, there is a more suitable tool, **[uf-scan](UnfinniganScan.md)**.

`-hex`

> add the hex encoding of decimals

> It is sometimes useful to see how the value written to an XML file by a decoder program was encoded in the raw file. This option instructs **zxml-unpack** to prepend all decimal values in binary arrays with their hexadecimal encoding. Even though the binary values in the XML interchange formats (mzXML and mzML) are encoded in the network order, **mzxml-unpack** shows the little-endian format (in case the value needs to be located in the raw file (Thermo raw files are little-endian).


## DESCRIPTION ##

**mzxml-unpack** will read the given input file and unpack the contents of **scan.peaks** element in mzXML or **binary** in mzML. Both formats use base64 encoding to save space; unpacking this encoding makes the data human-readable. It does not otherwise change the file structure (unless the _**-r**_ option is used), so in principle, it can be packed again.


## SEE ALSO ##

**[uf-scan](UnfinniganScan.md)**

**[uf-mzxml](UnfinniganMzXML.md)**

## EXAMPLES ##


```
 mzxml-unpack sample.mzXML > sample-unpacked.mzXML
```

```
 mzxml-unpack -hex sample.mzML > sample-unpacked.mzML
```