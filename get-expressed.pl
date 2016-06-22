#!/usr/bin/perl
use strict;

my $MIN_FPKM=0;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $INFILE="$ASSEMBLY/rna.txt";
my $OUTFILE="$ASSEMBLY/expressed.txt";

my %seen;
open(OUT,">$OUTFILE") || die $OUTFILE;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  next if(/allele/);
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next unless $FPKM>=$MIN_FPKM;
  my $key="$gene $transcript";
  next if $seen{$key};
  print OUT "$gene\t$transcript\n";
  $seen{$key}=1;
}
close(IN);
close(OUT);

