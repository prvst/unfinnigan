package Finnigan::InstID;

use strict;
use warnings FATAL => qw( all );
our $VERSION = 0.0207;

use Finnigan;
use base 'Finnigan::Decoder';

use overload ('""' => 'stringify');

sub decode {
  my ($class, $stream) = @_;

  my $fields = [
                "unknown long[1]"    => ['V',      'UInt32'],
                "unknown long[2]"    => ['V',      'UInt32'],
                "unknown long[3]"    => ['V',      'UInt32'],
                "model[1]"           => ['varstr', 'PascalStringWin32'],
                "model[2]"           => ['varstr', 'PascalStringWin32'],
  ];

  my $self = Finnigan::Decoder->read($stream, $fields);

  bless $self, $class;

  my $insert = [
                "model[3]"             => ['varstr', 'PascalStringWin32'],
  ];
  if ( $self->{data}->{"unknown long[3]"}->{value} > 0 ) {
    $self->SUPER::decode($stream, $insert);
  }

  my $tail = [
                "serial number"      => ['varstr', 'PascalStringWin32'],
                "software version"   => ['varstr', 'PascalStringWin32'],
                "tag[1]"             => ['varstr', 'PascalStringWin32'],
                "tag[2]"             => ['varstr', 'PascalStringWin32'],
                "tag[3]"             => ['varstr', 'PascalStringWin32'],
                "tag[4]"             => ['varstr', 'PascalStringWin32'],
  ];

  $self->SUPER::decode($stream, $tail);
  return $self;
}

sub model {
  shift->{data}->{"model[1]"}->{value};
}

sub serial_number {
  my $self = shift;
  my $value = $self->{data}->{"serial number"}->{value};
  $value = 'NULL' unless $value gt '';
  return $value
}

sub software_version {
  my $self = shift;
  my $value = $self->{data}->{"software version"}->{value};
  $value = 'NULL' unless $value gt '';
  return $value;
}

sub stringify {
  my $self = shift;
  return $self->model
    . ", S/N: " . $self->serial_number
      . "; software version " . $self->software_version;
}

1;
__END__

=head1 NAME

Finnigan::InstID -- a decoder for InstID, a set of instrument identifiers

=head1 SYNOPSIS

  use Finnigan;
  my $inst = Finnigan::InstID->decode(\*INPUT);
  say $inst->model;
  say $inst->serial_number;
  say $inst->software_version;
  $inst->dump;

=head1 DESCRIPTION

InstID is a static (fixed-size) structure containing several
instrument identifiers and some unknown data.

The identifiers include the model name, the serial number and the software version.

=head2 METHODS

=over 4

=item decode($stream)

The constructor method

=item model

Get the first copy of the model attribute (there always seem to be two of them)

=item serial_number

Get the instrument's serial number

=item software_version

Get the version of software that created the data file

=item stringify

Concatenate all IDs in a single line of text

=back

=head1 SEE ALSO

L<uf-instrument>

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
