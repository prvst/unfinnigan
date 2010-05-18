package Finnigan::ScanParameters;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream, $fields) = @_;

  my $self = Finnigan::Decoder->read($stream, $fields);
  bless $self, $class;
  return $self;
}

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
  say $h->dump;

=head1 DESCRIPTION


=head2 EXPORT

None

=head1 SEE ALSO

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
