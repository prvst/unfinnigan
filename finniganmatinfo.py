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

class FinniganMatInfo(Parser):
    MAGIC = "\x54\x00\x68\x00\x69\x00\x73\x00\x20\x00\x69\x00\x73\x00\x20\x00\x61\x00\x20\x00\x46\x00\x49\x00\x4E\x00\x4E\x00\x49\x00\x47\x00\x41\x00\x4E\x00\x2F\x00\x4D\x00\x41\x00\x54\x00\x20\x00\x49\x00\x4E\x00\x46\x00\x4F\x00\x20\x00\x66\x00\x69\x00\x6C\x00\x65\x00" # This is a FINNIGAN/MAT INFO file"

    PARSER_TAGS = {
        "magic": ((MAGIC, 0),),
        "id": "finniganmatinfo",
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
        #yield CString(self, "finnigan signature", "Finnigan signature (wide ASCIIZ string)", charset="UTF-16-LE") #, strip="\0")
        yield String(self, "finnigan signature", 120, "Finnigan signature (wide ASCIIZ string)", charset="UTF-16-LE", truncate="\0")
        for index in range(2, 4+1):
            yield UInt32(self, "unknown long[%s]" % index)
        yield TimestampUnix32(self, "time[1]")
        yield UInt32(self, "unknown long[%s]" % 6)
        yield RawBytes(self, "zero[2]", 120, "padding")
        for index in range(7, 10+1):
            yield UInt32(self, "unknown long[%s]" % index)


        #####################################################################
        #yield ArrayOfLong(self, "unknown array")
        yield ArrayOfLong(self, "unknown array")
        yield RawBytes(self, "zero[3]", 80, "padding")
        yield LinearRamp(self, "linear ramp")
        yield CString(self, "header file", "The full filesystem path to the header file", charset="UTF-16-LE")
        yield ArrayOfShort172(self, "unknown array[2]")
        yield CString(self, "method file", "The full filesystem path to the method file", charset="UTF-16-LE")
        yield RawBytes(self, "zero[4]", 1044, "padding")

        ## --------------- struct 2 --------------------
        yield UInt16(self, "unknown short")
        yield RawBytes(self, "zero[5]", 28, "padding")

        # ----- strutct 1 --------------
        yield Struct1(self, "Struct1[1]")
        yield Struct1(self, "Struct1[2]")

        yield ArrayOfShort96(self, "unknown array[3]")

        yield RawBytes(self, "zero[6]", 1586, "padding")

        ## --------------- struct 2 --------------------
        yield UInt16(self, "unknown short (bis)")
        yield RawBytes(self, "zero[7]", 28, "padding")

        # ----- strutct 1 --------------
        yield Struct1(self, "Struct1[3]")
        yield Struct1var(self, "unknown struct")
        yield Struct1(self, "Struct1[5]")


        yield UInt16(self, "unknown short[1]")

        yield RawBytes(self, "junk[1]", 766, "probably buffer detritus")

        yield Struct1(self, "Struct1[4]")

        yield RawBytes(self, "undecoded[1]", 4184, "probably junk, but there are several instances of Struct1 in it")

        yield ArrayOfShort32(self, "unknown array[4]")

        yield TimestampUnix32(self, "time[1]")

        yield CString(self, "tune file", "Path to tune file (wide ASCIIZ string)", charset="UTF-16-LE") #, strip="\0")
        yield UInt16(self, "unknown short[2]")
        yield CString(self, "file path[1]", "Uknown file path", charset="UTF-16-LE") #, strip="\0")

        yield ArrayOfShort120(self, "unknown array[5]", "Contains 9x periodic structure with inrementing element")

        yield CString(self, "unknown string[1]", "", charset="UTF-16-LE") #, strip="\0")
        yield CString(self, "unknown string[2]", "", charset="UTF-16-LE") #, strip="\0")

        yield ArrayOfShort30(self, "unknown array[6]")
        yield TimestampUnix32(self, "time[2]")
        yield TimestampUnix32(self, "time[3]")
        yield CString(self, "unknown string[3]", "", charset="UTF-16-LE") #, strip="\0")
        yield ArrayOfShort36(self, "unknown array[7]", "Contains 4x periodic structure")
        yield CString(self, "unknown string[4]", "", charset="UTF-16-LE") #, strip="\0")

        yield RawBytes(self, "zero[8]", 530, "padding")
        yield CString(self, "unknown string[5]", "", charset="UTF-16-LE") #, strip="\0")
        yield CString(self, "unknown string[6]", "", charset="UTF-16-LE") #, strip="\0")

        yield RawBytes(self, "zero[9]", 266, "padding")
        yield CString(self, "unknown string[7]", "", charset="UTF-16-LE") #, strip="\0")
        yield CString(self, "unknown string[8]", "", charset="UTF-16-LE") #, strip="\0")

        yield RawBytes(self, "zero[10]", 226, "padding")
        yield CString(self, "unknown string[9]", "", charset="UTF-16-LE") #, strip="\0")
        yield CString(self, "unknown string[10]", "", charset="UTF-16-LE") #, strip="\0")

        yield RawBytes(self, "zero[11]", 226, "padding")
        yield CString(self, "unknown string[11]", "", charset="UTF-16-LE") #, strip="\0")

        yield RawBytes(self, "zero[12]", 236, "padding")

        yield ArrayOfShort44(self, "unknown array[8]", "Contains 4x periodic structure with increment [0..3]")

        # -------------- Ions --------------------------
        for index in range(1, 4+1):
            yield IonStruct(self, "ion struct[%s]" % index, "unknown ion-based structure")

        yield ArrayOfShort1856(self, "unknown array[9]", "Contains a 4x-periodic structure near the start [25..40]")

        for index in range(1, 4+1):
            yield Struct2(self, "Struct2[%s]" % index, "")

        yield ArrayOfShort2344(self, "unknown array[10]", "Poissibly contains two large and two small periods")

        for index in range(1, 2+1):
            yield Struct4(self, "Struct4[%s]" % index)
            yield ArrayOfLong224(self, "unknown Struct4[%s]-associated array" % index)

        yield Struct4(self, "Struct4[%s]" % 3)

        yield UInt16(self, "count 1")
        yield UInt16(self, "count 2")

        for index in range(1, 40+1):
            yield Struct3(self, "Struct3[%s]" % index)

        for index in range(1, 10+1):
            yield Float64(self, "unknown double[%s]" % index)

        for index in range(1, 40+1):
            yield Struct5(self, "Struct5[%s]" % index)

        # ---  irregularity ---
        for index in range(1, 2+1):
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(41, 80+1):
            yield Struct5(self, "Struct5[%s]" % index)

        for index in range(81, 120+1):
            yield Struct5(self, "Struct5var[%s]" % index)

        yield self.seekBit(self._size, "trailer")
# ------------------------------------------------------------

class ArrayOfLong(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 174+1):
            yield UInt32(self, "unknown long[%s]" % index)

class ArrayOfLong224(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 224/4+1):
            yield UInt32(self, "unknown long[%s]" % index)

class ArrayOfShort18(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 9+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort30(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 15+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort32(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 16+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort36(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 18+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort44(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 22+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort96(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 48+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort120(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 60+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort172(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 86+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort512(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 256+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort2344(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 2344/2+1):
            yield UInt16(self, "short[%s]" % index)

class ArrayOfShort1856(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 1856/2+1):
            yield UInt16(self, "short[%s]" % index)

class LinearRamp(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 39+1):
            yield UInt16(self, "short[%s]" % index)

class Struct1(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
       for index in range(1, 4+1):
           yield UInt16(self, "unknown short[%s]" % index)

       for index in range(1, 3+1):
           yield Float64(self, "unknown double[%s]" % index)

       for index in range(5, 6+1):
           yield UInt16(self, "unknown short[%s]" % index)

       yield UInt32(self, "unknown long[%s]" % 3)

       yield Float64(self, "unknown double[%s]" % 4)

class Struct1var(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
       for index in range(1, 18+1):
           yield UInt16(self, "unknown short[%s]" % index)

       yield UInt32(self, "unknown long[%s]" % 3)

       yield Float64(self, "unknown double[%s]" % 4)

class Struct2(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
       for index in range(1, 39+1):
           yield Float64(self, "unknown double[%s]" % index)
       for index in range(1, 2+1):
           yield UInt32(self, "unknown long[%s]" % index)
       for index in range(40, 41+1):
           yield Float64(self, "unknown double[%s]" % index)

class Struct3(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 4+1):
            yield UInt16(self, "short[%s]" % index)
        yield Float64(self, "unknown double")

class Struct4(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 28+1):
            yield Float64(self, "unknown double[%s]" % index)

class Struct5(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "unknown double")
        for index in range(1, 2+1):
            yield UInt32(self, "unknown long[%s]" % index)

class IonStruct(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield ArrayOfShort18(self, "unknown array[2]", "some data similar to ArrayOfShort44")
        yield CString(self, "unknown string[1]", "", charset="UTF-16-LE") #, strip="\0")
        yield RawBytes(self, "zero[1]", 52, "padding")

        yield UInt16(self, "unknown short[1]")
        yield UInt32(self, "unknown long[1]")
        yield Float64(self, "unknown double[%s]" % 1)
        yield UInt32(self, "unknown long[2]")
        yield UInt32(self, "unknown long[3]")
        yield Float64(self, "unknown double[%s]" % 2)
        yield UInt16(self, "unknown short[2]")
        yield UInt16(self, "unknown short[3]")
        yield UInt32(self, "unknown long[4]")
        yield Float64(self, "unknown double[%s]" % 3)
        yield Float64(self, "unknown double[%s]" % 4)
        yield Float64(self, "unknown double[%s]" % 5)

        yield Struct1(self, "Struct1")

        yield ArrayOfShort512(self, "unknown array[1]", "Contains just a few numbers that can be relevant")

        yield Float64(self, "unknown double[%s]" % 6)



