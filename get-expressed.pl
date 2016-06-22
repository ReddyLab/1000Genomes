#!/usr/bin/perl
use strict;
use SummaryStats;

my $MIN_FPKM=0;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $INFILE="$ASSEMBLY/rna.txt";
my $OUTFILE="$ASSEMBLY/expressed.txt";

my (%sum,%N);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  next if(/allele/);
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next unless $FPKM>=$MIN_FPKM;
  my $key="$gene\t$transcript";
  $sum{$key}+=$FPKM;
  ++$N{$key};
}
close(IN);

#open(OUT,">$OUTFILE") || die $OUTFILE;
my @keys=keys %sum;
my $n=@keys;
for(my $i=0 ; $i<$n ; ++$i) {
  my $key=$keys[$i];
  my $sum=$sum{$key};
  my $N=$N{$key};
  my $mean=$sum/$N;
  #print OUT "$key\t$mean\n";
  print "$mean\t$sum\t$N\n";
}
#close(OUT);

