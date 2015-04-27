This type represents a wide character string with a prefix counter (a.k.a. "Pascal string").

## Decoding in Hachoir ##

Use the `PascalStringWin32` type, as in:
```
        yield PascalStringWin32(self, "id", "ID")
```

It assumes the UTF16-LE encoding of the characters.

## Decoding in perl ##

[Finnigan::Decoder](FinniganDecoder.md) has the following case for unpacking the template named `varstr` (which corresponds to PascalStringWin32 in Hachoir):

```
    elsif ( $template eq 'varstr' ) {
      # read the prefix counter into $nchars
      my $bytes_to_read = 4;
      $nbytes = read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $bytes_to_read bytes of the prefix counter in $name at $current_addr";
      my $nchars = unpack "V", $rec;

      # read the 2-byte characters
      $bytes_to_read = 2*$nchars;
      $nbytes = read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $nchars 2-byte characters of $name at $current_addr";
      $value = pack "C*", unpack "U0C*", $rec;
      $nbytes += 4;
    }
```