package Finnigan;

use 5.010000;
use strict;
use warnings;
use Module::Find qw/findsubmod/;

our $VERSION = '0.02';

my @modules = findsubmod __PACKAGE__;

map { eval "require $_" } @modules;

sub list_modules {
  say foreach (sort @modules);
}

1;

__END__

=head1 NAME

Finnigan - A collection of parser modules for decoding structures in
the raw files written by Thermo mass spectrometers

=head1 SYNOPSIS

  use Finnigan;

  my $struct = Finnigan::<Structure>->read(\*STREAM);
  say $struct->keys;

=head1 DESCRIPTION

Finnigan is a dummy parent package whose only purpose is to pull in
all all packages in its namespace. It does no work; all work is done
in sub-modules.

Blah blah blah.

=head2 EXPORT

None by default.


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
