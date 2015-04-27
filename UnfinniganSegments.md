# uf-segments #

## SYNOPSIS ##

```
uf-segments <file>
```

## DESCRIPTION ##

This is a very rough-and-ready means to examine the scan hierarchy in
a Finnigan raw file. All ScanEventTemplate structures are dumped to
STDIN, prepended with their segment and scan event numbers.

## SEE ALSO ##

[Scan event hierarchy](ScanEventHierarchy.md)

[ScanEventTemplate](ScanEventTemplate.md) (structure)

[Finnigan::ScanEventTemplate](FinniganScanEventTemplate.md) (decoder object)