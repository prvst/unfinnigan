package Finnigan::OLE2DIF;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

use overload ('""' => 'stringify');

my $NDIF = 109;
my $UNUSED = 0xffffffff;

sub decode {
  my ($class, $stream, $param) = @_;
  my ($start, $count) = @$param;

  # do a null read to initialize internal variables
  my $self = Finnigan::Decoder->read($stream, [], $param);
  bless $self, $class;

  $self->{start} = $start;
  $self->{count} = $count;

  die "non-trivial DIF (DIF count == $count) not implemented" if $count;

  $self->iterate_scalar($stream, $NDIF, sect => ['V', 'UInt32']);

  return $self;
}

sub sect {
  shift->{data}->{sect}->{value};
}

sub stringify {
  my $self = shift;

  my $used = grep {$_ != $UNUSED} @{$self->sect};
  return "Double-Indirect FAT; $used/$NDIF entries used";
}

1;
__END__

=head1 NAME

Finnigan::OLE2DIF -- a decoder for Double-Indirect FAT, a block allocation structure in Microsoft OLE2

=head1 SYNOPSIS

  use Finnigan;
  my $method_data = Finnigan::OLE2DIF->decode(\*INPUT);
  $method_data->dump;

=head1 DESCRIPTION

DIF == Double-Indirect File Allocation Table


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
