This structure is an element of SeqRow. It holds a number of injection parameteres.

## Structure ##

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 4 | UInt32 | `unknown_long[1]` | 0 |
| 4 | 4 | UInt32 | `n` | 22 |
| 8 | 4 | UInt32 | `unknown_long[2]` | 2 |
| 12 | 12 | UTF16LE | `vial` | "122" |
| 24 | 8 | Float64 | `inj volume` | 50.0 |
| 32 | 8 | Float64 | `weight` | 0.0 |
| 40 | 8 | Float64 | `volume` | 0.0 |
| 48 | 8 | Float64 | `istd amount` | 0.0 |
| 56 | 8 | Float64 | `dilution factor` | 1.0 |

It is often left entirely blank, with the exception of the row number, `n`.

## Decoding in Hachoir ##

```
class InjectionData(FieldSet):
    endian = LITTLE_ENDIAN

    def createFields(self):
        yield UInt32(self, "unknown long[1]", "Unknown Long")
        yield UInt32(self, "n", "Row Number")
        yield UInt32(self, "unknown long[2]", "Unknown Long")
        yield String(self, "vial", 12, "Vial ID; assigned to InstConfig::MSSerialNum at the end of SeqRow parsing", charset="UTF-16-LE", truncate="\0")
        yield Float64(self, "inj volume", "Injection Volume (ul)")
        yield Float64(self, "weight", "Sample Weight")
        yield Float64(self, "volume", "Sample Volume (ul)")
        yield Float64(self, "istd amount", "Internal Standard Amount")
        yield Float64(self, "df", "Dilution Factor")
```

## Decoding in perl ##

```
  my $fields = [
                "unknown_long[1]" => ['V',       'UInt32'],
                "n"               => ['V',       'UInt32'],
                "unknown_long[2]" => ['V',       'UInt32'],
                vial              => ['U0C12',   'UTF16LE'],
                "inj volume"      => ['d',       'Float64'],
                "weight"          => ['d',       'Float64'],
                "volume"          => ['d',       'Float64'],
                "istd amount"     => ['d',       'Float64'],
                "dilution factor" => ['d',       'Float64'],
	       ];

  my $data = Finnigan::Decoder->read($stream, $fields);
```