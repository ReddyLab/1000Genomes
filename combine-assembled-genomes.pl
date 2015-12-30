#!/usr/bin/perl
use strict

my $BASEDIR="/data/reddylab/Reference_Data/1000Genomes/analysis/assembly/fasta";
my @dirs=(0,1,2,3,4,5,6,7,8,9);

my @files=`ls $BASEDIR/0/*-?.fasta`;
foreach my $file (@files) {
  chomp $file;
  print "$file\n";
}

