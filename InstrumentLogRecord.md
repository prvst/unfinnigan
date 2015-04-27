## Description ##

The instrument log records contain more than a hundred parameters, including operational data on the pumps, power supplies, ion optics and injectors -- everything that may be useful in the auditing of the instrument's performance.

Each record is timestamped with the current retention time of the sample (a 32-bit floating point number).

The content of the record (besides the timestamp) is designed to be decoded with the GenericDataHeader.

## Structure ##
### Size: fixed, varies with the file version ###