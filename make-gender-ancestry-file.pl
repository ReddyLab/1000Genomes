#!/usr/bin/perl
use strict;

my $VCF="/gpfs/fs0/data/common/1000_genomes/VCF/20130502";
my $POP_INFO="$VCF/population-info.txt";
my $ALL_ANCESTRIES="$VCF/ancestries.txt";
my $GENDERS="/home/bmajoros/1000G/vcf/gender.txt";

my %superpop;
open(IN,$POP_INFO) || die $POP_INFO;
while(<IN>) {
  chomp;
  my @fields=split/\t/; next unless @fields>=3;
  my ($sub,$text,$super)=@fields;
  $superpop{$sub}=$super;
}
close(IN);

my %gender;
open(IN,$GENDERS) || die $GENDERS;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($indiv,$gender)=@fields;
  $gender{$indiv}=$gender;
}
close(IN);

open(IN,$ALL_ANCESTRIES) || die $ALL_ANCESTRIES;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($indiv,$ancestry)=@fields;
  my $super=$superpop{$ancestry};
  my $gender=$gender{$indiv};
  next unless $gender;
  print "$indiv\t$gender\t$ancestry\t$super\n";
}
close(IN);

