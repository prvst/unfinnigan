package Finnigan;

use 5.010000;
use strict;
use warnings;
use Module::Find qw/findsubmod/;

our $VERSION = '0.02';

$Finnigan::activationMethod = 'cid';

my @modules = findsubmod __PACKAGE__;

map { eval "require $_" } @modules;

sub list_modules {
  say foreach (sort @modules);
}

1;

__END__

=head1 NAME

Finnigan - Thermo/Finnigan mass spec data decoder

=head1 SYNOPSIS

  use Finnigan;

  my $struct = Finnigan::Object->decode(\*STREAM);
  $struct->dump;

where 'Object' is a symbol for any of the specific decoder objects,
such as FileHeader, for example, and STREAM is an open filehandle
positioned at the start of the structure to be decoded.

=head1 DESCRIPTION

Finnigan is a non-functional package whose only purpose is to pull in all other
packages in the suite into its namespace. It does no work; all work is
done in the sub-modules.

=head2 METHODS

=over 4

=item list_modules

Gets the list of all submodules using Modules::Find.

=back

=head1 SEE ALSO

All Finnigan sub-modules are described in their own documentation. To
see the list of all available modules, run

  perl -MFinnigan -e 'Finnigan::list_modules'

For more details, see

  http://code.google.com/p/unfinnigan/wiki/WikiHome

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
