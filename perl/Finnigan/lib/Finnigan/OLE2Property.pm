package Finnigan::OLE2Property;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

use overload ('""' => 'stringify');

sub decode {
  my ($class, $stream, $param) = @_;
  my ($bb_log, $charset) = @$param;

  # do a null read to initialize internal variables
  my $self = Finnigan::Decoder->read($stream, []);
  bless $self, $class;

  my $fields = [
                "name"        => ['string',       'UTF-16-LE:64'],
                "namelen"     => ['v',            'UInt16'],
                "type"        => ['c',            'UInt8'],
                "decorator"   => ['c',            'UInt8'],
                "left"        => ['V',            'UInt32'],
                "right"       => ['V',            'UInt32'],
                "child"       => ['V',            'UInt32'],   # child node (valid for storage and root types
                "clsid"       => ['a16',          'RawBytes'], # CLSID of this storage (valid for storage and root types
                "flags"       => ['a4',           'RawBytes'], # user flags
                "create time" => ['windows_time', 'TimestampWin64'],
                "mod time"    => ['windows_time', 'TimestampWin64'],
                "start"       => ['V',            'UInt32'],   # starting index of the stream (valid for stream and root types)
               ];

  if ( $bb_log == 9 ) {
    push @$fields, (
                    "size"    => ['V',  'UInt32'],   # size in bytes (valid for stream and root types)
                    "padding" => ['a4', 'RawBytes'],
                   );
  }
  else {
    die "small block streams and Uint64 stream size are not implemented";
    push @$fields, (
                    "size"    => ['*',  'UInt64'],   # size in bytes (valid for stream and root types)
                   );
  }

  $self->SUPER::decode($stream, $fields);

  return $self;
}

sub name {
  shift->{data}->{name}->{value};
}

sub size {
  shift->{data}->{size}->{value};
}

sub child {
  shift->{data}->{child}->{value};
}

sub left {
  shift->{data}->{left}->{value};
}

sub right {
  shift->{data}->{right}->{value};
}

sub start {
  shift->{data}->{start}->{value};
}

sub type {
  shift->{data}->{type}->{value};
}


sub stringify {
  my $self = shift;
  my $name = $self->name;
  return $name;
}


1;
__END__

=head1 NAME

Finnigan::OLE2Property -- a decoder for the Property structure in Microsoft OLE2

=head1 SYNOPSIS

  use Finnigan;
  my $method_data = Finnigan::OLE2Property->decode(\*INPUT);
  $method_data->dump;

=head1 DESCRIPTION

...

=head2 EXPORT

None

=head1 SEE ALSO

Finnigan::MethodFile
Finnigan::OLE2File

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
