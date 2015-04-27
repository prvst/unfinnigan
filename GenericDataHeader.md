## Purpose ##

**GenericDataHeader** describes the format of all records in a stream. It is an ordered list of [GenericDataDescriptor](GenericDataDescriptor.md)'s, where each descriptor gives instructions for how to read and interpret a particular element of a record. Records composed using the **GenericDataHeader** mechanism are, similarly, ordered lists, in which every element corresponds to its definition in the GenericDataHeader instance. Such records can be parsed using the [GenericRecord](GenericRecord.md) object referring to the matching **GenericDataHeader**.

For every type of [GenericRecord](GenericRecord.md), there must be an instance of **GenericDataHeader** defined somewhere in the data file, or created in software. This mechanism allows the data streams to be self-descriptive. Usually, but not always, a **GenericDataHeader** immediately precedes a stream of [GenericRecord](GenericRecord.md)'s in Finnigan data files.

In the earlier versions of the Finnigan file format (from mid-1990's), generic headers did not exist, which apparently made concurrent maintenance of multiple versions a difficult task. The generic header mechanism can nonetheless be used to read the old files, but the appropriate headers must be created within software (rather than read from the file)

This mechanism is best suited for records with a fixed number of elements (although elements can be of variable length). A typical record has no structure (it cannot be nested, nor can it contain other records), but there is a grouping mechanism in **GenericDataHeader** that allows creation of simple 2-level structures. Grouping of data elements in a record can be achieved with _headings_, the special zero-length elements of the the generic header.

Unlike other data types, the heading data type (Finnigan type code `0x0`) is not stored in the stream's records. It is only stored in the header itself. Because the header is scanned along with each new record being parsed (thus directing the parser), when the the parser encounters a heading among the data descriptors in the header, it can change its state and treat all subsequent record elements differently -- for example, it can put them in a different container.

## Structure ##
The structure of **GenericDataHeader** is very simple: it consists of a series of descriptors whose length is indicated by a 32-bit integer number at the head of thhe structure.
```
typedef {
   UInt32 n,  /* the number of data elements in each instance of GenericRecord */
   GenericDataDescriptor[] descriptor
} GenericDataHeader;
```

## Implementation ##
This python implementation of **GenericDataHeader** is somewhat involved, because it needs to keep the data descriptors' labels compatible with Hachoir. In order to guarantee uniqueness of the parse tree path from the root node to every element of the header, it concatenates each descriptor's label with with the preceding heading, if such is encountered.

This is done because in some Finnigan headers, identically named parameters can occur under different headings.

For example, in the [File header](Tune.md) in V.57 of the LTQ-FT file, the element labelled
```
Multipole 11 (V):
```
occurs twice: once following the `POSITIVE POLARITY` heading, and the second time following `NEGATIVE POLARITY`. Registering these labels with Hachoir more than once results in warnings during parsing and arbitrary assignment of numeric suffixes. Concatenating them with the heading label solves both problems.

This is a good example of how headings can be interpreted as containers by directing transitions in the parser, although the code for doing so is admittedly ugly. Because the heading mechanism allows to implement only a 2-level hierarchy (unless the content of the heading labels can be consulted to create a deeper nesting), concatenating the heading and the data descriptor's label only solves the problem of same labels occurring under different headings. Because I had seen duplicate instances of the same label under the same heading, I had to augment the parser to handle that by attaching a suffix to one of the labels. And even so, it does not handle more than duplicate occurrences.

The real life can be ugly.

```
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
```

## Examples ##

  * [A complete example](GenericRecordExample.md) of a generic header and a corressponding record decoded with it.

  * An example of the data header in the InstrumentLog stream:


| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 785078 | 4 | UInt32 | `n` | `158` |
| 785082 | 4 | UInt32 | `type` | `0` |
| 785086 | 4 | UInt32 | `length` | `0` |
| 785090 | 24 | PascalStringWin32 | `label` | `API SOURCE` |
| 785114 | 4 | UInt32 | `type` | `10` |
| 785118 | 4 | UInt32 | `length` | `2` |
| 785122 | 44 | PascalStringWin32 | `label` | `Source Voltage (kV):` |
| 785166 | 4 | UInt32 | `type` | `10` |
| 785170 | 4 | UInt32 | `length` | `2` |
| 785174 | 44 | PascalStringWin32 | `label` | `Source Current (uA):` |
| 785218 | 4 | UInt32 | `type` | `3` |
| 785222 | 4 | UInt32 | `length` | `0` |
| 785226 | 56 | PascalStringWin32 | `label` | `Vaporizer Thermocouple OK:` |
| 785282 | 4 | UInt32 | `type` | `10` |
| 785286 | 4 | UInt32 | `length` | `2` |
| 785290 | 42 | PascalStringWin32 | `label` | `Vaporizer Temp (C):` |
| 785332 | 4 | UInt32 | `type` | `10` |
| 785336 | 4 | UInt32 | `length` | `2` |
| 785340 | 52 | PascalStringWin32 | `label` | `Sheath Gas Flow Rate ():` |
| 785392 | 4 | UInt32 | `type` | `10` |
| 785396 | 4 | UInt32 | `length` | `2` |
| 785400 | 44 | PascalStringWin32 | `label` | `Aux Gas Flow Rate():` |
| 785444 | 4 | UInt32 | `type` | `10` |
| 785448 | 4 | UInt32 | `length` | `2` |
| 785452 | 48 | PascalStringWin32 | `label` | `Sweep Gas Flow Rate():` |
| 785500 | 4 | UInt32 | `type` | `3` |
| 785504 | 4 | UInt32 | `length` | `0` |
| 785508 | 40 | PascalStringWin32 | `label` | `Capillary Temp OK:` |
| 785548 | 4 | UInt32 | `type` | `10` |
| 785552 | 4 | UInt32 | `length` | `2` |
| 785556 | 48 | PascalStringWin32 | `label` | `Capillary Voltage (V):` |
| 785604 | 4 | UInt32 | `type` | `10` |
| 785608 | 4 | UInt32 | `length` | `2` |
| 785612 | 42 | PascalStringWin32 | `label` | `Capillary Temp (C):` |
| 785654 | 4 | UInt32 | `type` | `10` |
| 785658 | 4 | UInt32 | `length` | `2` |
| 785662 | 48 | PascalStringWin32 | `label` | `Tube Lens Voltage (V):` |
| 785710 | 4 | UInt32 | `type` | `0` |
| 785714 | 4 | UInt32 | `length` | `0` |
| 785718 | 4 | PascalStringWin32 | `label` | `` |
| 785722 | 4 | UInt32 | `type` | `0` |
| 785726 | 4 | UInt32 | `length` | `0` |
| 785730 | 16 | PascalStringWin32 | `label` | `VACUUM` |
| 785746 | 4 | UInt32 | `type` | `3` |
| 785750 | 4 | UInt32 | `length` | `0` |
| 785754 | 24 | PascalStringWin32 | `label` | `Vacuum OK:` |
| 785778 | 4 | UInt32 | `type` | `3` |
| 785782 | 4 | UInt32 | `length` | `0` |
| 785786 | 48 | PascalStringWin32 | `label` | `Ion Gauge Pressure OK:` |
| 785834 | 4 | UInt32 | `type` | `4` |
| 785838 | 4 | UInt32 | `length` | `0` |
| 785842 | 38 | PascalStringWin32 | `label` | `Ion Gauge Status:` |
| 785880 | 4 | UInt32 | `type` | `10` |
| 785884 | 4 | UInt32 | `length` | `2` |
| 785888 | 46 | PascalStringWin32 | `label` | `Ion Gauge (E-5 Torr):` |
| 785934 | 4 | UInt32 | `type` | `3` |
| 785938 | 4 | UInt32 | `length` | `0` |
| 785942 | 50 | PascalStringWin32 | `label` | `Convectron Pressure OK:` |
| 785992 | 4 | UInt32 | `type` | `10` |
| 785996 | 4 | UInt32 | `length` | `2` |
| 786000 | 52 | PascalStringWin32 | `label` | `Convectron Gauge (Torr):` |
| 786052 | 4 | UInt32 | `type` | `0` |
| 786056 | 4 | UInt32 | `length` | `0` |
| 786060 | 4 | PascalStringWin32 | `label` | `` |
| 786064 | 4 | UInt32 | `type` | `0` |
| 786068 | 4 | UInt32 | `length` | `0` |
| 786072 | 22 | PascalStringWin32 | `label` | `FT VACUUM` |
| 786094 | 4 | UInt32 | `type` | `3` |
| 786098 | 4 | UInt32 | `length` | `0` |
| 786102 | 50 | PascalStringWin32 | `label` | `FT Penning Pressure OK:` |
| 786152 | 4 | UInt32 | `type` | `10` |
| 786156 | 4 | UInt32 | `length` | `2` |
| 786160 | 62 | PascalStringWin32 | `label` | `FT Penning Gauge (E-10 Torr):` |
| 786222 | 4 | UInt32 | `type` | `10` |
| 786226 | 4 | UInt32 | `length` | `2` |
| 786230 | 54 | PascalStringWin32 | `label` | `FT Pirani Gauge 1 (Torr):` |
| 786284 | 4 | UInt32 | `type` | `10` |
| 786288 | 4 | UInt32 | `length` | `2` |
| 786292 | 54 | PascalStringWin32 | `label` | `FT Pirani Gauge 2 (Torr):` |
| 786346 | 4 | UInt32 | `type` | `0` |
| 786350 | 4 | UInt32 | `length` | `0` |
| 786354 | 4 | PascalStringWin32 | `label` | `` |
| 786358 | 4 | UInt32 | `type` | `0` |
| 786362 | 4 | UInt32 | `length` | `0` |
| 786366 | 24 | PascalStringWin32 | `label` | `TURBO PUMP` |
| 786390 | 4 | UInt32 | `type` | `13` |
| 786394 | 4 | UInt32 | `length` | `14` |
| 786398 | 18 | PascalStringWin32 | `label` | `Status:` |
| 786416 | 4 | UInt32 | `type` | `9` |
| 786420 | 4 | UInt32 | `length` | `0` |
| 786424 | 30 | PascalStringWin32 | `label` | `Life (hours):` |
| 786454 | 4 | UInt32 | `type` | `9` |
| 786458 | 4 | UInt32 | `length` | `0` |
| 786462 | 26 | PascalStringWin32 | `label` | `Speed (Hz):` |
| 786488 | 4 | UInt32 | `type` | `6` |
| 786492 | 4 | UInt32 | `length` | `0` |
| 786496 | 32 | PascalStringWin32 | `label` | `Power (Watts):` |
| 786528 | 4 | UInt32 | `type` | `10` |
| 786532 | 4 | UInt32 | `length` | `2` |
| 786536 | 36 | PascalStringWin32 | `label` | `Temperature (C):` |
| 786572 | 4 | UInt32 | `type` | `0` |
| 786576 | 4 | UInt32 | `length` | `0` |
| 786580 | 4 | PascalStringWin32 | `label` | `` |
| 786584 | 4 | UInt32 | `type` | `0` |
| 786588 | 4 | UInt32 | `length` | `0` |
| 786592 | 34 | PascalStringWin32 | `label` | `FT TURBO PUMP 1` |
| 786626 | 4 | UInt32 | `type` | `13` |
| 786630 | 4 | UInt32 | `length` | `14` |
| 786634 | 18 | PascalStringWin32 | `label` | `Status:` |
| 786652 | 4 | UInt32 | `type` | `9` |
| 786656 | 4 | UInt32 | `length` | `0` |
| 786660 | 30 | PascalStringWin32 | `label` | `Life (hours):` |
| 786690 | 4 | UInt32 | `type` | `9` |
| 786694 | 4 | UInt32 | `length` | `0` |
| 786698 | 26 | PascalStringWin32 | `label` | `Speed (Hz):` |
| 786724 | 4 | UInt32 | `type` | `6` |
| 786728 | 4 | UInt32 | `length` | `0` |
| 786732 | 32 | PascalStringWin32 | `label` | `Power (Watts):` |
| 786764 | 4 | UInt32 | `type` | `0` |
| 786768 | 4 | UInt32 | `length` | `0` |
| 786772 | 4 | PascalStringWin32 | `label` | `` |
| 786776 | 4 | UInt32 | `type` | `0` |
| 786780 | 4 | UInt32 | `length` | `0` |
| 786784 | 34 | PascalStringWin32 | `label` | `FT TURBO PUMP 2` |
| 786818 | 4 | UInt32 | `type` | `13` |
| 786822 | 4 | UInt32 | `length` | `14` |
| 786826 | 18 | PascalStringWin32 | `label` | `Status:` |
| 786844 | 4 | UInt32 | `type` | `9` |
| 786848 | 4 | UInt32 | `length` | `0` |
| 786852 | 30 | PascalStringWin32 | `label` | `Life (hours):` |
| 786882 | 4 | UInt32 | `type` | `9` |
| 786886 | 4 | UInt32 | `length` | `0` |
| 786890 | 26 | PascalStringWin32 | `label` | `Speed (Hz):` |
| 786916 | 4 | UInt32 | `type` | `6` |
| 786920 | 4 | UInt32 | `length` | `0` |
| 786924 | 32 | PascalStringWin32 | `label` | `Power (Watts):` |
| 786956 | 4 | UInt32 | `type` | `0` |
| 786960 | 4 | UInt32 | `length` | `0` |
| 786964 | 4 | PascalStringWin32 | `label` | `` |
| 786968 | 4 | UInt32 | `type` | `0` |
| 786972 | 4 | UInt32 | `length` | `0` |
| 786976 | 34 | PascalStringWin32 | `label` | `FT TURBO PUMP 3` |
| 787010 | 4 | UInt32 | `type` | `13` |
| 787014 | 4 | UInt32 | `length` | `14` |
| 787018 | 18 | PascalStringWin32 | `label` | `Status:` |
| 787036 | 4 | UInt32 | `type` | `9` |
| 787040 | 4 | UInt32 | `length` | `0` |
| 787044 | 30 | PascalStringWin32 | `label` | `Life (hours):` |
| 787074 | 4 | UInt32 | `type` | `9` |
| 787078 | 4 | UInt32 | `length` | `0` |
| 787082 | 26 | PascalStringWin32 | `label` | `Speed (Hz):` |
| 787108 | 4 | UInt32 | `type` | `6` |
| 787112 | 4 | UInt32 | `length` | `0` |
| 787116 | 32 | PascalStringWin32 | `label` | `Power (Watts):` |
| 787148 | 4 | UInt32 | `type` | `0` |
| 787152 | 4 | UInt32 | `length` | `0` |
| 787156 | 4 | PascalStringWin32 | `label` | `` |
| 787160 | 4 | UInt32 | `type` | `0` |
| 787164 | 4 | UInt32 | `length` | `0` |
| 787168 | 24 | PascalStringWin32 | `label` | `ION OPTICS` |
| 787192 | 4 | UInt32 | `type` | `10` |
| 787196 | 4 | UInt32 | `length` | `2` |
| 787200 | 52 | PascalStringWin32 | `label` | `Multipole 00 Offset (V):` |
| 787252 | 4 | UInt32 | `type` | `10` |
| 787256 | 4 | UInt32 | `length` | `2` |
| 787260 | 26 | PascalStringWin32 | `label` | `Lens 0 (V):` |
| 787286 | 4 | UInt32 | `type` | `10` |
| 787290 | 4 | UInt32 | `length` | `2` |
| 787294 | 50 | PascalStringWin32 | `label` | `Multipole 0 Offset (V):` |
| 787344 | 4 | UInt32 | `type` | `10` |
| 787348 | 4 | UInt32 | `length` | `2` |
| 787352 | 26 | PascalStringWin32 | `label` | `Lens 1 (V):` |
| 787378 | 4 | UInt32 | `type` | `10` |
| 787382 | 4 | UInt32 | `length` | `2` |
| 787386 | 32 | PascalStringWin32 | `label` | `Gate Lens (V):` |
| 787418 | 4 | UInt32 | `type` | `10` |
| 787422 | 4 | UInt32 | `length` | `2` |
| 787426 | 50 | PascalStringWin32 | `label` | `Multipole 1 Offset (V):` |
| 787476 | 4 | UInt32 | `type` | `10` |
| 787480 | 4 | UInt32 | `length` | `2` |
| 787484 | 86 | PascalStringWin32 | `label` | `Multipole RF Amplitude (Vp-p, set point):` |
| 787570 | 4 | UInt32 | `type` | `10` |
| 787574 | 4 | UInt32 | `length` | `2` |
| 787578 | 34 | PascalStringWin32 | `label` | `Front Lens (V):` |
| 787612 | 4 | UInt32 | `type` | `10` |
| 787616 | 4 | UInt32 | `length` | `2` |
| 787620 | 40 | PascalStringWin32 | `label` | `Front Section (V):` |
| 787660 | 4 | UInt32 | `type` | `10` |
| 787664 | 4 | UInt32 | `length` | `2` |
| 787668 | 42 | PascalStringWin32 | `label` | `Center Section (V):` |
| 787710 | 4 | UInt32 | `type` | `10` |
| 787714 | 4 | UInt32 | `length` | `2` |
| 787718 | 38 | PascalStringWin32 | `label` | `Back Section (V):` |
| 787756 | 4 | UInt32 | `type` | `10` |
| 787760 | 4 | UInt32 | `length` | `2` |
| 787764 | 32 | PascalStringWin32 | `label` | `Back Lens (V):` |
| 787796 | 4 | UInt32 | `type` | `10` |
| 787800 | 4 | UInt32 | `length` | `2` |
| 787804 | 48 | PascalStringWin32 | `label` | `Trap Eject Offset (V):` |
| 787852 | 4 | UInt32 | `type` | `10` |
| 787856 | 4 | UInt32 | `length` | `2` |
| 787860 | 70 | PascalStringWin32 | `label` | `FT Transfer Multipole Offset (V):` |
| 787930 | 4 | UInt32 | `type` | `10` |
| 787934 | 4 | UInt32 | `length` | `2` |
| 787938 | 82 | PascalStringWin32 | `label` | `FT Transfer Multipole Amplitude (Vp-p):` |
| 788020 | 4 | UInt32 | `type` | `10` |
| 788024 | 4 | UInt32 | `length` | `2` |
| 788028 | 52 | PascalStringWin32 | `label` | `FT Gate Lens Offset (V):` |
| 788080 | 4 | UInt32 | `type` | `10` |
| 788084 | 4 | UInt32 | `length` | `2` |
| 788088 | 52 | PascalStringWin32 | `label` | `FT Trap Lens Offset (V):` |
| 788140 | 4 | UInt32 | `type` | `10` |
| 788144 | 4 | UInt32 | `length` | `2` |
| 788148 | 68 | PascalStringWin32 | `label` | `FT Storage Multipole Offset (V):` |
| 788216 | 4 | UInt32 | `type` | `10` |
| 788220 | 4 | UInt32 | `length` | `2` |
| 788224 | 80 | PascalStringWin32 | `label` | `FT Storage Multipole Amplitude (Vp-p):` |
| 788304 | 4 | UInt32 | `type` | `10` |
| 788308 | 4 | UInt32 | `length` | `2` |
| 788312 | 58 | PascalStringWin32 | `label` | `FT Reflect Lens Offset (V):` |
| 788370 | 4 | UInt32 | `type` | `10` |
| 788374 | 4 | UInt32 | `length` | `2` |
| 788378 | 60 | PascalStringWin32 | `label` | `FT Main RF Amplitude (Vp-p):` |
| 788438 | 4 | UInt32 | `type` | `10` |
| 788442 | 4 | UInt32 | `length` | `2` |
| 788446 | 50 | PascalStringWin32 | `label` | `FT Main RF Current (A):` |
| 788496 | 4 | UInt32 | `type` | `10` |
| 788500 | 4 | UInt32 | `length` | `2` |
| 788504 | 58 | PascalStringWin32 | `label` | `FT Main RF Frequency (kHz):` |
| 788562 | 4 | UInt32 | `type` | `10` |
| 788566 | 4 | UInt32 | `length` | `2` |
| 788570 | 46 | PascalStringWin32 | `label` | `FT HV Ion Energy (V):` |
| 788616 | 4 | UInt32 | `type` | `10` |
| 788620 | 4 | UInt32 | `length` | `2` |
| 788624 | 38 | PascalStringWin32 | `label` | `FT HV Lens 1 (V):` |
| 788662 | 4 | UInt32 | `type` | `10` |
| 788666 | 4 | UInt32 | `length` | `2` |
| 788670 | 38 | PascalStringWin32 | `label` | `FT HV Lens 2 (V):` |
| 788708 | 4 | UInt32 | `type` | `10` |
| 788712 | 4 | UInt32 | `length` | `2` |
| 788716 | 38 | PascalStringWin32 | `label` | `FT HV Lens 3 (V):` |
| 788754 | 4 | UInt32 | `type` | `10` |
| 788758 | 4 | UInt32 | `length` | `2` |
| 788762 | 38 | PascalStringWin32 | `label` | `FT HV Lens 4 (V):` |
| 788800 | 4 | UInt32 | `type` | `10` |
| 788804 | 4 | UInt32 | `length` | `2` |
| 788808 | 50 | PascalStringWin32 | `label` | `FT HV Push Voltage (V):` |
| 788858 | 4 | UInt32 | `type` | `10` |
| 788862 | 4 | UInt32 | `length` | `2` |
| 788866 | 50 | PascalStringWin32 | `label` | `FT HV Pull Voltage (V):` |
| 788916 | 4 | UInt32 | `type` | `0` |
| 788920 | 4 | UInt32 | `length` | `0` |
| 788924 | 4 | PascalStringWin32 | `label` | `` |
| 788928 | 4 | UInt32 | `type` | `0` |
| 788932 | 4 | UInt32 | `length` | `0` |
| 788936 | 18 | PascalStringWin32 | `label` | `MAIN RF` |
| 788954 | 4 | UInt32 | `type` | `3` |
| 788958 | 4 | UInt32 | `length` | `0` |
| 788962 | 50 | PascalStringWin32 | `label` | `Standing Wave Ratio OK:` |
| 789012 | 4 | UInt32 | `type` | `10` |
| 789016 | 4 | UInt32 | `length` | `2` |
| 789020 | 46 | PascalStringWin32 | `label` | `Main RF Detected (V):` |
| 789066 | 4 | UInt32 | `type` | `10` |
| 789070 | 4 | UInt32 | `length` | `2` |
| 789074 | 46 | PascalStringWin32 | `label` | `RF Detector Temp (C):` |
| 789120 | 4 | UInt32 | `type` | `10` |
| 789124 | 4 | UInt32 | `length` | `2` |
| 789128 | 48 | PascalStringWin32 | `label` | `RF Generator Temp (C):` |
| 789176 | 4 | UInt32 | `type` | `0` |
| 789180 | 4 | UInt32 | `length` | `0` |
| 789184 | 4 | PascalStringWin32 | `label` | `` |
| 789188 | 4 | UInt32 | `type` | `0` |
| 789192 | 4 | UInt32 | `length` | `0` |
| 789196 | 44 | PascalStringWin32 | `label` | `ION DETECTION SYSTEM` |
| 789240 | 4 | UInt32 | `type` | `10` |
| 789244 | 4 | UInt32 | `length` | `2` |
| 789248 | 44 | PascalStringWin32 | `label` | `Dynode Voltage (kV):` |
| 789292 | 4 | UInt32 | `type` | `10` |
| 789296 | 4 | UInt32 | `length` | `2` |
| 789300 | 38 | PascalStringWin32 | `label` | `Multiplier 1 (V):` |
| 789338 | 4 | UInt32 | `type` | `10` |
| 789342 | 4 | UInt32 | `length` | `2` |
| 789346 | 38 | PascalStringWin32 | `label` | `Multiplier 2 (V):` |
| 789384 | 4 | UInt32 | `type` | `0` |
| 789388 | 4 | UInt32 | `length` | `0` |
| 789392 | 4 | PascalStringWin32 | `label` | `` |
| 789396 | 4 | UInt32 | `type` | `0` |
| 789400 | 4 | UInt32 | `length` | `0` |
| 789404 | 26 | PascalStringWin32 | `label` | `FT Analyzer` |
| 789430 | 4 | UInt32 | `type` | `10` |
| 789434 | 4 | UInt32 | `length` | `2` |
| 789438 | 56 | PascalStringWin32 | `label` | `FT CE Measure Voltage (V):` |
| 789494 | 4 | UInt32 | `type` | `10` |
| 789498 | 4 | UInt32 | `length` | `2` |
| 789502 | 54 | PascalStringWin32 | `label` | `FT CE Inject Voltage (V):` |
| 789556 | 4 | UInt32 | `type` | `10` |
| 789560 | 4 | UInt32 | `length` | `2` |
| 789564 | 70 | PascalStringWin32 | `label` | `FT Deflector Measure Voltage (V):` |
| 789634 | 4 | UInt32 | `type` | `10` |
| 789638 | 4 | UInt32 | `length` | `2` |
| 789642 | 68 | PascalStringWin32 | `label` | `FT Deflector Inject Voltage (V):` |
| 789710 | 4 | UInt32 | `type` | `10` |
| 789714 | 4 | UInt32 | `length` | `2` |
| 789718 | 50 | PascalStringWin32 | `label` | `FT Analyzer Temp. (*C):` |
| 789768 | 4 | UInt32 | `type` | `10` |
| 789772 | 4 | UInt32 | `length` | `2` |
| 789776 | 52 | PascalStringWin32 | `label` | `FT Analyzer TEC Voltage:` |
| 789828 | 4 | UInt32 | `type` | `10` |
| 789832 | 4 | UInt32 | `length` | `2` |
| 789836 | 52 | PascalStringWin32 | `label` | `FT Analyzer TEC Current:` |
| 789888 | 4 | UInt32 | `type` | `10` |
| 789892 | 4 | UInt32 | `length` | `2` |
| 789896 | 58 | PascalStringWin32 | `label` | `FT Analyzer TEC Temp. (*C):` |
| 789954 | 4 | UInt32 | `type` | `10` |
| 789958 | 4 | UInt32 | `length` | `2` |
| 789962 | 62 | PascalStringWin32 | `label` | `FT CE Electronics Temp. (*C):` |
| 790024 | 4 | UInt32 | `type` | `10` |
| 790028 | 4 | UInt32 | `length` | `2` |
| 790032 | 70 | PascalStringWin32 | `label` | `FT CE Electronics TEC Temp. (*C):` |
| 790102 | 4 | UInt32 | `type` | `0` |
| 790106 | 4 | UInt32 | `length` | `0` |
| 790110 | 4 | PascalStringWin32 | `label` | `` |
| 790114 | 4 | UInt32 | `type` | `0` |
| 790118 | 4 | UInt32 | `length` | `0` |
| 790122 | 32 | PascalStringWin32 | `label` | `POWER SUPPLIES` |
| 790154 | 4 | UInt32 | `type` | `10` |
| 790158 | 4 | UInt32 | `length` | `2` |
| 790162 | 50 | PascalStringWin32 | `label` | `+5V Supply Voltage (V):` |
| 790212 | 4 | UInt32 | `type` | `10` |
| 790216 | 4 | UInt32 | `length` | `2` |
| 790220 | 52 | PascalStringWin32 | `label` | `-15V Supply Voltage (V):` |
| 790272 | 4 | UInt32 | `type` | `10` |
| 790276 | 4 | UInt32 | `length` | `2` |
| 790280 | 52 | PascalStringWin32 | `label` | `+15V Supply Voltage (V):` |
| 790332 | 4 | UInt32 | `type` | `10` |
| 790336 | 4 | UInt32 | `length` | `2` |
| 790340 | 52 | PascalStringWin32 | `label` | `-18V Supply Voltage (V):` |
| 790392 | 4 | UInt32 | `type` | `10` |
| 790396 | 4 | UInt32 | `length` | `2` |
| 790400 | 52 | PascalStringWin32 | `label` | `+18V Supply Voltage (V):` |
| 790452 | 4 | UInt32 | `type` | `10` |
| 790456 | 4 | UInt32 | `length` | `2` |
| 790460 | 52 | PascalStringWin32 | `label` | `+24V Supply Voltage (V):` |
| 790512 | 4 | UInt32 | `type` | `10` |
| 790516 | 4 | UInt32 | `length` | `2` |
| 790520 | 52 | PascalStringWin32 | `label` | `-28V Supply Voltage (V):` |
| 790572 | 4 | UInt32 | `type` | `10` |
| 790576 | 4 | UInt32 | `length` | `2` |
| 790580 | 52 | PascalStringWin32 | `label` | `+28V Supply Voltage (V):` |
| 790632 | 4 | UInt32 | `type` | `10` |
| 790636 | 4 | UInt32 | `length` | `2` |
| 790640 | 58 | PascalStringWin32 | `label` | `+28V Supply Current (Amps):` |
| 790698 | 4 | UInt32 | `type` | `10` |
| 790702 | 4 | UInt32 | `length` | `2` |
| 790706 | 52 | PascalStringWin32 | `label` | `+36V Supply Voltage (V):` |
| 790758 | 4 | UInt32 | `type` | `10` |
| 790762 | 4 | UInt32 | `length` | `2` |
| 790766 | 54 | PascalStringWin32 | `label` | `-150V Supply Voltage (V):` |
| 790820 | 4 | UInt32 | `type` | `10` |
| 790824 | 4 | UInt32 | `length` | `2` |
| 790828 | 54 | PascalStringWin32 | `label` | `+150V Supply Voltage (V):` |
| 790882 | 4 | UInt32 | `type` | `10` |
| 790886 | 4 | UInt32 | `length` | `2` |
| 790890 | 54 | PascalStringWin32 | `label` | `-300V Supply Voltage (V):` |
| 790944 | 4 | UInt32 | `type` | `10` |
| 790948 | 4 | UInt32 | `length` | `2` |
| 790952 | 54 | PascalStringWin32 | `label` | `+300V Supply Voltage (V):` |
| 791006 | 4 | UInt32 | `type` | `10` |
| 791010 | 4 | UInt32 | `length` | `2` |
| 791014 | 40 | PascalStringWin32 | `label` | `Ambient Temp. (C):` |
| 791054 | 4 | UInt32 | `type` | `0` |
| 791058 | 4 | UInt32 | `length` | `0` |
| 791062 | 4 | PascalStringWin32 | `label` | `` |
| 791066 | 4 | UInt32 | `type` | `0` |
| 791070 | 4 | UInt32 | `length` | `0` |
| 791074 | 38 | PascalStringWin32 | `label` | `FT POWER SUPPLIES` |
| 791112 | 4 | UInt32 | `type` | `10` |
| 791116 | 4 | UInt32 | `length` | `2` |
| 791120 | 48 | PascalStringWin32 | `label` | `FT ICB +15 Supply (V):` |
| 791168 | 4 | UInt32 | `type` | `10` |
| 791172 | 4 | UInt32 | `length` | `2` |
| 791176 | 48 | PascalStringWin32 | `label` | `FT ICB -15 Supply (V):` |
| 791224 | 4 | UInt32 | `type` | `10` |
| 791228 | 4 | UInt32 | `length` | `2` |
| 791232 | 48 | PascalStringWin32 | `label` | `FT ICB +10 Supply (V):` |
| 791280 | 4 | UInt32 | `type` | `10` |
| 791284 | 4 | UInt32 | `length` | `2` |
| 791288 | 48 | PascalStringWin32 | `label` | `FT ICB -10 Supply (V):` |
| 791336 | 4 | UInt32 | `type` | `10` |
| 791340 | 4 | UInt32 | `length` | `2` |
| 791344 | 46 | PascalStringWin32 | `label` | `FT ICB +5 Supply (V):` |
| 791390 | 4 | UInt32 | `type` | `10` |
| 791394 | 4 | UInt32 | `length` | `2` |
| 791398 | 50 | PascalStringWin32 | `label` | `FT ICB +3.3 Supply (V):` |
| 791448 | 4 | UInt32 | `type` | `10` |
| 791452 | 4 | UInt32 | `length` | `2` |
| 791456 | 50 | PascalStringWin32 | `label` | `FT ICB +2.5 Supply (V):` |
| 791506 | 4 | UInt32 | `type` | `10` |
| 791510 | 4 | UInt32 | `length` | `2` |
| 791514 | 50 | PascalStringWin32 | `label` | `FT IOS +275 Supply (V):` |
| 791564 | 4 | UInt32 | `type` | `10` |
| 791568 | 4 | UInt32 | `length` | `2` |
| 791572 | 50 | PascalStringWin32 | `label` | `FT IOS -275 Supply (V):` |
| 791622 | 4 | UInt32 | `type` | `10` |
| 791626 | 4 | UInt32 | `length` | `2` |
| 791630 | 48 | PascalStringWin32 | `label` | `FT IOS +32 Supply (V):` |
| 791678 | 4 | UInt32 | `type` | `10` |
| 791682 | 4 | UInt32 | `length` | `2` |
| 791686 | 48 | PascalStringWin32 | `label` | `FT IOS +15 Supply (V):` |
| 791734 | 4 | UInt32 | `type` | `10` |
| 791738 | 4 | UInt32 | `length` | `2` |
| 791742 | 48 | PascalStringWin32 | `label` | `FT IOS -15 Supply (V):` |
| 791790 | 4 | UInt32 | `type` | `10` |
| 791794 | 4 | UInt32 | `length` | `2` |
| 791798 | 46 | PascalStringWin32 | `label` | `FT IOS +5 Supply (V):` |
| 791844 | 4 | UInt32 | `type` | `10` |
| 791848 | 4 | UInt32 | `length` | `2` |
| 791852 | 48 | PascalStringWin32 | `label` | `FT RF1 Amp. Temp. (C):` |
| 791900 | 4 | UInt32 | `type` | `10` |
| 791904 | 4 | UInt32 | `length` | `2` |
| 791908 | 48 | PascalStringWin32 | `label` | `FT RF1 Amp. Temp. (C):` |
| 791956 | 4 | UInt32 | `type` | `10` |
| 791960 | 4 | UInt32 | `length` | `2` |
| 791964 | 52 | PascalStringWin32 | `label` | `FT TMPC +15V Supply (V):` |
| 792016 | 4 | UInt32 | `type` | `10` |
| 792020 | 4 | UInt32 | `length` | `2` |
| 792024 | 52 | PascalStringWin32 | `label` | `FT TMPC -15V Supply (V):` |
| 792076 | 4 | UInt32 | `type` | `10` |
| 792080 | 4 | UInt32 | `length` | `2` |
| 792084 | 48 | PascalStringWin32 | `label` | `FT TMPC HS Temp. (*C):` |
| 792132 | 4 | UInt32 | `type` | `10` |
| 792136 | 4 | UInt32 | `length` | `2` |
| 792140 | 52 | PascalStringWin32 | `label` | `FT CLTS HS 1 Temp. (*C):` |
| 792192 | 4 | UInt32 | `type` | `10` |
| 792196 | 4 | UInt32 | `length` | `2` |
| 792200 | 52 | PascalStringWin32 | `label` | `FT CLTS HS 2 Temp. (*C):` |
| 792252 | 4 | UInt32 | `type` | `10` |
| 792256 | 4 | UInt32 | `length` | `2` |
| 792260 | 64 | PascalStringWin32 | `label` | `FT Water Chiller Flow (L/min):` |
| 792324 | 4 | UInt32 | `type` | `0` |
| 792328 | 4 | UInt32 | `length` | `0` |
| 792332 | 4 | PascalStringWin32 | `label` | `` |
| 792336 | 4 | UInt32 | `type` | `0` |
| 792340 | 4 | UInt32 | `length` | `0` |
| 792344 | 38 | PascalStringWin32 | `label` | `INSTRUMENT STATUS` |
| 792382 | 4 | UInt32 | `type` | `13` |
| 792386 | 4 | UInt32 | `length` | `10` |
| 792390 | 26 | PascalStringWin32 | `label` | `Instrument:` |
| 792416 | 4 | UInt32 | `type` | `13` |
| 792420 | 4 | UInt32 | `length` | `15` |
| 792424 | 22 | PascalStringWin32 | `label` | `Analysis:` |
| 792446 | 4 | UInt32 | `type` | `0` |
| 792450 | 4 | UInt32 | `length` | `0` |
| 792454 | 4 | PascalStringWin32 | `label` | `` |
| 792458 | 4 | UInt32 | `type` | `0` |
| 792462 | 4 | UInt32 | `length` | `0` |
| 792466 | 28 | PascalStringWin32 | `label` | `SYRINGE PUMP` |
| 792494 | 4 | UInt32 | `type` | `13` |
| 792498 | 4 | UInt32 | `length` | `14` |
| 792502 | 18 | PascalStringWin32 | `label` | `Status:` |
| 792520 | 4 | UInt32 | `type` | `10` |
| 792524 | 4 | UInt32 | `length` | `2` |
| 792528 | 42 | PascalStringWin32 | `label` | `Flow Rate (uL/min):` |
| 792570 | 4 | UInt32 | `type` | `10` |
| 792574 | 4 | UInt32 | `length` | `2` |
| 792578 | 48 | PascalStringWin32 | `label` | `Syringe Diameter (mm):` |
| 792626 | 4 | UInt32 | `type` | `0` |
| 792630 | 4 | UInt32 | `length` | `0` |
| 792634 | 4 | PascalStringWin32 | `label` | `` |
| 792638 | 4 | UInt32 | `type` | `0` |
| 792642 | 4 | UInt32 | `length` | `0` |
| 792646 | 28 | PascalStringWin32 | `label` | `DIVERT VALVE` |
| 792674 | 4 | UInt32 | `type` | `13` |
| 792678 | 4 | UInt32 | `length` | `7` |
| 792682 | 44 | PascalStringWin32 | `label` | `Divert/Inject valve:` |