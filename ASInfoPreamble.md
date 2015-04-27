ASInfoPreamble is fixed-length structure with some unknown data about the autosampler. It is a component of [ASInfo](ASInfo.md), which includes this preamble and a text string following it.

## Structure ##
### Static size: 24 bytes ###

### When autosampler is present ###

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 4 | UInt32 | `unknown long[1]` | `1` |
| 4 | 4 | UInt32 | `unknown long[2]` | `25` |
| 8 | 4 | UInt32 | `number of wells` | `384` |
| 12 | 4 | UInt32 | `unknown long[3]` | `24` |
| 16 | 4 | UInt32 | `unknown long[4]` | `16` |
| 20 | 4 | UInt32 | `unknown long[5]` | `0` |

<div>
</div>

### Autosampler absent or not used ###

| offset | size | type | key | value |
|:-------|:-----|:-----|:----|:------|
| 0 | 4 | UInt32 | `unknown long[1]` | `0xFFFFFFFF` |
| 4 | 4 | UInt32 | `unknown long[2]` | `0xFFFFFFFF` |
| 8 | 4 | UInt32 | `number of wells` | `0` |
| 12 | 4 | UInt32 | `unknown long[3]` | `0` |
| 16 | 4 | UInt32 | `unknown long[4]` | `0` |
| 20 | 4 | UInt32 | `unknown long[5]` | `4` |