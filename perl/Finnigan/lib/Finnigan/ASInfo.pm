package Finnigan::ASInfo;

use strict;
use warnings FATAL => qw( all );
our $VERSION = 0.0207;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
                preamble =>  ['object', 'Finnigan::ASInfoPreamble'],
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

Finnigan::ASInfo -- a decoder for autosampler data

=head1 SYNOPSIS

  use Finnigan;
  my $cas_info = Finnigan::ASInfo->decode(\*INPUT);
  $cas_info->dump;

=head1 DESCRIPTION

ASInfo is a structure with uncertain purpose that contains a binary
preamble with autosampler co-ordinates (ASInfoPreamble), followed by
a text string. The text string is apparently a comment; in one
instance where it was non-null, it contained this text: C<384 Well Plate>.

=head2 METHODS

=over 4

=item decode($stream)

The constructor method

=item preamble

Get the Finnigan::ASInfoPreamble object

=back

=head1 SEE ALSO

Finnigan::ASInfoPreamble

L<uf-asinfo>

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
