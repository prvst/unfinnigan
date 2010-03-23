package Finnigan::Profile;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $layout) = @_;

  my $preamble = [
		  "first value" => ['d', 'Float64'],
		  "step"        => ['d', 'Float64'],
		  "peak count"  => ['V', 'UInt32'],
		  "nbins"       => ['V', 'UInt32'],
		 ];

  my $self = bless Finnigan::Decoder->read($stream, $preamble), $class;
  $self->iterate_object($stream, $self->peak_count, chunks => 'Finnigan::ProfileChunk', $layout);
  return $self;
}

sub peak_count {
  shift->{data}->{"peak count"}->{value};
}

sub first_value {
  shift->{data}->{"first value"}->{value};
}

sub step {
  shift->{data}->{"step"}->{value};
}

sub chunks {
  shift->{data}->{"chunks"}->{value};
}
sub chunk { # a syntactic eye-sore remover
  shift->{data}->{"chunks"}->{value};
}

sub list {
  my $self = shift;
  my $start = $self->first_value;
  my $step = $self->step;
  foreach my $i ( 0 .. $self->peak_count - 1 ) {
    my $chunk = $self->chunk->[$i];
    my $x = $start + $self->chunk->[$i]->first_bin * $step;
    foreach my $j ( 0 .. $self->chunk->[$i]->nbins - 1) {
      $x += $j * $step;
      print "$x\t" . $self->chunk->[$i]->signal->[$j] . "\n";
    }
  }
}

1;
__END__

=head1 NAME

Finnigan::ScanIndexEntry -- decoder for ScanIndexEntry, a linked list item pointing to scan data

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


=head2 EXPORT

None

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
