package Finnigan::Peaks;

use strict;
use warnings FATAL => qw( all );
our $VERSION = 0.02;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my $self = bless Finnigan::Decoder->read($_[1], ["count" => ['V', 'UInt32']]), $_[0];
  return $self->iterate_object(
                               $_[1],
                               $self->{data}->{count}->{value},
                               peaks => 'Finnigan::Peak'
                              );
}

sub count {
  shift->{data}->{count}->{value};
}

sub peaks {
  shift->{data}->{peaks}->{value};
}

sub peak {
  shift->{data}->{peaks}->{value};
}

sub all {
  my $d;
  return [
          map {$d = $_->{data}; [$d->{mz}->{value}, $d->{abundance}->{value}]}
          @{$_[0]->{data}->{peaks}->{value}}
         ];
}

sub list {
  my $self = shift;
  foreach my $peak ( @{$self->peaks} ) {
    print "$peak\n";
  }
}

1;
__END__

=head1 NAME

Finnigan::Peaks -- a decoder for PeaksList, the list of peak centroids

=head1 SYNOPSIS

  use Finnigan;
  my $entry = Finnigan::ScanIndexEntry->decode(\*INPUT);
  say $entry->offset; # returns an offset from the start of scan data stream 
  say $entry->data_size;
  $entry->dump;

=head1 DESCRIPTION

ScanIndexEntry is a static (fixed-size) structure containing the
pointer to a scan, the scan's data size and some auxiliary information
about the scan.

ScanIndexEntry elements seem to form a linked list. Each
ScanIndexEntry contains the index of the next entry.

Although in all observed instances the scans were sequential and their
indices could be ignored, it may not always be the case.

It is not clear whether scan index numbers start at 0 or at 1. If they
start at 0, the list link index must point to the next item. If they
start at 1, then "index" will become "previous" and "next" becomes
"index" -- the list will be linked from tail to head. Although
observations are lacking, I am inclined to interpret it as a
forward-linked list, simply from common sense.


=head2 METHODS

=over 4

=item decode($stream)

The constructor method

=item count

Get the number of peaks in the list

=item peaks

Get the list of Finnigan::Peak objects

=item peak

Same as B<peaks>.  I find the dereference expressions easier to read
when the reference name is singular: C<$scan-E<gt>peak-E<gt>[0]>
(rather than C<$scan-E<gt>peaks-E<gt>[0]>). However, I prefer the
plural form when there is no dereferencing: C<$peaks =
$scan-E<gt>peaks;>q

=item all

Get the reference to an array containing the pairs of abundance? values of each centroided peak. This method avoids the expense of calling the Finnigan::Peak accessors.

=item list

Print the entire peak list to STDOUT

=back


=head1 SEE ALSO

Finnigan::RunHeader

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
