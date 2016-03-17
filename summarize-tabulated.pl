#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my (%hash,$altSum,$altN,$frameshiftLen,$frameshiftN);
my @dirs=`ls $COMBINED`;
my $slurmID=1;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  process("$dir/1-tabulated.txt");
  process("$dir/2-tabulated.txt");
}

my @keys=keys %hash;
foreach my $key (@keys) {
  my $array=$hash{$key};
  my ($mean,$stddev,$min,$max)=SummaryStats::roundedSummaryStats($array);
  print "$key\t$mean +/- $stddev ($min\-$max)\n";
}
my $meanAlt=$altSum/$altN;
print "ALT_TRANSCRIPTS\tmean=$meanAlt\tsum=$altSum\tN=$altN\n";
my $meanFrameshift=$frameshiftLen/$frameshiftN;
print "FRAMESHIFT_LENGTHS\tmean=$meanFrameshift\tsum=$frameshiftLen\tN=$frameshiftN\n";

sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp;
    if(/ALT_TRANSCRIPTS\s+(\S+)\s+(\S+)/) {
      $altSum+=$1;
      $altN+=$2;
      next;
    }
    if(/GENES_FRAMESHIFT\s+(\S+)\s+(\S+)\s+(\S+)/) {
      push @{$hash{"GENES_FRAMESHIFT"}},$1;
      $frameshiftLen+=$2;
      $frameshiftN+=$3;
      next;
    }
    if(/(\S+)\s+(\S+)/) { push @{$hash{$1}},$2 }
  }
  close(IN);
}

