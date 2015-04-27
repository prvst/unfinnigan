# Finnigan #

`Finnigan` is a non-functional package whose only purpose is to pull in all other
packages in the suite into its namespace. It does no work; all work is
done in the sub-modules.

## SYNOPSIS ##

```
use Finnigan;

my $struct = Finnigan::Object->decode(\*STREAM);
$struct->dump;
```

where 'Object' is a symbol for any of the specific decoder objects,
such as [Finnigan::FileHeader](FinniganFileHeader.md), for example, and `STREAM` is an open filehandle positioned at the start of the structure to be decoded.

## Description ##

Besides its function as the namespace root for the Finnigan suite of modules, this module defines a convenience method, **list\_modules()**. One possible use for it is to obtain the current list of modules on the command line:

```
perl -MFinnigan -e 'Finnigan::list_modules'
```

Additionally, it defines the `$VERSION` variable for the package (used in [Makefile.PL](http://code.google.com/p/unfinnigan/source/browse/perl/Finnigan/Makefile.PL)), and it can also be the place to set the default values for package globals:

```
  $Finnigan::activationMethod = 'cid';
```

(_Setting the activation method globally is a hack, and it will be needed for only as long as we don't know where the actual activation method value is stored in the data files, but this is the proper place for similar hacks. An alternative -- creating a dummy method in the decoder -- does not seem to be as good._)