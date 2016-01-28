#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.gcf> <individual>\n" unless @ARGV==2;
my ($gcf,$indiv)=@ARGV;

open(IN,$gcf) || die $gcf;
my $header=<IN>; chomp $header;
my @variants=split/\s/,$header;
while(<IN>) {
  chomp;
  my @fields=split/\s+/,$_;
  my $ID=shift @fields;
  next unless $ID eq $indiv;
  my $n=@fields;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $label=$variants[$i];
    my $genotype=$fields[$i];
    $genotype=~/(\d)\|(\d)/ || die;
    my ($left,$right)=($1,$2);
    next unless $left>0 || $right>0;
    print "$label\t$genotype\n";
  }
}
close(IN);
