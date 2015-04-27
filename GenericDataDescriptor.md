## Purpose ##
**GenericDataDescriptor** stores the information on the type, size and name of a data element in a stream of GenericData records. It is the only structural element in [GenericDataHeader](GenericDataHeader.md).

## Structure ##
```
typedef struct {
  UInt32 type,  /* Finnigan data type */
  UInt32 size,  /* storage size in bytes */
  PascalStringWin32 label  /* display label; charset = "UTF-16-LE" */
}
```

<blockquote title='Note'>
<b>Note</b>: All Thermo software runs in Windows on Intel PCs. Because of that, many instances of text strings found in Finnigan files are simply dumps of their internal representations in live Windows software. These strings objects use 2 bytes per character and they start with a length prefix. Here is an example of the PascalStringWin32 encoding of the string '<code>AGC:</code>'<br>
<pre><code>04  00  00  00 'A' 00 'G' 00 'C' 00 ':' 00  00<br>
</code></pre>

Conversely, the Thermo software simply copies these labels from the data files and uses them to display the data in the GUI.<br>
</blockquote>

## Known data types ##

The following mapping is used to parse the data in Finnigan files with an instance of [GenericDataHeader](GenericDataHeader.md). However, neither [GenericDataHeader](GenericDataHeader.md), nor **GenericDataDescriptor** do the mapping. They only store the Finnigan data types, which are mapped into the appropriate machine types in the [GenericRecord](GenericRecord.md) objects.

I have so far seen the following data types:

| Finnigan storage type | used as | machine type | size |
|:----------------------|:--------|:-------------|:-----|
| 0x0 | heading |  | 0 `*`|
| 0x1 | byte | UInt8 | 1 byte `**` |
| 0x3 | boolean | UInt8 | 1 byte |
| 0x4 | byte | UInt8 | 1 byte `**` |
| 0x6 | short | UInt16 | 2 bytes |
| 0x9 | long | UInt32 | 4 bytes |
| 0xA | float | Float32 | 4 bytes |
| 0xB | double | Float64 | 8 bytes |
| 0xC | ascii string | String/ASCII | 1 byte per character + 0x00 `***` |
| 0xD | wide string | String/UTF-16-LE | 2 bytes percharacter + 0x0000 `***` |

<blockquote> <code>*</code> This zero-length object only exists in the header and serves as a means of grouping of the data elements, primarily for rendering in the GUI</blockquote>
<blockquote> <code>**</code> I do not know the difference between these two types. One of them may represent a set of bit flags, rather than a single entity</blockquote>
<blockquote> <code>***</code> These strings can occupy more storage in the file than their length requires; the surplus storge is usually padded with zeroes, so depending on the mechanism used to read shuch strings, they may need to be truncated to the first trailing zero. </blockquote>

## Implementation ##

In addition to simply encoding the **GenericDataDescriptor** structure, the python implementation includes a couple hacks needed to make it work with Hachoir.

```
class GenericDataDescriptor(FieldSet):
    endian = LITTLE_ENDIAN
    ascii_label = None

    def createFields(self):
        yield UInt32(self, "type", "Generic Data Type")
        yield UInt32(self, "size", "size (where applicable)")
        yield PascalStringWin32(self, "label", "Parameter label", charset="UTF-16-LE")
        if self["label"].value:
            self.ascii_label = unicodedata.normalize('NFKD', self["label"].value).encode('ascii','ignore')
            self.ascii_label = self.ascii_label.replace("/", "<sl>")

```

The `unicodedata.normalize()` method is used because Wx, the GUI library used in Hachoir, has problems displaying some unicode characters, such as the degree character (°) in

```
FT RF1 Amp. Temp. (°C):
```

Slashes in `GenericDataDescriptor` labels also need to be replaced, because the label text automatically becomes part of the Hachoir parse tree paths, where the slash character is used as a node delimiter.