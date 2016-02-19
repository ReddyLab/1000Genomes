#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my%hash;
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


sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp;
    if(/(\S+)\s+(\S+)/) { push @{$hash{$1}},$2 }
  }
  close(IN);
}

