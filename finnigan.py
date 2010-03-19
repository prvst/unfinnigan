"""
Thermo Finnigan raw data parser
"""

import sys
import struct
import unicodedata

from hachoir_parser import Parser
from hachoir_core.field import (
    Enum,
    ParserError,
    Bits,
    RawBits,
    Bytes,
    RawBytes,
    Int8,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    UInt64,
    Float32,
    Float64,
    TimestampWin64,
    String,
    CString,
    PaddingBytes,
    PascalString8,
    FieldSet
    )
from hachoir_parser.common.win32 import PascalStringWin32
from hachoir_core.endian import LITTLE_ENDIAN, BIG_ENDIAN

VERSION = []
ABBREVIATE_LISTS = True
VERBOSE_GENERIC_RECORDS = False

BOOL = {
    0: "False",
    1: "True"
}

ON_OFF = {
    0: "off",
    1: "on",
    2: "undefined",
}

DETECTOR = {
    0: "valid",
    1: "undefined",
};

ANALYZER = {
    0: "ITMS",
    1: "TQMS",
    2: "SQMS",
    3: "TOFMS",
    4: "FTMS",
    5: "Sector",
    6: "undefined"
}

POLARITY = {
    0: "negative",
    1: "positive",
    2: "undefined",
};

SCAN_MODE = {
    0: "centroid",
    1: "profile",
    2: "undefined",
}

SCAN_TYPE = {
    0: "Full",
    1: "Zoom",
    2: "SIM",
    3: "SRM",
    4: "CRM",
    5: "undefined",
    6: "Q1",
    7: "Q3",
}

MS_POWER = {
    0: "undefined",
    1: "MS1",
    2: "MS2",
    3: "MS3",
    4: "MS4",
    5: "MS5",
    6: "MS6",
    7: "MS7",
    8: "MS8",
}

IONIZATION = {
    0: "EI",
    1: "CI",
    2: "FABI",
    3: "ESI",
    4: "APCI",
    5: "NSI",
    6: "TSI",
    7: "FDI",
    8: "MALDI",
    9: "GDI",
    10: "undefined"
}

FILTER=''.join([(len(repr(chr(x)))==3) and chr(x) or '.' for x in range(256)])

def dump(src, length=8):
    result=[]
    for i in xrange(0, len(src), length):
       s = src[i:i+length]
       hexa = ' '.join(["%02X"%ord(x) for x in s])
       printable = s.translate(FILTER)
       result.append("%04X   %-*s   %s\n" % (i, length*3, hexa, printable))
    return ''.join(result)

class Finnigan(Parser):
    MAGIC = "\1\xa1"

    PARSER_TAGS = {
        "magic": ((MAGIC, 0),),
        "id": "finnigan",
        "category": "misc",    # "archive", "audio", "container", ...
        "file_ext": ("raw",),
        "mime": (u"application/xcalibur",),
        "min_size": 0x054C * 8,
        "description": "Raw data collected from a Thermo mass spectrometer",
    }

    endian = LITTLE_ENDIAN
    abs_addr = 0

    def __init__(self, stream, **args):
        Parser.__init__(self, stream, **args)
        VERSION.append(self["/file header/version"].value) # may need a stack of versions to parse embedded files

    def validate(self):
        if self.stream.readBytes(0, len(self.MAGIC)) != self.MAGIC:
            return "Unknon magic number"
        return True

    def createFields(self):
        yield FinniganHeader(self, "file header", "The root file header (magic 1)")
        if VERSION[-1] == 8: # OldLCQ
            # OnConvertOldLCQ -> 127044 (0x0001F044)
            yield RunHeader(self, "run header", "The run header with information about the number of scans")
            yield SeqRow(self, "seq row", "SeqRow -- Sequence Table Row")
            yield RawFileInfo(self, "raw file info", "The first index structure in the file")
            yield IcisStatusLog(self, "icis status log", "Interactive Chemical Information System (ICIS) log -- meaning unknown; can have 0 records")
            yield Instfile(self, "inst file", "Embedded instrument file")
            yield UInt32(self, "nsegs", "Number of scan segments -- possibly (a conjecture)")
            for index in range(1, self["nsegs"].value + 1): # this loop may actually include all of the following objects
                yield TuneData(self, "tune data", "TuneData")
            yield PeakData(self, "peak data", "Called peaks")
            yield ScanData(self, "scan data", "ScanData")

            nrecords = self["/run header/sample info/inst log length"].value
            for n in range(1, nrecords + 1):
                yield LogRecord(self, "log[%s]" % n, "LogRecord %s" % n)

        elif VERSION[-1] >= 57:
            yield SeqRow(self, "seq row", "SeqRow -- Sequence Table Row")
            yield CASInfo(self, "CAS info", "Autosampler data?")
            yield RawFileInfo(self, "raw file info", "Something called RawFileInfo -- the root pointer structure")
            yield MethodFile(self, "method file", "Embedded method file")

            data_addr = self["raw file info/preamble/data addr"].value

            if data_addr > self.current_size/8:
                yield RawBytes(self, "parse error", data_addr - self.current_size/8, "If you see this, it is likely that MethodInfo is missing something")

            run_header_addr = self["raw file info/preamble/run header addr"].value
            [first_scan_number] = struct.unpack("I", self.stream.readBytes((run_header_addr + 0x8)*8, 4))
            [last_scan_number] = struct.unpack("I", self.stream.readBytes((run_header_addr + 0xC)*8, 4))
            nscans = last_scan_number - first_scan_number + 1

            #for n in range(1, nscans + 1):
            for n in range(1, min(nscans, 33) + 1):
                yield Packet(self, "packet %s" % n)
                print >> sys.stderr, "\rread %s of %s packets ... " % (n, nscans),

            if run_header_addr > self.current_size/8:
                yield RawBytes(self, "unparsed packets", run_header_addr - self.current_size/8, "This is where the scand data packets are found")
            yield RunHeader(self, "run header", "The directory structure for the entire file")
            yield InstID(self, "inst id", "Instrument ID")
            yield InstrumentLog(self, "inst log", "Instrument status log")
            yield ErrorLog(self, "error log", "Error Log File")
            yield MSScanEvents(self, "ms scan events", "MS Scan Events")
            yield StatusLog(self, "status log", "Status log")
        else:
            exit("unknown file version: %s" % VERSION[-1])

        # Read rest of the file
        if self.current_size < self._size:
            yield self.seekBit(self._size, "trailer")


    def allFeatures(self):
        for feature in self:
            try:
                iter_exists = getattr(feature, "__iter__", None)
            except AttributeError:
                pass
            if iter_exists:
                for f in feature:
                    yield f
            else:
                yield self


    def visit(self, visitor):
        visitor.at(self)
        visitor.down()
        for feature in self:
            visitor.at(feature)
        visitor.up()


class Packet(FieldSet):
    def createFields(self):
        yield PacketHeader(self, "header")
        if self["header/profile size"].value:
            yield Profile(self, "profile", "Raw or filtered profile (depending on scan mode)")
        if self["header/peak list size"].value:
            yield PeakList(self, "peak list", "Peak centroids")
        if self["header/descriptor list size"].value:
            yield PeakDescriptorList(self, "peak descriptors");
        if self["header/size of unknown stream"].value:
            yield UnknownStream(self, "unknown stream")
        if self["header/size of unknown triplet stream"].value:
            yield UnknownTriplets(self, "unknown triplets")

class PacketHeader(FieldSet):
    def createFields(self):
        yield UInt32(self, "unknown long[1]")
        yield UInt32(self, "profile size", "Size of the profile object, in 4-byte words")
        yield UInt32(self, "peak list size", "Size of the peak list, in 4-byte words")
        yield UInt32(self, "layout", "This is believed to be the packet layout indicator")
        yield UInt32(self, "descriptor list size", "Size of the peak descriptor list in 4-byte words (co-incides with the number of peaks)")
        yield UInt32(self, "size of unknown stream", "Size of the unknown stream in 4-byte words")
        yield UInt32(self, "size of unknown triplet stream", "Size of the stream of unknown triplets in 4-byte words")
        yield UInt32(self, "unknown long[2]", "Seems to be zero everywhere")
        yield Float32(self, "low mz", "Scan low M/z; appears in filterLine in mzXML")
        yield Float32(self, "high mz", "Scan high M/z; appears in filterLine in mzXML")

class Profile(FieldSet):
    def createFields(self):
        yield Float64(self, "first bin value", "in the case of spectra, this will be the highest frequency")
        yield Float64(self, "bin step", "the amount each bin value differs from the previous one")
        yield UInt32(self, "peak count")
        yield UInt32(self, "nbins", "Number of bins in scan")

        for n in range(1, self["peak count"].value + 1):
            yield UInt32(self, "first bin[%s]" % n, "Starting bin number in peak")
            yield UInt32(self, "nbins[%s]" % n, "Peak width in bins")
            if self["../header/layout"].value > 0:
                # This may be a risky conjecture, but I must forge
                # ahead. These values only appear in calibrated
                # profiles, whose "layout" indicator (if that's what it is) is a non-zero number
                yield Float32(self, "unknown float[%s]" % n, "Does this have anything to do with lock mass/calibrtion?")
            for index in range(1, self["nbins[%s]" % n].value + 1):
                 yield Float32(self, "peak[%s][%s]" % (n, index))


class PeakList(FieldSet):
    def createFields(self):
        yield UInt32(self, "n")
        for n in range(1, self["n"].value + 1):
            yield Float32(self, "mz[%s]" % n)
            yield Float32(self, "signal[%s]" % n)

class PeakDescriptorList(FieldSet):
    def createFields(self):
        for n in range(1, self["../peak list/n"].value + 1):
            yield PeakDescriptor(self, "descriptor[%s]" % n)
            #yield Bytes(self, "descriptor[%s]" % n, 4)

class PeakDescriptor(FieldSet):
    def createFields(self):
        yield UInt16(self, "index")
        yield UInt8(self, "flags")
        yield UInt8(self, "charge")

class UnknownStream(FieldSet):
    def createFields(self):
        yield UInt32(self, "unknown long")
        # read one thing less because we've just read one
        for n in range(1, (self["../header/size of unknown stream"].value - 1) + 1):
            yield Float32(self, "unknown[%s]" % n)

class UnknownTriplets(FieldSet):
    def createFields(self):
        ntriplets = self["../header/size of unknown triplet stream"].value / 3
        for n in range(1, ntriplets + 1):
            yield Float32(self, "mz[%s]" % n)
            yield Float32(self, "unknown value[1][%s]" % n)
            yield Float32(self, "unknown value[2][%s]" % n)

class GenericRecord(FieldSet):
    def __init__(self, parent, header, name, description=None):
        FieldSet.__init__(self, parent, name, description)
        self.header = header
 
    def createFields(self):
        for item in self.header:
            if isinstance(item, GenericDataDescriptor):
                if item["type"].value:
                    if VERBOSE_GENERIC_RECORDS:
                        print >> sys.stderr, "matching " \
                        + item.ascii_label \
                        + " (" + str(item["type"].value) \
                        + ", " + str(item["length"].value) + ") ... ",

                    # c char
                    if item["type"].value == 0x1:
                        yield Int8(self, item.ascii_label,
                                    "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "signed byte (type 1): %s" % self[item.ascii_label].value

                    # bool (true/false)
                    elif item["type"].value == 0x2:
                        yield UInt8(self, item.ascii_label,
                                    "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "bool (type 2): %s" % self[item.ascii_label].value

                    # yes/no
                    elif item["type"].value == 0x3:
                        yield UInt8(self, item.ascii_label,
                                    "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "yes/no (type 3): %s" % self[item.ascii_label].value

                    # on/off
                    elif item["type"].value == 0x4:
                        yield UInt8(self, item.ascii_label,
                                    "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "on/off (type 4): %s" % self[item.ascii_label].value

                    # c unsigned char
                    elif item["type"].value == 0x5:
                        yield UInt8(self, item.ascii_label,
                                    "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "unsigned byte (type 5): %s" % self[item.ascii_label].value

                    # c short
                    elif item["type"].value == 0x6:
                        yield Int16(self, item.ascii_label,
                                     "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "short: %s" % self[item.ascii_label].value

                    # c unsigned short
                    elif item["type"].value == 0x7:
                        yield UInt16(self, item.ascii_label,
                                     "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "unsigned short: %s" % self[item.ascii_label].value

                    # c long
                    elif item["type"].value == 0x8:
                        yield Int32(self, item.ascii_label,
                                     "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "long: %s" % self[item.ascii_label].value

                    # c unsigned long
                    elif item["type"].value == 0x9:
                        yield UInt32(self, item.ascii_label,
                                     "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "unsigned long: %s" % self[item.ascii_label].value

                    # c float
                    elif item["type"].value == 0xA:
                        yield Float32(self, item.ascii_label,
                                      "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "float: %s" % self[item.ascii_label].value

                    # c double
                    elif item["type"].value == 0xB:
                        yield Float64(self, item.ascii_label,
                                      "(" + str(item["type"].value) + ", " + str(item["length"]) + ")")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "double: %s" % self[item.ascii_label].value

                    # asciiz string
                    elif item["type"].value == 0xC:
                        # yield String(self, item.ascii_label, item["length"].value,
                        #              "(" + str(item["type"].value) + ", " + str(item["length"]) + ")",
                        #              charset="ASCII", truncate="\0")
                        yield String(self, item.ascii_label, item["length"].value,
                                     "(" + str(item["type"].value) + ", " + str(item["length"]) + ")",
                                    truncate="\0")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "asciiz: %s" % self[item.ascii_label].value

                    # wide string, zero-terminated
                    elif item["type"].value == 0xD:
                        yield String(self, item.ascii_label, item["length"].value * 2, charset="UTF-16-LE", truncate="\0")
                        if VERBOSE_GENERIC_RECORDS:
                            print >> sys.stderr, "string: %s" % self[item.ascii_label].value

                    else:
                        exit( "unkown data type ("
                              + str(item["type"]) + " at %x" % (self.absolute_address/8) + ", " + str(item["length"].value) + "): "
                              + item.ascii_label + " in " + str(item) )


class FinniganHeader(FieldSet):
    static_size = 0x054C * 8
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Bytes(self, "magic", 2, r'File signature ("\1\xA1")')
        yield CString(self, "signature", "Finnigan signature: \"Finnigan\" (wide string)", charset="UTF-16-LE") #, strip="\0")
        yield UInt32(self, "unknown long[1]", "Unknown long; seems to be the same in all files")
        yield UInt32(self, "unknown long[2]", "Unknown long; seems to be the same in all files")
        yield UInt32(self, "unknown long[3]", "Unknown long; seems to be the same in all files")
        yield UInt32(self, "unknown long[4]", "Unknown long; seems to be the same in all files, except embedded ones, where it is 0")
        yield UInt32(self, "version", "File format version")

        yield AuditTag(self, "audit start", "Start Audit Tag")
        yield AuditTag(self, "audit end", "End Audit Tag")

        yield UInt32(self, "unknown long[5]", "Unknown long, file-specific")
        yield RawBytes(self, "unknown area", 60, "Unknown zero-padded area")
        yield String(self, "tag", 1028, charset="UTF-16-LE", truncate="\0")
        # Read rest of the header
        if self.current_size < self._size:
            yield self.seekBit(self._size, "trailer")

class ThermoFinniganHeader(FieldSet):
    # this may actually be an accidental leftover in the method
    # file. It was complete in two instances of V.62, but in one instance of
    # V.57, it was missing the magic number -- possibly overwritten?
    static_size = 0x0600 * 8
    endian = LITTLE_ENDIAN

    def createFields(self):
        if VERSION[-1] >= 62:
            yield RawBytes(self, "magic", 2, r'File signature ("\5\xA1")')
            yield CString(self, "signature", "Thermo Finnigan signature: \"Thermo Finnigan LTQ\" (wide string)", charset="UTF-16-LE")
            yield RawBytes(self, "unknown area", 24, "Unknown zero-padded area")
            yield UInt16(self, "unknown int[1]", "Unknown int")
            yield UInt16(self, "unknown int[2]", "Unknown int")
            yield UInt16(self, "unknown int[3]", "Unknown int")
            yield AuditTag(self, "audit start", "Start Audit Tag")
            yield AuditTag(self, "audit end", "End Audit Tag")
            yield UInt16(self, "unknown int[4]", "Unknown int")
            yield UInt16(self, "unknown int[5]", "Unknown int")
            yield UInt16(self, "unknown int[6]", "Unknown int")
        else:
            pass # this whole area may be a nonsense leftover even
                 # V.62, where it contains some reasonable objects
                 # Read rest of the header
        if self.current_size < self._size:
            yield self.seekBit(self._size, "trailer")

class AuditTag(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield TimestampWin64(self, "start", "Timestamp")
        yield String(self, "tag[1]", 50, charset="UTF-16-LE", truncate="\0")
        yield String(self, "tag[2]", 50, charset="UTF-16-LE", truncate="\0")
        yield UInt32(self, "unknown long", "It seems like in some cases it is used to hold a CRC-32 sum")

class RunHeader(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield SampleInfo(self, "sample info", "Besides holding file pointers, this structure identifies the sample and provides a comment area for it")
        if VERSION[-1] < 57:
            yield PascalStringWin32(self, "orig file name", "The original file name as seen on the instrument controller")
            yield PascalStringWin32(self, "file name[1]", "Unknown file name")
            yield PascalStringWin32(self, "file name[2]", "Unknown file name")
            yield PascalStringWin32(self, "file name[3]", "Unknown file name")
        else:
            for index in "123456":
                yield String(self, "file name[%s]" % index, 520, charset="UTF-16-LE", truncate="\0")

            yield Float64(self, "unknown double[1]")
            yield Float64(self, "unknown double[2]")

            for index in "789abcd":
                yield String(self, "file name[%s]" % index, 520, charset="UTF-16-LE", truncate="\0")

            yield UInt32(self, "scan trailer addr", "Absolute seek address of the TrailerScanEvent stream")
            yield UInt32(self, "scan params addr", "Absolute seek address of the ScanParameters (ScanHeader) stream")
            yield UInt32(self, "unknown length[1]", "I am guessing it is the length of TrailerScanEvent (although it has its own)")
            yield UInt32(self, "unknown length[2]", "I am guessing it is the length of the ScanParameters (ScanHeader) stream")
            yield UInt32(self, "nsegs", "Number of scan segments? -- fairly positive it is")
            yield UInt32(self, "unknown long[1]")
            yield UInt32(self, "unknown long[2]")
            yield UInt32(self, "own addr", "RunHeader's own address")
            for index in "34":
                yield UInt32(self, "unknown long[%s]" % index)


class SampleInfo(FieldSet):
    static_size = (0x079C - 0x054C) * 8  # 592 bytes
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "unknown long[1]")
        yield UInt32(self, "unknown long[2]")
        yield UInt32(self, "first scan number", "The number of the first scan in the file")
        yield UInt32(self, "last scan number", "The number of the last scan in the file")
        yield UInt32(self, "inst log length", "The number of instrument status samples logged")
        yield UInt32(self, "unknown long[3]")
        yield UInt32(self, "unknown long[4]")
        yield UInt32(self, "scan index addr", "Absolute seek address of ScanIndex (ScanIndexEntry stream)")
        yield UInt32(self, "data addr", "Absolute seek address of scan data")
        yield UInt32(self, "inst log addr", "Absolute seek address of the first StatusLogRecord in Instrument Status Log (past the StatusLog header)")
        yield UInt32(self, "error log addr", "Absolute seek address of ErrorLog")
        yield UInt32(self, "unknown long[5]")
        yield Float64(self, "max ion current", "The maximum total ion current measured in scans")
        yield Float64(self, "low mz", "Lower end of scan range")
        yield Float64(self, "high mz", "Upper end of scan range")
        yield Float64(self, "start time", "Retention time at first scan (see ScanIndex)")
        yield Float64(self, "end time", "Retention time at last scan (see ScanIndex)")
        yield RawBytes(self, "unknown area", 56, "this may be a space reserved for tags")
        yield String(self, "tag[1]", 88, charset="UTF-16-LE", truncate="\0")
        yield String(self, "tag[2]", 40, charset="UTF-16-LE", truncate="\0")
        yield String(self, "tag[3]", 320, charset="UTF-16-LE", truncate="\0")

class SeqRow(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield InjectionData(self, "injection", "Injection Parameters")
        for index in "ab":
            yield PascalStringWin32(self, "unknown text[%s]" % index, "Unknown Pascal string")
        yield PascalStringWin32(self, "id", "Sample ID")
        yield PascalStringWin32(self, "comment")
        yield PascalStringWin32(self, "user label[1]", "Label heading is found in RawFileInfo")
        yield PascalStringWin32(self, "user label[2]", "Label heading is found in RawFileInfo")
        yield PascalStringWin32(self, "user label[3]", "Label heading is found in RawFileInfo")
        yield PascalStringWin32(self, "user label[4]", "Label heading is found in RawFileInfo")
        yield PascalStringWin32(self, "user label[5]", "Label heading is found in RawFileInfo")
        yield PascalStringWin32(self, "inst method", "Instrument Method")
        yield PascalStringWin32(self, "proc method", "Processing Method")
        yield PascalStringWin32(self, "file name")
        yield PascalStringWin32(self, "path")

        if VERSION[-1] >= 57:
            yield PascalStringWin32(self, "vial")
            for index in "cd":
                yield PascalStringWin32(self, "unknown text[%s]" % index, "Unknown Pascal string")

            yield UInt32(self, "unknown long", "Unknown long in SeqRow")

            if VERSION[-1] == 57:
                pass
            elif VERSION[-1] >= 62:
                for index in "efghijklmnopqrs":
                    yield PascalStringWin32(self, "unknown text[%s]" % index, "Unknown Pascal string")
            else:
                exit("unknown file version: %s" % VERSION[-1])
            
 

class InjectionData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "unknown long[1]", "Unknown Long")
        yield UInt32(self, "n", "Row Number")
        yield UInt32(self, "unknown long[2]", "Unknown Long")
        yield String(self, "vial", 12, "Vial ID; assigned to InstConfig::MSSerialNum at the end of SeqRow parsing", charset="UTF-16-LE", truncate="\0")
        yield Float64(self, "inj volume", "Injection Volume (ul)")
        yield Float64(self, "weight", "Sample Weight")
        yield Float64(self, "volume", "Sample Volume (ul)")
        yield Float64(self, "istd amount", "Internal Standard Amount")
        yield Float64(self, "df", "Dilution Factor")


class CASInfo(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield CASInfoPreamble(self, "preamble", "CASInfo preamble")
        yield PascalStringWin32(self, "text", "Unknown text")

class CASInfoPreamble(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Int32(self, "unknown signed long[1]")
        yield Int32(self, "unknown signed long[2]")
        yield UInt32(self, "number of wells")
        yield UInt32(self, "unknown long[4]")
        yield UInt32(self, "unknown long[5]")
        yield UInt32(self, "unknown long[6]")


class RawFileInfo(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawFileInfoPreamble(self, "preamble", "RawFileInfo preamble, containing the address of RunHeader")
        yield PascalStringWin32(self, "label heading[1]", "User label heading; default: \"Study\"")
        yield PascalStringWin32(self, "label heading[2]", "User label heading; default: \"Client\"")
        yield PascalStringWin32(self, "label heading[3]", "User label heading; default: \"Laboratory\"")
        yield PascalStringWin32(self, "label heading[4]", "User label heading; default: \"Company\"")
        yield PascalStringWin32(self, "label heading[5]", "User label heading; default: \"Phone\"")
        yield PascalStringWin32(self, "unknown text")

class RawFileInfoPreamble(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "unknown long[1]")
        yield UInt16(self, "year")
        yield UInt16(self, "month")
        yield UInt16(self, "day of the week")
        yield UInt16(self, "day")
        yield UInt16(self, "hour")
        yield UInt16(self, "minute")
        yield UInt16(self, "second")
        yield UInt16(self, "millisecond")
        if VERSION[-1] >= 57:
            yield UInt32(self, "unknown long[2]")
            yield UInt32(self, "data addr", "Absolute address of scan data")
            for index in range(3, 6 + 1):
                yield UInt32(self, "unknown long[%s]" % index)
            yield UInt32(self, "run header addr", "Absolute address of RunHeader")
            yield RawBytes(self, "padding", 804 - 12 * 4, "padding?")

class MethodFile(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield FinniganHeader(self, "finnigan header", "Method file header (magic 1)")
        yield MethodInfo(self, "method info", "Method file description")
        yield RawBytes(
            self,
            "method data",
            self["method info/bytes to eof"].value,
            "Method file data"
            )
        # This probably was just the end of the buffer with random junk left over from earlier use
        # yield ThermoFinniganHeader(self, "thermo header", "A version of the Finnigan header (magic 5) -- purpose unknown)")

class MethodInfo(FieldSet):
     endian = LITTLE_ENDIAN

     def createFields(self):
         yield UInt32(self, "bytes to eof", "Method data size = file length - header size - method info size")
         yield PascalStringWin32(self, "file name", "Method file name")
         yield UInt32(self, "n", "the number of tag pairs")
         for index in range(1, self["n"].value + 1):
             yield PascalStringWin32(self, "tag[%s].a" % index, "Unknown tag")
             yield PascalStringWin32(self, "tag[%s].b" % index, "Unknown tag")


class IcisStatusLog(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
         yield UInt32(self, "n", "Number of IcisStatusLog records")
        

class InstID(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 8)
        yield UInt32(self, "unknown long[1]")
        for index in range(1, 2 + 1):
            yield PascalStringWin32(self, "model[%s]" % index, "Why two model tags?")
        yield PascalStringWin32(self, "serial number")
        yield PascalStringWin32(self, "software version")
        for index in range(1, 4 + 1):
            yield PascalStringWin32(self, "tag[%s]" % index, "Some text")


class Instfile(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield FinniganHeader(self, "header", "Instrument file header")
        yield InstConfig(self, "inst config", "Instrument Configuration")
        yield RunInfo(self, "run info", "Run Info")
        yield ColumnInfo(self, "column info", "Column Info")
        for index in "1234":
            yield PascalStringWin32(self, "unknown text[%s]" % index, "Unknown Pascal string")
        yield InletMethods(self, "inlet methods", "Inlet Methods")
        yield MSMethod(self, "ms method", "MS Method")
        yield RealTimeSpec(self, "real time spec", "RealTimeSpec")
        yield RealTimeChro(self, "real time chro", "RealTimeChro")
        yield AuditTrail(self, "audit trail", "AuditTrail")

class InstConfig(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 28, "Instrument Configuration preamble")
        yield PascalStringWin32(self, "ion source", "Unknown Pascal string")
        yield PascalStringWin32(self, "analyzer", "Unknown Pascal string")
        for index in "123456789abcdefgh":
            yield PascalStringWin32(self, "unknown text[%s]" % index, "Unknown Pascal string")
            
class InstrumentLog(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield GenericDataHeader(self, "header", "Generic Data Header")

        nrecords = self["/run header/sample info/inst log length"].value
        if ABBREVIATE_LISTS and nrecords > 100:
            yield StatusLogRecord(self, self["header"], "log[1]", "LogRecord 1")
            yield StatusLogRecord(self, self["header"], "log[2]", "LogRecord 1")
            record_sz = self["log[1]"].size/8
            yield RawBytes(self, ". . .", (nrecords - 3) * record_sz, "records skipped for speed")
            yield StatusLogRecord(self, self["header"], "log[%s]" % nrecords, "LogRecord %s" % nrecords)
        else:
            for n in range(1, nrecords + 1):
                yield StatusLogRecord(self, self["header"], "log[%s]" % n, "LogRecord %s" % n)
                print >> sys.stderr, "\rread %s of %s instrument log records ... " % (n, nrecords),
            print >> sys.stderr, "done"

class StatusLogRecord(GenericRecord):
    endian = LITTLE_ENDIAN

    def createFields(self):
         yield Float32(self, 'time', "log timestamp")
         for item in GenericRecord.createFields(self):
             yield item

class ErrorLog(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "n", "The number of errors logged")
        nrecords = self["n"].value
        for n in range(1, nrecords + 1):
            yield ErrorLogRecord(self, "error[%s]" % n, "ErrorRecord")

class ErrorLogRecord(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float32(self, "time", "Retention time")
        yield PascalStringWin32(self, "message", "Error Message")

class RunInfo(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "unknown double[1]", "Parameter 1")
        yield Float64(self, "unknown double[2]", "Parameter 2")
        yield Float64(self, "unknown double[3]", "Parameter 3")

class ColumnInfo(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "unknown double[1]", "Parameter 1")
        yield Float64(self, "unknown double[2]", "Parameter 2")
        yield PascalStringWin32(self, "unknown text", "Unknown Pascal string")

class InletMethods(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield GCMethod(self, "gc method", "GC Method")
        yield LCMethod(self, "lc method", "LC Method")
        yield Autosampler(self, "Autosampler", "Autosampler")
        yield Probe(self, "Probe", "Probe")
        yield RawBytes(self, "unknown data[1]", 24, "Unknown data")
        # the following is read as a group
        for index in "1234":
            yield Float64(self, "unknown double[%s]" % index, "Unknown parameter")
        for index in "1234":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class GCMethod(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 48, "GC Method preamble")
        for index in "12345678":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class LCMethod(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "123456":
            yield Float64(self, "unknown double[%s]" % index, "Parameter %s" % index)
        yield RawBytes(self, "unknown data", 32, "Unknown data")
        yield UInt32(self, "ntables", "Number of LC tables")
        for index in range(1, self["ntables"].value + 1):
            yield LCTable(self, "lc table[%s]" % index, "LC Table")
        yield UInt32(self, "unknown long[1]", "Unknown long")
        yield UInt32(self, "unknown long[2]", "Unknown long")

class LCTable(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "preamble", 24, "LC Table preamble")
        yield RawBytes(self, "unknown data", 4, "Unknown data")
        for index in "1234":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class Autosampler(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "12":
            yield Float64(self, "unknown double[%s]" % index, "Parameter %s" % index)
        yield RawBytes(self, "unknown data", 56, "Autosampler data")

class Probe(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data[1]", 8, "Probe data")
        yield RawBytes(self, "unknown data[2]", 4, "Probe data")


class MSMethod(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data[1]", 4, "Unknown data")
        yield DisplayOptions(self, "display options", "Display Options")
        yield NonITCL(self, "non itcl", "NonITCL")

class DisplayOptions(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "12":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")
        yield Float64(self, "unknown double[1]", "Unknown prameter")
        for index in "34":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class NonITCL(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        # these items are read as a group
        for index in "123":
            yield Float64(self, "unknown double[%s]" % index, "Parameter %s" % index)
        yield RawBytes(self, "unknown data", 24, "NonITCL data")
        for index in "45":
            yield Float64(self, "unknown double[%s]" % index, "Parameter %s" % index)

        # and this is a separate group
        for index in "123":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

        yield MSSegment(self, "ms segment", "MS Segment")

class MSSegment(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        # the following two things are read as a group
        yield Float64(self, "unknown double", "Unknown parameter")
        yield RawBytes(self, "unknown data", 8, "Unknown data")

        # the reast are each read in its own transaction
        yield UInt32(self, "n", "Number of scan events")
        for index in range(1, self["n"].value + 1):
            yield MSScanEvent(self, "ms scan event[%s]" % index, "MS ScanEvent")
        yield PascalStringWin32(self, "file name", "Unknown file name")

class MSScanEvents(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "nsegs", "The number of scan segments")
        for index in range(1, self["nsegs"].value + 1):
            yield ArrMSScanEvents(self, "events[%s]" % index, "Scan Events in Segment %s" % index)

class ArrMSScanEvents(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "n", "Number of scan events")
        for index in range(1, self["n"].value + 1):
            yield MSScanEvent(self, "ms scan event[%s]" % index, "MS ScanEvent")

class MSScanEvent(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield MSScanEventPreamble(self, "preabmle", "MS Scan Event preamble")
        if VERSION[-1] < 57:
            yield MSDependentData(self, "ms dependent data", "MS Dependent Data")
            yield UInt32(self, "unknown long[1]", "Unknown long")
            yield MSReaction(self, "ms reaction", "MS Reaction")
            yield UInt32(self, "unknown long[2]", "Unknown long")
            yield FractionCollector(self, "fraction collector", "Fraction Collector")
        elif VERSION[-1] <= 62:
            yield UInt32(self, "unknown long[1]", "Unknown long (or two shorts)")
            yield UInt32(self, "unknown long[2]", "Unknown long")
            yield FractionCollector(self, "fraction collector", "Fraction Collector")
            yield UInt32(self, "unknown long[3]", "Unknown long")
            yield UInt32(self, "unknown long[4]", "Unknown long")
            yield UInt32(self, "unknown long[5]", "Unknown long")
        else: # 63
            yield UInt32(self, "unknown long[1]", "Unknown long (or two shorts)")
            yield UInt32(self, "unknown long[2]", "Unknown long")
            yield UInt32(self, "unknown long[3]", "Unknown long")
            yield UInt32(self, "unknown long[4]", "Unknown long")
            yield FractionCollector(self, "fraction collector", "Fraction Collector")
            yield UInt32(self, "unknown long[5]", "Unknown long")
            yield UInt32(self, "unknown long[6]", "Unknown long")
            yield UInt32(self, "unknown long[7]", "Unknown long")


class MSScanEventPreamble(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        if VERSION[-1] < 57:
            for index in range(1, 7):
                yield UInt32(self, "unknown long[%s]" % index, "Unknown long")
            for index in "123":
                yield Float64(self, "unknown double[%s]" % index, "Parameter %s" % index)
        elif VERSION[-1] == 57:
            yield RawBytes(self, "unknown data", 80, "MS Scan Event preamble")
        else:
            yield RawBytes(self, "unknown data", 120, "MS Scan Event preamble")

class ScanEventPreamble(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt8(self, "unknown byte[1]")
        yield UInt8(self, "unknown byte[2]")
        yield Enum(UInt8(self, "corona"), ON_OFF)
        yield Enum(UInt8(self, "detector"), DETECTOR)
        yield Enum(UInt8(self, "polarity"), POLARITY)
        yield Enum(UInt8(self, "scan mode"), SCAN_MODE)
        yield Enum(UInt8(self, "ms power"), MS_POWER)
        yield Enum(UInt8(self, "scan type"), SCAN_TYPE)
        yield UInt8(self, "unknown byte[3]")
        yield UInt8(self, "unknown byte[4]")
        yield Enum(UInt8(self, "dependent"), BOOL)
        yield Enum(UInt8(self, "ionization"), IONIZATION)
        yield RawBytes(self, "unknown data[1]", 20)
        yield Enum(UInt8(self, "wideband"), ON_OFF)
        yield RawBytes(self, "unknown data[2]", 7)
        yield Enum(UInt8(self, "analyzer"), ANALYZER)

        if VERSION[-1] <= 57:
            yield RawBytes(self, "unknown data", 39, "Scan Event preamble")
        elif VERSION[-1] <= 62:
            yield RawBytes(self, "unknown data", 79, "Scan Event preamble")
        else:
            yield RawBytes(self, "unknown data", 87, "Scan Event preamble")

class MSDependentData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "unknown long[1]", "Unknown long")
        yield UInt32(self, "unknown long[2]", "Unknown long")
        yield Float64(self, "unknown double", "Unknown parameter")

class MSReaction(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "123":
            yield Float64(self, "unknown double[%s]" % index, "Parameter %s" % index)

class Reaction(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "precursor mz")
        yield Float64(self, "unknown double", "seems to be consistently set to 1")
        yield Float64(self, "energy")
        yield UInt32(self, "unknown long[1]", "Unknown long")
        yield UInt32(self, "unknown long[2]", "Unknown long")

class FractionCollector(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "low mz")
        yield Float64(self, "high mz")


class TrailerScanEvent(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "n", "Number of trailer events")
        nrecords = self["n"].value
        # cannot only show the first few records because they are of
        # variable size and the last record's position will not be
        # known without reading them all
        if 0: # and ABBREVIATE_LISTS and nrecords > 100:
            ## this is likely to break the following items because the
            ## size to skip depends on the file!
            for n in range(1, 33+1):
                yield ScanEvent(self, "scan event[%s]" % n, "Scan Event")
            yield RawBytes(self, ". . .", 3634072 - 2*212 - 4, "records skipped for speed")
        else:
            for index in range(1, nrecords + 1):
                yield ScanEvent(self, "scan event[%s]" % index, "ScanEvent")
                print >> sys.stderr, "\rread %s of %s of trailer scan events ... " % (index, nrecords),
            print >> sys.stderr, "done"


class ScanEvent(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield ScanEventPreamble(self, "preabmle", "MS Scan Event preamble")
        yield UInt32(self, "type", "Indicates event type (Reaction == 1)")
        if self["type"].value == 0:
            yield UInt32(self, "unknown long[1]", "Unknown long")
            yield FractionCollector(self, "fraction collector", "Fraction Collector")
            yield UInt32(self, "nparam", "The number of double-precision parameters following this")
            for index in range(1, self["nparam"].value + 1):
                key = "unknown double[%s]" % index
                label = "Unknown double";
                if (self["nparam"].value == 4): # LTQ-FT
                    if (index == 2):
                        label = "may be Conversion Parameter A"
                    elif (index == 3):
                        key = "param b"
                        label = "Conversion Parameter B"
                    elif(index == 4):
                        key = "param c"
                        label = "Conversion Parameter C"
                else:
                    if (index == 2):
                        label = "may be Conversion Parameter I"
                    elif (index == 3):
                        label = "may be Conversion Parameter A"
                    elif (index == 4):
                        key = "param b"
                        label = "Conversion Parameter B"
                    elif(index == 5):
                        key = "param c"
                        label = "Conversion Parameter C"
                    elif(index == 6):
                        key = "param d"
                        label = "Conversion Parameter D"
                    elif(index == 7):
                        key = "param e"
                        label = "Conversion Parameter E"
                yield Float64(self, key, label)
            for index in "23":
                yield UInt32(self, "unknown long[%s]" % index, "Unknown long")
        elif self["type"].value == 1:
            yield Reaction(self, "reaction", "Reaction")
            yield UInt32(self, "unknown long[1]", "Unknown long")
            yield FractionCollector(self, "fraction collector", "Fraction Collector")
            for index in "234":
                yield UInt32(self, "unknown long[%s]" % index, "Unknown long")
        else:
            exit( "unknown event type (" + str(self["type"]) + " at %x" % (self.absolute_address/8) + ")")



class StatusLog(FieldSet):  # was: StatusLogHeader (why?)
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield GenericDataHeader(self, "scan header", "Generic Data Header")
        if self.current_size < self._size:
            yield self.seekBit(self._size, "trailer")
        yield GenericDataHeader(self, "tune file header", "Generic Data Header")
        nsegs = self["/run header/nsegs"].value # this is a conjecture
        for n in range(1, nsegs + 1):
            yield TuneFile(self, self["tune file header"], "tune file[%s]" % n, "Tune File data")
        yield ScanIndex(self, "scan index", "A set of ScanIndexEntry records")
        yield TrailerScanEvent(self, "trailer scan event", "Something called TrailerScanEvent")
        yield ScanHeaderFile(self, "scan headers", "A stream of ScanHeader records")


class TuneFile(GenericRecord):
    endian = LITTLE_ENDIAN

    def createFields(self):
         for item in GenericRecord.createFields(self):
             yield item

class ScanIndex(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        info = self["/run header/sample info"]
        nrecords = info["last scan number"].value - info["first scan number"].value + 1
        if 0 and ABBREVIATE_LISTS and nrecords > 100:
            yield ScanIndexEntry(self, "scan header[1]", "ScanIndexEntry 1")
            yield ScanIndexEntry(self, "scan header[2]", "ScanIndexEntry 2")
            record_sz = self["scan header[1]"].size/8  # must read the first one to know the size
            yield RawBytes(self, ". . .", (nrecords - 3) * record_sz, "records skipped for speed")
            yield ScanIndexEntry(self, "scan header[%s]" % nrecords, "ScanIndexEntry %s" % nrecords)
        else:
            for n in range(1, nrecords + 1):
                yield ScanIndexEntry(self, "log[%s]" % n, "ScanIndexEntry %s" % n)
                print >> sys.stderr, "\rread %s of %s index entries ... " % (n, nrecords),
            print >> sys.stderr, "done"

class ScanHeaderFile(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        info = self["/run header/sample info"]
        nrecords = info["last scan number"].value - info["first scan number"].value + 1
        if ABBREVIATE_LISTS and nrecords > 100:
            yield ScanHeader(self, self["../scan header"], "scan header[1]", "ScanHeader 1")
            yield ScanHeader(self, self["../scan header"], "scan header[2]", "ScanHeader 2")
            record_sz = self["scan header[1]"].size/8  # must read the first one to know the size
            yield RawBytes(self, ". . .", (nrecords - 3) * record_sz, "records skipped for speed")
            yield ScanHeader(self, self["../scan header"], "scan header[%s]" % nrecords, "ScanHeader %s" % nrecords)
        else:
            for n in range(1, nrecords + 1):
                yield ScanHeader(self, self["../scan header"], "log[%s]" % n, "ScanHeader %s" % n)
                print >> sys.stderr, "\rread %s of %s scan headers ... " % (n, nrecords),
            print >> sys.stderr, "done"


class ScanHeader(GenericRecord):
    endian = LITTLE_ENDIAN

    def createFields(self):
         for item in GenericRecord.createFields(self):
             yield item

class GenericDataHeader(FieldSet):
    endian = LITTLE_ENDIAN
    keys = {}

    def createFields(self):
        yield UInt32(self, "n", "Number of entries")
        group = None
        for index in range(1, self["n"].value + 1):
            key = "entry[%s]" % index
            yield GenericDataDescriptor(self, key)

            old_label = self[key].ascii_label
            if self[key]["type"].value:
                if old_label:
                    if group:
                        label = group + "|" + old_label
                    else:
                        label = old_label
                    if self.keys.has_key(label):
                        if group:
                            label = self[key].ascii_label = group + "|" + old_label + ' [bis]'
                        else:
                            label = self[key].ascii_label = old_label + ' [bis]'
                    else:
                        self[key].ascii_label = label
                    self.keys[label] = 1
            else:
                if self[key].ascii_label == "None":
                    pass
                else:
                    group = old_label


class GenericDataDescriptor(FieldSet):
    endian = LITTLE_ENDIAN
    ascii_label = None

    def createFields(self):
        yield UInt32(self, "type", "Finnigan data type")
        yield UInt32(self, "length", "object length (where it varies)")
        yield PascalStringWin32(self, "label", "Descriptor label", charset="UTF-16-LE")
        if self["label"].value:
            self.ascii_label = unicodedata.normalize('NFKD', self["label"].value).encode('ascii','ignore')
            self.ascii_label = self.ascii_label.replace("/", "<sl>")

class RealTimeSpec(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 12, "Real Time Spec preamble")
        for index in range(1, 4):
            yield AxisParm(self, "axis parm[%s]" % index, "AxisParm")
        yield Filter(self, "filter", "Filter")
        yield DisplayOptions(self, "display options", "Display Options")
        yield RTSpecColor(self, "rt spec color", "RTSpecColor")
        yield RTSpecLabelV1(self, "rt spec label[1]", "RTSpecLabelV1")
        yield RTSpecOther(self, "rt spec other", "RTSpecOther")
        yield RTSpecLabelV2(self, "rt spec label[2]", "RTSpecLabelV2")

class AxisParm(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "param[1]", "Parameter 1")
        yield Float64(self, "param[2]", "Parameter 2")
        yield PascalStringWin32(self, "label", "Axis label")

class Filter(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "1234567":
            yield UInt32(self, "unknown list[%s]" % index, "Unknown list element")
        for index in "12":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class RTSpecColor(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 20, "Real Time Spec color data")

class RTSpecLabelV1(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "12":
            for index2 in "12":
                yield UInt32(self, "unknown long[%s,%s]" % (index, index2), "Unknown long (may be a union member in place of double -- see RTSpecLabelV2)")
        yield RawBytes(self, "unknown data", 8, "Real Time Spec label data")
        yield Float64(self, "unknown double[3]", "Parameter 3")
        for index in "12":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class RTSpecLabelV2(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "12":
            yield Float64(self, "unknown double[%s]" % index, "Unknown double (may be a union member in place of long -- see RTSpecLabelV1)")
        yield RawBytes(self, "unknown data", 8, "Real Time Spec label data")
        yield Float64(self, "unknown double[3]", "Parameter 3")
        for index in "12":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class RTSpecOther(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 64, "Real Time Spec other data")


class RealTimeChro(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in "12":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")
        for index in range(1, 3):
            yield AxisParm(self, "axis parm[%s]" % index, "AxisParm")
        yield DisplayOptions(self, "display options", "Display Options")
        yield RTChroLabel(self, "rt chro label[1]", "RTChroLabel")
        yield RawBytes(self, "falcon event[1]", 32, "FalconEvent")
        yield RawBytes(self, "falcon event[2]", 32, "FalconEvent")
        yield UInt32(self, "n chro trace", "The number of ChroTrace objects")
        for index in range(1, self["n chro trace"].value + 1):
            yield ChroTrace(self, "chro trace[%s]" % index, "ChroTrace")

class RTChroLabel(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown data", 48, "Real Time Chro label data")

class ChroTrace(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "preamble", 40, "ChroTrace preamble")
        yield UInt32(self, "n frac", "The number of FractionCollector objects")
        for index in range(1, self["n frac"].value + 1):
            yield FractionCollector(self, "fraction collector[%s]" % index, "FractionCollector")
        yield Filter(self, "filter", "Filter")


class AuditTrail(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "n audit data", "The number of AuditData objects")
        for index in range(1, self["n audit data"].value + 1):
            yield AuditData(self, "audit data[%s]" % index, "AuditData")

class AuditData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield AuditTag(self, "audit tag", "Audit Tag")
        yield PascalStringWin32(self, "unkntown text", "Audit text")


class TuneData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield TuneDataHeader(self, "header", "TuneData header")
        for index in range(1, 13+1): # Where does 13 come from? Must
                                     # be a sum of the numbers in the
                                     # header (10 + 3)?
            yield FractionCollector(self, "fraction collector[%s]" % index, "Fraction Collector")
            # There are also 13 SlopeInt's read from the same
            # file. The number must have been known earlier, because
            # the 13 SlopeInt's are created before TuneDataHeader is read.

        yield UInt32(self, "n", "The number of Doubles read")
        for index in range(1, self["n"].value + 1):
            yield Float64(self, "double[%s]" % index, "Unknown value")

class TuneDataHeader(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "capillary_temp", "Capillary Temp (C)")
        yield Float64(self, "apci vaporizer temp", "APCI Vaporizer Temp (C)")
        yield Float64(self, "source voltage", "Source Voltage (kV)")
        yield Float64(self, "source current", "Source Current (uA)")
        yield Float64(self, "sheath gas flow", "Sheath Gas Flow ()")
        yield Float64(self, "aux has flow", "Aux Gas Flow ()")
        yield Float64(self, "capillary voltage", "Capillary Voltage (V)")
        yield Float64(self, "octapole rf amp", "Octapole RF Amplifier (Vp-p)")
        yield Float64(self, "octapole1 offset", "Octapole 1 Offset (V)")
        yield Float64(self, "octapole2 offset", "Octapole 2 Offset (V)")
        yield Float64(self, "i8p lens voltage", "InterOctapole Lens Voltage (V)")
        yield Float64(self, "trap dc offset", "Trap DC Offset Voltage (V)")
        yield Float64(self, "multiplier voltage", "Multiplier Voltage (V)")
        yield Float64(self, "tube lens offset", "Tube Lens Offset (V)")
        yield Float64(self, "unknown double", "Unknown double")

        yield RawBytes(self, "unkonwn data", 32, "Unknown data; Data Type, Source Type and Polarity may be hiding here")

        yield UInt32(self, "zoom micro scans", "Zoom Micro Scans")
        yield UInt32(self, "full micro scans", "Full Micro Scans")
        yield UInt32(self, "sim micro scans", "SIM Micro Scans")
        yield UInt32(self, "msn micro scans", "MSn Micro Scans")

        yield Float64(self, "zoom agc target", "Zoom AGC Target")
        yield Float64(self, "full agc target", "Full AGC Target")
        yield Float64(self, "sim agc target", "SIM AGC Target")
        yield Float64(self, "msn agc target", "MSN AGC Target")
        yield Float64(self, "maximum ion time", "Maximum Ion Time (ms)")
        yield Float64(self, "ion time", "Ion Time (ms)")

        for index in "12":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")

class PeakData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        info = self["/run header/sample info"]
        data_size =  info["scan index addr"].value - info["data addr"].value
        nrecords = data_size/8
        for index in range(1, nrecords + 1):
            yield UInt32(self, "abundance[%s]" % index)
            yield UInt16(self, "mz_whole[%s]" % index, "Whole part of M/z")
            yield UInt16(self, "mz_frac[%s]" % index, "Fractional part of M/z")


class ScanData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        info = self["/run header/sample info"]
        nscans = info["last scan number"].value - info["first scan number"].value + 1
        for n in range(1, nscans + 1):
            yield OldLCQScan(self, "scan[%s]" % n, "OldLCQScan %s" % n)

class OldLCQScan(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "total ion current", "The total ion current in this scan")
        yield Float32(self, "scan low", "Scan low m/z")
        yield Float32(self, "scan high", "Scan high m/z")
        yield UInt32(self, "n", "Scan number")
        yield UInt32(self, "unknown long[1]", "Unknown long")
        yield UInt32(self, "start time", "Retention time (in 100 us) at the start of the scan")
        yield UInt32(self, "end time", "Retention time (in 100 us) at the end of the scan")
        yield UInt32(self, "base peak intensity", "Base peak intensity. It often has the rounded value of \"total ion current\"")
        yield Float32(self, "base peak mz", "Base peak m/z")
        yield Float32(self, "injection time", "Ion Injection Time (ms)")
        yield RawBytes(self, "unknown bits low", 3, "This value seems to be the same in all scans")
        yield RawBytes(self, "unknown bits high", 1, "This value alternates between even/odd scan numbers")
        yield UInt32(self, "unknown long[2]", "Unknown long; seems to be the same in all scans")
        yield UInt32(self, "unknown long[3]", "Unknown long; seems to be the same in all scans")
        yield UInt32(self, "unknown long[4]", "Unknown long; seems to be the same in all scans")
        for index in "1234":
            yield Float32(self, "unknown float[%s]" % index, "Unknown float")
        yield UInt32(self, "unknown long[5]", "Unknown long; seems to be the same in all scans")
        yield Float32(self, "elapsed time", "Elapsed Scan Time (sec)")
        yield UInt32(self, "ms level", "MS level(?)")
        yield Float32(self, "precursor mz", "Precursor m/z")
        yield RawBytes(self, "unknown data[1]", 36, "Unknown Data")
        yield Float32(self, "cid energy", "CID Energy (?)")
        yield RawBytes(self, "unknown data[2]", 36, "Unknown Data")
        yield Float32(self, "unknown float[5]", "Unknown float")
        yield Float32(self, "unknown float[6]", "Unknown float")
        yield RawBytes(self, "unknown data[3]", 32, "Unknown Data")
        yield Float32(self, "unknown float[7]", "Unknown float")
        yield Float32(self, "unknown float[8]", "Unknown float")
        yield RawBytes(self, "unknown data[4]", 64, "Unknown data")
        yield UInt32(self, "offset", "The byte offset of the first peak in the peak table")
        yield UInt32(self, "peak count", "The number of peaks in this scan")

class LogRecord(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield AutosamplerStatus(self, "autosampler", "Autosampler Status")
        yield LCPump(self, "lc pump", "LC Pump")

        yield RawBytes(self, "reserved", 36, "Unknown zero-padded area; may be reserved for additional devices")

        yield SyringePump(self, "syringe pump", "Syringe Pump")
        yield TurboPump(self, "turbo pump", "Turbo Pump")
        for index in "123":
            yield UInt32(self, "unknown long[%s]" % index, "Unknown long")
        yield Float32(self, "octapole2 offset", "Octapole 2 Offset (V)")
        yield Float32(self, "unknown float[1]", "Unknown")
        yield Float32(self, "unknown float[2]", "Unknown")
        yield Float32(self, "trap dc offset", "Trap DC Offset (V)")
        yield IonDetector(self, "ion detector", "Ion Detection System")
        yield Float32(self, "unknown float[3]", "Unknown")
        yield Float32(self, "lens voltage", "Lens Voltage (V)")
        yield Float32(self, "unknown float[4]", "Unknown")
        yield Float32(self, "ion gauge reading", "Ion Gauge (x 10e-5 Torr)")
        yield Float32(self, "main rf dac", "Main RF DAC (steps)")
        yield Float32(self, "convection gauge", "Convection Gauge (Torr)")
        yield Float32(self, "unknown float[5]", "Unknown")
        yield Float32(self, "unknown float[6]", "Unknown -- Main RF Detected?")
        yield Float32(self, "unknown float[7]", "Unknown")
        yield Float32(self, "supply p15", "+15V Supply Voltage")
        yield Float32(self, "supply m15", "-15V Supply Voltage")
        yield Float32(self, "unknown float[8]", "Unknown")
        yield Float32(self, "supply p5", "+5V Supply Voltage")
        yield Float32(self, "sheath gas flow", "Sheath Gas Flow Rate ()")
        yield Float32(self, "aux gas flow", "Aux Gas Flow Rate ()")
        yield Float32(self, "api source current", "API Source Current (uA)")
        yield Float32(self, "api source voltage", "API Source Voltage (kV)")
        yield Float32(self, "api capillary voltage", "Capillary Voltage (V)")
        yield Float32(self, "supply p150", "+150V Supply Voltage")
        yield Float32(self, "unknown float[9]", "Unknown")
        yield Float32(self, "supply p35", "+35V Supply Voltage")
        yield Float32(self, "supply p28 current", "+28V Supply Current (A)")
        yield Float32(self, "capillary temp", "Capillary Temp (C)")
        yield Float32(self, "vaporizer temp", "Vaporizer Temp (C)")
        yield Float32(self, "octapole1 offset", "Octapole 1 Offset (V)")
        yield Float32(self, "supply p36", "+36V Supply Voltage")
        yield Float32(self, "supply m28", "-28V Supply Voltage")
        yield Float32(self, "rf detector temp", "RF Detector Temp (C)")
        yield Float32(self, "rf generator temp", "RF Generator Temp (C)")
        yield Float32(self, "ambient temp", "Ambient Temp (C)")
        yield Float32(self, "supply p24", "+24V Supply Voltage")
        yield Float32(self, "unknown float[a]", "Unknown")
        yield Float32(self, "supply m150", "-150V Supply Voltage")
        yield Float32(self, "supply m24", "-24V Supply Voltage")
        yield Float32(self, "supply p205", "+205V Supply Voltage")
        yield Float32(self, "unknown float[b]", "Unknown")
        yield Float32(self, "supply m205", "-205V Supply Voltage")
        yield Float32(self, "unknown float[c]", "Unknown")
        yield Float32(self, "unknown float[d]", "Unknown")
        yield Float32(self, "unknown float[e]", "Unknown")
        yield Float32(self, "unknown float[f]", "Unknown")
        yield Float32(self, "unknown float[g]", "Unknown")
        yield Float32(self, "supply p28", "+28V Supply Voltage")
        yield UInt32(self, "unknown long[i]", "Unknown")
        yield UInt32(self, "unknown long[j]", "Unknown")
        yield Float32(self, "unknown float[k]", "Unknown")


class AutosamplerStatus(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "status", "Status")
        yield UInt16(self, "vial pos", "Current Vial Position")
        yield UInt16(self, "n", "Number of injections")

class LCPump(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "status", "Status")
        yield Float32(self, "run time", "Run Time (min)")
        yield Float32(self, "flow", "Flow Rate (mL/min)")
        yield Float32(self, "comp c", "Composition C (%)")
        yield Float32(self, "pressure", "Pump Pressure (psi)")
        yield Float32(self, "comp d", "Composition D (%)")
        yield Float32(self, "temperature", "Temperature (C)")
        yield Float32(self, "comp a", "Composition A (%)")
        yield Float32(self, "comp b", "Composition B (%)")

class SyringePump(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "status", "Status")
        yield Float32(self, "flow", "Flow Rate (uL/min)")
        yield Float32(self, "volume", "Infused Volume (uL)")
        yield Float32(self, "diameter", "Syringe Diameter (mm)")

class TurboPump(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float32(self, "life", "Life (hours)")
        yield Float32(self, "speed", "Speed (x 1000 rpm)")
        yield Float32(self, "temperature", "Temperature (C)")
        yield Float32(self, "power", "Power (Watts)")
        yield UInt32(self, "status", "Status")

class IonDetector(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float32(self, "multiplier actual", "Multiplier Actual (V)")

class ScanIndexEntry(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "offset", "Offset of this scan's data from the start of the scan data stream")
        yield UInt32(self, "index", "This scan's index")
        yield UInt16(self, "scan event", "Scan event number")
        yield UInt16(self, "scan segment", "Scan segment number")
        yield UInt32(self, "next", "The next scan's index")
        yield UInt32(self, "unknown long", "Unknown long")
        yield UInt32(self, "size", "Scan data size")
        yield Float64(self, "start time", "Scan Start Time")
        yield Float64(self, "total current", "Total Ion Current")
        yield Float64(self, "base intensity", "Base Peak Intensity")
        yield Float64(self, "base mass", "Base Peak Mass")
        yield Float64(self, "low mz")
        yield Float64(self, "high mz")
