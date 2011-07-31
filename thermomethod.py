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

class ThermoMethod(Parser):
    MAGIC = "\x0d\x00\x00\x00"

    PARSER_TAGS = {
        "magic": ((MAGIC, 0),),
        "id": "thermomethod",
        "category": "misc",    # "archive", "audio", "container", ...
        "file_ext": ("meth",),
        "mime": (u"application/xcalibur",),
        "min_size": 0x054C * 8,
        "description": "Thermo method file, embedded in mass spec raw data",
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
        yield UInt32(self, "magic number")
        yield UInt32(self, "unknown long[%s]" % 2)
        yield UInt32(self, "suspected version")

        if self["suspected version"].value == 60:
            for index in range(4, 20+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(1, 7+1):
                yield Float64(self, "unknown double[%s]" % index)
            yield Float64(self, "run time")
            for index in range(9, 10+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(21, 23+1):
                yield UInt32(self, "unknown long[%s]" % index)

            yield Float64(self, "segment duration")

            for index in range(24, 25+1):
                yield UInt32(self, "unknown long[%s]" % index)

            yield UInt32(self, "structOneCount")
            for n in range(1, self["structOneCount"].value + 1):
                yield StructOne(self, "StructOne[%s]" % n)


            yield UInt32(self, "n_events")
            for n in range(1, self["n_events"].value + 1):
                yield ScanEvent(self, "ScanEvent[%s]" % n)

        
            yield PascalStringWin32(self, "orig file name", "The original file name as seen on the instrument controller")
            yield PascalStringWin32(self, "unknown string")

            yield UInt32(self, "unknown long[%s]" % 26)

        
            for n in range(1, 3 + 1):
                yield StructFour(self, "StructFour[%s]" % n)

            for n in range(1, 3 + 1):
                yield StructFive(self,  "StructFive[%s]" % n)

        #####################################################################
        elif self["suspected version"].value == 52:
            for index in range(4, 18+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(1, 7+1):
                yield Float64(self, "unknown double[%s]" % index)
            yield Float64(self, "run time")
            yield Float64(self, "segment duration")
            yield Float64(self, "unknown double[%s]" % 11)

            yield UInt32(self, "structOneCount")
            for n in range(1, self["structOneCount"].value + 1):
                yield StructOne(self, "StructOne[%s]" % n)

            for index in range(12, 13+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(19, 24+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(14, 41+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(25, 26+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(42, 43+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(27, 28+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(44, 49+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(29, 36+1):
                yield UInt32(self, "unknown long[%s]" % index)


            yield Float64(self, "unknown double[%s]" % 50)

            for index in range(37, 56+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(51, 54+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(57, 63+1):
                yield UInt32(self, "unknown long[%s]" % index)


            yield Float64(self, "unknown double[%s]" % 55)

            for index in range(64, 74+1):
                yield UInt32(self, "unknown long[%s]" % index)

            yield Float64(self, "unknown double[%s]" % 56)
            yield Float64(self, "unknown double[%s]" % 57)

            yield UInt32(self, "unknown long[%s]" % 75)

            for index in range(58, 66+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(76, 78+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(67, 69+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(79, 90+1):
                yield UInt32(self, "unknown long[%s]" % index)

            yield Float64(self, "unknown double[%s]" % 70)

            for index in range(91, 96+1):
                yield UInt32(self, "unknown long[%s]" % index)

            for index in range(71, 80+1):
                yield Float64(self, "unknown double[%s]" % index)



# ------------------------------------------------------------

class StructOne(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):

        if self["/suspected version"].value == 60:
            for index in range(1, 3+1):
                yield Float64(self, "unknown double[%s]" % index)

            for index in range(1, 14+1):
                yield UInt32(self, "unknown long[%s]" % index)


            yield UInt32(self, "structTwoCount")
            for n in range(1, self["structTwoCount"].value + 1):
                yield StructTwo(self, "StructTwo[%s]" % n)
     
            yield StructThree(self, "StructThree[%s]" % 1)

        elif self["/suspected version"].value == 52:
            yield Float64(self, "unknown double[%s]" % 1)
            yield UInt32(self, "unknown long[%s]" % 1)
            yield UInt32(self, "unknown long[%s]" % 2)
            yield Float64(self, "unknown double[%s]" % 2)

            for index in range(3, 4+1):
                yield UInt32(self, "unknown long[%s]" % index)

            yield Float64(self, "unknown double[%s]" % 3)

            for index in range(5, 13+1):
                yield UInt32(self, "unknown long[%s]" % index)

            yield UInt32(self, "structTwoCount")
            #for n in range(1, self["structTwoCount"].value + 1):
            for n in range(1, 9 + 1):
                yield StructTwo52(self, "StructTwo52[%s]" % n)

            yield StructThree52(self, "StructThree52[%s]" % 1)

            yield PascalStringWin32(self, "file name")

            for index in range(14, 17+1):
                yield UInt32(self, "unknown long[%s]" % index)

class StructTwo(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):

        for index in range(1, 2+1):
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(1, 3+1):
            yield Float64(self, "unknown double[%s]" % index)

        yield Float32(self, "unknown float[%s]" % 1)

        yield UInt32(self, "unknown long[%s]" % 3)

        yield Float64(self, "unknown double[%s]" % 4)
        yield Float64(self, "unknown double[%s]" % 5)

        for index in range(4, 6+1):
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(6, 20+1):
            yield Float64(self, "unknown double[%s]" % index)


class StructTwo52(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):

        for index in range(1, 2+1):
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(1, 3+1):
            yield Float64(self, "unknown double[%s]" % index)

        yield Float32(self, "unknown float[%s]" % 1)

        yield UInt32(self, "unknown long[%s]" % 3)

        yield Float64(self, "unknown double[%s]" % 4)
        yield Float64(self, "unknown double[%s]" % 5)


class StructThree(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):

        for index in range(2, 10+1):
            yield Float32(self, "unknown float[%s]" % index)

        yield UInt32(self, "unknown long[%s]" % 45)

        for index in range(11, 13+1):
            yield Float64(self, "unknown double[%s]" % index)

        for index in range(46, 57+1):
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(14, 18+1):
            yield Float64(self, "unknown double[%s]" % index)


class StructThree52(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):

        for index in range(1, 9+1):
            yield Float32(self, "unknown float[%s]" % index)

        yield UInt32(self, "unknown long[%s]" % 1)
        yield UInt32(self, "n_events")
        for n in range(1, self["n_events"].value + 1):
            yield ScanEvent52(self, "ScanEvent[%s]" % n)


class ScanEvent(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):

        for index in range(1, 2+1):
            yield Int32(self, "unknown long[%s]" % index, "these may be binary type flags (as in ScanEventPreamble)")

        for index in range(3, 4+1):
            yield UInt32(self, "unknown long[%s]" % index)

        yield Float64(self, "unknown double[%s]" % 1)

        yield Float32(self, "unknown float[%s]" % 1)

        yield UInt32(self, "resolution", "As in:  FTMS + p norm !corona !pi res=60000 o(400.0-2000.0)")

        yield Float32(self, "unknown float[%s]" % 2)
        yield Float32(self, "unknown float[%s]" % 3)

        for index in range(6, 19+1):
            yield UInt32(self, "unknown long[%s]" % index)

        yield Float64(self, "unknown double[%s]" % 4)

        yield UInt32(self, "default charge state")
        yield UInt32(self, "unknown long[%s]" % 21)

        yield Float64(self, "unknown double[%s]" % 5)
        yield Float64(self, "unknown double[%s]" % 6)

        for index in range(4, 19+1):
            yield Float32(self, "unknown float[%s]" % index)

        yield UInt32(self, "n_act_param");
        for n in range(1, self["n_act_param"].value + 1):
            yield ActivationParam(self, "ActivationParam[%s]" % n)

        yield UInt32(self, "unknown long[%s]" % 23)
        yield UInt32(self, "unknown long[%s]" % 24)

        yield Float64(self, "low mz")
        yield Float64(self, "high mz")
        yield Float64(self, "unknown double[%s]" % 24)

        for index in range(20, 27+1):
            yield Float32(self, "unknown float[%s]" % index)

        for index in range(25, 25+1):
            yield UInt32(self, "unknown long[%s]" % index)


class ScanEvent52(FieldSet):
    static_size = 116 * 8
    endian = LITTLE_ENDIAN

    def createFields(self):

        for index in range(2, 5+1):
            yield UInt32(self, "unknown long[%s]" % index)

        yield Float64(self, "unknown double[%s]" % 1)
        yield Float32(self, "unknown float[%s]" % 10)

        for index in range(46, 55+1):
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(2, 4+1):
            yield Float64(self, "unknown double[%s]" % index)

        for index in range(11, 16+1):
            yield Float32(self, "unknown float[%s]" % index)

        # Undecoded tail
        if self.current_size < self._size:
            yield self.seekBit(self._size, "trailer")



class ActivationParam(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float64(self, "normalized collision energy")
        yield Float64(self, "activation time")
        yield Float64(self, "activation Q")


class StructFour(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 6+1): # 6 int
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(1, 2+1): # 2 double
            yield Float64(self, "unknown double[%s]" % index)



class StructFive(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        for index in range(1, 18+1): # 18 double
            yield Float64(self, "unknown double[%s]" % index)

        for index in range(1, 2+1): # 2 int
            yield UInt32(self, "unknown long[%s]" % index)

        for index in range(19, 22+1): # 4 double
            yield Float64(self, "unknown double[%s]" % index)

