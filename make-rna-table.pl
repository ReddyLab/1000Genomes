#!/usr/bin/perl
use strict;

my $INFILE="/home/bmajoros/1000G/assembly/combined/tab-all-sorted.txt";

my @indiv;
my @dirs=`ls /home/bmajoros/1000G/assembly/combined`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
  push @indiv,$dir;
}

my ($prevTrans,$prevGene,%hash);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=3;
  my ($transcript,$gene,$indiv)=@fields;
  if($transcript ne $prevTrans) {
    if($prevTrans) {
      print "$prevTrans\t$prevGene";
      foreach my $ID (@invid) {
	my $bool=$hash{$ID} ? 1 : 0;
	print "\t$bool";
      }
      print "\n";
    }
    $prevTrans=$transcript;
    $prevGene=$gene;
    undef %hash;
  }
  $hash{$indiv}=1;
}
close(IN);

