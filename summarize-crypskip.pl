#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $SLURMS="$THOUSAND/assembly/predict-crypskip-slurms";
my $PROGRAM="$THOUSAND/src/predict-crypskip.pl";

my $slurm=new SlurmWriter;
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/RNA/stringtie.gff";


