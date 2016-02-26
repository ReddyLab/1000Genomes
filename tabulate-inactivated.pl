#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my %hash;
my @dirs=`ls $COMBINED`;
my $slurmID=1;
print "transcript\tgene";
#my @indiv;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $indiv=$subdir;
#  push @indiv,$indiv;
  print "\t$indiv";
}
print "\n";

foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $indiv=$subdir;
  process("$dir/1-inactivated.txt",$indiv);
  process("$dir/2-inactivated.txt",$indiv);
}

my @keys=keys %hash;
foreach my $key (@keys) {
  my $array=$hash{$key};


}


sub process
{
  my ($infile,$indiv,$hash)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>3;
    my ($gene,$transcript,$event,$why)=@fields;
    push @{$hash->{$gene}},{invid=>$indiv,event=>$event,why=>$why};
  }
  close(IN);
}

