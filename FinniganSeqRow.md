# `Finnigan::SeqRow` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/SeqRow.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $seq_row = Finnigan::SeqRow->decode(\*INPUT, $version);
say $seq_row->comment;
$seq_row->dump;
```

## Description ##

Decodes the data describing the injection that delivered the sample for
analysis to the mass specrometer. The data includes the numeric values bundled in the [Finnigan::InjectionData](FinniganInjectionData.md) object, accompanied by an array of text tags. The recent format versions also include an integer number of unknown meaning.

Judging by the samples I have seen, nobody really understands the purpose of those tags. A couple of them contain the file name and the directory path, apparently pointing to the location where the Finnigan file was originally created.

## Methods ##

  * **decode($stream, $version)**
> > The constructor method

  * **injection**
> > Get the [Finnigan::InjectionData](FinniganInjectionData.md) object

  * **file\_name**
> > Get the original raw file name

  * **path**
> > Get the directory path to the raw file in the source file system

### Methods to be added ###

Since I had not seen this object used by the programs, I did not worry about providing the complete interface for it. Accessors may be added for:

  * the ID field (whatever that is)
  * comment
  * user labels 1 .. 5
  * instrument file name
  * "proc method" (?)
  * vial (apparently, the label on the vial)
  * a whole lot of unknown text tags

## See Also ##

[SeqRow](SeqRow.md) (structure)

[Finnigan::InjectionData](FinniganInjectionData.md) (decoder object)