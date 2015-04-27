## Purpose ##

This is a substructure of ScanDataPacket, which stores the layout indicator and sizes of the data streams acquired during one scan or derived from it.


## Structure ##
### Static size: 40 bytes ###

| offset | size | type | key | example value | interpretation |
|:-------|:-----|:-----|:----|:--------------|:---------------|
| 0 | 4 | UInt32 | `unknown long[1]` | `1` |  |
| 4 | 4 | UInt32 | `profile size` | `5624` | variable size |
| 8 | 4 | UInt32 | `peak list size` | `1161` | _2·n+1_ |
| 12 | 4 | UInt32 | `layout` | `128` |  |
| 16 | 4 | UInt32 | `descriptor list size` | `580` | _n_ |
| 20 | 4 | UInt32 | `size of unknown stream` | `581` | _n + 1_ |
| 24 | 4 | UInt32 | `size of triplet stream` | `27` | _9·3_ |
| 28 | 4 | UInt32 | `unknown long[2]` | `0` |  |
| 32 | 4 | Float32 | `low mz` | `400` |  |
| 36 | 4 | Float32 | `high mz` | `2000` |  |

All stream sizes are measured in 4-byte units (they contain only floating-point numbers); _n_ is the number of called peaks in the peak list. Because each peak in the list contains both the centroid _M/z_ and the calculated signal intensity, the list has the total of _2·n_ numbers, plus one 4-byte integer containing the list length (580 · 2 + 1 = 1161).

## Decoding in Hachoir ##

```

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
```

## Decoding in Perl ##

```

  my $fields = [
		"unknown long[1]"         => ['V',      'UInt32'],
		"profile size"            => ['V',      'UInt32'],
		"peak list size"          => ['V',      'UInt32'],
		"layout"                  => ['V',      'UInt32'],
		"descriptor list size"    => ['V',      'UInt32'],
		"size of unknown stream"  => ['V',      'UInt32'],
		"size of triplet stream"  => ['V',      'UInt32'],
		"unknown long[2]"         => ['V',      'UInt32'],
		"low mz"                  => ['f',      'Float32'],
		"high mz"                 => ['f',      'Float32'],
	       ];

  my $ph = Finnigan::Decoder->read($stream, $fields);
```