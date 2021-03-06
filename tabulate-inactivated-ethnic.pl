#!/usr/bin/perl
use strict;
use SummaryStats;

my $HOMOZYGOUS=0;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined-ethnic";

my %parent;
my @dirs=`ls $COMBINED`;
my $slurmID=1;
print "transcript\tgene";
my @indiv;
foreach my $subdir (@dirs) {
  chomp $subdir;
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/1-inactivated.txt";
  my $indiv=$subdir;
  push @indiv,$indiv;
  print "\t$indiv";
}
print "\n";

my %genes;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless -e "$COMBINED/$subdir/1-inactivated.txt";
  my $dir="$COMBINED/$subdir";
  my $indiv=$subdir;
  my (%hash1,%hash2);
  process("$dir/1-inactivated.txt",$indiv,\%hash1);
  my %combined;
  my @keys=keys %hash1;
  foreach my $key (@keys) {
    my $rec=$hash1{$key}; my ($event,$why)=@$rec;
    ++$combined{$key};}
  my @keys=keys %combined;
  foreach my $key (@keys) {
    if($combined{$key}>$HOMOZYGOUS) {
      $genes{$key}->{$indiv}=1;
    }
  }
}

my @transcripts=keys %genes;
foreach my $transcript (@transcripts) {
  my $parent=$parent{$transcript};
  print "$transcript\t$parent";
  my $hash=$genes{$transcript};
  foreach my $indiv (@indiv) {
    #my $status=0+$hash->{$indiv};
    my $status=1-$hash->{$indiv};
    print "\t$status";
  }
  print "\n";
}


sub process
{
  my ($infile,$indiv,$hash)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>3;
    my ($gene,$transcript,$event,$why)=@fields;
    $hash->{$transcript}=[$event,$why];
    $parent{$transcript}=$gene;
  }
  close(IN);
}

