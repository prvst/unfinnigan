package Finnigan::Profile;

use strict;
use warnings FATAL => qw( all );
use Carp;

use Finnigan;
use base 'Finnigan::Decoder';

my $preamble = [
                "first value" => ['d', 'Float64'],
                "step"        => ['d', 'Float64'],
                "peak count"  => ['V', 'UInt32'],
                "nbins"       => ['V', 'UInt32'],
               ];


sub decode {
  my $self = bless Finnigan::Decoder->read($_[1], $preamble), $_[0];
  return $self->iterate_object($_[1], $self->{data}->{"peak count"}->{value}, chunks => 'Finnigan::ProfileChunk', $_[2]); # the last arg is layout
}

sub peak_count {
  shift->{data}->{"peak count"}->{value};
}

sub nbins {
  shift->{data}->{"nbins"}->{value};
}

sub first_value {
  shift->{data}->{"first value"}->{value};
}

sub step {
  my $self = shift;
  confess "undefined" unless $self;
  $self->{data}->{"step"}->{value};
}

sub chunks {
  shift->{data}->{"chunks"}->{value};
}

sub chunk { # a syntactic eye-sore remover
  shift->{data}->{"chunks"}->{value};
}

sub converter {
  $_[0]->{converter};
}

sub set_converter {
  $_[0]->{converter} = $_[1];
}

sub inverse_converter {
  $_[0]->{"inverse converter"};
}

sub set_inverse_converter {
  $_[0]->{"inverse converter"} = $_[1];
}

sub bins {
  my ($self, $range, $add_zeroes) = @_;
  my @list;
  my $start = $self->{data}->{"first value"}->{value};
  my $step = $self->{data}->{step}->{value};
  unless ( $range ) {
    unless ( exists $self->{converter} ) {
      $range = [$start, $start + $self->{data}->{nbins}->{value} * $step];
    }
  }

  push @list, [$range->[0], 0] if $add_zeroes;
  my $last_bin_written = 0;

  my $shift = 0; # this is declared outside the chunk loop to allow
                 # writing the empty bin following the last chunk with
                 # the same amount of shift as in the last chunk

  foreach my $i ( 0 .. $self->{data}->{"peak count"}->{value} - 1 ) { # each chunk
    my $chunk = $self->{data}->{chunks}->{value}->[$i];
    my $first_bin = $chunk->{data}->{"first bin"}->{value};
    $shift = $chunk->{data}->{fudge} ? $chunk->{data}->{fudge}->{value} : 0;
    my $x = $start + $first_bin * $step;

    if ( $add_zeroes and $last_bin_written < $first_bin - 1) {
      # add an empty bin ahead of the chunk, unless there is no gap
      # between this and the previous chunk
      my $x0 = $x - $step;
      my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x0) + $shift : $x0;
      push @list, [$x_conv, 0];
    }

    foreach my $j ( 0 .. $chunk->{data}->{nbins}->{value} - 1) {
      my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift : $x;
      $x += $step;
      if ( $range ) {
        if ( exists $self->{converter} ) {
          next unless $x_conv >= $range->[0] and $x_conv <= $range->[1];
        }
        else {
          # frequencies have the reverse order
          next unless $x_conv <= $range->[0] and $x_conv >= $range->[1];
        }
      }
      my $bin = $first_bin + $j;
      push @list, [$x_conv, $chunk->{data}->{signal}->{value}->[$j]];
      $last_bin_written = $first_bin + $j;
    }

    if ( $add_zeroes
         and
         $i < $self->{data}->{"peak count"}->{value} - 1
         and
         $last_bin_written < $self->{data}->{chunks}->{value}->[$i+1]->{data}->{"first bin"}->{value} - 1
       ) {
      # add an empty bin following the chunk, unless there is no gap
      # between this and the next chunk
      my $bin = $last_bin_written + 1;
      # $x has been incremented inside the chunk loop
      my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift: $x;
      push @list, [$x_conv, 0];
      $last_bin_written++;
    }
  }

  if ( $add_zeroes and $last_bin_written < $self->{data}->{nbins}->{value} - 1 ) {
    # add an empty bin following the last chunk, unless there is no gap
    # left between it and the end of the range ($self->nbins - 1)
    my $x = $start + ($last_bin_written + 1) * $step;
    my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift: $x;
    push @list, [$x_conv, 0];
    push @list, [$range->[1], 0] if $add_zeroes;
  }
  return \@list;
}

sub print_bins {
  my ($self, $range, $add_zeroes) = @_;
  my @list;
  my $data = $self->{data};
  my $start = $data->{"first value"}->{value};
  my $step = $data->{step}->{value};
  my $chunks = $data->{chunks}->{value};

  unless ( $range ) {
    unless (exists $self->{converter} ) {
      $range = [$start, $start + $data->{nbins}->{value} * $step];
    }
  }

  print "$range->[0]\t0\n" if $add_zeroes;

  my $shift = 0; # this is declared outside the chunk loop to allow
                 # writing the empty bin following the last chunk with
                 # the same amount of shift as in the last chunk

  foreach my $i ( 0 .. $data->{"peak count"}->{value} - 1 ) { # each chunk
    my $chunk = $chunks->[$i]->{data};
    my $first_bin = $chunk->{"first bin"}->{value};
    $shift = $chunk->{fudge} ? $chunk->{fudge}->{value} : 0;
    my $x = $start + $first_bin * $step;
    my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift : $x;

    # print all points in the chunk that fall within the specified range
    foreach my $j ( 0 .. $chunk->{nbins}->{value} - 1) {
      my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift : $x;
      $x += $step;
      if ( $range ) {
        if ( exists $self->{converter} ) {
          next unless $x_conv >= $range->[0] and $x_conv <= $range->[1];
        }
        else {
          # frequencies have the reverse order
          next unless $x_conv <= $range->[0] and $x_conv >= $range->[1];
        }
      }
      my $bin = $first_bin + $j;
      print "$x_conv\t" . $chunk->{signal}->{value}->[$j] . "\n";
    }

    if ( $add_zeroes and $i < $data->{"peak count"}->{value} - 1 ) {
      my $from = $chunks->[$i]->first_bin + $chunks->[$i]->{data}->{nbins}->{value};
      my $to = $chunks->[$i+1]->first_bin - 1;
      if ($to >= $from) {
        foreach my $bin ( $from .. $to ) {
          my $x = $start + $bin * $step;
          my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift: $x;
          if ( $range ) {
            if ( exists $self->{converter} ) {
              next unless $x_conv >= $range->[0] and $x_conv <= $range->[1];
            }
            else {
              # frequencies have the reverse order
              next unless $x_conv <= $range->[0] and $x_conv >= $range->[1];
            }
          }
          print "$x_conv\t0\n";
        }
      }
    }
  }

  # get the last bin number in the last chunk
  if ( $add_zeroes ) {
    my $last_chunk = $chunks->[$data->{"peak count"}->{value} - 1];
    my $first_trailer_bin = $last_chunk->{data}->{"first bin"}->{value} + $last_chunk->{data}->{nbins}->{value};
    if ( $first_trailer_bin < $data->{nbins}->{value} ) {
      foreach my $bin ( $first_trailer_bin .. $self->{data}->{nbins}->{value} - 1 ) {
        my $x = $start + $bin * $step;
        my $x_conv = exists $self->{converter} ? &{$self->{converter}}($x) + $shift : $x;
        if ( $range ) {
          if ( exists $self->{converter} ) {
            next unless $x_conv >= $range->[0] and $x_conv <= $range->[1];
          }
          else {
            # frequencies have the reverse order
            next unless $x_conv <= $range->[0] and $x_conv >= $range->[1];
          }
        }
        print "$x_conv\t0\n";
      }
    }
    print "$range->[1]\t0\n";
  }
}

sub find_precursor_peak {
  my ($self, $query) = @_;

  my $raw_query = &{$self->{"inverse converter"}}($query);

  my $start = $self->{data}->{"first value"}->{value};
  my $step = $self->{data}->{step}->{value};
  my $chunks = $self->{data}->{chunks}->{value};

  # find the closest point
  my $closest = my $second_closest = { point => {chunk => 0, n => 0}, dist => 10e6 };
  foreach my $i ( 0 .. $self->{data}->{"peak count"}->{value} - 1 ) {
    my $x = $start + ($chunks->[$i]->{data}->{"first bin"}->{value} - 1) * $step;
    foreach my $j ( 0 .. $chunks->[$i]->{data}->{nbins}->{value} - 1) {
      $x += $step;
      my $dist1 = $raw_query - $x;
      my $dist2 = $x - $raw_query;
      if ( $dist1 >= 0 and $dist1 < $closest->{dist}) {
        $closest = { point => {chunk => $i, n => $j}, dist => $dist1 };
      }
      if ( $dist2 >= 0 and $dist2 < $second_closest->{dist}) {
        $second_closest = { point => {chunk => $i, n => $j}, dist => $dist2 };
      }
    }
  }

  if ( $closest->{dist} > 0.1 ) {
    print STDERR "could not find the precursor peak for M/z $query; the nearest candidate is $closest->{dist} a.u. away\n";
    return {mz => $query, intensity => 0};
  }
  my $i = $closest->{point}->{chunk};
  my $j = $closest->{point}->{n};
  my $point1 = {
                mz => &{$self->{converter}}($start + ($chunks->[$i]->{data}->{"first bin"}->{value} + $j - 1) * $step),
                intensity => $chunks->[$i]->{data}->{signal}->{value}->[$j]
               };
  $i = $second_closest->{point}->{chunk};
  $j = $second_closest->{point}->{n};
  my $point2 = {
                mz => &{$self->{converter}}(
                                            $start +
                                            (
                                             $self->{data}->{chunks}->{value}->[$i]
                                             ->{data}->{"first bin"}->{value}
                                             + $j - 1
                                            ) * $step
                                           ),
                intensity => $chunks->[$i]->{data}->{signal}->{value}->[$j]
               };
  return $point1->{intensity} > $point2->{intensity} ? $point1 : $point2;
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


=head1 EXPORT

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
