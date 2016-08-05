#!/usr/bin/perl
use strict;

my $SLURMS="/home/bmajoros/1000G/assembly/filter-essex-slurms";
my %running;
my @list=`squeue -u bmajoros`;
foreach my $line (@list) {
  chomp $line;
  next unless($line=~/ICE(\d+)/);
  $running{$1}=1;
}

open(IN,"$SLURMS/unfinished.txt") || die;
while(<IN>) {
  chomp;
  $_=~/(\d+).output/ || die $_;
  next if $running{$1};
  print "sbatch $SLURMS/$1.slurm\n";
  #print "mv $SLURMS/$1.output $SLURMS/trash\n";
}
close(IN);

