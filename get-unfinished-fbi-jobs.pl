#!/usr/bin/perl
use strict;

my $DIR="/home/bmajoros/1000G/assembly/fbi-slurms";
my @files=`ls $DIR/*.output`;
my $dates=0;
foreach my $file (@files) {
  chomp $file;
  open(IN,$file) || die $file;
  while(<IN>) {
    if(/\S+\s+\S+\s+\d+\s+\d+:\d+:\d+\s+EST\s+\d+/) { ++$dates }
  }
  close(IN);
  if($dates<2) { print "$file\n" }
}
