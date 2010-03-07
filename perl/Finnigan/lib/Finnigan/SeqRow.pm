package Finnigan::SeqRow;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream) = @_;

  my @common_fields = (
		       injection          => ['object',  'Finnigan::InjectionData'],
		       "unknown text[1]"  => ['varstr', 'PascalStringWin32'],
		       "unknown text[2]"  => ['varstr', 'PascalStringWin32'],
		       "id"               => ['varstr', 'PascalStringWin32'],
		       "remark"           => ['varstr', 'PascalStringWin32'],
		       "study"            => ['varstr', 'PascalStringWin32'],
		       "client"           => ['varstr', 'PascalStringWin32'],
		       "laboratory"       => ['varstr', 'PascalStringWin32'],
		       "company"          => ['varstr', 'PascalStringWin32'],
		       "phone"            => ['varstr', 'PascalStringWin32'],
		       "inst method"      => ['varstr', 'PascalStringWin32'],
		       "proc method"      => ['varstr', 'PascalStringWin32'],
		      );

  my $self = Finnigan::Decoder->read($stream, \@common_fields);

  return bless $self, $class;
}

sub injection {
  shift->{data}->{injection}->{value};
}

1;

__END__

=head1 NAME

Finnigan::SeqRow -- a decoder for Finnigan file headers

=head1 SYNOPSIS

  use Finnigan;
  my $header = Finnigan::SeqRow->read(\*INPUT);
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
