package Finnigan::RunHeader;

use strict;
use warnings;

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
			  "scan header list addr" => ['V',      'UInt32'],
			  "nscans[1]"             => ['V',      'UInt32'],
			  "nscans[2]"             => ['V',      'UInt32'],
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
  shift->{data}->{"self_addr"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::RunHeader -- decoder for RunHeader, the primary file index structure

=head1 SYNOPSIS

  use Finnigan;
  my $file_info = Finnigan::RunHeader->decode(\*INPUT);
  say $file_info->first_scan;
  say $file_info->last_scan;
  $file_info->dump;

=head1 DESCRIPTION

RunHeader is a static (fixed-size) binary preamble to RunHeader
containing data stream lengths and addresses, as well as some
unidentified data. Every data stream in the file, except for the list
of ScanHeader records, has its address stored in RunHeader.

The address of the ScanHeader stream is stored in the parent
structure, RunHeader.

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
