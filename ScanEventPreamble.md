This fixed-size structure is a byte array at the head of ScanEvent. It
contains various boolean flags an enumerated types with a small number
of values.

A large number of the values in ScanEventPreamble remain unknown.

The structure seems to have grown historically; to the 41 bytes in
v.57, 39 more are added in v.62, and 8 further bytes are added in
v.63.

## Known values ##

| position | meaning | value |
|:---------|:--------|:------|
| 0 |
| 1 |
| 2 | corona | On/Off |
| 3 | detector | { 0 => "valid", 1 => "undefined" } |
| 4 | polarity | { 0 => "negative", 1 => "positive", 2 => "undefined" } |
| 5 | scan mode | { 0 => "centroid", 1 => "profile", 2 => "undefined" } |
| 6 | MS power | { 0 => "undefined", 1 => "MS1", 2 => "MS2", 3 => "MS3", ... } |
| 7 | scan type | { 0 => "Full", 1 => "Zoom", 2 => "SIM", 3 => "SRM", 4 => "CRM", 5 => "undefined", 6 => "Q1", 7 => "Q3" } |
| 8 |
| 9 |
| 10 | dependent | Yes/No |
| 11 | ionization | { 0 => "EI", 1 => "CI", 2 => ""FABI, 3 => "ESI", 4 => "APCI", 5 => "NSI", 6 => "TSI", 7 => "FDI", 8 => "MALDI", 9 => "GDI", 10 => "undefined" } |
| 12 |
| 13 |
| 14 |
| 15 |
| 16 |
| 17 |
| 18 |
| 19 |
| 20 |
| 21 |
| 22 |
| 23 |
| 24 |
| 25 |
| 26 |
| 27 |
| 28 |
| 29 |
| 30 |
| 31 |
| 32 | wideband | On/Off |
| 33 |
| 34 |
| 35 |
| 36 |
| 37 |
| 38 |
| 39 |
| 40 | analyzer | { 0 => "ITMS", 1 => "TQMS", 2 => "SQMS", 3 => "TOFMS", 4 => "FTMS", 5 => "Sector", 6 => "undefined" } |

At the moment, nothing is known about the meaning of bytes 41..128.