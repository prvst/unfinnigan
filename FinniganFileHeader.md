# `Finnigan::FileHeader` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/FileHeader.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $header = Finnigan::FileHeader->decode(\*INPUT);
say "$header";
```

## Description ##

`Finnigan::FileHeader` decodes the fixed-length [FileHeader](FileHeader.md) structure at the start of a Finnigan file containing the file version number.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **version**
> > Get the file version

  * **audit\_start**
> > Get the start [AuditTag](FinniganAuditTag.md) object

  * **audit\_end**
> > Get the end [AuditTag](FinniganAuditTag.md) object

  * **tag**
> > Get the header tag

  * **stringify**
> > Create a short string representation of the header data

## See Also ##

[FileHeader](FileHeader.md) (structure)