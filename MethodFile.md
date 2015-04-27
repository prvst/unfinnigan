## Purpose ##

Contains a Windows OLE2 file which in turn contains a number of method file representations. The purpose of this structure is to embed the OLE2 file tree into the Finnigan data file.

Also, it contains a name translation table mapping the names of the actual system components into the names used in the method files.

## Structure ##

This structure has a variable number of key-value pairs.

### Example 1 (one pair) ###
| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 2666 | 1356 | [FileHeader](FileHeader.md) | `header` | `V.62; 2007-05-23 10:41:28; Mann Lab` |
| 4022 | 4 | UInt32 | `file size` | `22528` |
| 4026 | 92 | PascalStringWin32 | `orig file name` | `C:\DOCUME~1\MANNLA~1\LOCALS~1\Temp\MTH65.tmp` |
| 4118 | 4 | UInt32 | `n` | `1` |
| 4122 | 44 | PascalStringWin32 | `name trans` | `LTQ Orbitrap MS, LTQ` |
| 4166 | 2176 | [OLE2File](OLE2File.md) | `container` | `Windows Compound Binary File: 5 nodes` |

### Example 2 (two pairs) ###
| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 2984 | 1356 | FileHeader | `header` | `V.63; 2008-04-30 14:12:52; LTQ Orbitrap` |
| 4340 | 4 | UInt32 | `file size` | `34304` |
| 4344 | 86 | PascalStringWin32 | `orig file name` | `C:\DOCUME~1\LTQ\LOCALS~1\Temp\MTH1F5E.tmp` |
| 4430 | 4 | UInt32 | `n` | `4` |
| 4434 | 346 | PascalStringWin32 | `name trans` | `LTQ Orbitrap MS, LTQ, Eksigent LC Channel 1, EksigentNanoLcCom_DLL, Eksigent LC Channel 2, EksigentNanoLc_Channel2, Eksigent NanoLC-AS1 Autosampler, NanoLC-AS1 Autosampler` |
| 4780 | 3712 | [OLE2File](OLE2File.md) | `container` | `Windows Compound Binary File: 13 nodes` |


## Decoding in Hachoir ##

The present decoder in Hachoir is incorrect. I did not recognise the proper boundaries between the objects and their possible variations when I first looked at them, and I had no idea what OLE was.

## Decoding in Perl ##

Decoding it in perl is not straightforward either. The [Finnigan::MethodFile](FinniganMethodFile.md) decoder was one of the last to be written and I did not have time to add a new method to [Finnigan::Decoder](FinniganDecoder.md) to decode a set of key-value pairs. Instead, I stashed them in a list, to be converted into a hash with the accessor method.

```
sub decode {
  my ($class, $stream, $version) = @_;

  my @fields = (
                "header"      => ['object', 'Finnigan::FileHeader'],
                "file size"        => ['V',      'UInt32'],
                "orig file name"   => ['varstr', 'PascalStringWin32'],
                "n"                => ['V',      'UInt32'],
               );

  my $self = Finnigan::Decoder->read($stream, \@fields, $version);
  bless $self, $class;

  if ( $self->n ) { # this is a hack, because I don't have an iterate_hash() method
    # the tags come in pairs, so retreive them later with a method
    $self->iterate_scalar($stream, 2*$self->n, "name trans" => ['varstr', 'PascalStringWin32']);
  }

  $self->SUPER::decode($stream, ["container" => ['object', 'Finnigan::OLE2File']]);

  return $self;
}
```