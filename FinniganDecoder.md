# Finnigan::Decoder #

`Finnigan::Decoder` defines the common structure-decoding methods. Specific decoders either use or override these methods, and they augment the base functionality by providing accessors to the decoded data.

The fields to be decoded are passed to the decoder's read() method as an array reference. In this array,  every even item defines the key this field will have in the resulting hash, and every odd item specifies the unpack template for the field.

Perl unpack templates are used to specify the encoding to decode in most fields. Some fields are decoded in a different manner, using the templates such as:

  * `object` -- instructs the current decoder to call another Finnigan decoder at that location.
  * `windows_time` -- instructs Finingan::Decoder to call its own Windows timestamp routine.
  * `varstr` -- decoded as a Windows Pascal string in a special case in the Finnigan::Decoder::read() method.

## Example ##

```
  use Finnigan;

  my $fields = [
		short_int => 'v',
		long_int => 'V',
		ascii_string => 'C60',
		wide_string => 'U0C18',
		audit_tag => 'object=Finnigan::AuditTag',
		time => 'windows_time',
	       ];

  my $data = Finnigan::Decoder->read(\*STREAM, $fields);
```


## Methods ##
  * `read($class, $stream, $fields, $any_arg)`

> Returns a new decoder blessed into class `$class` and initialized with the values read from `$stream` and decoded according to a list of templates specified in `$fields`.

> The fourth argument, `$any_arg`, is not used by the Decoder class, but may be used by derived classes to pass parse context to their component decoders. For example, this can be useful to parse structures whose layout is governed by the data they contain; in such cases, if the layout indicator is read by the top-level decoder, it can be passed to those lower-level decoders whose work depends on it. Also, this argument is used by the user program to pass the Finnigan file version to version-sensitive decoders.

> Here is an example of the template list for a simple decoder:
```
  my $fields = [
		"mz"        => ['f', 'Float32'],
		"abundance" => ['f', 'Float32'],
	       ];
```

  * `decode($stream, $fields, $any_arg)`

> This method must be called on a blessed, instantiated Decoder. The `read()` method calls it internally, but it can also be used by the user code in those cases where not all data can be decoded with a plain list of templates. In some cases, it may be necessary to decode one part of an object, analyse it, make decisions about the rest (calculate sizes, layouts, etc.), and then grow the object under construction by decoding more data from the stream.

  * `iterate_scalar($stream, $count, $name, $desc)`

> This method is similar to the `decode()` metod, in that it does not instantiate a Decoder, but rather adds data to an existing one. Its purpose is to decode simple arrays whose elements have neither structure, nor behaviour, and can be described by a simple list. The list will consist of `$count` elements read into the current Decoder's attribute given in `$name`, according to the template specified in `$desc`. For example, to read a list of 4-byte integers, the template description must be of the form:
```
  $desc = ['V', 'Uint32']
```

  * `iterate_object($stream, $count, $name, $class, $any_arg)`

> Similarly to `iterate_scalar()`, this method can be used to read a list of structures into the current decoder's attribute specified in the `$name` argument, but in this case, the list elements can be complex structures, to be decoded with their own decoder pecified in the `$class` argument. The optional argument `$any_arg` can be used to parse context information to that decoder.

  * `dump(style => <plain|wiki|html>, relative => bool, filter => ['field1', 'field2', ... 'fieldN'])`

> Pretty-prints the decoded object's contents to STDOUT using three styles: 'plain' (the default), 'wiki', and 'html'. The second argument is a boolean that commands the use of relative addresses in the output. The relative addresses start at the head of the object; the absolute addresses start at the head of the file. If the filter argument is given, only those fields in the filter list will be dumped.

  * `purge_unused_data`

> Delete the location, size and type data for all structure elements.  Calling this method will free some memory when no introspection is needeed (the necessary measure in production-grade code)


---

  * `addr`
> Get the seek address of the decoded object

  * `size`
> Get object size

  * `data`

> Get the object's data hash (equivalent to $obj->{data}). Every data hash element contains the decoded value as well as location and type data.

  * `item($key)`

> Get an item by name (equivalent to $obj->{data}->{$key})

  * `values`

> Extract the simple value hash (no location data, only the element names and values)

  * `dump($param)`

> Dump the object's contents in three different styles, using absolute or relative addresses. The attribute `$param->{style}` can be set to `wiki` or `html`, or it can be absent or have any other value, it which case the dump will have a simple tabular format. The attribute `$param->{relative}`is a Boolean, requesting relative addresses when it is set to a truthy value.