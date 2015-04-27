## Structure ##
### Static size: 1356 bytes ###

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 2 | UInt16 | `magic` | 0xA101 |
| 2 | 18 | UTF16LE | `signature` | Finnigan |
| 20 | 4 | UInt32 | `unknown_long[1]` | 0 |
| 24 | 4 | UInt32 | `unknown_long[2]` | 0 |
| 28 | 4 | UInt32 | `unknown_long[3]` | 0 |
| 32 | 4 | UInt32 | `unknown_long[4]` | 524288 (0x08000000) |
| 36 | 4 | UInt32 | `version` | 8 |
| 40 | 112 | AuditTag | `audit_start` | ... |
| 152 | 112 | AuditTag | `audit_end` | ... |
| 264 | 4 | UInt32 | `unknown_long[5]` | 376 |
| 268 | 60 | RawBytes | `unknown_area` | 0 |
| 328 | 1028 | UTF16LE | `tag` | QC=10 pg/ml,IS=100 pg/ml |

The key information contained in the Finnigan header is the file version number. Since the file structure varies from one version to another, the decoders must be aware of it.

Other items of interest are the two AuditTag entries. Each contains a timestamp and a couple text tags, usually containing the ID of the system user who created the file. The timestamps seem to correspond to the start and end of the run, respectively.

In some files, the `tag` field has some text, apparently describing the sample or indicating some parameters of the run. It is intended purpose seems to be a general remark. There are more sample-related remark fields in SampleInfo. In most files, the `tag` field in the file header is blank.

### The unknowns ###

The first four unkonwn longs seem to be the same in all files. The fourth always has this value (0x08000000) in the root file headers, and it is set to 0 in embedded files' headers, such as in MethodFile.

The fifth unknown long value varies from file to file, but I was unable to relate it to anything.

The 60-byte zero-filled are may be just padding, or it may harbour some useful data I have not seen yet.


## Decoding in Hachoir ##

```
class FinniganHeader(FieldSet):
    static_size = 0x054C * 8
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield RawBytes(self, "magic", 2, r'File signature ("\1\xA1")')
        yield CString(self, "signature", "Finnigan signature: \"Finnigan\" (wide string)", charset="UTF-16-LE") #, strip="\0")
        yield UInt32(self, "unknown long[1]", "Unknown long; seems to be the same in all files")
        yield UInt32(self, "unknown long[2]", "Unknown long; seems to be the same in all files")
        yield UInt32(self, "unknown long[3]", "Unknown long; seems to be the same in all files")
        yield UInt32(self, "unknown long[4]", "Unknown long; seems to be the same in all files, except embedded ones, where it is 0")
        yield UInt32(self, "version", "File format version")

        yield AuditTag(self, "audit start", "Start Audit Tag")
        yield AuditTag(self, "audit end", "End Audit Tag")

        yield UInt32(self, "unknown long[5]", "Unknown long, file-specific")
        yield RawBytes(self, "unknown area", 60, "Unknown zero-padded area")
        yield String(self, "tag", 1028, charset="UTF-16-LE", truncate="\0")
```

## Decoding in perl ##

This code is part of the [Finnigan::FileHeader](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/FileHeader.pm) class:

```
  my $fields = [
		magic             => ['v',       'UInt16'],
		signature         => ['U0C18',   'UTF16LE'],
		"unknown_long[1]" => ['V',       'UInt32'],
		"unknown_long[2]" => ['V',       'UInt32'],
		"unknown_long[3]" => ['V',       'UInt32'],
		"unknown_long[4]" => ['V',       'UInt32'],
		version           => ['V',       'UInt32'],
		audit_start       => ['object',  'Finnigan::AuditTag'],
		audit_end         => ['object',  'Finnigan::AuditTag'],
		"unknown_long[5]" => ['V',       'UInt32'],
		unknown_area      => ['C60',     'RawBytes'],
		tag               => ['U0C1028', 'UTF16LE'],
	       ];

  my $data = Finnigan::Decoder->read($stream, $fields);
```