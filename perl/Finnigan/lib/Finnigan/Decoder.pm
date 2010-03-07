package Finnigan::Decoder;

use 5.010000;
use strict;
use warnings;

our $VERSION = '0.01';

sub windows_datetime_in_bytes {
  # expects 8 arguments representing windows date in little-endian order

  require DateTime::Format::WindowsFileTime;

  my @hex = map { sprintf "%2.2X", $_ } @_; # convert to upper-case hex
  my $hex_date = join('', @hex[reverse 0..7]); # swap to network format
  my $dt = DateTime::Format::WindowsFileTime->parse_datetime( $hex_date );
  # $dt is a regular DateTime object
  return $dt->ymd . " " . $dt->hms;
}

sub read {
  my ($class, $stream, $fields) = @_;
  my $self = {};
  my ( $rec, $nbytes );  

  my $addr = my $current_addr = tell $stream;
  my $size = 0;

  foreach my $i ( 0 .. @$fields/2 - 1 ) {
    my ($name, $template) = ($fields->[2*$i], $fields->[2*$i+1]);
    my $value;
    if ( $template =~ /^object=/ ) {
      my $class = (split /=/, $template)[-1];
      $value = eval{$class}->read($stream);
    }
    elsif ( $template eq 'windows_time' ) {
      my $bytes_to_read = 8;
      $nbytes = read $stream, $rec, 8;
      $nbytes == $bytes_to_read
	or die "could not read all $bytes_to_read bytes of $name at $current_addr";
      $value = windows_datetime_in_bytes(unpack "W*", $rec);
    }
    else {
      my $bytes_to_read = length(pack($template,()));
      $nbytes = read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $bytes_to_read bytes of $name at $current_addr";

      if ($template =~ /^U0C/) {
	$value = pack "C*", unpack $template, $rec;
      }
      else {
	$value = unpack $template, $rec;
      }
    }

    $self->{data}->{$name} = {addr => $current_addr, value => $value};
    $current_addr = tell $stream;
    $size += $nbytes;
  }

  $self->{addr} = $addr;
  $self->{size} = $size;

  return bless $self, $class;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Finnigan::Decoder - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Finnigan::Decoder;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Finnigan::Decoder, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
