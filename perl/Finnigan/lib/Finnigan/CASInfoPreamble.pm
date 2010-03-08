package Finnigan::CASInfoPreamble;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
		unknown_area => ['C20',  'RawBytes'],
		unknown_long => ['V',    'UInt32'],
	       ];

  my $self = Finnigan::Decoder->read($stream, $fields);

  return bless $self, $class;
}

sub time {
  my ( $self ) = @_;
  $self->{data}->{time}->{value};
}

sub tag1 {
  my ( $self ) = @_;
  $self->{data}->{"tag[1]"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::CASInfoPreamble -- a decoder for CASInfoPreamble, a totally obscure structure standing in the way to interesting data

=head1 SYNOPSIS

  use Finnigan;
  my $object = Finnigan::CASInfoPreamble->decode(\*INPUT);
  $object->dump;

=head1 DESCRIPTION

CASInfoPreamble is a structure with uncertain purpose. It is a component of the equally obscure CASInfo.
It has a strange padded area (0xFF x 8  and 0x00 x 12), followed by an unknown long integer.

=head2 EXPORT

None

=head1 SEE ALSO

Finnigan::CASInfo

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
