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
  my ($class, $stream, $fields, $any_arg) = @_;
  my $self = {size => 0};

  bless $self, $class;
  $self->decode($stream, $fields, $any_arg);
}

sub iterate_object {
  my ($self, $stream, $count, $name, $class, $any_arg) = @_;

  my $addr = tell $stream;

  my $current_element = scalar keys(%{$self->{data}}) + 1;

  die qq(key "$name" already exists) if $self->item($name);

  my $size = 0;
  $self->{data}->{$name} = {};
  $self->{data}->{$name}->{value} = [];
  foreach my $i ( 1 .. $count ) {
    my $value = eval{$class}->decode($stream, $any_arg);
    $size += $value->size();
    push @{$self->{data}->{$name}->{value}}, $value;
  }

  $self->{data}->{$name}->{seq} = $current_element;
  $self->{data}->{$name}->{addr} = $addr,
  $self->{data}->{$name}->{size} = $size,
  $self->{data}->{$name}->{type} = "$class\[\]",

  $self->{size} += $size;
  $self->{current_element}++;

  return $self;
}

sub iterate_scalar {
  my ($self, $stream, $count, $name, $desc) = @_;
  my ($template, $type) = @$desc;

  my $addr = my $current_addr = tell $stream;

  my $current_element = scalar keys(%{$self->{data}}) + 1;

  die qq(key "$name" already exists) if $self->item($name);

  my $size = 0;
  $self->{data}->{$name} = {};
  $self->{data}->{$name}->{value} = [];
  foreach my $i ( 1 .. $count ) {
    my $rec;
    my $bytes_to_read = length(pack($template,()));
    my $nbytes = CORE::read $stream, $rec, $bytes_to_read;
    $nbytes == $bytes_to_read
      or die "could not read all $bytes_to_read bytes of $name at $current_addr";

    my $value;
    if ($template =~ /^U0C/) {
      $value = pack "C*", unpack $template, $rec;
    }
    else {
      $value = unpack $template, $rec;
    }
    $size += $nbytes;
    $current_addr += $nbytes;

    push @{$self->{data}->{$name}->{value}}, $value;
  }

  $self->{data}->{$name}->{seq} = $current_element;
  $self->{data}->{$name}->{addr} = $addr,
  $self->{data}->{$name}->{size} = $size,
  $self->{data}->{$name}->{type} = $type,

  $self->{size} += $size;
  $self->{current_element}++;

  return $self;
}

sub decode {
  my ($self, $stream, $fields, $any_arg) = @_;
  my ( $rec, $nbytes );  

  my $current_addr = tell $stream;
  $self->{addr} ||= $current_addr; # assign the address only if called
                                   # the first time (because decoding
                                   # can be done in multiple chunks).

  my $current_element = scalar keys %{$self->{data}};

  foreach my $i ( 0 .. @$fields/2 - 1 ) {
    my ($name, $desc) = ($fields->[2*$i], $fields->[2*$i+1]);
    my ($template, $type) = @$desc;
    my $value;

    die qq(key "$name" already exists) if $self->item($name);

    if ( $template eq 'object' ) {
      $value = eval{$type}->decode($stream, $any_arg);
      $nbytes = $value->size();
    }
    elsif ( $template eq 'varstr' ) {
      # read the prefix counter into $nchars
      my $bytes_to_read = 4;
      $nbytes = CORE::read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $bytes_to_read bytes of the prefix counter in $name at $current_addr";
      my $nchars = unpack "V", $rec;

      # read the 2-byte characters
      $bytes_to_read = 2*$nchars;
      $nbytes = CORE::read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $nchars 2-byte characters of $name at $current_addr";
      $value = pack "C*", unpack "U0C*", $rec;
      $nbytes += 4;
    }
    elsif ( $template eq 'windows_time' ) {
      my $bytes_to_read = 8;
      $nbytes = CORE::read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $bytes_to_read bytes of $name at $current_addr";
      $value = windows_datetime_in_bytes(unpack "W*", $rec);
    }
    else {
      my $bytes_to_read = length(pack($template,()));
      $nbytes = CORE::read $stream, $rec, $bytes_to_read;
      $nbytes == $bytes_to_read
	or die "could not read all $bytes_to_read bytes of $name at $current_addr";

      if ($template =~ /^U0C/) {
	$value = pack "C*", unpack $template, $rec;
      }
      else {
	$value = unpack $template, $rec;
      }
    }

    $self->{data}->{$name} = {
			      seq => $current_element + $i,
			      addr => $current_addr,
			      size => $nbytes,
			      type => $type,
			      value => $value,
			     };

    $current_addr = tell $stream;
    $self->{size} += $nbytes;
    $self->{current_element} = $i;
  }

  return $self;
}

sub size {
  shift->{size};
}

sub data {
  shift->{data};
}

sub item {
  my ($self, $key) = @_;
  $self->{data}->{$key};
}

sub values {
  my ($self) = @_;
  my %values = map { $_ => $self->{data}->{$_}->{value} } keys %{$self->{data}};
  return \%values;
}

sub dump {
  my ( $self, %arg ) = @_;

  my $addr = $self->{addr};

  my @keys = sort {
    $self->data->{$a}->{seq} <=> $self->data->{$b}->{seq}
  } keys %{$self->{data}};

  if ($arg{style} and $arg{style} eq 'html') {
    say "<table>";
    say "  <tr> <td>offset</td> <td>size</td> <td>type</td> <td>key</td> <td>value</td> </tr>";
    foreach my $key ( @keys ) {
      my $offset = $arg{relative} ? $self->item($key)->{addr} - $addr :  $self->item($key)->{addr};
      my $value = $self->item($key)->{value};
      say "  <tr>"
	. " <td>" . $offset . "</td>"
	  . " <td>" . $self->item($key)->{size} . "</td>"
	    . " <td>" . $self->item($key)->{type} . "</td>"
	      . " <td>" . $key . "</td>"
		. " <td>$value</td>"
		  . " </tr>"
		    ;
    }
    say "</table>";
  }
  elsif ($arg{style} and $arg{style} eq 'wiki') {
    say "|| " . join(" || ", qw/offset size type key value/) . " ||";
    foreach my $key ( @keys ) {
      my $offset = $arg{relative} ? $self->item($key)->{addr} - $addr :  $self->item($key)->{addr};
      my $value = $self->item($key)->{value};
      if ($self->item($key)->{type} eq 'UTF16LE'
	  and substr($value, 0, 2) eq "\x00\x00") {
	$value =~ s/\x00/00 /g;
	if (length($value) > 20) {
	  $value = substr($value, 0, 30) . "...";
	}
      }
      say "|| " . join(" || ",
		       $offset,
		       $self->item($key)->{size},
		       $self->item($key)->{type},
		       "\`$key\`",
		       "$value"
		      ). " ||";
    }
  }
  else {
    foreach my $key ( @keys ) {
      my $offset = $arg{relative} ? $self->item($key)->{addr} - $addr :  $self->item($key)->{addr};
      my $value = $self->item($key)->{value};
      say join("\t",
	       $offset,
	       $self->item($key)->{size},
	       $self->item($key)->{type},
	       $key,
	       "$value"
	      );
    }
  }
}

1;
__END__
=head1 NAME

Finnigan::Decoder - a generic binary structure decoder

=head1 SYNOPSIS

  use Finnigan;

  my $fields = [
		short_int => 'v',
		long_int => 'V',
		ascii_string => 'C60',
		wide_string => 'U0C18',
		audit_tag => 'object=Finnigan::AuditTag',
		time => 'windows_time',
	       ];

  my $data = Finnigan::Decoder->read(\*STREAM, $fields);


=head1 DESCRIPTION

This class is not inteded to be used directly; it is a parent class
for all Finnigan decoders. The fields to decode are passed to
the decoder's read() method in a list reference, where every even item
specifies the key the item will be known as in the resulting hash, and
every odd item specifies the unpack template.

Perl unpack templates are used to decode most fields. For some fields, non-perl templates are used, such as:

=over 2

=item * object: instructs the current decoder to call another Finnigan decoder at that location.

=item * windows_time: instructs Finingan::Decoder to call its own Windows timestamp routine.

=item * varstr: decoded as a Windows Pascal string in a special case in the Finnigan::Decoder::read() method.

=back

=head2 METHODS

=over 4

=item C<read($class, $stream, $fields, $any_arg)>

Returns a new decoder blessed into class C<$class> and initialized
with the values read from C<$stream> and decoded according to a list
of templates specified in C<$fields>.

The fourth argument, C<$any_arg> is not used by the Decoder class, but
may be used by derived classes to pass parse context to their
component decoders. For example, this can be useful to parse
structures whose layout is governed by the data they contain; in that
case if the layout indicator is read by the top-level decoder, it can
be passed to lower-level decoders whose work depends on it. Also, this
argument is used by the user program to pass the Finnigan file version
to version-sensitive decoders.

Here is an example of the template list for a simple decoder:

  my $fields = [
		"mz"        => ['f', 'Float32'],
		"abundance" => ['f', 'Float32'],
	       ];

=item C<sub decode($stream, $fields, $any_arg)>

This method must be called on a blessed, instantiated Decoder. The
C<read()> method calls it internally, but it can also be used by the
user code in those cases where not all data can be decoded with a
plain list of templates. In some cases, it may be necessary to decode
one part of an object, analyse it, make decisions about the rest
(calculate sizes, layouts, etc.), and then grow the object under
construction by decoding more data from the stream.


=item C<iterate_scalar($stream, $count, $name, $desc)>

This method is similar to the C<decode> metod, in that it does not
instantiate a Decoder, but rather adds data to an existing one. Its
purpose is to decode simple arrays whose elements have neither
structure, nor behaviour, and can be described by a simple list. The
list will consist of C<$count> elements read into the current
Decoder's attribute given in C<$name>, according to the template
specified in C<$desc>.  For example, to read a list of 4-byte
integers, the template description must be of the form:

  $desc = ['V', 'Uint32']


=item C<iterate_object($stream, $count, $name, $class, $any_arg)>

Similarly to C<iterate_scalar()>, this method can be used to read a
list of structures into the current decoder's attribute specified in
the C<$name> argument, but in this case, the list elements can be
complex structures to be decoded with their own decoder specified in
C<$class>. The optional argument C<$any_arg> can be used to parse
context information to that decoder.

=back

=head2 EXPORT

None


=head1 SEE ALSO

Use this command to list all available Finnigan decoders:

 perl -MFinnigan -e 'Finnigan::list_modules'


=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
