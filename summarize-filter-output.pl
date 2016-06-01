#!/usr/bin/perl
use strict;
use SummaryStats;

my $DIR="/home/bmajoros/1000G/assembly/filter-essex-slurms/outputs";

my %values;
my @files=`ls $DIR/*.output`;
foreach my $file (@files) {
  open(IN,$file) || die "can't open file: $file\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($key,$value)=@fields;
    next if $key eq "SLURM";
    push @{$values{$key}},$value;
  }
  close(IN);
}

my @keys=keys %sums;
foreach my $key (@keys) {
  my $values=$values{$key};
  my ($mean,$stddev,$min,$max)=SummaryStats::roundedSummaryStats($values);
  print "$key\t$mean +/- $stddev ($min-$max)\n";
}


