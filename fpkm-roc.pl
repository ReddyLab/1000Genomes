#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";

my $real=load("$ASSEMBLY/fpkm-real.txt"); my $numReal=@$real;
my $sim=load("$ASSEMBLY/fpkm-sim.txt"); my $numSim=@$sim;
my $maxReal=$real->[$numReal-1]; my $maxSim=$sim->[$numSim-1];



sub load {
  my ($filename)=@_;
  my $array=[];
  open(IN,$filename) || die "can't open $filename";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($transcript,$fpkm)=@fields;
    push @$array,$fpkm;
  }
  close(IN);
  @$array=sort {$a <=> $b} @$array;
  return $array;
}








