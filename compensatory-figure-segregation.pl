#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/compensatory-example-variants.txt";

my %genotypes;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split/\t/; next unless @fields>=9;
  my $rs=$fields[2];
  my $numFields=@fields;
  for(my $i=9 ; $i<$numFields ; ++$i) {
    my $G=$fields[$i];
    $G=~/(\d)\|(\d)/ || die $G;
    my ($allele1,$allele2)=($1,$2);
    push @{$genotypes{$rs}},[$allele1,$allele2];
  }
}
close(IN);

my @rs=keys %genotypes;
for(my $i=0 ; $i<@rs ; ++$i) {
  my $rs1=$rs[$i];
  for(my $j=$i+1 ; $j<@rs ; ++$j) {
    my $rs2=$rs[$j];
    coseg($rs1,$genotypes{$rs1},$rs2,$genotypes{$rs2});
  }
}

sub coseg {
  my ($rs1,$A1,$rs2,$A2)=@_;
  my $sum=0;
  my $L=@$A1;
  my $hasFirst=0; my $hasSecond=0; my $hasBoth=0; my $hasEither=0;
  for(my $i=0 ; $i<$L ; ++$i) {
    my $pair1=$A1->[$i]; my $pair2=$A2->[$i];
    my $alt1=$pair1->[0] || $pair1->[1];
    my $alt2=$pair2->[0] || $pair2->[1];
    if($alt1) { ++$hasFirst }
    if($alt2) { ++$hasSecond }
    if($alt1 && $alt2) { ++$hasBoth }
    if($alt1 || $alt2) { ++$hasEither }
  }
  my $jaccard=$hasBoth/$hasEither;
  print "$rs1=$hasFirst\t$rs2=$hasSecond\tboth=$hasBoth\teither=$hasEither\tJaccard=$jaccard\n";
}

