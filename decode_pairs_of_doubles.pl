#!/usr/bin/env perl

# This tool decodes the called peaks in the PeakData section of the "Old LCQ" data file.
# It expects to read the extracted binary chunk containing PeakData.

use strict;
use warnings;
use feature qw/state say/;
use 5.010;

@ARGV == 1 or do { say STDERR "usage: $0 <input_file>"; exit -1 };

my $file = shift @ARGV;

-e $file or die "file '$file' does not exist";
-f $file or die "'$file' is not a plain file";
-s $file or die "'$file' has zero size";

open INPUT, "<$file" or die "can't open '$file': $!";
binmode INPUT;

my ( $pos, $rec, $nbytes );

$pos = sprintf "%08x", 0;

while ( $nbytes = read INPUT, $rec, 16 ) {
  $nbytes == 16 or die "could not read a complete chunk of 16 bytes at $pos";
  $pos = sprintf "%08x", tell INPUT;
  my ( $a, $b ) = unpack "dd", $rec;
  say "$pos\t$a\t$b";
}

