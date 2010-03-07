package Finnigan::InjectionData;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
                "unknown_long[1]" => ['V',       'UInt32'],
                "n"               => ['V',       'UInt32'],
                "unknown_long[2]" => ['V',       'UInt32'],
                vial              => ['U0C12',   'UTF16LE'],
                "inj volume"      => ['d',       'Float64'],
                "weight"          => ['d',       'Float64'],
                "volume"          => ['d',       'Float64'],
                "istd amount"     => ['d',       'Float64'],
                "dilution factor" => ['d',       'Float64'],
	       ];

  my $self = Finnigan::Decoder->read($stream, $fields);

  return bless $self, $class;
}

1;

__END__

=head1 NAME

Finnigan::InjectionData -- a decoder for Finnigan file headers

=head1 SYNOPSIS

  use Finnigan;
  my $header = Finnigan::InjectionData->read(\*INPUT);
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
