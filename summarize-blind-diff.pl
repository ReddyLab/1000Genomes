#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $OUTFILE="$THOUSAND/assembly/sensitivity-histogram.txt";

open(OUT,">$OUTFILE") || die $OUTFILE;

my ($totalFound,$totalNotFound,%transcriptFound,%allTranscripts,
    %geneFound,%allGenes);
my @dirs=`ls $COMBINED`;
foreach my $subdir (@dirs) {
  chomp $subdir;
  next unless $subdir=~/^HG\d+$/ || $subdir=~/^NA\d+$/;
  my $dir="$COMBINED/$subdir";
  my $diffFile="$dir/diff.txt";
  next unless -e $diffFile;
  process($diffFile);
}
close(OUT);

my $total=$totalFound+$totalNotFound;
my $ratio=$totalFound/$total;
print "$ratio ($totalFound\/$total) expressed ALTs were found by StringTie without annotation\n";

my @keys=keys %allTranscripts; my $total=@keys;
my @found=keys %transcriptFound; my $found=@found;
my $ratio=$found/$total;
print "$ratio ($found\/$total) transcripts with expressed ALTs were found by StringTie without annotation\n";

my @keys=keys %allGenes; my $total=@keys;
my @found=keys %geneFound; my $found=@found;
my $ratio=$found/$total;
print "$ratio ($found\/$total) genes with expressed ALTs were found by StringTie without annotation\n";


sub process {
  my ($infile)=@_;
  open(IN,$infile) || die "can't open $infile";
  my $numFound=0; my $total=0;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($geneID,$transcriptID,$found)=@fields;
    if($transcriptID=~/ALT\d+_(\S+)/) { $transcriptID=$1 }
    if($found) { ++$totalFound }
    else { ++$totalNotFound }
    #print "gene=$geneID\t\ttranscript=$transcriptID\n";
    $allTranscripts{$transcriptID}=1;
    $allGenes{$geneID}=1;
    if($found) {
      $transcriptFound{$transcriptID}=1;
      $geneFound{$geneID}=1;
      ++$numFound;
    }
    ++$total;
  }
  my $sensitivity=$numFound/$total;
  print OUT "$sensitivity\n";
  close(IN);
}





