package Finnigan::Error;

use strict;
use warnings;

use Finnigan;
use base 'Finnigan::Decoder';


sub decode {
  my ($class, $stream, $layout) = @_;

  my $fields = [
                "time"     => ['f', 'Float32'],
                "message"  =>  ['varstr', 'PascalStringWin32'],
               ];

  my $self = bless Finnigan::Decoder->read($stream, $fields), $class;
  return $self;
}

sub time {
  shift->{data}->{"time"}->{value};
}

sub message {
  shift->{data}->{"message"}->{value};
}

1;
__END__

=head1 NAME

Finnigan::Error -- the decoder for Error, an error log record

=head1 SYNOPSIS

  use Finnigan;
  my $entry = Finnigan::Error->decode(\*INPUT);
  say $entry->time;
  say $entry->message;

=head1 DESCRIPTION

Error is a varibale-length structure containing the timestamped error messages.

=head2 EXPORT

None

=head1 AUTHOR

Gene Selkov, E<lt>selkovjr@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Gene Selkov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
