package Finnigan::CASInfo;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
		preamble =>  ['object', 'Finnigan::CASInfoPreamble'],
		text     =>  ['varstr', 'PascalStringWin32'],
	       ];

  my $self = Finnigan::Decoder->read($stream, $fields);

  return bless $self, $class;
}

sub preamble {
  my ( $self ) = @_;
  $self->{data}->{preamble}->{value};
}

1;
__END__

=head1 NAME

Finnigan::CASInfo -- a decoder for CASInfo, a totally obscure structure standing in the way to interesting data

=head1 SYNOPSIS

  use Finnigan;
  my $cas_info = Finnigan::CASInfo->decode(\*INPUT);
  $cas_info->dump;

=head1 DESCRIPTION

CASInfo is a structure with uncertain purpose that contains a binary
preamble (CASInfoPreamble) and a text string (which is blank in all known
cases).

It may have something to do with Chemical Abstracts. What exactly, is not clear.

=head2 EXPORT

None



=head1 SEE ALSO

Finnigan::CASInfoPreamble

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
