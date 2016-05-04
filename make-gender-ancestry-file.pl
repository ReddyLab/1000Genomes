#!/usr/bin/perl
use strict;

my $VCF="/gpfs/fs0/data/common/1000_genomes/VCF/20130502";
my $ALL_ANCESTRIES="$VCF/ancestries.txt";
my $GENDERS="/home/bmajoros/1000G/vcf/gender.txt";

my %gender;
open(IN,$GENDERS) || die $GENDERS;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields==2;
  my ($indiv,$gender)=@fields;
  $gender{$invid}=$gender;
}
close(IN);

open(IN,$ALL_ANCESTRIES) || die $ALL_ANCESTRIES;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields==2;
  my ($indiv,$ancestry)=@fields;
  my $gender=$gender{$indiv};
  print "$indiv\t$gender\t$ancestry\n";
}
close(IN);

