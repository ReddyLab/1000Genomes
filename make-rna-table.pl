#!/usr/bin/perl
use strict;

my $INFILE="/home/bmajoros/1000G/assembly/combined/tab-all-sorted.txt";

print "transcript\tgene";
my @indiv;
my @dirs=`ls /home/bmajoros/1000G/assembly/combined`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
  push @indiv,$dir;
  print "\t$dir";
}
print "\n";

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
      foreach my $ID (@indiv) {
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

