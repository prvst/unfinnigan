# `Finnigan::AuditTag` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/AuditTag.pm)]

## SYNOPSIS ##

```
  use Finnigan;
  my $tag = Finnigan::AuditTag->decode(\*INPUT);
  say $tag->time;
```

## Description ##

AuditTag is a structure with uncertain purpose that contains a
timestamp in Windows format and a pair of text tags. These tags seem
to carry the user ID of the person who created the
files. Additionally, there is a long integer, possibly carrying the
CRC-32 sum of the data file or a portion of it.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **time**
> > Get the timestamp

  * **tag1**
> > Get the value of the first tag. The second tag was found to be identical in all cases studied, so there is no **tag2** accessor, but its value can be accessed as `$obj->{data}->{"tag[2]"}->{value}`.

  * **stringify**
> > Returns the timestamp followed by the first tag

## See Also ##

[AuditTag](AuditTag.md) (structure)

[FileHeader](FileHeader.md) (parent structure)

[Finnigan::FileHeader](FinniganFileHeader.md) (parent decoder module)