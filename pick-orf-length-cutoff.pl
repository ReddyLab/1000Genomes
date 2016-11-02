#!/usr/bin/perl
use strict;

my $INFILE="/home/bmajoros/1000G/assembly/protein-lengths.txt";
my $THRESHOLD=0.05;

my @lengths;
open(IN,$INFILE) || die;
while(<IN>) {
  chomp;
  next unless $_>0;
  push @lengths,$_;
}
close(IN);

@lengths=sort {$a <=> $b} @lengths;
my $n=@lengths;

my $min=$lengths[0];
print "min = $min AA\n";
report(0.008);
report(0.05);

sub report
{
  my ($threshold)=@_;
  my $index=int($threshold*$n);
  my $cutoff=$lengths[$index];
  print "length of $cutoff AA is $threshold percentile\n";
}





