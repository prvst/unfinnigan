package Finnigan::FractionCollector;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream) = @_;

  my @fields = (
		"low mz"  => ['d', 'Float64'],
		"high mz" => ['d', 'Float64'],
	       );
  my $self = Finnigan::Decoder->read($stream, \@fields);

  return bless $self, $class;
}

sub low {
  shift->{data}->{"low mz"}->{value};
}

sub high {
  shift->{data}->{"high mz"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::FractionCollector -- a decoder for FractionCollector, a mass range object in ScanEvent

=head1 SYNOPSIS

  use Finnigan;
  my $f = Finnigan::FractionCollector->decode(\*INPUT);
  say f->low;
  say f->high;

=head1 DESCRIPTION

This object is just a container for a pair of double-precision floating point
numbers that define the M/z range of ions collected during a scan.

=head2 EXPORT

None

=head1 SEE ALSO

Finnigan::ScanEvent

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
