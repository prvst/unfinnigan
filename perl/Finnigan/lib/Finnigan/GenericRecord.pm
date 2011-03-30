package Finnigan::GenericRecord;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

sub decode {
  my ($class, $stream, $header) = @_;

  # This is a sleazy way of decoding this structure. The result will be
  # a hash whose keys start with the ordinal numbers of elements;
  # this answers the need to preserve order and to introduce gaps and
  # section titles commanded by the GenericHeader but not present in 
  # the actual record.
  my $self = Finnigan::Decoder->read($stream, $header->field_templates);
  return bless $self, $class;
}

1;
__END__

=head1 NAME

Finnigan::GenericRecord -- a decoder for data structures defined by GenericDataHeader

=head1 SYNOPSIS

  use Finnigan;
  my $d = Finnigan::GenericRecord->decode(\*INPUT, $header);

=head1 DESCRIPTION

Finnigan::GenericRecord is a pass-through decorder that only passes
the field definitions it obtains from the header
(Finnigan::GenericDataHeader) to Finnigan::Decoder.

Because Thermo's GenericRecord objects are odered and may have
"virtual" gaps and section titles in them, the Finnigan::Decoder's
method of stashing the decoded data into a hash is not directly
applicable. A GenericRecord may have duplicate keys and the key order
needs to be preserved. That is why Finnigan::GenericRecord relies on
the B<field_template> method of Finnigan::GenericHeader to insert
ordinal numbers into the keys.

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
