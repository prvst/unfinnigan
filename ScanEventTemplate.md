## Purpose ##

This is a template structure that apparently forms the core of each
ScanEvent structure corresponding to an individual scan. It is an
elment of MSScanEvent hirerachy (that's the name used by Thermo),
which models the grouping of scan events into segments.

The ScanEvent structure in each dependent scan starts with `ScanEventTemplate`, and it augments it with information about precursor ions (where applicable), conversion coefficients, and some other data.

## Structure ##
### Size: 116 bytes ###

| offset | size | type | key | value | remark |
|:-------|:-----|:-----|:----|:------|:-------|
| 0 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI d SIM ms` |  |
| 80 | 4 | UInt32 | `unknown long[1]` | `0` | _suspected controllerType == Controller\_MS_ |
| 84 | 4 | UInt32 | `unknown long[2]` | `1` | _suspected controllerNumber_ |
| 88 | 16 | FractionCollector | `fraction collector` | `[50.00-150.00]` |  |
| 104 | 4 | UInt32 | `unknown long[3]` | `0` |  |
| 108 | 4 | UInt32 | `unknown long[4]` | `0` |  |
| 112 | 4 | UInt32 | `unknown long[5]` | `0` |  |

## The unknowns ##

None of the unknown data varies from sample to sample in the data files I have examined, so it is fair to say that this structure defines the scan type (with all the relevant data stored in ScanEventPreamble) and the scan range (in FractionCollector)

## See also ##

[Scan event hierarchy](ScanEventHierarchy.md)

[ScanEvent](ScanEvent.md) (structure)

[ScanEventPreamble](ScanEventPreamble.md) (structure)

[FractionCollector](FractionCollector.md) (structure)

[Finnigan::ScanEventTemplate](FinniganScanEventTemplate.md) (the decoder object for this structure)