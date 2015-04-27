## Purpose ##

This structure is a fixed-size element of the Finnigan [FileHeader](FileHeader.md) structure. It seems to be used to mark the start and the end of the run, or to register the file creation and modification dates. Ff the latter interpretation is true, then the former is also true, meaning that the end of the run is when the file gets modified the last time.

## Structure ##
### Static size: 112 bytes ###
| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 8 | TimestampWin64 | `time` | 1996-05-05 01:31:23 |
| 8 | 50 | UTF16LE | `tag[1]` | linda |
| 58 | 50 | UTF16LE | `tag[2]` | linda |
| 108 | 4 | UInt32 | `unknown_long` | 0 |

<blockquote><b>Note</b>: The timestamp seems to represent the local time. A UTC timestamp corresponding to it is located in RawFileInfoPreamble.</blockquote>

## The unknowns ##

  * `tag[1]` and `tag[2]`: the exact meaning of these tags is unknown; they seem to be used to store the user ID of the person operating the instrument or altering the file; in all instances I have examined these two tags contained identical text.

  * `unknown_long` seems to be used to store a CRC-32 sum of the file or of a portion of it, but this is an unverified conjecture.

## Decoding in Hachoir ##

```
class AuditTag(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield TimestampWin64(self, "start", "Timestamp")
        yield String(self, "tag[1]", 50, charset="UTF-16-LE", truncate="\0")
        yield String(self, "tag[2]", 50, charset="UTF-16-LE", truncate="\0")
        yield UInt32(self, "unknown long", "It seems like in some cases it is used to hold a CRC-32 sum")
```

## Decoding in Perl ##
```
  my $fields = [
		time =>         ['windows_time', 'TimestampWin64'],
		"tag[1]" =>     ['U0C50',        'UTF16LE'],
		"tag[2]" =>     ['U0C50',        'UTF16LE'],
		unknown_long => ['V',            'UInt32'],
	       ];

  my $data = Finnigan::Decoder->read($stream, $fields);
```