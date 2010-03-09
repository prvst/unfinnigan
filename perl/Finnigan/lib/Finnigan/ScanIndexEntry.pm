package Finnigan::ScanIndexEntry;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream) = @_;

  my $fields = [
		"offset"           => ['V',      'UInt32'],
		"index"            => ['V',      'UInt32'],
		"scan event"       => ['v',      'UInt16'],
		"scan segment"     => ['v',      'UInt16'],
		"next"             => ['V',      'UInt32'],
		"unknown long"     => ['V',      'UInt32'],
		"data size"        => ['V',      'UInt32'],
		"start time"       => ['d',      'Float64'],
		"total current"    => ['d',      'Float64'],
		"base intensity"   => ['d',      'Float64'],
		"base mass"        => ['d',      'Float64'],
		"low mz"           => ['d',      'Float64'],
		"high mz"          => ['d',      'Float64'],
	       ];

  my $self = Finnigan::Decoder->read($stream, $fields);

  return bless $self, $class;
}

sub offset {
  shift->{data}->{"offset"}->{value};
}

sub index {
  shift->{data}->{"index"}->{value};
}

sub scan_event {
  shift->{data}->{"scan event"}->{value};
}

sub scan_segment {
  shift->{data}->{"scan segment"}->{value};
}

sub next {
  shift->{data}->{"next"}->{value};
}

sub unknown {
  shift->{data}->{"unknown long"}->{value};
}

sub data_size {
  shift->{data}->{"data size"}->{value};
}

sub start_time {
  shift->{data}->{"start time"}->{value};
}

sub total_current {
  shift->{data}->{"total current"}->{value};
}

sub base_intensity {
  shift->{data}->{"base intensity"}->{value};
}

sub base_mass {
  shift->{data}->{"base mass"}->{value};
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
