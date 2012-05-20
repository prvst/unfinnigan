"""
Thermo method file parser
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
    TimestampUnix32,
    TimestampWin64,
    String,
    CString,
    PaddingBytes,
    PascalString8,
    FieldSet
    )
from hachoir_parser.common.win32 import PascalStringWin32
from hachoir_core.endian import LITTLE_ENDIAN, BIG_ENDIAN

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

class FinniganMatDat(Parser):
    MAGIC = "\x43\x00"

    PARSER_TAGS = {
        "magic": ((MAGIC, 0),),
        "id": "finniganmatdat",
        "category": "misc",    # "archive", "audio", "container", ...
        "file_ext": ("meth",),
        "mime": (u"application/xcalibur",),
        "min_size": 0x054C * 8,
        "description": "Finnigan .dat file",
    }

    endian = LITTLE_ENDIAN
    abs_addr = 0

    def __init__(self, stream, **args):
        Parser.__init__(self, stream, **args)

    def validate(self):
        if self.stream.readBytes(0, len(self.MAGIC)) != self.MAGIC:
             return "Unknon magic number"
        return True

    def createFields(self):
        yield Header(self, "header")
        yield RunHeader(self, "run header")

        for index in range(1, 10+1):
            yield Spectrum(self, "scan[%s]" % index)

        yield Trailer(self, "trailer", "trailer structure containing scan index and file checksum")


# ------------------------------------------------------------

class Header(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt16(self, "magic number")
        yield CString(self, "finnigan signature", "Finnigan signature (wide ASCIIZ string)", charset="UTF-16-LE") #, strip="\0")
        yield UInt16(self, "unknown short")
        yield UInt32(self, "unknown long[1]")
        yield UInt32(self, "RunHeader addr", "skips over the following list")
        yield ListOfLong(self, "unknown list")

class RunHeader(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "unknown string", 24, "detritus from a previous write?")
        yield UInt32(self, "unknown long 1")
        yield UInt32(self, "trailer addr")
        for index in range(2, 7+1):
            yield UInt32(self, "unknown long[%s]" % index)
        yield TimestampUnix32(self, "start time[1]")
        yield TimestampUnix32(self, "end time[1]")
        yield TimestampUnix32(self, "start time[2]")
        yield TimestampUnix32(self, "end time[2]")
        yield RawBytes(self, "unknown area 1", 16)
        yield UInt16(self, "unknown short 1")
        yield UInt16(self, "unknown short 2")
        yield RawBytes(self, "unknown area 2", 8)
        yield UInt16(self, "unknown short 3")
        yield RawBytes(self, "unknown area 3", 6)
        yield UInt16(self, "unknown short 4")
        yield UInt16(self, "unknown short 5")
        yield RawBytes(self, "unknown area 4", 0x2c)
        yield UInt32(self, "unknown long[%s]" % 8)
        yield RawBytes(self, "unknown string or buffer", 76, "detritus from a previous write?")
        yield PascalStringWin32(self, "file path", "The full filesystem path to this file")
        yield RawBytes(self, "uknown area 5", 16)
        yield PascalStringWin32(self, "method file", "The filesystem path to method file")
        yield PascalStringWin32(self, "tune file", "The filesystem path to tune file")
        yield StructOne(self, "unknown structure")


class Trailer(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "unknown long", "possibly a null list, shuch as error log")
        for index in range(0, 9+1):
            yield UInt32(self, "scan index[%s]" % index)
        for index in range(1, 2+1):
            yield UInt16(self, "short[%s]" % index)
        yield UInt32(self, "checksum", "CRC32 digest")

class Spectrum(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield SpectrumHeader(self, "header")
        yield RawBytes(self, "uknown area 1", 16)
        for index in range(1, 2+1):
            yield UInt32(self, "unknown index[%s]" % index)
        yield TimestampUnix32(self, "start")
        yield TimestampUnix32(self, "end")
        yield UInt32(self, "unknown long[%s]" % 1)
        yield RawBytes(self, "uknown area 2", 16)
        for index in range(2, 6+1):
            yield UInt32(self, "unknown long[%s]" % index)
        yield Float64(self, "unknown double")
        yield StructTwo(self, "unknown 52-byte structure")

        yield Struct100(self, "unknown 100-byte structure[1]")
        for index in range(1, 4+1):
            yield UInt16(self, "short[%s]" % index)
        yield Struct100(self, "unknown 100-byte structure[2]")
        for index in range(5, 6+1):
            yield UInt16(self, "short[%s]" % index)
        yield Struct100(self, "unknown 100-byte structure[3]")
        for index in range(7, 10+1):
            yield UInt16(self, "short[%s]" % index)
        yield Struct100(self, "unknown 100-byte structure[4]")
        for index in range(11, 14+1):
            yield UInt16(self, "short[%s]" % index)

class SpectrumHeader(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(0, 8+1):
            yield UInt32(self, "unknown long[%s]" % index)
        yield UInt32(self, "scan number")
        for index in range(10, 13+1):
            yield UInt32(self, "unknown long[%s]" % index)

class TwentyByteStruct(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 10+1):
            yield UInt16(self, "byte[%s]" % index)

class ListOfLong(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "count");
        for index in range(1, self["count"].value + 1):
            yield UInt32(self, "unknown long[%s]" % index)

class StructOne(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 19+1):
            yield UInt16(self, "unknown short[%s]" % index)

class StructTwo(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 26+1):
            yield UInt16(self, "unknown short[%s]" % index)

class Struct100(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 5+1):
            yield TwentyByteStruct(self, "twenty-byte struct[%s]" % index)

