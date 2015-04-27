# `Finnigan::Error` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/Error.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $entry = Finnigan::Error->decode(\*INPUT);
say $entry->time;
say $entry->message;
```

## Description ##

[Error](Error.md) is a is a varibale-length structure containing timestamped error messages.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **time**
> > Get the entry's timestamp (retention time)

  * **message**
> > Get the text message