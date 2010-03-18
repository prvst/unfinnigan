package Finnigan::Reaction;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream) = @_;

  my @fields = (
		"precursor mz"      => ['d', 'Float64'],
		"unknown double"    => ['d', 'Float64'],
		"ionization energy" => ['d', 'Float64'],
		"unknown long[1]"   => ['V', 'UInt32'],
		"unknown long[2]"   => ['V', 'UInt32'],
	       );
  my $self = Finnigan::Decoder->read($stream, \@fields);

  return bless $self, $class;
}

sub precursor {
  shift->{data}->{"precursor mz"}->{value};
}

sub energy {
  shift->{data}->{"ionization energy"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::Reaction -- a decoder for Reaction, an object describing ion fragmentation in ScanEvent

=head1 SYNOPSIS

  use Finnigan;
  my $f = Finnigan::Reaction->decode(\*INPUT);
  say f->precursor;
  say f->enengy;

=head1 DESCRIPTION

This object contains a couple of double-precision floating point
numbers that define the precursor ion M/z and, apparently, the enrgy
with which it was whacked (both are conjectures at this time, but very
plausible ones).

There are other elements that currently remain unknown: a double (set
to 1.0 in all observations) and a couple longs.


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
