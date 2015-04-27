ASInfo is a variable-length structure containing a static binary
preamble ([ASInfoPreamble](ASInfoPreamble.md)) and a text string describing the auto-sampler (the letters A and S in 'CAS' stand for Auto-Sampler; I do not know what C stands for).

## Structure ##

| offset | size | type | key | example |
|:-------|:-----|:-----|:----|:--------|
| 0 | 24 | [ASInfoPreamble](ASInfoPreamble.md) | `preamble` | ... |
| 24 | 4 | PascalStringWin32 | `text` | `384 Well Plate` |