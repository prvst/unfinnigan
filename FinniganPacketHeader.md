# `Finnigan::PacketHeader` #

[[source](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/lib/Finnigan/PacketHeader.pm)]

## SYNOPSIS ##

```
use Finnigan;

my $ph = Finnigan::PacketHeader->decode(\*INPUT);
say $ph->layout;
say $ph->profile_size;
```

## Description ##

Calling this decoder is a pre-requisite to reading any scan data. It
reads the data packet layout indicator and the sizes of the data
streams included in the packet.

## Methods ##

  * **decode($stream)**
> > The constructor method

  * **layout**
> > Get the layout indicator. Two values have been sighted so far: 0 and 128

  * **profile\_size**
> > Get the profile size in 4-byte words

  * **peak\_list\_size**
> > Get the peak list size in 4-byte words

  * **low\_mz**


> Get the low end of the _M/z_ range

  * **high\_mz**

> Get the high end of the _M/z_ range

## See Also ##

[PacketHeader](PacketHeader.md) (structure)

[ScanDataPacket](ScanDataPacket.md) (structure)