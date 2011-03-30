package Finnigan::GenericDataDescriptor;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

use overload ('""' => 'stringify');

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
		"type"   => ['V', 'UInt32'],
		"length" => ['V', 'UInt32'],
                "label"  => ['varstr', 'PascalStringWin32'],

	       ];
  my $self = Finnigan::Decoder->read($stream, $fields);

  return bless $self, $class;
}

sub type {
  shift->{data}->{"type"}->{value};
}

sub length {
  shift->{data}->{"length"}->{value};
}

sub label {
  shift->{data}->{"label"}->{value};
}

sub stringify {
  my $self = shift;
  my $type = $self->type;
  my $length = $self->length;
  my $label = $self->label;
  return "$label [type $type, length $length]";
}

sub definition {
  my $self = shift;

  my $type = $self->type;

  # a gap in the listing or a section title
  if ( $type == 0 ) {
    return;
  }

  # c char (a signed byte)
  if ( $type == 0x1 ) {
    return $self->label => ['c', 'Int8'];
  }

  # bool (true/false)
  if ( $type == 0x2 ) {
    return $self->label => ['C', 'UInt8 (true/false)'];
  }
  
  # yes/no
  if ( $type == 0x3 ) {
    return $self->label => ['C', 'UInt8 (yes/no)'];
  }

  # on/off
  if ( $type == 0x4 ) {
    return $self->label => ['C', 'UInt8 (on/off)'];
  }

  # c unsigned char
  if ( $type == 0x5 ) {
    return $self->label => ['C', 'UInt8'];
  }

  # c short
  if ( $type == 0x6 ) {
    return $self->label => ['s', 'Int16'];
  }

  # c unsigned short
  if ( $type == 0x7 ) {
    return $self->label => ['v', 'UInt16'];
  }

  # c long
  if ( $type == 0x8 ) {
    return $self->label => ['l', 'Int32'];
  }

  # c unsigned long
  if ( $type == 0x9 ) {
    return $self->label => ['V', 'UInt32'];
  }

  # c float
  if ( $type == 0xA ) {
    return $self->label => ['f', 'Float32'];
  }

  # c double
  if ( $type == 0xB ) {
    return $self->label => ['d', 'Float64'];
  }

  # asciiz string
  if ( $type == 0xC ) {
    my $l = $self->length;
    return $self->label => ['string', "ASCIIZ:$l"];
  }

  # wide string, zero-terminated
  if ( $type == 0xD ) {
    my $l = $self->length;
    return $self->label => ['string', "UTF-16-LE:$l"];
  }

  die "unkown data type at $self->{addr}, " . $self;
}

1;
__END__

=head1 NAME

Finnigan::GenericDataDescriptor -- a decoder for GenericDataDescriptor, a key to decoding GenericRecord fields

=head1 SYNOPSIS

  use Finnigan;
  my $d = Finnigan::GenericDataDescriptor->decode(\*INPUT);
  say d->type;
  say d->label;

=head1 DESCRIPTION

GenericDataDescriptor stores information about the type, size and name
of a data element in a generic data record.

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
