#!/usr/bin/perl
use strict;
use ProgramName;
use SubstitutionMatrix;

my $MATRIX_FILE="/home/bmajoros/alignment/matrices/pam10";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";

#my ($refAndEthnicIdentical,$ethnicAndMappedIdentical);
my ($ethnicLessExtreme,$refEthnicIdentical,$ethnicMappedIdentical,$sampleSize);
my $M=new SubstitutionMatrix($MATRIX_FILE);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  process("$dir/1-substitutions.txt");
  process("$dir/2-substitutions.txt");
  my $percentLessExtreme=$ethnicLessExtreme/$sampleSize;
  my $percentRefEthnicIdentical=$refEthnicIdentical/$sampleSize;
  my $percentEthnicMappedIdentical=$ethnicMappedIdentical/$sampleSize;
  $percentLessExtreme=round($percentLessExtreme);
  $percentRefEthnicIdentical=round($percentRefEthnicIdentical);
  $percentEthnicMappedIdentical=round($percentEthnicMappedIdentical);
  print "$percentLessExtreme\t$percentRefEthnicIdentical\t$percentEthnicMappedIdentical\tN=$sampleSize\n";
}

sub round
{
  my ($x)=@_;
  return int($x*100+5/9)/100;
}

sub process
{
  my ($filename)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=5;
    my ($indiv,$transcriptID,$ref,$ethnic,$mapped)=@fields;
    my $refToMapped=$M->lookup($ref,$mapped);
    my $ethnicToMapped=$M->lookup($ethnic,$mapped);
    if($ethnicToMapped<$refToMapped) { ++$ethnicLessExtreme }
    if($ref eq $ethnic) { ++$refEthnicIdentical }
    if($ethnic eq $mapped) { ++$ethnicMappedIdentical }
    ++$sampleSize;
  }
  close(IN);
}




