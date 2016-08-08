#!/usr/bin/perl
use strict;

my $SEARCH="ENSG00000174177";

open(IN,"/home/bmajoros/1000G/assembly/combined/HG00096/RNA/junctions.bed")
  || die;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=11;
  my $substrate=$fields[0];
  next unless $substrate=~/$SEARCH/;
  my $begin=$fields[1]; my $end=$fields[2];
  my $overhangs=$fields[10];
  $overhangs=~/(\d+),(\d+)/ || die $overhangs;
  my ($left,$right)=($1,$2);
  $begin+=$left; $end-=$right;
  my $count=$fields[4];
  my $substrate=$fields[0];
  print "$substrate\t$begin\t$end\t$count\n";
}
close(IN);


