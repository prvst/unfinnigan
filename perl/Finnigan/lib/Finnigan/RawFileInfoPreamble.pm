package Finnigan::RawFileInfoPreamble;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $version) = @_;

  my @common_fields = (
		       "unknown long"     => ['V',    'UInt32'],
		       year               => ['v',    'UInt16'],
		       month              => ['v',    'UInt16'],
		       "day of the week"  => ['v',    'UInt16'],
		       day                => ['v',    'UInt16'],
		       hour               => ['v',    'UInt16'],
		       minute             => ['v',    'UInt16'],
		       second             => ['v',    'UInt16'],
		       "unknown_short[1]" => ['v',    'UInt16'],
		      );

  my %specific_fields;
  $specific_fields{8} = [],
  $specific_fields{57} = [
			  "unknown_short[2]"  => ['v',    'UInt16'],
			  "unknown_short[3]"  => ['v',    'UInt16'],
			  "unknown_short[4]"  => ['v',    'UInt16'],
			  "unknown_short[5]"  => ['v',    'UInt16'],
			  "unknown_short[6]"  => ['v',    'UInt16'],
			  "unknown_short[7]"  => ['v',    'UInt16'],
			  "unknown_short[8]"  => ['v',    'UInt16'],
			  "unknown_short[9]"  => ['v',    'UInt16'],
			  "unknown_short[10]" => ['v',    'UInt16'],
			  "unknown_short[11]" => ['v',    'UInt16'],
			  "unknown_short[12]" => ['v',    'UInt16'],
			  "unknown_short[13]" => ['v',    'UInt16'],
			  "run header addr"   => ['V',    'UInt32'],
			  unknown_area        => ['C756', 'RawBytes'], # 804 - 12 * 4 (the structure seems to be fixed-size)
			 ];

  $specific_fields{62} = $specific_fields{57};
  $specific_fields{63} = $specific_fields{57};

  die "don't know how to parse version $version" unless $specific_fields{$version};
  my $self = Finnigan::Decoder->read($stream, [@common_fields, @{$specific_fields{$version}}]);

  return bless $self, $class;
}

sub timestamp {
  my $self = shift;
  my @dow_abbr = qw/X Mon Tue Wed Thu Fri Sat Sun/;
  my @month_abbr = qw/X Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
  $dow_abbr[$self->{data}->{"day of the week"}->{value}] . " "
    . $month_abbr[$self->{data}->{month}->{value}]
      . " "
	. $self->{data}->{day}->{value}
	  . " "
	    . $self->{data}->{year}->{value}
	      . " "
		. $self->{data}->{hour}->{value}
		  . ":"
		    . $self->{data}->{minute}->{value}
		      . ":"
			. $self->{data}->{second}->{value} 
			  ;
}

sub run_header_addr {
  shift->{data}->{"run header addr"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::RawFileInfoPreamble -- a decoder for RawFileInfoPreamble, the binary data part of RawFileInfo

=head1 SYNOPSIS

  use Finnigan;
  my $file_info = Finnigan::RawFileInfoPreamble->decode(\*INPUT);
  say $file_info->run_header_addr;
  $file_info->dump;

=head1 DESCRIPTION

This structure is a binary preamble to RawFileInfo, and it contains an
unpacked representation of the UTC date (apparently, file creation
date), a set of unknown numbers, and most importantly, the more modern
versions of this structure contain the pointer to RunHeader, which
stores the pointers to all data streams in the file.

=head2 EXPORT

None

=head1 SEE ALSO

Finnigan::RawFileInfo

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
