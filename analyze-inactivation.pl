#!/usr/bin/perl
use strict;
use SummaryStats;

# Some globals
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my %xy; # genes on X/Y chromosomes
loadXY("$ASSEMBLY/xy.txt",\%xy);

# Process input files
open(NMD,">nmd-proportions.txt") || die;
open(BOTH,">homo-het-counts.txt");
my (@hetCounts,@homoCounts,%counts);
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  my $genes1=process("$COMBINED/$indiv/1-inactivated.txt");
  my $genes2=process("$COMBINED/$indiv/2-inactivated.txt");
  my @keys1=keys %$genes1; my @keys2=keys %$genes2;
  my $numHet=0; my $numHomo=0;
  foreach my $key (@keys1) 
    { if($genes2->{$key}) {++$numHomo} else {++$numHet} }
  foreach my $key (@keys2) { if(!$genes1->{$key}) {++$numHet} }
  push @hetCounts,$numHet; push @homoCounts,$numHomo;
  my $both=$numHet+$numHomo;
  print BOTH "$both\n";
}
close(BOTH); close(NMD);

# Report het/homo stats
my ($meanHet,$sdHet,$minHet,$maxHet)=
    SummaryStats::roundedSummaryStats(\@hetCounts);
my ($meanHomo,$sdHomo,$minHomo,$maxHomo)=
    SummaryStats::roundedSummaryStats(\@homoCounts);
print "Each individual has $meanHet +- $sdHet het LOFs\n";
print "Each individual has $meanHomo +- $sdHomo homo LOFs\n";

# Make counts files for histograms
open(OUT,">het-counts.txt") || die;
foreach my $het (@hetCounts) { print OUT "$het\n" }
close(OUT);
open(OUT,">homo-counts.txt") || die;
foreach my $homo (@homoCounts) { print OUT "$homo\n" }
close(OUT);

# Split out events and causes
my @keys=keys %counts;
my $total=0;
foreach my $what (@keys) {
  my $hash=$counts{$what};
  my @whys=keys %$hash;
  my $sum=0;  foreach my $why (@whys) { $sum+=$hash->{$why} }
  $total+=$sum;
  foreach my $why (@whys) {
    my $count=$hash->{$why};
    my $proportion=round($count/$sum);
    print "$proportion = $count/$sum $what $why\n";
  }
}
foreach my $what (@keys) {
  my $hash=$counts{$what};
  my @whys=keys %$hash;
  my $sum=0;  foreach my $why (@whys) { $sum+=$hash->{$why} }
  my $proportion=round($sum/$total);
  print "TOTAL $what $proportion = $sum/$total\n";
}
#=====================================================
sub process
{
  my ($filename)=@_;
  my $brokenGenes={};
  open(IN,$filename) || die "can't open file: $filename\n";
  my $total=0; my $nmd=0;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$type,$why)=@fields;
    next if($xy{$gene});
    $brokenGenes->{$gene}=1;
    ++$counts{$type}->{$why};
    ++$total;
    if($type eq "NMD") { ++$nmd }
  }
  close(IN);
  my $proportion=$nmd/$total;
  print NMD "$proportion\t$nmd\t$total\n";
  return $brokenGenes;
}
#=====================================================
sub round
{
  my ($x)=@_;
  $x=int($x*10000+5/9)/10000;
  return $x;
}
#======================================================================
sub loadXY
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($chr,$gene,$transcript)=@fields;
    $hash->{$gene}=1;
  }
  close(IN);
}
#======================================================================
#=====================================================
#=====================================================
#=====================================================
#=====================================================
#=====================================================
#=====================================================



