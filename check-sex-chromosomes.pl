#!/usr/bin/perl
use strict;

my %chr;
open(IN,"/home/bmajoros/1000G/assembly/local-CDS-and-UTR.gff") || die;
while(<IN>) {
  chomp;
  next unless $_=~/transcript_id=([^;]+)/;
  my $id=$1;
  my @fields=split;
  my $chr=$fields[0];
#  print "mapping $id => $chr\n";
  $chr{$id}=$chr;
}
close(IN);

my %counts;
open(IN,"/home/bmajoros/1000G/assembly/ethnicity-results.txt") || die;
while(<IN>) {
  chomp;
  if(/(\S+)\s+(ENST\S+)/) {
    my ($pop,$ENST)=($1,$2);
    my $chr=$chr{$ENST};
    next if $chr eq "chrX" || $chr eq "chrY";
    #print "$chr\n";
    ++$counts{$pop};
  }
}
close(IN);

my @keys=keys %counts;
foreach my $key (@keys) {
  my $count=$counts{$key};
  print "$key\t$count\n";
}
