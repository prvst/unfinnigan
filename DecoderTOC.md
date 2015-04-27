# Finnigan data decoder #

**Note**: _The API has changed to accommodate the new 64-bit file pointers introduced in **v.64**, as well as the 32-bit pointers used in the older versions. [The tools written with the old API must be fixed](APIChanges.md)._

## Overview ##

The decoder is written in [perl](http://www.perl.org/) and it consists of a hierarchy of objects recursively instantiating themselves from the binary data in the input file. The object hierarchy closely follows the [Finnigan file structure](FileStructureTOC.md). The simplest objects use the [unpack](http://perldoc.perl.org/functions/unpack.html) function to read the data according to their object templates, and the more complex objects call other objects' constructors, passing them the file pointer they have acquired from the user program. Each elementary object advances the file pointer by the size of its template.

Because the size of some objects stored in the input file cannot be known beforehand, certain data streams can only be reached by reading through all the preceding data structures. Use [this diagram](FileLayoutOverview.md) as a guide to determine which structures must be consumed on the way to a certain type of data.

## Decoder API ##

This document is work in progress. While it is reasonably complete and accurate, it cannot possibly cover all code and all use cases. An alternative way to learn how to use the decoder is to look at [the Unfinnigan tools (uf-\*)](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/#Finnigan%2Fbin) and at the test suite [Finnigan.t](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/t/Finnigan.t), which covers a substantial part of the API.

### The basic use pattern ###

```
  seek INPUT, $object_address, 0
  $object = Finnigan::Object->decode(\*INPUT, $args);
```

where `Object` is a symbol for any of the decoder objects listed below.

Each Finnigan object has a constructor method named **decode()**, whose first argument is a filehandle positioned at the start of the object to be decoded. Some decoders require additional arguments passed as an array reference, for example, the version number argument in [Finnigan::ScanEventPreamble](FinniganScanEventPreamble.md). A single argument can be passed as it is, while multiple arguments can be passed as an array reference.

The constructor advances the handle to the start of the next object,
so seeking to the start of the object of interest is only necessary
when doing partial reads; in principle, the entire file can be read by
calling of object constructors in sequency. In reality, it is often
more efficient to seek ahead to fetch an index structure stored near
the end of the file, then go back to the data stream using the
pointers in the index.

The decoded data can be obtained by calling accessor methods on the object or by de-referencing the object reference (since all Finnigan objects are blessed hash references):

```
  $x = $object->element
```

or

```
  $x = $object->{element}
```

The accessor option is nicer, as it leads to less clutter in the code and leaves the possibility for additional processing of the data by the accessor routine, but it incurs a substantial performance penalty. For this reason, hash dereference is preferred in performance-critical code (inside loops).

### dump(%args) ###

All Finnigan objects are descendants of Finnigan::Decoder. One of the **Finnigan::Decoder** methods they inherit is **dump()**, which provides an easy way to explore the contents of decoded objects. The **dump()** method prints out the structure of the object it is called on in a few style, with relative or absolute addressess.

For example, many object dumps used in this wiki were created thus:
```
  $object->dump(style => 'wiki', relative => 1);
```

The **style** argument can have the values of `wiki`, `html` or none (meaning plain text). The **relative** argument is a boolean indicating whether to use the absolute or relative file addresses in the output. Relative in this case means "an offset within the object", while absolute is the seek address within the data file.

### read($stream, $template\_list, $arg) ###

This is the [Finnigan::Decoder](FinniganDecoder.md) constructor method. Some derived decoders use it internally, but it can also be used to decode trivial objects at a given location in a file without having to write a dedicated decoder.

For example, to read a 32-bit stream length, use:

```
  my $object = Finnigan::Decoder->read(\*INPUT, ['length' => ['V', 'UInt32']]);
```

The `$template_list` argument names all fields to decode (in this
case, just one: `length`), the template to use for each field (in
this example, `V`), and provides a human-readable symbol for the
template, which can be used in a number of ways; for example, when
inspecting the structures with the `dump` method.

This may seem like a kludgy way of reading four bytes, but the upshot is that the resulting `$object` will have the size, type and location information tucked into it, so it can be analysed and dumped in a way
consistent with other decoded objects. The advantage becomes even more apparent when the structure is more complex than a single scalar object.

The inherited `read` method provides the core functionality of all Finnigan decoders.

If only the value of the object is sought, then this even more kludgy
code can be used:

```
  my $stream_length = Finnigan::Decoder->read(\*INPUT, ['length' => ['V', 'UInt32']])->{data}->{length}->{value};
```

Doing it this way is nonetheless easier than writing several lines of code reading the data into a buffer, checking for the I/O errors and unpacking the value.


### stringify() ###

Another handy method defined in some of the Finnigan objects is **stringify()**.  It allows a concise representation of an object to be injected anywhere Perl expects a string. For example,

```
  $scan_event = Finnigan::ScanEvent->decode( \*INPUT, $header->version);
  say "$scan_event";
```

## Submodules ##

All submodules have built-in documentation (POD). To read the documentation for the installed modules, use **man** or **perldoc**, as in this example:

```
man Finnigan::ScanEvent
perldoc Finnigan::ScanEvent
```


**[Finnigan](FinniganNamespace.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan.pm)] -- the namespace object

**[Finnigan::AuditTag](FinniganAuditTag.md)**
[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/AuditTag.pm)] -- [AuditTag](AuditTag.md) decoder

**[Finnigan::ASInfo](FinniganASInfo.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ASInfo.pm)] -- [ASInfo](ASInfo.md) decoder

**[Finnigan::ASInfoPreamble](FinniganASInfoPreamble.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ASInfoPreamble.pm)] -- [ASInfoPreamble](ASInfoPreamble.md) decoder

**[Finnigan::Decoder](FinniganDecoder.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Decoder.pm)] -- the base class for all Finnigan decoders

**[Finnigan::Error](FinniganError.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Error.pm)] -- decoder for [Error](Error.md), an [ErrorLog](ErrorLog.md) entry

**[Finnigan::FileHeader](FinniganFileHeader.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/FileHeader.pm)] -- [FileHeader](FileHeader.md) decoder

**[Finnigan::FractionCollector](FinniganFractionCollector.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/FractionCollector.pm)] -- [FractionCollector](FractionCollector.md) decoder

**[Finnigan::GenericDataDescriptor](FinniganGenericDataDescriptor.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/GenericDataDescriptor.pm)] -- [GenericDataDescriptor](GenericDataDescriptor.md) decoder

**[Finnigan::GenericDataHeader](FinniganGenericDataHeader.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/GenericDataHeader.pm)] -- [GenericDataHeader](GenericDataHeader.md) decoder

**[Finnigan::GenericRecord](FinniganGenericRecord.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/GenericRecord.pm)] -- [GenericRecord](GenericRecord.md) decoder

**[Finnigan::InjectionData](FinniganInjectionData.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/InjectionData.pm)] -- [InjectionData](InjectionData.md) decoder

**[Finnigan::InstID](FinniganInstID.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/InstID.pm)] -- [InstID](InstID.md) (instrument identifiers) decoder

**[Finnigan::InstrumentLogRecord](FinniganInstrumentLogRecord.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/InstrumentLogRecord.pm)] -- [InstrumentLogRecord](InstrumentLogRecord.md) decoder

**[Finnigan::MethodFile](FinniganMethodFile.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/MethodFile.pm)] -- a decoder for [MethodFile](MethodFile.md), an OLE2 method file container

**[Finnigan::OLE2DIF](FinniganOLE2DIF.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2DIF.pm)] -- Double-Indirect FAT decoder

**[Finnigan::OLE2DirectoryEntry](FinniganOLE2DirectoryEntry.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2DirectoryEntry.pm)] -- OLE2 directory entry decoder

**[Finnigan::OLE2FAT](FinniganOLE2FAT.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2FAT.pm)] -- FAT sector decoder

**[Finnigan::OLE2File](FinniganOLE2File.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2File.pm)] -- Microsoft OLE2 (CDF) file decoder

**[Finnigan::OLE2Header](FinniganOLE2Header.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2Header.pm)] -- OLE2 header decoder

**[Finnigan::OLE2Property](FinniganOLE2Property.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/OLE2Property.pm)] -- OLE2 Property (index node) decoder

**[Finnigan::PacketHeader](FinniganPacketHeader.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/PacketHeader.pm)] -- PacketHeader decoder

**[Finnigan::Peak](FinniganPeak.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Peak.pm)] -- the decoder for a single peak in PeakList

**[Finnigan::Peaks](FinniganPeaks.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Peaks.pm)] -- PeakList decoder

**[Finnigan::Profile](FinniganProfile.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Profile.pm)] -- [Profile](Profile.md) decoder

**[Finnigan::ProfileChunk](FinniganProfileChunk.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/ProfileChunk.pm)] -- ProfileChunk decoder

**[Finnigan::RawFileInfo](FinniganRawFileInfo.md)** [[source](.md)] - the decoder for RawFileInfo, the primary index structure

**[Finnigan::RawFileInfoPreamble](FinniganRawFileInfoPreamble.md)** [[source](.md)] -- the binary data part in RawFileInfo

**[Finnigan::Reaction](FinniganReaction.md)** [[source](.md)] -- the decoder for [Reaction](Reaction.md) (precursor ion data)

**[Finnigan::RunHeader](FinniganRunHeader.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/RunHeader.pm)] -- RunHeader (the primary file index) decoder

**[Finnigan::SampleInfo](FinniganSampleInfo.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/SampleInfo.pm)] -- SampleInfo (the primary file index) decoder

**[Finnigan::Scan](FinniganScan.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Scan.pm)] -- compound and lightweight ScanDataPacket decoder

  * **[Finnigan::Scan::Profile](FinniganScanProfile.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Scan.pm)] -- [Profile](Profile.md) decoder

  * **[Finnigan::Scan::ProfileChunk](FinniganScanProfileChunk.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Scan.pm)] -- [ProfileChunk](ProfileChunk.md) decoder

  * **[Finnigan::Scan::CentroidList](FinniganScanCentroidList.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Scan.pm)] -- [PeakList](PeakList.md) decoder

**[Finnigan::ScanEvent](FinniganScanEvent.md)** [[source](.md)] -- the decoder for ScanEvent, the scan type descriptor

**[Finnigan::ScanEventPreamble](FinniganScanEventPreamble.md)** [[source](.md)] -- the decoder for ScanEventPreamble, the byte array component of ScanEvent

**[Finnigan::ScanEventTemplate](FinniganScanEventTemplate.md)** [[source](.md)] -- the decoder for ScanEventTemplate, the prototype scan descriptor

**[Finnigan::ScanIndexEntry](FinniganScanIndexEntry.md)** [[source](.md)] -- the decoder for ScanIndexEntry, a linked list element pointing to scan data

**[Finnigan::ScanParameters](FinniganScanParameters.md)** [[source](.md)] -- the decoder for ScanParameters, a GenericRecord containing various scan meta-data

**[Finnigan::SeqRow](FinniganSeqRow.md)** [[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/SeqRow.pm)] -- SeqRow (sequencer table row) decoder