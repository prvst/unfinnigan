package Finnigan::ScanParameters;

use strict;
use warnings;

use Finnigan;
our @ISA = ('Finnigan::GenericRecord');

sub charge_state {
  shift->{data}->{"Charge State:"}->{value}
}

1;
__END__

=head1 NAME

Finnigan::ScanParameters -- a decoder for ScanParameters, a GenericRecord containing various scan meta-data

=head1 SYNOPSIS

  use Finnigan;
  my $h = Finnigan::ScanParameters->decode(\*INPUT, $generic_header_ref);
  say $h->n;
  say $h->charge_state;

=head1 DESCRIPTION

This decoder augments the GenericRecord decoder with the charge_state() method.

=head2 EXPORT

None

=head1 SEE ALSO

Finnigan::GenericRecord
Finnigan::GenericDataHeader
Finnigan::ScanEventPreamble
Finnigan::FractionCollector
Finnigan::Reaction

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
