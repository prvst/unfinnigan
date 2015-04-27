## Purpose ##

This is a nested-list structure representing the relationships between the various scans done on the sample and their properties. A single sample run is subdivided into segments, and each segment can have multiple scan events of different types. The data for each event type is encoded in a ScanEventTemplate object, which is copied, augmented with specific data, into ScanEvent structures corresponding to individual scans.

The hierarchy of scan types is encoded as simple ordered tree of height 2.

## Structure ##

The hierarchy af scan types as a simple ordered tree of height 2.

`LTQ-FTsampleDataSet1.RAW`

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 64931682 | 4 | UInt32 | nsegs | 2 |
|  |  | **Segment (1)** |  |  |
| 64931686 | 4 | UInt32 | nevents | 1 |
|  |  | [ScanEventTemplate](ScanEventTemplate.md) (1,1) |  |  |
| 64931690 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI Full ms` |
| 64931770 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64931774 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64931778 | 16 | FractionCollector | `fraction collector` | `[300.00-1500.00]` |
| 64931794 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64931798 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64931802 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | **Segment (2)** |  |  |
| 64931806 | 4 | UInt32 | nevents | 1 |
|  |  | ScanEventTemplate (2,1) |  |  |
| 64931810 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI Full ms` |
| 64931890 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64931894 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64931898 | 16 | FractionCollector | `fraction collector` | `[300.00-1500.00]` |
| 64931914 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64931918 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64931922 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | ScanEventTemplate (2,2) |  |  |
| 64931926 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI d SIM ms` |
| 64932006 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64932010 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64932014 | 16 | FractionCollector | `fraction collector` | `[50.00-150.00]` |
| 64932030 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64932034 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64932038 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | ScanEventTemplate (2,3) |  |  |
| 64932042 | 80 | ScanEventPreamble | `preamble` | `ITMS + c ESI d Full ms2` |
| 64932122 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64932126 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64932130 | 16 | FractionCollector | `fraction collector` | `[300.00-2000.00]` |
| 64932146 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64932150 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64932154 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | ScanEventTemplate (2,4)|  |  |
| 64932158 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI d SIM ms` |
| 64932238 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64932242 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64932246 | 16 | FractionCollector | `fraction collector` | `[50.00-150.00]` |
| 64932262 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64932266 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64932270 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | ScanEventTemplate (2,5) |  |  |
| 64932274 | 80 | ScanEventPreamble | `preamble` | `ITMS + c ESI d Full ms2` |
| 64932354 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64932358 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64932362 | 16 | FractionCollector | `fraction collector` | `[300.00-2000.00]` |
| 64932378 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64932382 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64932386 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | ScanEventTemplate (2,6) |  |  |
| 64932390 | 80 | ScanEventPreamble | `preamble` | `FTMS + p ESI d SIM ms` |
| 64932470 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64932474 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64932478 | 16 | FractionCollector | `fraction collector` | `[50.00-150.00]` |
| 64932494 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64932498 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64932502 | 4 | UInt32 | `unknown long[5]` | `0` |
|  |  | ScanEventTemplate (2,7) |  |  |
| 64932506 | 80 | ScanEventPreamble | `preamble` | `ITMS + c ESI d Full ms2` |
| 64932586 | 4 | UInt32 | `unknown long[1]` | `0` |
| 64932590 | 4 | UInt32 | `unknown long[2]` | `1` |
| 64932594 | 16 | FractionCollector | `fraction collector` | `[300.00-2000.00]` |
| 64932610 | 4 | UInt32 | `unknown long[3]` | `0` |
| 64932614 | 4 | UInt32 | `unknown long[4]` | `0` |
| 64932618 | 4 | UInt32 | `unknown long[5]` | `0` |

## Decoding the hierarchy ##

There is no special decoder for this structure. It can be read with a couple loops like so:

```
my $nsegs = Finnigan::Decoder->read(\*INPUT, ['n' => ['V', 'UInt32']])->{data}->{n}->{value};
foreach my $i ( 0 .. $nsegs - 1) {
  my $nevents = Finnigan::Decoder->read(\*INPUT, ['n' => ['V', 'UInt32']])->{data}->{n}->{value};
  foreach my $j ( 0 .. $nevents - 1) {
    my $e = Finnigan::ScanEventTemplate->decode(\*INPUT, $header->version);
    say "($i, $j)";
    $e->dump;
  }
}
```

## See also ##
[ScanEventTemplate](ScanEventTemplate.md) (structure)

[ScanEvent](ScanEvent.md) (structure)

[Finnigan::ScanEventTemplate](FinniganScanEventTemplate.md) (decoder object)