#!/usr/bin/perl
use strict;
use ProgramName;
use SubstitutionMatrix;

my @keep=("AFR");
#my @keep=("AFR","SAS","EAS");
my %keep; foreach my $k (@keep) { $keep{$k}=1 }
my $MATRIX_FILE="/home/bmajoros/alignment/matrices/pam10";
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $POP_FILE="$THOUSAND/assembly/populations.txt";
my $GFF="$ASSEMBLY/local-genes.gff";

my %geneID;
open(IN,$GFF) || die $GFF;
while(<IN>) {
  if(/transcript_id=(\S+);gene_id=([^;]+);/) {
    my ($trans,$gene)=($1,$2);
    $geneID{$trans}=$gene;
  }
}
close(IN);

my %pop;
open(IN,$POP_FILE) || die "can't open file: $POP_FILE\n";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($id,$pop)=@fields;
  $pop{$id}=$pop;
}
close(IN);

my ($ethnicLessExtreme,$refEthnicIdentical,$ethnicMappedIdentical,$sampleSize,
    $refMappedIdentical);
my $M=new SubstitutionMatrix($MATRIX_FILE);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $eth=$pop{$subdir};
  die unless $eth;
  #next if $eth eq "EUR";
  next unless $eth eq "AFR";
  next unless $keep{$eth};
  my $dir="$COMBINED/$subdir";
  next unless -e "$dir/1-substitutions.txt";
  process("$dir/1-substitutions.txt");
  process("$dir/2-substitutions.txt");
  my $percentLessExtreme=$ethnicLessExtreme/$sampleSize;
  my $percentRefEthnicIdentical=$refEthnicIdentical/$sampleSize;
  my $percentEthnicMappedIdentical=$ethnicMappedIdentical/$sampleSize;
  my $percentRefMappedIdentical=$refMappedIdentical/$sampleSize;
  $percentLessExtreme=round($percentLessExtreme);
  $percentRefEthnicIdentical=round($percentRefEthnicIdentical);
  $percentEthnicMappedIdentical=round($percentEthnicMappedIdentical);
  $percentRefMappedIdentical=round($percentRefMappedIdentical);
  print "$percentLessExtreme ($percentRefMappedIdentical)\tREI=$percentRefEthnicIdentical\tEMI=$percentEthnicMappedIdentical\tN=$sampleSize\n";
}

sub round
{
  my ($x)=@_;
  return int($x*1000+5/9)/1000;
}

sub process
{
  my ($filename)=@_;
  my %seen;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=5;
    my ($indiv,$transcriptID,$ref,$ethnic,$mapped)=@fields;
    my $geneID=$geneID{$transcriptID};
    next if $seen{$geneID};
    $seen{$geneID}=1;
    my $refToMapped=$M->lookup($ref,$mapped);
    my $ethnicToMapped=$M->lookup($ethnic,$mapped);
    if($ethnicToMapped>$refToMapped) {
      print "$ref => $ethnic => $mapped    $ethnicToMapped > $refToMapped\n"
	unless $ref eq $mapped || $ethnic eq $mapped || $ethnicToMapped<-1;
      ++$ethnicLessExtreme unless $ref eq $mapped || $ethnic eq $mapped;
      if($ref eq $mapped) { ++$refMappedIdentical }
    }
    if($ref eq $ethnic) { ++$refEthnicIdentical }
    if($ethnic eq $mapped) { ++$ethnicMappedIdentical }
    ++$sampleSize;
  }
  close(IN);
}




