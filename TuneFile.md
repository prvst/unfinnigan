I have only a vague idea of the purpose of these data. It seems to be a complete snapshot of the instrument settings at a certain moment of time (at the end of calibration?) Or are these fixed target values for all parameters?

There is some overlap with the data in the InstrumentLog.

For example, in one of the files I see these lens voltages in the InstrumentLogRecord #5:

```
uf-log -n 5 100225.raw | grep Lens\ [01]
5       Lens 0 (V):     -1.45281195640564
5       Lens 1 (V):     -14.8208923339844
```

In the tune file, these voltages have somewhat tidier values:

```
uf-tune  100225.raw | grep Lens\ [01]
Lens 0 Voltage (V):     -1.5
Lens 1 Voltage (V):     -15
Lens 0 Voltage (V):     4.2
Lens 1 Voltage (V):     15
```

The first two values (-1.5V and -15V) come from the POSITIVE POLARITY section of the tune file, and they do correspond to the values in the log record #5 -- the fact that makes me think the tune file has the target settings, while the log file reports the actual running values.

But the overlap is partial: there is a great number of parameters in the tune file never seen in the logs, and there are also values in the log not mentioned in the tune file.

### Location ###

There is no pointer to the Tune File object; it can be reached by seeking to the ErrorLog, reading it, reading the [Scan Event Hierarchy](ScanEventHierarchy.md), then reading the next GenericDataHeader (which happens to be the detached header for the [ScanParameters](ScanParameters.md) stream. After that, the file pointer will be pointing at the Tune File.

### Decoding ###

This object was made to be decoded with the GenericRecord decoder and it does not require its own decoder. Here is how to decode it with the generic decoders:

```
my $tune_file_header = Finnigan::GenericDataHeader->decode(\*INPUT);
my $tune_file = Finnigan::GenericRecord->decode(\*INPUT, $tune_file_header->ordered_field_templates);
$tune_file->dump;
```

### Example tune file ###

| label | value |
|:------|:------|
| Tune File Values |  |
| Source Type: | ESI |
| Capillary Temp (C): | 275 |
| APCI Vaporizer Temp (C): | 0 |
| Sheath Gas Flow (): | 0 |
| Aux Gas Flow (): | 0 |
| Sweep Gas Flow (): | 0 |
| Injection Waveforms: | 1 |
| Ion Trap Zoom AGC Target: | 3000 |
| Ion Trap Full AGC Target: | 30000 |
| Ion Trap SIM AGC Target: | 10000 |
| Ion Trap MSn AGC Target: | 10000 |
| FTMS Injection Waveforms: | 1 |
| FTMS Full AGC Target: | 500000 |
| FTMS SIM AGC Target: | 100000 |
| FTMS MSn AGC Target: | 100000 |
|  |  |
| POSITIVE POLARITY |  |
| Source Voltage (kV): | 4.6 |
| Source Current (uA): | 100 |
| Capillary Voltage (V): | 28 |
| Tube Lens (V): | 105 |
| Skimmer Offset (V): | 0 |
| Multipole RF Amplifier (Vp-p): | 400 |
| Multipole 00 Offset (V): | -2.25 |
| Lens 0 Voltage (V): | -1.5 |
| Multipole 0 Offset (V): | -4.5 |
| Lens 1 Voltage (V): | -15 |
| Gate Lens Offset (V): | -64 |
| Multipole 1 Offset (V): | -6.5 |
| Front Lens (V): | -5.5 |
| Ion Trap Zoom Micro Scans: | 1 |
| Ion Trap Zoom Max Ion Time (ms): | 50 |
| Ion Trap Full Micro Scans: | 1 |
| Ion Trap Full Max Ion Time (ms): | 50 |
| Ion Trap SIM Micro Scans: | 1 |
| Ion Trap SIM Max Ion Time (ms): | 50 |
| Ion Trap MSn Micro Scans: | 1 |
| Ion Trap MSn Max Ion Time (ms): | 200 |
| FTMS Full Micro Scans: | 1 |
| FTMS Full Max Ion Time (ms): | 200 |
| FTMS SIM Micro Scans: | 1 |
| FTMS SIM Max Ion Time (ms): | 50 |
| FTMS MSn Micro Scans: | 1 |
| FTMS MSn Max Ion Time (ms): | 1500 |
|  |  |
| NEGATIVE POLARITY |  |
| Source Voltage (kV): | 5 |
| Source Current (uA): | 100 |
| Capillary Voltage (V): | -35 |
| Tube Lens (V): | -200 |
| Skimmer Offset (V): | 0 |
| Multipole RF Amplifier (Vp-p): | 400 |
| Multipole 00 Offset (V): | 4 |
| Lens 0 Voltage (V): | 4.2 |
| Multipole 0 Offset (V): | 4.5 |
| Lens 1 Voltage (V): | 15 |
| Gate Lens Offset (V): | 35 |
| Multipole 1 Offset (V): | 8 |
| Front Lens (V): | 5.25 |
| Ion Trap Zoom Micro Scans: | 1 |
| Ion Trap Zoom Max Ion Time (ms): | 50 |
| Ion Trap Full Micro Scans: | 1 |
| Ion Trap Full Max Ion Time (ms): | 10 |
| Ion Trap SIM Micro Scans: | 1 |
| Ion Trap SIM Max Ion Time (ms): | 50 |
| Ion Trap MSn Micro Scans: | 1 |
| Ion Trap MSn Max Ion Time (ms): | 100 |
| FTMS Full Micro Scans: | 1 |
| FTMS Full Max Ion Time (ms): | 10 |
| FTMS SIM Micro Scans: | 1 |
| FTMS SIM Max Ion Time (ms): | 50 |
| FTMS MSn Micro Scans: | 1 |
| FTMS MSn Max Ion Time (ms): | 100 |
|  |  |
| Additional FT Tune File Values |  |
| FT Tune Item 1: | 0 |
| FT Tune Item 2: | 0 |
| FT Tune Item 3: | 0 |
| FT Tune Item 4: | 0 |
| FT Tune Item 5: | 0 |
| FT Tune Item 6: | 0 |
| FT Tune Item 7: | 0 |
| FT Tune Item 8: | 0 |
| FT Tune Item 9: | 0 |
| FT Tune Item 10: | 0 |
|  |  |
| Calibration File Values |  |
| Multiple RF Frequency: | 2897.8 |
| Main RF Frequency: | 1191.5 |
| QMSlope0: | 32.6952306540375 |
| QMSlope1: | 32.7889826335866 |
| QMSlope2: | 32.4557312901694 |
| QMSlope3: | 0 |
| QMSlope4: | 0 |
| QMInt0: | -27.4863764106794 |
| QMInt1: | 0 |
| QMInt2: | -31.498598102349 |
| QMInt3: | 0 |
| QMInt4: | 0 |
| End Section Slope: | 0.00329196608776634 |
| End Section Int: | 12 |
| PQD CE Factor: | 11.2042258337125 |
| IsoW Slope: | 0.000289967719325847 |
| IsoW Int: | 0.0218061656043128 |
| Tickle Amp. Slope0: | 4.89838797885841e-05 |
| Tickle Amp. Int0: | 0.00877718350970492 |
| Tickle Amp. Slope1: | 0.002 |
| Tickle Amp. Int1: | 0.4 |
| Tickle Amp. Slope2: | 0.002 |
| Tickle Amp. Int2: | 0.4 |
| Tickle Amp. Slope3: | 0.002 |
| Tickle Amp. Int3: | 0.4 |
| Multiplier 1 Normal Gain: | -1045 |
| Multiplier 1 High Gain: | -1180 |
| Multiplier 2 Normal Gain: | -948 |
| Multiplier 2 High Gain: | -1065 |
| Normal Res. Eject Slope: | 0.0138772617036031 |
| Normal Res. Eject Intercept: | 4.01477059703527 |
| Zoom Res. Eject Slope: | 0.00350774703591171 |
| Zoom Res. Eject Intercept: | 2.46173290836301 |
| Turbo Res. Eject Slope: | 0.0692 |
| Turbo Res. Eject Intercept: | 35 |
| AGC Res. Eject Slope: | 0.0692 |
| AGC Res. Eject Intercept: | 17.3 |
| UltraZoom Res. Eject Slope: | 0.00118545420917888 |
| UltraZoom Res. Eject Intercept: | 0.392234333635423 |
| Normal Mass Slope: | 28.6719560724925 |
| Normal Mass Intercept: | -5.68903033332039 |
| Zoom Mass Slope: | 27.1037565071964 |
| Zoom Mass Intercept: | -44.3436655194345 |
| Turbo Mass Slope: | 28.3680848980717 |
| Turbo Mass Intercept: | 136.675547997898 |
| AGC Mass Slope: | 28.3680848980717 |
| AGC Mass Intercept: | 136.675547997898 |
| UltraZoom Mass Slope: | 27.1331526023409 |
| UltraZoom Mass Intercept: | -34.4321184504399 |
| Vernier Fine Mass Slope: | 429.462235607234 |
| Vernier Fine Mass Intercept: | 0 |
| Vernier Coarse Mass Slope: | 0 |
| Vernier Coarse Mass Intercept: | 0 |
| Cap. Device Min (V): | -138.937117631265 |
| Cap.  Device Max (V): | 138.948397655131 |
| Tube Lens Device Min (V): | 259.030466344069 |
| Tube Lens  Device Max (V): | -257.925925185535 |
| Skimmer Device Min (V): | -139.098825005173 |
| Skimmer Device Max (V): | 138.867432732966 |
| Multipole 00 Device Min (V): | -138.339440124674 |
| Multipole 00 Device Max (V): | 138.211048870593 |
| Lens 0 Device Min (V): | -138.40331367295 |
| Lens 0 Device Max (V): | 138.002968335209 |
| Gate Lens Device Min (V): | -135.619903771826 |
| Gate Lens Device Max (V): | 135.213152911219 |
| Split Gate Device Min (V): | -0.169434792187699 |
| Split Gate Device Max (V): | 0.581632436084885 |
| Multipole 0 Device Min (V): | -138.511284736956 |
| Multipole 0 Device Max (V): | 138.169291454364 |
| Lens 1 Device Min (V): | -138.6984520281 |
| Lens 1 Device Max (V): | 138.452564400154 |
| Multipole 1 Device Min (V): | -138.38711516691 |
| Multipole 1 Device Max (V): | 137.955547082073 |
| Front Lens Device Min (V): | -138.402747350741 |
| Front Lens Device Max (V): | 138.325486931047 |
| Front Section Device Min (V): | -142.346572798178 |
| Front Section Device Max (V): | 141.955307395198 |
| Center Section Device Min (V): | -141.766908533748 |
| Center Section Device Max (V): | 141.790477648133 |
| Back Section Device Min (V): | -142.651476643382 |
| Back Section Device Max (V): | 142.447312897751 |
| Back Lens Device Min (V): | -141.562887415279 |
| Back Lens Device Max (V): | 141.611004592586 |
| FT Cal. Item 1: | 205 |
| FT Cal. Item 2: | 3.51774025494387 |
| FT Cal. Item 3: | 3.51774025494387 |
| FT Cal. Item 4: | 4.35917729198091 |
| FT Cal. Item 5: | 4.35917729198091 |
| FT Cal. Item 6: | 8 |
| FT Cal. Item 7: | 8 |
| FT Cal. Item 8: | 8 |
| FT Cal. Item 9: | 8 |
| FT Cal. Item 10: | 6.58333333333334 |
| FT Cal. Item 11: | 6.58333333333334 |
| FT Cal. Item 12: | 4.49166666666667 |
| FT Cal. Item 13: | 4.49166666666667 |
| FT Cal. Item 14: | 8 |
| FT Cal. Item 15: | 8 |
| FT Cal. Item 16: | 8 |
| FT Cal. Item 17: | 8 |
| FT Cal. Item 18: | 18 |
| FT Cal. Item 19: | 18 |
| FT Cal. Item 20: | 18 |
| FT Cal. Item 21: | 18 |
| FT Cal. Item 22: | 500 |
| FT Cal. Item 23: | 500 |
| FT Cal. Item 24: | 500 |
| FT Cal. Item 25: | 500 |
| FT Cal. Item 26: | 500 |
| FT Cal. Item 27: | 500 |
| FT Cal. Item 28: | 500 |
| FT Cal. Item 29: | 500 |
| FT Cal. Item 30: | 6 |
| FT Cal. Item 31: | 6 |
| FT Cal. Item 32: | 6 |
| FT Cal. Item 33: | 6 |
| FT Cal. Item 34: | 25 |
| FT Cal. Item 35: | 25 |
| FT Cal. Item 36: | 25 |
| FT Cal. Item 37: | 25 |
| FT Cal. Item 38: | 15 |
| FT Cal. Item 39: | 15 |
| FT Cal. Item 40: | 15 |
| FT Cal. Item 41: | 15 |
| FT Cal. Item 42: | 250 |
| FT Cal. Item 43: | 250 |
| FT Cal. Item 44: | 250 |
| FT Cal. Item 45: | 250 |
| FT Cal. Item 46: | 250 |
| FT Cal. Item 47: | 250 |
| FT Cal. Item 48: | 250 |
| FT Cal. Item 49: | 250 |
| FT Cal. Item 50: | 340 |
| FT Cal. Item 51: | 340 |
| FT Cal. Item 52: | 120 |
| FT Cal. Item 53: | 120 |
| FT Cal. Item 54: | 0 |
| FT Cal. Item 55: | 0 |
| FT Cal. Item 56: | 0 |
| FT Cal. Item 57: | 0 |
| FT Cal. Item 58: | 160 |
| FT Cal. Item 59: | 160 |
| FT Cal. Item 60: | 170 |
| FT Cal. Item 61: | 170 |
| FT Cal. Item 62: | 0 |
| FT Cal. Item 63: | 0 |
| FT Cal. Item 64: | 0 |
| FT Cal. Item 65: | 0 |
| FT Cal. Item 66: | 75 |
| FT Cal. Item 67: | 75 |
| FT Cal. Item 68: | 100 |
| FT Cal. Item 69: | 100 |
| FT Cal. Item 70: | 185 |
| FT Cal. Item 71: | 185 |
| FT Cal. Item 72: | 210 |
| FT Cal. Item 73: | 210 |
| FT Cal. Item 74: | 1100 |
| FT Cal. Item 75: | 1100 |
| FT Cal. Item 76: | 1070 |
| FT Cal. Item 77: | 1070 |
| FT Cal. Item 78: | 20 |
| FT Cal. Item 79: | 47484100.3440312 |
| FT Cal. Item 80: | 47484054.4797093 |
| FT Cal. Item 81: | 47483983.5928076 |
| FT Cal. Item 82: | 47483797.3874308 |
| FT Cal. Item 83: | 47484226.6266234 |
| FT Cal. Item 84: | 47484206.0417848 |
| FT Cal. Item 85: | 47484123.6005122 |
| FT Cal. Item 86: | 47483996.1687637 |
| FT Cal. Item 87: | 47475548.5858988 |
| FT Cal. Item 88: | 47475448.3699832 |
| FT Cal. Item 89: | 47475174.5532172 |
| FT Cal. Item 90: | 47475027.0068159 |
| FT Cal. Item 91: | 47475549.7550463 |
| FT Cal. Item 92: | 47475488.4592654 |
| FT Cal. Item 93: | 47475379.1806199 |
| FT Cal. Item 94: | 47475291.5929506 |
| FT Cal. Item 95: | -7913366.33740503 |
| FT Cal. Item 96: | -8885805.82841696 |
| FT Cal. Item 97: | -10752616.2247758 |
| FT Cal. Item 98: | -11429054.2492863 |
| FT Cal. Item 99: | -18394191.9173264 |
| FT Cal. Item 100: | -19284066.1481123 |
| FT Cal. Item 101: | -21545128.2260251 |
| FT Cal. Item 102: | -20457333.415937 |
| FT Cal. Item 103: | -2065724.19496035 |
| FT Cal. Item 104: | -2150250.55760076 |
| FT Cal. Item 105: | -1222778.89028962 |
| FT Cal. Item 106: | 282836.786338346 |
| FT Cal. Item 107: | 4077893.55096619 |
| FT Cal. Item 108: | 1139934.58031036 |
| FT Cal. Item 109: | 183951.994318227 |
| FT Cal. Item 110: | 1470287.70369865 |
| FT Cal. Item 111: | 658063 |
| FT Cal. Item 112: | 1410813.75 |
| FT Cal. Item 113: | 3610003 |
| FT Cal. Item 114: | 5443399 |
| FT Cal. Item 115: | 716468.1875 |
| FT Cal. Item 116: | 1591027 |
| FT Cal. Item 117: | 3593915.5 |
| FT Cal. Item 118: | 5213239.5 |
| FT Cal. Item 119: | 5123728 |
| FT Cal. Item 120: | 9044761 |
| FT Cal. Item 121: | 16740389 |
| FT Cal. Item 122: | 17048454 |
| FT Cal. Item 123: | 2512751.5 |
| FT Cal. Item 124: | 4601645 |
| FT Cal. Item 125: | 9142286 |
| FT Cal. Item 126: | 7718251.5 |
| FT Cal. Item 127: | 351911.898222222 |
| FT Cal. Item 128: | 351911.901569445 |
| FT Cal. Item 129: | 333666.641558333 |
| FT Cal. Item 130: | 333666.646008333 |
| FT Cal. Item 131: | -2.09362915010152 |
| FT Cal. Item 132: | -2.09362915010152 |
| FT Cal. Item 133: | -0.9631197846483 |
| FT Cal. Item 134: | -0.9631197846483 |
| FT Cal. Item 135: | -9.80473438271572 |
| FT Cal. Item 136: | -9.80473438271572 |
| FT Cal. Item 137: | -30.2855541443473 |
| FT Cal. Item 138: | -30.2855541443473 |
| FT Cal. Item 139: | -4.2846354528833 |
| FT Cal. Item 140: | -4.2846354528833 |
| FT Cal. Item 141: | -14.2120179115577 |
| FT Cal. Item 142: | -14.2120179115577 |
| FT Cal. Item 143: | 7.93991044221173 |
| FT Cal. Item 144: | 7.93991044221173 |
| FT Cal. Item 145: | 88.1685178228383 |
| FT Cal. Item 146: | 88.1685178228383 |
| FT Cal. Item 147: | 50 |
| FT Cal. Item 148: | 50 |
| FT Cal. Item 149: | 50 |
| FT Cal. Item 150: | 50 |
| FT Cal. Item 151: | -11.5585395923133 |
| FT Cal. Item 152: | -11.5585395923133 |
| FT Cal. Item 153: | -11.5116896448858 |
| FT Cal. Item 154: | -11.5116896448858 |
| FT Cal. Item 155: | -1.84809739520123 |
| FT Cal. Item 156: | -1.84809739520123 |
| FT Cal. Item 157: | -1.14951875143854 |
| FT Cal. Item 158: | -1.14951875143854 |
| FT Cal. Item 159: | 2300 |
| FT Cal. Item 160: | 2300 |
| FT Cal. Item 161: | 2300 |
| FT Cal. Item 162: | 2300 |
| FT Cal. Item 163: | 0.2 |
| FT Cal. Item 164: | 0.2 |
| FT Cal. Item 165: | 0.2 |
| FT Cal. Item 166: | 0.2 |
| FT Cal. Item 167: | 2840 |
| FT Cal. Item 168: | 2840 |
| FT Cal. Item 169: | 2820 |
| FT Cal. Item 170: | 2820 |
| FT Cal. Item 171: | 3500 |
| FT Cal. Item 172: | 3500 |
| FT Cal. Item 173: | 3500 |
| FT Cal. Item 174: | 3500 |
| FT Cal. Item 175: | 0 |
| FT Cal. Item 176: | 0 |
| FT Cal. Item 177: | 25 |
| FT Cal. Item 178: | 25 |
| FT Cal. Item 179: | 300 |
| FT Cal. Item 180: | 300 |
| FT Cal. Item 181: | 310 |
| FT Cal. Item 182: | 310 |
| FT Cal. Item 183: | 25.9792434313742 |
| FT Cal. Item 184: | 25.9806559691136 |
| FT Cal. Item 185: | 25.9952154480014 |
| FT Cal. Item 186: | 25.9951937660567 |
| FT Cal. Item 187: | 27.3467336838366 |
| FT Cal. Item 188: | -30.7 |
| FT Cal. Item 189: | -74.8000000000002 |
| FT Cal. Item 190: | 50 |
| FT Cal. Item 191: | 1951722 |
| FT Cal. Item 192: | 1951722 |
| FT Cal. Item 193: | 2651780 |
| FT Cal. Item 194: | 2651780 |
| FT Cal. Item 195: | 10070 |
| FT Cal. Item 196: | 0.862655623670652 |
| FT Cal. Item 197: | 0.95 |
| FT Cal. Item 198: | 0.5 |
| FT Cal. Item 199: | 7.5 |
| FT Cal. Item 200: | 7.5 |
| FT Cal. Item 201: | 7 |
| FT Cal. Item 202: | 8 |
| FT Cal. Item 203: | 0.75 |
| FT Cal. Item 204: | 0.8 |
| FT Cal. Item 205: | 0 |
| FT Cal. Item 206: | 0 |
| FT Cal. Item 207: | 0 |
| FT Cal. Item 208: | 0 |
| FT Cal. Item 209: | 0 |
| FT Cal. Item 210: | 0 |
| FT Cal. Item 211: | 0 |
| FT Cal. Item 212: | 0 |
| FT Cal. Item 213: | 0 |
| FT Cal. Item 214: | 0 |
| FT Cal. Item 215: | 0 |
| FT Cal. Item 216: | 0 |
| FT Cal. Item 217: | 0 |
| FT Cal. Item 218: | 0 |
| FT Cal. Item 219: | 0 |
| FT Cal. Item 220: | 0 |
| FT Cal. Item 221: | 0 |
| FT Cal. Item 222: | 0 |
| FT Cal. Item 223: | 0 |
| FT Cal. Item 224: | 0 |
| FT Cal. Item 225: | 0 |
| FT Cal. Item 226: | 0 |
| FT Cal. Item 227: | 0 |
| FT Cal. Item 228: | 0 |
| FT Cal. Item 229: | 0 |
| FT Cal. Item 230: | 0 |
| FT Cal. Item 231: | 0 |
| FT Cal. Item 232: | 0 |
| FT Cal. Item 233: | 0 |
| FT Cal. Item 234: | 0 |
| FT Cal. Item 235: | 0 |
| FT Cal. Item 236: | 0 |
| FT Cal. Item 237: | 0 |
| FT Cal. Item 238: | 0 |
| FT Cal. Item 239: | 0 |
| FT Cal. Item 240: | 0 |
| FT Cal. Item 241: | 0 |
| FT Cal. Item 242: | 0 |
| FT Cal. Item 243: | 0 |
| FT Cal. Item 244: | 0 |
| FT Cal. Item 245: | 0 |
| FT Cal. Item 246: | 0 |
| FT Cal. Item 247: | 0 |
| FT Cal. Item 248: | 0 |
| FT Cal. Item 249: | 0 |
| FT Cal. Item 250: | 0 |