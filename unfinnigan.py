#!/usr/bin/env python

import sys
import inspect
from optparse import OptionParser
from hachoir_core.stream import FileInputStream, LITTLE_ENDIAN
from hachoir_parser import guessParser, HachoirParserList
from hachoir_core.error import HACHOIR_ERRORS, error
from hachoir_parser import ValidateError
#from finnigan import Finnigan

def main():
    usage = "usage: %prog <file_name>"
    op = OptionParser(usage)

    (options, args) = op.parse_args()
    if len(args) != 1:
        op.print_help()
        sys.exit(1)

    inputFileName = unicode(args[0])
    try:
        stream = FileInputStream(inputFileName)
    except InputStreamError, err:
        exit("Unable to open file: %s" % err)


    try:
        data = guessParser(stream)
        if not data:
            exit("Unable to parse file: %s" % inputFileName)

        for struct in data.allFeatures():
            print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)

        return 1

        for struct in data:
            print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)
            try:
                iter_exists = getattr(struct, "__iter__", None)
            except AttributeError:
                pass
            if iter_exists:
                for field in data[struct.name]:
                 print "%08X: %s = %s" % ((struct.address + field.address)/8, field.path, field.display)
            else:
                 print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)
                

        print "------------------------------------------------"


        for struct in data["header"]:
            print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)

        if hasattr(data, "run_header"):
            object = data["run_header"]
            for struct in object:
                print "%08X: %s = %s" % ((object.address + struct.address)/8, struct.path, struct.display)
                try:
                    iter_exists = getattr(struct, "__iter__", None)
                except AttributeError:
                    pass
                if iter_exists:
                    for field in object[struct.name]:
                        print "%08X: %s = %s" % ((object.address + struct.address + field.address)/8, field.path, field.display)
                    else:
                        print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)

        object = data["seq_row"]
        for struct in object:
            print "%08X: %s = %s" % ((object.address + struct.address)/8, struct.path, struct.display)
            try:
                iter_exists = getattr(struct, "__iter__", None)
            except AttributeError:
                pass
            if iter_exists:
                for field in object[struct.name]:
                    print "%08X: %s = %s" % ((object.address + struct.address + field.address)/8, field.path, field.display)
            else:
                 print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)

        object = data["CAS_info"]
        for struct in object:
            print "%08X: %s = %s" % ((object.address + struct.address)/8, struct.path, struct.display)
            try:
                iter_exists = getattr(struct, "__iter__", None)
            except AttributeError:
                pass
            if iter_exists:
                for field in object[struct.name]:
                    print "%08X: %s = %s" % ((object.address + struct.address + field.address)/8, field.path, field.display)
            else:
                 print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)

        object = data["raw_file_info"]
        for struct in object:
            print "%08X: %s = %s" % ((object.address + struct.address)/8, struct.path, struct.display)
            try:
                iter_exists = getattr(struct, "__iter__", None)
            except AttributeError:
                pass
            if iter_exists:
                for field in object[struct.name]:
                    print "%08X: %s = %s" % ((object.address + struct.address + field.address)/8, field.path, field.display)
            else:
                 print "%08X: %s = %s" % ((struct.address)/8, struct.path, struct.display)

        object = data["trailer"]
        print "%08X: %s = %s" % ((object.address)/8, object.path, object.display)

    except ValidateError, err:
        error(u"%s" % (err))

    # except HACHOIR_ERRORS, err:
    #     error(u"%s" % (err))

if __name__ == "__main__":
    main()

