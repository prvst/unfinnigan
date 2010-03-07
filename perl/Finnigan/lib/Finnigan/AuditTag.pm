package Finnigan::AuditTag;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
		time =>         ['windows_time', 'TimestampWin64'],
		"tag[1]" =>     ['U0C50',        'UTF16LE'],
		"tag[2]" =>     ['U0C50',        'UTF16LE'],
		unknown_long => ['V',            'UInt32'],
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

Finnigan::AuditTag -- a decoder for AuditTag, a substructure found in the Finnigan file headers

=head1 SYNOPSIS

  use Finnigan;
  my $tag = Finnigan::AuditTag->read(\*INPUT);
  say $tag->time;

=head1 DESCRIPTION

AuditTag is a structure with uncertain purpose that contains a
timestamp in Windows format and a pair of text tags. These tags seem
to carry the user id of the person who created the
files. Additionally, there is a long integer, possibly carrying the
CRC32 sum of the data file or a portion of it.

=head2 EXPORT

None



=head1 SEE ALSO

Finnigan::FileHeader -- the parent structure

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
