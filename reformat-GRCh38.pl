#!/usr/bin/perl
use strict;

my $echo=0;
while(<STDIN>) {
  chomp;
  if(/>/) {
    if(/Homo sapiens chromosome ([^,]+).*Primary Assembly\s*$/) {
      my $chr=$1;
      $echo=1;
      print ">chr$chr\n";
    }
    else { $echo=0 }
  }
  elsif($echo) { print "$_\n" }
}

