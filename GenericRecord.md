## Purpose ##

This type of record provides a container for streams of packed binary data. The only difference between this and any old stream record is that it works together with an instance of GenericDataHeader included with the stream to parse its own internals, so the exact format of the record does not have to be maintained in software.

Essentially this GenericDataHeader/GenericRecord tandem allows the code to access the stream's elements by name, rather than through fixed pointers and offsets.

In some instances, where a data stream is not essential for processing, but only exists for perusal by humans, the code can be written to handle such data transparently, without any knowledge of what is in there.

## Structure ##

This object is devoid of fixed data elements and therefore has no specific structure. But once the decoder object associates it with a matching GenericDataHeader, it knows how to use it to fill itself with the data specified in that header.

## Implementation ##

This is how GenericRecord is implemented in the [Hachoir parser](HachoirParser.md):

```
class GenericRecord(FieldSet):
    def __init__(self, parent, header, name, description=None):
        FieldSet.__init__(self, parent, name, description)
        self.header = header
 
    def createFields(self):
        for item in self.header:
            if isinstance(item, GenericDataDescriptor):
                if item["type"].value:
                    if item["type"].value == 0xD:
                        yield String(self, item.ascii_label, item["length"].value * 2,
                                     charset="UTF-16-LE", truncate="\0")
                    elif item["type"].value == 0xC:
                        yield String(self, item.ascii_label, item["length"].value,
                                     truncate="\0")
                    elif item["type"].value == 0xB:
                        yield Float64(self, item.ascii_label)
                    elif item["type"].value == 0xA:
                        yield Float32(self, item.ascii_label)
                    elif item["type"].value == 0x9:
                        yield UInt32(self, item.ascii_label)
                    elif item["type"].value == 0x6:
                        yield UInt16(self, item.ascii_label)
                    elif item["type"].value == 0x4:
                        yield UInt8(self, item.ascii_label)
                    elif item["type"].value == 0x3:
                        yield UInt8(self, item.ascii_label)
                    elif item["type"].value == 0x1:
                        yield UInt8(self, item.ascii_label)
                    else:
                        exit( "unkown data type (" \
                              + str(item["type"]) \
                              + " at %x" % (self.absolute_address/8) \
                              + ", " + str(item["length"].value) + "): " \
                              + item.ascii_label + " in " + str(item)
                            )

```