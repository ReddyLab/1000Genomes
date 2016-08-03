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
coseg3($genotypes{$rs[0]},$genotypes{$rs[1]},$genotypes{$rs[2]});

sub coseg3 {
  my ($A1,$A2,$A3)=@_;
  my $L=@$A1;
  my $allThree=0; my $any=0;
  for(my $i=0 ; $i<$L ; ++$i) {
    for(my $allele=0 ; $allele<2 ; ++$allele) {
      my $pair1=$A1->[$i]; my $pair2=$A2->[$i]; my $pair3=$A3->[$i];
      my $alt1=$pair1->[$allele];
      my $alt2=$pair2->[$allele];
      my $alt3=$pair3->[$allele];
      if($alt1 || $alt2 || $alt3) { ++$any }
      if($alt1 && $alt2 && $alt3) { ++$allThree }
    }
  }
  print "all three=$allThree\tany=$any\n"
}

sub coseg {
  my ($rs1,$A1,$rs2,$A2)=@_;
  my $L=@$A1;
  my $hasFirst=0; my $hasSecond=0; my $hasBoth=0; my $hasEither=0;
  my $firstOnly=0; my $secondOnly=0;
  for(my $i=0 ; $i<$L ; ++$i) {
    for(my $allele=0 ; $allele<2 ; ++$allele) {
      my $pair1=$A1->[$i]; my $pair2=$A2->[$i];
      my $alt1=$pair1->[$allele];
      my $alt2=$pair2->[$allele];
      if($alt1) { ++$hasFirst }
      if($alt2) { ++$hasSecond }
      if($alt1 && $alt2) { ++$hasBoth }
      if($alt1 || $alt2) { ++$hasEither }
      if($alt1 && !$alt2) { ++$firstOnly }
      if($alt2 && !$alt1) { ++$secondOnly }
    }
  }
  my $jaccard=$hasBoth/$hasEither;
  print "$rs1=$hasFirst\t$rs2=$hasSecond\tboth=$hasBoth\teither=$hasEither\tJaccard=$jaccard\tfirst only=$firstOnly\tsecond only=$secondOnly\n";
}

