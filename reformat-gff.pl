#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajors/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my @dirs=`ls $COMBINED`;
foreach my $dir (@$dirs) {
  chomp $dir;
  next unless $dir=~/^HG\d+$/ || $dir=~/^NA\d$/;
  
}

