#!/usr/bin/perl
use strict;
use FastaReader;
$|=1;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $FASTA="$ASSEMBLY/fasta-good";
my $COMBINED="$ASSEMBLY/combined";

my @indivs=`ls $COMBINED`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  process($indiv,1);
  process($indiv,2);
}


sub process
{
  my ($indiv,$genomeNum)=$_;
  my $combinedSize=seqLen("$COMBINED/$indiv/$genomeNum.fasta");
  print "$indiv combined: $combinedSize\n";
  my $totalChunkSize;
  for(my $i=0 ; $i<30 ; ++$i) {
    
  }
}


sub seqLen
{
  my ($filename)=@_;
  return FastaReader::getGenomicSize($filename);
}


