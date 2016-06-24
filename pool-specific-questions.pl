#!/usr/bin/perl
use strict;
use SummaryStats;
$|=1;

# Some globals
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

# Process input files
my @indivs=`ls $COMBINED`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  process("$COMBINED/$indiv/1.specific-questions");
  process("$COMBINED/$indiv/2.specific-questions");
}

my ($genesWithSplicingChanges,$codingGenesWithSplicingChanges,
    $allGenes,$codingGenes,$lofInAll,$transWithSplicingChanges,
    $lofInSome,$lofGenes);
sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile";
  while(<IN>) {
    if(/(\d+)\/(\d+) coding genes had splicing changes/)
      { $codingGenesWithSplicingChanges+=$1; $genesWithSplicingChanges+=$2 }
    if(/(\d+)\/(\d+) coding genes present/)
      { $codingGenes+=$1; $allGenes+=$2 }
    if(/(\d+)\/(\d+)  transcripts with splicing changes had LOF in all alt structures/)
      { $lofInAll+=$1; $transWithSplicingChanges+=$2 }
    if(/(\d+)\/(\d+) of LOF genes had LOF in some isoforms but not others/)
      { $lofInSome+=$1; $lofGenes+=$2 }
  }
  close(IN);
}

report($genesWithSplicingChanges,$codingGenesWithSplicingChanges,
       "proportion of genes with splicing changes that are coding genes");
report($allGenes,$codingGenes,"proportion of genes that are coding");
report($lofInAll,$transWithSplicingChanges,
       "of those genes with splicing changes, this proportion had LOF in all predicted ALT structures");
report($lofInSome,$lofGenes,"of genes with LOF, this many had LOF in some but not all isoforms");




