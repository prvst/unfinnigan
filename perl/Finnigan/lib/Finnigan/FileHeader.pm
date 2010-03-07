package Finnigan::FileHeader;

use strict;
use warnings;

use Finnigan;

sub read {
  my ($class, $stream) = @_;

  my $fields = [
		magic => 'v',
		signature => 'U0C18',
		"unknown_long[1]" => 'V',
		"unknown_long[2]" => 'V',
		"unknown_long[3]" => 'V',
		"unknown_long[4]" => 'V',
		version => 'V',
		audit_start => 'object=Finnigan::AuditTag',
		audit_end => 'object=Finnigan::AuditTag',
		"unknown_long[4]" => 'V',
		unknown_area => 'C60',
		tag => 'U0C514',
	       ];

  my $self = Finnigan::Decoder->read($stream, $fields);

  # make sure we're reading the right file
  my $magic = sprintf "%4x", $self->{data}->{magic}->{value};
  die "unrecognized magic number $magic" unless $self->{data}->{magic}->{value} == 0xa101;

  return bless $self, $class;
}

sub version {
  my ( $self ) = @_;
  $self->{data}->{version}->{value};
}

sub audit_start {
  my ( $self ) = @_;
  $self->{data}->{audit_start}->{value};
}

sub audit_end {
  my ( $self ) = @_;
  $self->{data}->{audit_end}->{value};
}

1;

__END__

=head1 NAME

Finnigan::FileHeader -- a decoder for Finnigan file headers

=head1 SYNOPSIS

  use Finnigan;
  my $header = Finnigan::FileHeader->read(\*INPUT);
  say "$file: version " . $header->version . "; " . $header->audit_start->time;

=head1 DESCRIPTION

The key information contained in the Finnigan header is the file
version number. Since the file structure may vary, the parsers better
know the version number, so they can adapt themselves.

=head2 EXPORT

None


=head1 SEE ALSO


=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
