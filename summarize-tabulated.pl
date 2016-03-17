#!/usr/bin/perl
use strict;
use SummaryStats;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

my (%hash,$altSum,$altSquared,$altN,$frameshiftLen,$frameshiftSquared,
    $frameshiftN,$crypticSum,$crypticSquared,$crypticN);
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
my $varAlt=($altSquared-$altSum*$altSum/$altN)/($altN-1);
my $sdAlt=sqrt($varAlt);
print "ALT_TRANSCRIPTS\tmean=$meanAlt\tSD=$sdAlt\tsum=$altSum\tN=$altN\n";
my $meanFrameshift=$frameshiftLen/$frameshiftN;
my $varFrameshift=
  ($frameshiftSquared-$frameshiftLen*$frameshiftLen/$frameshiftN)/
  ($frameshiftN-1);
my $sdFrameshift=sqrt($varFrameshift);
print "FRAMESHIFT_LENGTHS\tmean=$meanFrameshift\tSD=$sdFrameshift\tsum=$frameshiftLen\tN=$frameshiftN\n";
my $meanCryptic=$crypticSum/$crypticN;
my $varCryptic=($crypticSquared-$crypticSum*$crypticSum/$crypticN)/
  ($crypticN-1);
my $sdCryptic=sqrt($varCryptic);
print "CRYPTIC_SITES\tmean=$meanCryptic\tSD=$sdCryptic\tsum=$crypticSum\tN=$crypticN\n";

sub process
{
  my ($infile)=@_;
  open(IN,$infile) || die $infile;
  while(<IN>) {
    chomp;
    if(/ALT_TRANSCRIPTS\s+(\S+)\s+(\S+)\s+(\S+)/) {
      $altSum+=$1;
      $altSquared+=$2;
      $altN+=$3;
      next;
    }
    if(/CRYPTIC_SITES\s+(\S+)\s+(\S+)\s+(\S+)/) {
      $crypticSum+=$1;
      $crypticSquared+=$2;
      $crypticN+=$3;
      next;
    }
    if(/GENES_FRAMESHIFT\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
      push @{$hash{"GENES_FRAMESHIFT"}},$1;
      $frameshiftLen+=$2;
      $frameshiftSquared+=$3;
      $frameshiftN+=$4;
      next;
    }
    if(/(\S+)\s+(\S+)/) { push @{$hash{$1}},$2 }
  }
  close(IN);
}

