#!/usr/bin/perl
use strict;

my $DIR="/home/bmajoros/1000G/assembly/ice-slurms";
my @files=`ls $DIR/*.output`;
foreach my $file (@files) {
  chomp $file;
  my $dates=0;
  open(IN,$file) || die $file;
  while(<IN>) {
    if(/\S+\s+\S+\s+\d+\s+\d+:\d+:\d+\s+EST\s+\d+/) {
      #print "$file\t$_\n";
      ++$dates }
  }
  close(IN);
  if($dates<4) { print "$file\n" }
}
