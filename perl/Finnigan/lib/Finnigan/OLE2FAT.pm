package Finnigan::OLE2FAT;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';
use Carp qw/confess/;

sub decode {
  my ($class, $stream, $param) = @_;
  my ($start, $count) = @$param;

  # do a null read to initialize internal variables
  my $self = Finnigan::Decoder->read($stream, [], $param);
  bless $self, $class;

  $self->{start} = $start; # this is used in Hachoir to generate continuous index in descriptions
  $self->{count} = $count;

  $self->iterate_scalar($stream, $count, sect => ['V', 'UInt32']);

  return $self;
}

sub sect {
  shift->{data}->{sect}->{value};
}


1;
__END__

=head1 NAME

Finnigan::OLE2FAT -- a decoder for FAT Sector, a block allocation structure in OLE2

=head1 SYNOPSIS

  use Finnigan;
  my $sector = Finnigan::OLE2FAT->decode(\*INPUT);
  $sector->dump;

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
