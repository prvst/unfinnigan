package Finnigan::RunHeader;

use strict;
use warnings FATAL => qw( all );
our $VERSION = 0.02;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $version) = @_;

  my @common_fields = (
                       "sample info" => ['object', 'Finnigan::SampleInfo'],
                      );

  my %specific_fields;
  $specific_fields{8} = [
                         "orig file name"   => ['varstr', 'PascalStringWin32'],
                         "file name[1]"  => ['varstr', 'PascalStringWin32'],
                         "file name[2]"  => ['varstr', 'PascalStringWin32'],
                         "file name[3]"  => ['varstr', 'PascalStringWin32'],
                        ];

  $specific_fields{57} = [
                          "file name[1]"          => ['U0C520', 'UTF16LE'],
                          "file name[2]"          => ['U0C520', 'UTF16LE'],
                          "file name[3]"          => ['U0C520', 'UTF16LE'],
                          "file name[4]"          => ['U0C520', 'UTF16LE'],
                          "file name[5]"          => ['U0C520', 'UTF16LE'],
                          "file name[6]"          => ['U0C520', 'UTF16LE'],
                          "unknown double[1]"     => ['d',      'Float64'],
                          "unknown double[2]"     => ['d',      'Float64'],
                          "file name[7]"          => ['U0C520', 'UTF16LE'],
                          "file name[8]"          => ['U0C520', 'UTF16LE'],
                          "file name[9]"          => ['U0C520', 'UTF16LE'],
                          "file name[a]"          => ['U0C520', 'UTF16LE'],
                          "file name[b]"          => ['U0C520', 'UTF16LE'],
                          "file name[c]"          => ['U0C520', 'UTF16LE'],
                          "file name[d]"          => ['U0C520', 'UTF16LE'],
                          "scan trailer addr"     => ['V',      'UInt32'],
                          "scan params addr"      => ['V',      'UInt32'],
                          "unknown length[1]"     => ['V',      'UInt32'],
                          "unknown length[2]"     => ['V',      'UInt32'],
                          "nsegs"                 => ['V',      'UInt32'],
                          "unknown long[1]"       => ['V',      'UInt32'],
                          "unknown long[2]"       => ['V',      'UInt32'],
                          "own addr"              => ['V',      'UInt32'],
                          "unknown long[3]"       => ['V',      'UInt32'],
                          "unknown long[4]"       => ['V',      'UInt32'],
                         ];
  $specific_fields{62} = $specific_fields{57};
  $specific_fields{63} = $specific_fields{57};

  die "don't know how to parse version $version" unless $specific_fields{$version};
  my $self = Finnigan::Decoder->read($stream, [@common_fields, @{$specific_fields{$version}}]);

  return bless $self, $class;
}

sub sample_info {
  shift->{data}->{"sample info"}->{value};
}

sub self_addr {
  shift->{data}->{"own addr"}->{value};
}

sub trailer_addr {
  shift->{data}->{"scan trailer addr"}->{value};
}

sub params_addr {
  shift->{data}->{"scan params addr"}->{value};
}

sub ntrailer {
  my $self = shift;
  my $l1 = $self->{data}->{"unknown length[1]"}->{value};
  my $l2 = $self->{data}->{"unknown length[2]"}->{value};
  die "It\'s a happy day! We\'ve run into a case where the two lengths differ: l1 = $l1 and l2 = $l2"
    unless $l1 = $l2;

  # I am assuming it is the length of TrailerScanEvent
  return $l1;
}

sub nparams {
  my $self = shift;
  my $l1 = $self->{data}->{"unknown length[1]"}->{value};
  my $l2 = $self->{data}->{"unknown length[2]"}->{value};
  die "It\'s a happy day! We\'ve run into a case where the two lengths differ: l1 = $l1 and l2 = $l2"
    unless $l1 = $l2;

  # I am assuming it is the length of ScanParams
  return $l2;
}

sub nsegs {
  shift->{data}->{"nsegs"}->{value};
}

sub u1 {
  shift->{data}->{"unknown double[1]"}->{value};
}

sub u2 {
  shift->{data}->{"unknown double[2]"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::RunHeader -- decoder for RunHeader, the primary file index structure

=head1 SYNOPSIS

  use Finnigan;
  my $rh = Finnigan::RunHeader->decode(\*INPUT, $version);
  my $first_scan_number = $rh->first_scan;
  my $last_scan_number = $rh->last_scan;
  my $scan_index_addr = $rh->sample_info->scan_index_addr;

=head1 DESCRIPTION

Decodes RunHeader, the static (fixed-size) structure containing data
stream lengths and addresses, as well as some unidentified data. Every
data stream in the file has its address stored in RunHeader or in its
historical antecedent SampleInfo, which it now includes.

=head2 METHODS

=over 4

=item decode($stream, $version)

The constructor method

=item sample_info

Get the Finnigan::SampleInfo object

=item self_addr

Get own address

=item trailer_addr

Get the "trailer" address -- the pointer to the stream of ScanEvent
structures

=item params_addr

Get the pointer to the stream of ScanPrarameters? structures

=item ntrailer

Get the length of the ScanEvent stream

=item nparams

Get the length of the ScanParameters stream

=item nsegs

Get the number of scan segments

=item u1

Get the unknown double 1

=item u2

Get the unknown double 2

=back

=head1 SEE ALSO

Finnigan::SampleInfo

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
