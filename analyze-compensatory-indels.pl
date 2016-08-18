#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/compensatory.txt";

open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my ($indiv,$hap,$gene,$transcript,$L,$variants)=@fields;
  @fields=split/,/,$variants;
  foreach my $variant (@fields) {
    $variant=~// || die $variant;
  }
}
close(IN);



