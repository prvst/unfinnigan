`hexdump` has all the same functions as `od`, but its options are somewhat easier to type. The following command will dump the data part of the instrument method in a raw data file:

```
uf-meth sample.raw -p LTQ/Data | hexdump -C
```