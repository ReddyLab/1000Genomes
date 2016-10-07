#!/bin/env perl
use strict;
use SummaryStats;

# Globals
my $BASE="/home/bmajoros/GGR/p300";
my $ACTIVATING="$BASE/increasing-pos5-neg1.txt";
my $DEACTIVATING="$BASE/decreasing-pos5-neg1.txt";
my $PEAKS="$BASE/peaks.bed";
my $GENES="$BASE/genes/DEGs_upreg.FDR_0.01.TSS.protein_coding.bed";

# Load peak coordinates
my %peaks;
open(IN,$PEAKS) || die $PEAKS;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($chr,$begin,$end,$id)=@fields;
  $peaks{$id} = { chr=>$chr, begin=>$begin, end=>$end }
close(IN);

# Load DEGs
my %DEGs;
open(IN,$GENES) || die $GENES;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($chr,$begin,$end,$id)=@fields;
  push @{$DEGs{$chr}},$begin;
}
close(IN);

# Sort DEGs
my @chroms=keys %DEGs;
foreach my $chr (@chroms) {
  @{$DEGs{$chr}}=sort {$a <=> $b} @{$DEGs{$chr}};
}

# Process activating/deactivating and compare mean distances to DEGs
my ($posDist,$posSD)=analyze($ACTIVATING);
my ($negDist,$negSD)=$negDist=analyze($DEACTIVATING);
print "activating: $posDist +/- $posSD\n";
print "inactivating: $negDist +/- $negSD\n";





#======================================================================
sub analyze {
  my ($peaksFile)=@_;
  my @distances;
  open(IN,$peaksFile) || die $peaksfile;
  while(<IN>) {
    chomp; next unless(/\S/);
    my $record=$peaks{$_}; die $_ unless $record;
    my $chr=$record->{chr}; my $begin=$record->{begin}; my $end=$record->{end};
    my $pos=int(($begin+$end)/2);
    my $dist=findNearest($chr,$pos);
    if($dist>=0) { push @distances,$dist }
  }
  close(IN);
  my ($mean,$stddev,$min,$max)=SummaryStats::roundedSummaryStats(\@distances);
  return ($mean,$stddev);
}
#======================================================================
sub findNearest {
  my ($chr,$pos)=@_;
  my $A=$DEGs{$chr};
  my $n=@$A;
  my $begin=0; my $end=$n;
  while($begin<$end) {
    my $mid=int(($begin+$end)/2);
    my $midPos=$A->[$mid];
    if($pos<$midPos) { $end=$mid }
    else { $begin=$mid }
  }
  die unless $begin>=0 && $begin<$n;
  my $thisPos=$A->[$begin];
  my $dist=abs($pos-$thisPos);
  if($begin>0) {
    my $prevPos=$A->[$begin-1];
    my $prevDist=abs($pos-$prevPos);
    if($prevDist<$dist) { $dist=$prevDist }
  }
  if($begin+1<$n) {
    my $nextPos=$A->[$begin];
    my $nextDist=abs($pos-$nextPos);
    if($nextDist<$dist) { $dist=$nextDist }
  }
}
#======================================================================
#======================================================================
#======================================================================
#======================================================================
#======================================================================







