package Finnigan::ScanEvent;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $version) = @_;

  my @common_fields = (
		       "preamble"   => ['object',  'Finnigan::ScanEventPreamble'],
		       "type"       => ['V',       'UInt32'],
		      );

  my %specific_fields;
  $specific_fields{0} = [
			 "unknown long[1]"    => ['V',      'UInt32'],
			 "fraction collector" => ['object', 'Finnigan::FractionCollector'],
			 "nparam"             => ['V',      'UInt32'],
			];

  $specific_fields{1} = [
			 "reaction"           => ['object', 'Finnigan::Reaction'],
			 "unknown long[1]"    => ['V',      'UInt32'],
			 "fraction collector" => ['object', 'Finnigan::FractionCollector'],
			 "unknown long[2]"    => ['V',      'UInt32'],
			 "unknown long[3]"    => ['V',      'UInt32'],
			 "unknown long[4]"    => ['V',      'UInt32'],
			];

  my $self = Finnigan::Decoder->read($stream, \@common_fields, $version);
  bless $self, $class;

  if ( $self->type == 0 ) {
    $self->SUPER::decode($stream, $specific_fields{$self->type}, $version);
    if ( $self->nparam == 4 ) {
      my $fields = [
		    "unknown double"  => ['d',      'Float64'],
		    "A"               => ['d',      'Float64'],
		    "B"               => ['d',      'Float64'],
		    "C"               => ['d',      'Float64'],
		    "unknown long[2]" => ['V',      'UInt32'],
		    "unknown long[3]" => ['V',      'UInt32'],
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
		    "unknown long[2]" => ['V',      'UInt32'],
		    "unknown long[3]" => ['V',      'UInt32'],
		   ];
      $self->SUPER::decode($stream, $fields);
    }
  }
  elsif ( $self->type == 1 ) {
    $self->SUPER::decode($stream, $specific_fields{$self->type}, $version);
  }
  else {
    die "don't know how to parse event type " . $self->type;
  }

  return $self;
}

sub type {
  shift->{data}->{"type"}->{value};
}

sub preamble {
  shift->{data}->{"preamble"}->{value};
}

sub fraction_collector {
  shift->{data}->{"fraction collector"}->{value};
}

sub reaction {
  shift->{data}->{"reaction"}->{value};
}

sub nparam {
  shift->{data}->{"nparam"}->{value};
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

The layout depends on the MS power of the scan and is governed by the
attribute named 'type'. Type 0 corresponds to MS1 scans. Type 1
corresponds to MS2 (and possibly, higher-power scans).

Both Type 0 and Type 1 layouts contain a structure named
FractionCollector, which is just a pair of double-precision numbers
indicating the M/z range of the scan.

In addition to some unknowns that occur in both layouts, Type 0
contains a copy of all conversion coefficients that determine the
transformation of the spectra from the frequency domain to M/z (the
other copy of the same coefficients is stored in the corresponding
ScanParameterSet -- a somewhat overlapping structure in a parallel
stream).

The Type 1 layout does not have those coefficients. Apparently,
because it has a subordinate M/z range and is generated at
approximately the same time as its parent scan, the parent's
coefficients are used. Instead of the conversion coefficients, the
Type 1 layout includes an object named Reaction, with data about the
parent ion mass and its fragmentation energy.

=head2 EXPORT

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
