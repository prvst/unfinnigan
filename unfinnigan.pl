#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/state say/;
use 5.010;

use DateTime::Format::WindowsFileTime;

sub windows_datetime_in_bytes {
  # expects 8 arguments representing windows date in little-endian order
  my @hex = map { sprintf "%2.2X", $_ } @_; # convert to upper-case hex
  my $hex_date = join('', @hex[reverse 0..7]); # swap to network format
  my $dt = DateTime::Format::WindowsFileTime->parse_datetime( $hex_date );
  # $dt is a regular DateTime object
  return $dt->ymd . " " . $dt->hms;
}


my $VERBOSE = 2;

@ARGV == 1 or do { say STDERR "usage: $0 <input_file>"; exit -1 };

my $file = shift @ARGV;

-e $file or die "file '$file' does not exist";
-f $file or die "'$file' is not a plain file";
-s $file or die "'$file' has zero size";

open INPUT, "<$file" or die "can't open '$file': $!";
binmode INPUT;

my ( @pattern, $pattern, $pos, $rec, $nbytes );
$pos = sprintf("%08x", 0);

# 1. Magic number
$pattern = pack "W2", 0x01, 0xA1;
$nbytes = read INPUT, $rec, 2;
$rec eq $pattern or die "this is not a Finnigan file";
$VERBOSE > 1 and say STDERR "$pos: Finnigan magic number";
$pos = sprintf "%08x", tell INPUT;

# 2. Finnigan signature
@pattern = qw/F i n n i g a n/;
$pattern = pack "W*", map {ord($_), 0} @pattern;
$nbytes = read INPUT, $rec, length($pattern);
$rec eq $pattern or die "this file does not have the Finnigan signature, or it is different";
$VERBOSE > 1 and say STDERR "$pos: Finnigan signature";
$pos = sprintf "%08x", tell INPUT;

# 3. zero padding
$pattern = pack "W*", (0) x 14;
$nbytes = read INPUT, $rec, length($pattern);
$rec eq $pattern or die "this file does not have the " . length($pattern) . " zero bytes at $pos";
$VERBOSE > 1 and say STDERR "$pos:   skipped $nbytes zero bytes";
$pos = sprintf "%08x", tell INPUT;

# 4. unknown long (?)
@pattern = (0, 0, 8, 0);
$pattern = pack "W*", @pattern;
$nbytes = read INPUT, $rec, length($pattern);
$rec eq $pattern or die "the file does not match the expected pattern at $pos: " . join(" ", map { sprintf "%2.2X", $_ } @pattern) . " <=> " . join(" ", map { sprintf "%2.2X", $_ } unpack "W*", $rec);
$VERBOSE > 1 and say STDERR "$pos:   skipped unknown long: " . join(" ", map { sprintf "%2.2X", $_ } @pattern);
$pos = sprintf "%08x", tell INPUT;

# 5. file format version (assumed long)
$nbytes = read INPUT, $rec, 4;
$nbytes == 4 or die "could not read a complete long integer containing file version at $pos";
my $FileVersion = unpack "L", $rec;
$VERBOSE and say STDERR "$pos: File Version: $FileVersion";
$pos = sprintf "%08x", tell INPUT;

# 6. start timestamp
$nbytes = read INPUT, $rec, 8;
$nbytes == 8 or die "could not read a complete timestamp at $pos";
@pattern = unpack "W*", $rec;
my $StartTimestamp = windows_datetime_in_bytes(@pattern);
$VERBOSE and say STDERR "$pos: Start Timestamp: $StartTimestamp";
$pos = sprintf "%08x", tell INPUT;

# 7. first and second tags
$nbytes = read INPUT, $rec, 50;
$nbytes == 50 or die "could not read a complete tag array at $pos";
my $Tag1 = pack "U*", grep {$_} unpack "S*", $rec;
$VERBOSE and say STDERR "$pos: Tag 1: $Tag1";
$pos = sprintf "%08x", tell INPUT;

$nbytes = read INPUT, $rec, 50;
$nbytes == 50 or die "could not read a complete tag array at $pos";
my $Tag2 = pack "U*", grep {$_} unpack "S*", $rec;
$VERBOSE and say STDERR "$pos: Tag 2: $Tag2";
$pos = sprintf "%08x", tell INPUT;

# 8. unknown long (?)
$nbytes = read INPUT, $rec, length($pattern);
$nbytes == 4 or die "could not read a complete long at $pos";
@pattern = unpack "W*", $rec;
$VERBOSE > 1 and say STDERR "$pos: *Unknown long: " . join(" ", map { sprintf "%2.2X", $_ } @pattern);
$pos = sprintf "%08x", tell INPUT;

# 9. end timestamp
$nbytes = read INPUT, $rec, 8;
$nbytes == 8 or die "could not read a complete timestamp at $pos";
@pattern = unpack "W*", $rec;
my $EndTimestamp = windows_datetime_in_bytes(@pattern);
$VERBOSE and say STDERR "$pos: End Timestamp: $EndTimestamp";
$pos = sprintf "%08x", tell INPUT;

# 10. third and fourth tags
$nbytes = read INPUT, $rec, 50;
$nbytes == 50 or die "could not read a complete tag array at $pos";
my $Tag3 = pack "U*", grep {$_} unpack "S*", $rec;
$VERBOSE and say STDERR "$pos: Tag 3: $Tag3";
$pos = sprintf "%08x", tell INPUT;

$nbytes = read INPUT, $rec, 50;
$nbytes == 50 or die "could not read a complete tag array at $pos";
my $Tag4 = pack "U*", grep {$_} unpack "S*", $rec;
$VERBOSE and say STDERR "$pos: Tag 4: $Tag4";
$pos = sprintf "%08x", tell INPUT;

