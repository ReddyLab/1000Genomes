#!/usr/bin/perl
use strict;

my $INFILE="/home/bmajoros/1000G/assembly/protein-lengths.txt";
my $THRESHOLD=0.05;

my @lengths;
open(IN,$INFILE) || die;
while(<IN>) {
  chomp;
  next unless $_>0;
  push @lengths $_;
}
close(IN);

@lengths=sort {$a <=> $b} @lengths;
my $n=@lengths;
my $index=int($THRESHOLD*$n);
my $cutoff=$lengths[$index];
print "length of $cutoff is $THRESHOLD percentile\n";




