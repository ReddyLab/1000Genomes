#!/usr/bin/perl
use strict;

my $BASE="/home/bmajoros/1000G/assembly";
my $CRYPSKIP="$BASE/crypskip.txt";
my $RNA="$BASE/rna.txt";

my %rna;
open(IN,$RNA) || die $RNA;
<IN>; # header
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@_;
  my $key="$indiv $allele";
  $rna{$key}->{$transcript}=$FPKM;
}
close(IN);

my (%crypticCounts,%exonSkipping);
open(IN,$CRYPSKIP) || die $CRYPSKIP;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my ($indiv,$hap,$gene,$transcript,$event,$dist)=@fields;
  $transcript=~/(\S+)_\d+$/ || die $transcript;
  $transcript=$1;
  my $key="$indiv $hap";
  if($event eq "exon-skipping") { $exonSkipping{$key}->{$transcript} =1 }
  else { ++$crypticCounts{$key}->$transcript }
}
close(IN);

my @keys=keys %exonSkipping;
my $numKeys=@keys;
for(my $i=0 ; $i<$numKeys ; ++$i) {
  my $key=$keys[$i];
  my $hash=$crypticCounts{$key};
  my @transcripts=keys %$hash;
  foreach my $transcript (@transcripts) {
    
  }
}

#indiv   allele  gene    transcript      cov     FPKM    TPM
#HG00096 1       ENSG00000042088.9       ALT1_ENST00000393452.3  2.948879        0.867289        1.876076



