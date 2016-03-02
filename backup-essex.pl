#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  system("cp $COMBINED/$subdir/1.essex $COMBINED/$subdir/1.essex.old");
  system("cp $COMBINED/$subdir/2.essex $COMBINED/$subdir/2.essex.old");
}



