#!/usr/bin/perl
use strict;
use SummaryStats;

# Some globals
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

# Process input files
my (@hetCounts,@homoCounts;
my @dirs=`ls $COMBINED`;
foreach my $indiv (@dirs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  my $genes1=process("$COMBINED/$indiv/1-inactivated.txt");
  my $genes2=process("$COMBINED/$indiv/2-inactivated.txt");
  my @keys1=keys %$genes1; my @keys2=keys %$genes2;
  my $numHet=0; my $numHomo=0;
  foreach my $key (@keys1) { if($genes2->{$key}) {++$numHomo} else {++$numHet} }
  foreach my $key (@keys2) { if(!$genes1->{$key}) {++$numHet} }
  push @hetCounts,$het; push @homoCounts,$homo;
}
my ($meanHet,$sdHet,$minHet,$maxHet)=
    SummaryStats::roundedSummaryStats(\@hetCounts);
my ($meanHomo,$sdHomo,$minHomo,$maxHomo)=
    SummaryStats::roundedSummaryStats(\@homotCounts);
print "Each individual has $meanHet +- $sdHet het LOFs\n";
print "Each individual has $meanHomo +- $sdHomo homo LOFs\n";

#=====================================================
sub process
{
  my ($filename)=@_;
  my $brokenGenes={};
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=4;
    my ($gene,$transcript,$type,$why)=@fields;
    $brokenGenes{$gene}=1;
  }
  close(IN);
  return $brokenGenes;
}



