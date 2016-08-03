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
    my $coseg=coseg($genotypes{$rs1},$genotypes{$rs2});
    print "$rs1\t$rs2\t$coseg\n";
  }
}

sub coseg {
  my ($A1,$A2)=@_;
  my $sum=0;
  my $L=@$A1;
  for(my $i=0 ; $i<$L ; ++$i) {
    my $pair1=$A1->[$i]; my $pair2=$A2->[$i];
    my $alt1=$pair1->[0] || $pair1->[1];
    my $alt1=$pair1->[0] || $pair1->[1];
  }
  my $score=$sum/$L;
  return $score;
}

