#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";

my ($totalFound,$totalNotFound,$uniqueFound,$uniqueNotFound,%seen,
    $geneFound,$geneNotFound,%geneSeen);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $diffFile="$dir/diff.txt";
  next unless -e $diffFile;
  process($diffFile);
}
my $total=$totalFound+$totalNotFound;
my $ratio=$totalFound/$total;
print "$ratio ($totalFound\/$total) expressed ALTs were found by StringTie without annotation\n";
my $total=$uniqueFound+$uniqueNotFound;
my $ratio=$uniqueFound/$total;
print "$ratio ($uniqueFound\/$total) transcripts with expressed ALTs were found by StringTie without annotation\n";
my $total=$geneFound+$geneNotFound;
my $ratio=$geneFound/$total;
print "$ratio ($geneFound\/$total) genes with expressed ALTs were found by StringTie without annotation\n";


sub process {
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($geneID,$transcriptID,$found)=@fields;
    if($transcriptID=~/ALT\d+_(\S+)/) { $transcriptID=$1 }
    if($found) { ++$totalFound }
    else { ++$totalNotFound }
    next if $seen{$transcriptID};
    if($found) { ++$uniqueFound }
    else { ++$uniqueNotFound }
    $seen{$transcriptID}=1;
    next if $geneSeen{$geneID};
    if($found) { ++$geneFound }
    else { ++$geneNotFound }
    $geneSeen{$geneID}=1;
  }
  close(IN);
}





