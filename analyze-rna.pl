#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $INFILE="$THOUSAND/assembly/rna.txt";

open(IN,$INFILE) || die "can't open file: $INFILE\n";
while(<IN>) {
  chomp;
  next if(/allele/);
  my @fields=split; next unless @fields>.6;
  
}
close(IN);

