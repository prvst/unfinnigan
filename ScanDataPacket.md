## Purpose ##

This structure contains the data stream acquired during a single scan and/or its processed forms and ancillary data. The data can be raw time-domain signals, frequency spectra or converted _M/z_ spectra.

Some data necessary for conversion (such as transform coefficients) reside in a separate stream (see ScanEvent).

## Structure (variable size) ##

| size | quantity | substructure | function |
|:-----|:---------|:-------------|:---------|
| _40_ | 0 or 1 | [PacketHeader](PacketHeader.md) | Stores the layout indicator and sizes of the data streams acquired during one scan or derived from it |
| _2·n+1_ | 0 or 1 | [PeakList](PeakList.md) | A list of peak centroids calculated from the profile data |
| _n_ | 0 or 1 | _n_ ⨯ [PeakDescriptor](PeakDescriptor.md) | A list of peak descriptors (_index_, _flags_, _charge_) |
| _n + 1_ | 0 or 1 | [UnknownStream](UnknownStream.md) | A list of floating-point numbers sometimes truncated (or rounded) to the nearest integer |
| _3 ⨯ 9_ | 0 or 1 | _9_ ⨯ [UnknownTriplet](UnknownTriplet.md) | Each triplet starts with an _M/z_ value followed by two floating-point numbers |

Either the profile or the peak list may be absent. The profile may contain various types of data: time-domain signal, frequency-domain signal, or converted _M/z_ spectrum.