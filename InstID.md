## Purpose ##

InstID is a variable-size structure containing several instrument identifiers and some unknown data.

## Structure ##

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 8 | RawBytes | `unknown data` | `31` |
| 8 | 4 | UInt32 | `unknown long[1]` | `0` |
| 12 | 10 | PascalStringWin32 | `model[1]` | `LTQ` |
| 22 | 10 | PascalStringWin32 | `model[2]` | `LTQ` |
| 32 | 18 | PascalStringWin32 | `serial number` | `1234567` |
| 50 | 54 | PascalStringWin32 | `software version` | `1.0 Beta 12 (HB 03-12-04)` |
| 104 | 4 | PascalStringWin32 | `tag[1]` | `` |
| 108 | 4 | PascalStringWin32 | `tag[2]` | `` |
| 112 | 4 | PascalStringWin32 | `tag[3]` | `` |
| 116 | 4 | PascalStringWin32 | `tag[4]` | `` |

## Decoding in Hachoir ##

```
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

```

## Decoding in Perl ##

```
  my $fields = [
                "unknown data"       => ['C8',     'RawBytes'],
		"unknown long[1]"    => ['V',      'UInt32'],
		"model[1]"           => ['varstr', 'PascalStringWin32'],
		"model[2]"           => ['varstr', 'PascalStringWin32'],
		"serial number"      => ['varstr', 'PascalStringWin32'],
		"software version"   => ['varstr', 'PascalStringWin32'],
		"tag[1]"             => ['varstr', 'PascalStringWin32'],
		"tag[2]"             => ['varstr', 'PascalStringWin32'],
		"tag[3]"             => ['varstr', 'PascalStringWin32'],
		"tag[4]"             => ['varstr', 'PascalStringWin32'],
	       ];

  my $data = Finnigan::Decoder->read($stream, $fields);
```