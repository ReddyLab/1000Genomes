#!/usr/bin/perl
use strict;

my $ALLELE_COUNTS="/home/bmajoros/1000G/assembly/allele-counts";
my $BROKEN="/home/bmajoros/1000G/assembly/inactivated3.txt";

my %distance;
my @files=`ls $ALLELE_COUNTS`;
foreach my $file (@files) {
  chomp $file;
  open(IN,"$ALLELE_COUNTS/$file") || die $file;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($indiv,$dist)=@fields;
    $distance{$indiv}+=$dist;
  }
  close(IN);
}

my %broken;
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($indiv,$allele,$gene,$transcript)=@fields;
  $broken{"$indiv\_$allele"}->{$gene}=1;
}

my @indivs=keys %distance;
foreach my $indiv (@indivs) {
  my $hash1=$broken{"$indiv\_1"};
  my $hash2=$broken{"$indiv\_2"};
  my @keys1=keys %$hash1;
  my @keys2=keys %$hash2;
  my $numKeys1=@keys1;
  my $numKeys2=@keys2;
  my $broken=$numKeys1+$numKeys2;
  my $dist=$distance{$indiv};
  print "$dist\t$broken\n";
}

