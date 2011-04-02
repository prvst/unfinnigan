package Finnigan::ScanEvent;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';

use overload ('""' => 'stringify');

sub decode {
  my ($class, $stream, $version) = @_;

  my @common_head = (
                     "preamble" => ['object',  'Finnigan::ScanEventPreamble'],
                     "np"       => ['V',       'UInt32'],
                    );

  my $self = Finnigan::Decoder->read($stream, \@common_head, $version);
  bless $self, $class;

  if ( $self->np ) {
    $self->iterate_object($stream, $self->np, reaction => 'Finnigan::Reaction');
  }

  my @common_middle = (
                       "unknown long[1]"    => ['V',      'UInt32'],
                       "fraction collector" => ['object', 'Finnigan::FractionCollector'],
                       "nparam"             => ['V',      'UInt32'],
                      );
  $self->SUPER::decode($stream, \@common_middle, $version);

  if ( $self->nparam == 0 ) {
    # do nothing
  }
  elsif ( $self->nparam == 4 ) {
    my $fields = [
                  "unknown double"  => ['d',      'Float64'],
                  "A"               => ['d',      'Float64'],
                  "B"               => ['d',      'Float64'],
                  "C"               => ['d',      'Float64'],
                 ];
    $self->SUPER::decode($stream, $fields);
  }
  elsif ( $self->nparam == 7 ) {
    my $fields = [
                  "unknown double"  => ['d',      'Float64'],
                  "I"               => ['d',      'Float64'],
                  "A"               => ['d',      'Float64'],
                  "B"               => ['d',      'Float64'],
                  "C"               => ['d',      'Float64'],
                  "D"               => ['d',      'Float64'],
                  "E"               => ['d',      'Float64'],
                 ];
    $self->SUPER::decode($stream, $fields);
  }
  else {
    die "don't know how to interpret the set of " . $self->nparam . " conversion parameters";
  }
  
  my @common_tail = (
                     "unknown long[2]"    => ['V',      'UInt32'],
                     "unknown long[3]"    => ['V',      'UInt32'],
                    );
  $self->SUPER::decode($stream, \@common_tail, $version);

  return $self;
}

sub purge_unused_data {
  my $self = shift;
  $self->SUPER::purge_unused_data;
  $self->preamble->purge_unused_data;
  $self->fraction_collector->purge_unused_data;
  if ($self->precursors) {
    foreach my $r ( @{$self->precursors} ) {
      $r->purge_unused_data;
    }
  }
  return $self;
}

sub np {
  # the number of precrusor ions
  shift->{data}->{"np"}->{value};
}

sub preamble {
  shift->{data}->{"preamble"}->{value};
}

sub fraction_collector {
  shift->{data}->{"fraction collector"}->{value};
}

sub precursors {
  shift->{data}->{"reaction"}->{value};
}

sub reaction {
  shift->{data}->{"reaction"}->{value}->[0];
}

sub nparam {
  shift->{data}->{"nparam"}->{value};
}

sub unknown_double {
  shift->{data}->{"unknown double"}->{value};
}

sub I {
  shift->{data}->{"I"}->{value};
}

sub A {
  shift->{data}->{"A"}->{value};
}

sub B {
  shift->{data}->{"B"}->{value};
}

sub C {
  shift->{data}->{"C"}->{value};
}

sub D {
  shift->{data}->{"D"}->{value};
}

sub E {
  shift->{data}->{"E"}->{value};
}

sub converter {
  my $self = shift;
  if ( $self->{data}->{nparam}->{value} == 0 ) {
    # no conversion parameters -- no conversion
    return sub{$_[0]};  # the null converter allows the M/z spectra to pass unchanged
  }
  elsif ( $self->{data}->{nparam}->{value} == 4 ) {
    # LTQ-FT
    my $A = $self->{data}->{A}->{value};
    my $B = $self->{data}->{B}->{value};
    my $C = $self->{data}->{C}->{value};
    return sub {$A + $B/$_[0] + $C/$_[0]/$_[0]};  # $_[0] = frequency
  }
  elsif ( $self->{data}->{nparam}->{value} == 7 ) {
    # Orbitrap
    my $A = $self->{data}->{A}->{value};
    my $B = $self->{data}->{B}->{value};
    my $C = $self->{data}->{C}->{value};
    return sub {$A + $B/($_[0]**2) + $C/($_[0]**4)};  # $_[0] = frequency
  }
  else {
    die "don't know how to convert with " . $self->nparam . " conversion parameters";
  }
}

sub inverse_converter {
  my $self = shift;
  if ( $self->{data}->{nparam}->{value} == 0 ) {
    # no conversion parameters -- no conversion
    return sub{shift};  # the null converter allows the M/z spectra to pass unchanged
  }
  elsif ( $self->{data}->{nparam}->{value} == 4 ) {
    # LTQ-FT
    my $A = $self->{data}->{A}->{value};
    my $B = $self->{data}->{B}->{value};
    my $C = $self->{data}->{C}->{value};
    return sub {
      (-$B - sqrt($B**2 - 4*$C*($A - $_[0])))  # $_[0] == Mz
        /
      (2*($A - $_[0]));
    };
  }
  elsif ( $self->{data}->{nparam}->{value} == 7 ) {
    # Orbitrap
    my $A = $self->{data}->{A}->{value};
    my $B = $self->{data}->{B}->{value};
    my $C = $self->{data}->{C}->{value};
    return sub {
      sqrt(
           (-$B - sqrt($B**2 - 4*$C*($A - $_[0])))  # $_[0] == Mz
           /
           (2*($A - $_[0]))
          );
    };
  }
  else {
    die "don't know how to convert with " . $self->nparam . " conversion parameters";
  }
}

sub stringify {
  my $self = shift;

  my $p = $self->preamble;
  my $f = $self->fraction_collector;
  if ( $self->np ) {
    my $pr = $self->precursors;
    my $r = join ", ", map {"$_"} @$pr;
    return "$p $r $f";
  }
  else {
    return "$p $f";
  }
}


1;
__END__

=head1 NAME

Finnigan::ScanEvent -- a decoder for ScanEvent, a detailed scan descriptor

=head1 SYNOPSIS

  use Finnigan;
  my $e = Finnigan::ScanEvent->decode(\*INPUT);
  say $e->size;
  say $e->dump;
  say join(" ", $e->preamble->list(decode => 'yes'));
  say $e->preamble->analyzer(decode => 'yes');
  $e->fraction_collector->dump;
  $e->reaction->dump if $e->type == 1 # Reaction will not be present in MS1

=head1 DESCRIPTION

This is a variable-layout (but otherwise static) structure, contaning
several key details about the scan. Most of those details are
concentrated in its head element, ScanEventPreamble.

The layout depends on the number of precursor ions and is governed by
the attribute named 'np'. The value np = 0 corresponds to an MS1 scan.

All variants contain a structure named FractionCollector, which is
just a pair of double-precision numbers indicating the M/z range of
the scan.

In addition to some unknowns that occur in all variants, the MS1
variant (np = 0) contains a copy of all conversion coefficients that
determine the transformation of the spectra from the frequency domain
to M/z (the other copy of the same coefficients is stored in the
corresponding ScanParameterSet -- a somewhat overlapping structure in
a parallel stream).

=head1 EXPORT

None

=head1 SEE ALSO

Finnigan::ScanEventPreamble
Finnigan::FractionCollector
Finnigan::Reaction

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
