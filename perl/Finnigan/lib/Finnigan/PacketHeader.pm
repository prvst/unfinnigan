package Finnigan::PacketHeader;

use strict;
use warnings FATAL => qw( all );
our $VERSION = 0.0207;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $type) = @_;

  my $fields;
  if ($type and $type == 14) {
    $fields = [
      "data offset"    => ['V',   'UInt32'],
      "low mz"         => ['f<',  'Float32'],
      "high mz"        => ['f<',  'Float32'],
      "bin size"       => ['d<',  'Float64'],
      "profile size"   => ['V',   'UInt32'],
      "padding 1"      => ['l<',  'Int32'],
      "padding 2"      => ['l<',  'Int32'],
      "padding 3"      => ['l<',  'Int32'],
      "padding 4"      => ['l<',  'Int32'],
    ];
  }
  else {
    $fields = [
      "unknown long[1]"         => ['V',      'UInt32'],
      "profile size"            => ['V',      'UInt32'],
      "peak list size"          => ['V',      'UInt32'],
      "layout"                  => ['V',      'UInt32'],
      "descriptor list size"    => ['V',      'UInt32'],
      "size of unknown stream"  => ['V',      'UInt32'],
      "size of triplet stream"  => ['V',      'UInt32'],
      "unknown long[2]"         => ['V',      'UInt32'],
      "low mz"                  => ['f<',     'Float32'],
      "high mz"                 => ['f<',     'Float32'],
    ];
  }

  my $self = Finnigan::Decoder->read($stream, $fields);
  $self->{type} = $type ? $type : 0;

  return bless $self, $class;
}

sub data_offset {
  shift->{data}->{"data offset"}->{value};
}

sub profile_size {
  shift->{data}->{"profile size"}->{value};
}

sub peak_list_size {
  shift->{data}->{"peak list size"}->{value};
}

sub layout {
  shift->{data}->{"layout"}->{value};
}

sub type {
  shift->{type};
}

sub descriptor_list_size {
  shift->{data}->{"descriptor list size"}->{value};
}

sub size_of_unknown_stream {
  shift->{data}->{"size of unknown stream"}->{value};
}

sub size_of_triplet_stream {
  shift->{data}->{"size of triplet stream"}->{value};
}

sub bin_size {
  shift->{data}->{"bin size"}->{value};
}

sub low_mz {
  shift->{data}->{"low mz"}->{value};
}

sub high_mz {
  shift->{data}->{"high mz"}->{value};
}


1;
__END__

=head1 NAME

Finnigan::PacketHeader -- a decoder for PacketHeader, a substructure of ScanDataPaket

=head1 SYNOPSIS

  use Finnigan;
  my $ph = Finnigan::PacketHeader->decode(\*INPUT);
  say $ph->layout;
  say $ph->profile_size;

=head1 DESCRIPTION

Calling this decoder is a pre-requisite to reading any scan data. It
reads the data packet layout indicator and the sizes of the data
streams included in the packet.

There are two versions of scans noted so far. Some have a true header that
preceds variously rendered scan data (profile, peaks, and other data). But
there is also a variant where there is a 4-byte zero at the start of a packet,
followed by an array of abundance data, followed by a trailer that contains
keys to the M/z values. That trailer and the true header are addressed in the
same way, through a pointer in scan index.

These two types of headers have little in common, Finnigan::PacketHeader is a
polymorphic object that switches its representation based on the type
attribute.

=head2 METHODS

=over 4

=item decode($stream)

The constructor method

=item layout

Get the layout indicator. Two values have been sighted so far: 0 and 128

=item type

Get header type. The header of (suspected) type 14 is actually a trailer, but
it is pointed to by scan index and it points to the scan preceding it.

=item data_offset

Get the offset of is packet's data relative to the start of the data stream.
This attribute is only defined in translated profiles.

=item profile_size

Get the profile size in 4-byte words

=item bin_size

Get the M/z bin size

=item peak_list_size

Get the peak list size in 4-byte words

=item low_mz

Get the low end of the M/z range

=item high_mz

Get the high end of the M/z range

=back

=head2 UNUSED METHODS

=over 4

=item descriptor_list_size

=item size_of_triplet_stream

=item size_of_unknown_stream

=back

=head1 SEE ALSO

Finnigan::Profile

Finnigan::Peaks

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
