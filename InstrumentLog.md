## Purpose ##

The instrument log typically tracks more than a hundred parameters, including operational data on the pumps, power supplies, ion optics and injectors -- everything that may be useful in the auditing of the instrument's performance.

Each log record is timestamped with the current retention time of the sample.

The content of the record (besides the timestamp) is designed to be decoded with the GenericDataHeader mechanism.

## Structure ##

| GenericDataHeader (loaded with `InstrumentLog` descriptors) |
|:------------------------------------------------------------|
| InstrumentLogRecord 1  = {timestamp,  GenericRecord} |
| . . . |
| InstrumentLogRecord _n_ = {timestamp, GenericRecord} |

The number of records in the instrument log and the seek address of the first InstrumentLogRecord in the file are contained in SampleInfo, which is prat of RunHeader.

The log header can only be reached by reading through all the preceding structures, making the address of the first record marginally useful (it may be used in a consistency check, for example).

## See Also ##

SampleInfo

[The overview of the file layout](FileLayoutOverview.md)

## Example log record ##


| API SOURCE |  |
|:-----------|:-|
| Source Voltage (kV): | 4.59612512588501 |
| Source Current (uA): | 0.500793814659119 |
| Vaporizer Thermocouple OK: | 0 |
| Vaporizer Temp (C): | -62.0724639892578 |
| Sheath Gas Flow Rate (): | 0.0658124163746834 |
| Aux Gas Flow Rate(): | 0.161437571048737 |
| Sweep Gas Flow Rate(): | 0.0483749583363533 |
| Capillary Temp OK: | 1 |
| Capillary Voltage (V): | 27.977201461792 |
| Capillary Temp (C): | 275.965301513672 |
| Tube Lens Voltage (V): | 104.91024017334 |
|  |  |
| VACUUM |  |
| Vacuum OK: | 1 |
| Ion Gauge Pressure OK: | 1 |
| Ion Gauge Status: | 1 |
| Ion Gauge (E-5 Torr): | 1.62867569923401 |
| Convectron Pressure OK: | 1 |
| Convectron Gauge (Torr): | 0.942075788974762 |
|  |  |
| FT VACUUM |  |
| FT Penning Pressure OK: | 1 |
| FT Penning Gauge (E-10 Torr): | 0.862699747085571 |
| FT Pirani Gauge 1 (Torr): | 0.904080867767334 |
| FT Pirani Gauge 2 (Torr): | 0.00023712070833426 |
|  |  |
| TURBO PUMP |  |
| Status: | Running |
| Life (hours): | 18398 |
| Speed (Hz): | 800 |
| Power (Watts): | 69 |
| Temperature (C): | 53 |
|  |  |
| FT TURBO PUMP 1 |  |
| Status: | Running |
| Life (hours): | 18285 |
| Speed (Hz): | 1499 |
| Power (Watts): | 12 |
|  |  |
| FT TURBO PUMP 2 |  |
| Status: | Running |
| Life (hours): | 18286 |
| Speed (Hz): | 1500 |
| Power (Watts): | 14 |
|  |  |
| FT TURBO PUMP 3 |  |
| Status: | Running |
| Life (hours): | 18286 |
| Speed (Hz): | 1500 |
| Power (Watts): | 14 |
|  |  |
| ION OPTICS |  |
| Multipole 00 Offset (V): | -2.0935959815979 |
| Lens 0 (V): | -1.40861999988556 |
| Multipole 0 Offset (V): | -4.42472410202026 |
| Lens 1 (V): | -14.826416015625 |
| Gate Lens (V): | -64.1004943847656 |
| Multipole 1 Offset (V): | -6.46307992935181 |
| Multipole RF Amplitude (Vp-p, set point): | 401.383209228516 |
| Front Lens (V): | -5.41351985931396 |
| Front Section (V): | -8.93693828582764 |
| Center Section (V): | -11.9450664520264 |
| Back Section (V): | -6.9694128036499 |
| Back Lens (V): | 0.0239285007119179 |
| Trap Eject Offset (V): | 6 |
| FT Transfer Multipole Offset (V): | 5.7109375 |
| FT Transfer Multipole Amplitude (Vp-p): | 500.000366210938 |
| FT Gate Lens Offset (V): | 251.2734375 |
| FT Trap Lens Offset (V): | 250.875 |
| FT Storage Multipole Offset (V): | 8.0703125 |
| FT Storage Multipole Amplitude (Vp-p): | 500.000366210938 |
| FT Reflect Lens Offset (V): | 17.96875 |
| FT Main RF Amplitude (Vp-p): | 2343.3837890625 |
| FT Main RF Current (A): | 0.21084375679493 |
| FT Main RF Frequency (kHz): | 3061.25 |
| FT HV Ion Energy (V): | 1076.77941894531 |
| FT HV Lens 1 (V): | 334.533569335938 |
| FT HV Lens 2 (V): | 0.091552697122097 |
| FT HV Lens 3 (V): | -157.012878417969 |
| FT HV Lens 4 (V): | 0 |
| FT HV Push Voltage (V): | 73.7609939575195 |
| FT HV Pull Voltage (V): | -181.121841430664 |
|  |  |
| MAIN RF |  |
| Standing Wave Ratio OK: | 1 |
| Main RF Detected (V): | -0.000305176014080644 |
| RF Detector Temp (C): | 49.5805816650391 |
| RF Generator Temp (C): | 30.7983627319336 |
|  |  |
| ION DETECTION SYSTEM |  |
| Dynode Voltage (kV): | -14.88831615448 |
| Multiplier 1 (V): | -1036.34606933594 |
| Multiplier 2 (V): | -938.048095703125 |
|  |  |
| FT Analyzer |  |
| FT CE Measure Voltage (V): | -3450.0146484375 |
| FT CE Inject Voltage (V): | -2801.65209960938 |
| FT Deflector Measure Voltage (V): | 296.578887939453 |
| FT Deflector Inject Voltage (V): | 2.22785115242004 |
| FT Analyzer Temp. (**C):**| 26.0009765625 |
| FT Analyzer TEC Voltage: | -0.277099639177322 |
| FT Analyzer TEC Current: | -0.053405798971653 |
| FT Analyzer TEC Temp. (**C):**| 26.551513671875 |
| FT CE Electronics Temp. (**C):**| 32.8226585388184 |
| FT CE Electronics TEC Temp. (**C):**| 33.4572715759277 |
|  |  |
| POWER SUPPLIES |  |
| +5V Supply Voltage (V): | 4.91913175582886 |
| -15V Supply Voltage (V): | -15.016489982605 |
| +15V Supply Voltage (V): | 14.95423412323 |
| -18V Supply Voltage (V): | -17.977352142334 |
| +18V Supply Voltage (V): | 17.9929237365723 |
| +24V Supply Voltage (V): | 23.6980533599854 |
| -28V Supply Voltage (V): | -28.1818313598633 |
| +28V Supply Voltage (V): | 28.2891120910645 |
| +28V Supply Current (Amps): | 0.985840022563934 |
| +36V Supply Voltage (V): | 36.0968170166016 |
| -150V Supply Voltage (V): | -147.541915893555 |
| +150V Supply Voltage (V): | 147.665512084961 |
| -300V Supply Voltage (V): | -296.054290771484 |
| +300V Supply Voltage (V): | 295.385955810547 |
| Ambient Temp. (C): | 40.5853576660156 |
|  |  |
| FT POWER SUPPLIES |  |
| FT ICB +15 Supply (V): | 14.6673583984375 |
| FT ICB -15 Supply (V): | -14.85107421875 |
| FT ICB +10 Supply (V): | 9.9041748046875 |
| FT ICB -10 Supply (V): | -9.886474609375 |
| FT ICB +5 Supply (V): | 4.98474454879761 |
| FT ICB +3.3 Supply (V): | 3.30688714981079 |
| FT ICB +2.5 Supply (V): | 2.49939155578613 |
| FT IOS +275 Supply (V): | 275.366088867188 |
| FT IOS -275 Supply (V): | -275.75 |
| FT IOS +32 Supply (V): | 29.4720897674561 |
| FT IOS +15 Supply (V): | 15.023193359375 |
| FT IOS -15 Supply (V): | -15.2001953125 |
| FT IOS +5 Supply (V): | 4.96246671676636 |
| FT RF1 Amp. Temp. (C): | 26.4251899719238 |
| FT RF1 Amp. Temp. (C): | 24.9817066192627 |
| FT TMPC +15V Supply (V): | 15.03173828125 |
| FT TMPC -15V Supply (V): | -15.0830078125 |
| FT TMPC HS Temp. (**C):**| -0.256347686052322 |
| FT CLTS HS 1 Temp. (**C):**| 30.3134708404541 |
| FT CLTS HS 2 Temp. (**C):**| 30.6072292327881 |
| FT Water Chiller Flow (L/min): | 3.14860010147095 |
|  |  |
| INSTRUMENT STATUS |  |
| Instrument: | On |
| Analysis: | Acquiring |
|  |  |
| SYRINGE PUMP |  |
| Status: | Ready |
| Flow Rate (uL/min): | 0 |
| Syringe Diameter (mm): | 3.25999999046326 |
|  |  |
| DIVERT VALVE |  |
| Divert/Inject valve: | Inject |