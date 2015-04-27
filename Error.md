## Purpose ##

Link an error message to a scan via retention time.

## Structure ##

### Size: variable ###

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 4 | Float32 | `time` | `39.581974029541` |
| 4 | 126 | PascalStringWin32 | `message` | `Dynamic exclusion list is full. Mass 442.78 has been dropped.` |

## Decoding in Hachoir ##

```
class ErrorLogRecord(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield Float32(self, "time", "Retention time")
        yield PascalStringWin32(self, "message", "Error Message")
```

## Decoding in Perl ##

```
my $fields = [
              "time"     => ['f', 'Float32'],
              "message"  =>  ['varstr', 'PascalStringWin32'],
       ];

my $entry = Finnigan::Decoder->read($stream, $fields);
```

## Decoder Object ##

[Finnigan::Error](FinniganError.md)