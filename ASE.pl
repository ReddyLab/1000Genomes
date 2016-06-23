#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $RNA="$ASSEMBLY/rna.txt";

open(IN,$RNA) || die "can't open file: $RNA";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  next if $fields[0] eq "indiv";
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;

}
close(IN);


