package Finnigan::RawFileInfo;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $version) = @_;

  my $fields = [
		"preamble"          => ['object',  'Finnigan::RawFileInfoPreamble'],
		"label heading[1]"  => ['varstr', 'PascalStringWin32'],
		"label heading[2]"  => ['varstr', 'PascalStringWin32'],
		"label heading[3]"  => ['varstr', 'PascalStringWin32'],
		"label heading[4]"  => ['varstr', 'PascalStringWin32'],
		"label heading[5]"  => ['varstr', 'PascalStringWin32'],
		"unknown text"      => ['varstr', 'PascalStringWin32'],
	       ];

  my $self = Finnigan::Decoder->read($stream, $fields, $version);

  return bless $self, $class;
}

sub preamble {
  shift->{data}->{preamble}->{value};
}

1;
__END__

=head1 NAME

Finnigan::RawFileInfo -- a decoder for RawFileInfo, the RunHeader address container

=head1 SYNOPSIS

  use Finnigan;
  my $file_info = Finnigan::RawFileInfo->decode(\*INPUT);
  say $file_info->preamble->run_header_addr;
  $file_info->dump;

=head1 DESCRIPTION

This structure contains in its binary preamble an unpacked
representation of the UTC file creation date, and (in the modern
versions) a pointer to RunHeader, which in turn stores the pointers to
all data streams in the file.

There are other data elements in the preamble, whose meaning is unkonwn.

The preamble is followed by a few text strings, also of unknown significance.

=head2 EXPORT

None

=head1 SEE ALSO

Finnigan::RawFileInfoPreamble
Finnigan::Runheader

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
