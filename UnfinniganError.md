# uf-error #

## SYNOPSIS ##

```
uf-error <file>
```

## DESCRIPTION ##

**uf-error** prints the list of messages from the embedded error log in
a Finnigan raw file. The messages are timestamped with retention time.

It will exit with no output if there are no error messages.

## SEE ALSO ##

[ErrorLog](ErrorLog.md) (structure)

[Error](Error.md) (structure)

[Finnigan::Error](FinniganError.md) (decoder object)