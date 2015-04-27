## Reasons for the change ##

With **v.64** of the Finnigan file format, Thermo introduced 64-bit file pointers and offsets. These pointers could not be fit into the existing index structures and some of them needed to be expanded; in some other cases, the pointer data migrated from one object to the next. Consequently, some structures that were thought to be version-independent no longer are, and the version argument has to be added to their interface.

## Summary of the changes ##

#### 1. RunHeader and SampleInfo ####
  * `Finnigan::RunHeader->sample_info->scan_index_addr` _becomes_ `Finnigan::RunHeader->scan_index_addr`
  * `Finnigan::RunHeader->sample_info->data_addr` _becomes_ `Finnigan::RunHeader->data_addr`
  * `Finnigan::RunHeader->sample_info->inst_log_addr` _becomes_ `Finnigan::RunHeader->inst_log_addr`
  * `Finnigan::RunHeader->sample_info->error_log_addr` _becomes_ `Finnigan::RunHeader->error_log_addr`

> The following command helped me locate all instances where this change was needed:
```
grep -r "run_header->sample_info" bin lib | grep addr
```

#### 2. ScanIndexEntry ####

  * This structure's decoder becomes version dependent:
```
Finnigan::ScanIndexEntry->decode($stream)
```
> becomes
```
Finnigan::ScanIndexEntry->decode($stream, $version)
```


> The following command helped me locate all instances where this change was needed:
```
grep -r ScanIndexEntry lib bin | grep -w decode | grep -vi version
```