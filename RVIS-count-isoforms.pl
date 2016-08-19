#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
$|=1;

my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";

my $reader=new GffTranscriptReader;
my $genes=$reader->loadGenes($GFF);
my $numGenes=@$genes;

for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$genes->[$i];
  my $numIsoforms=$gene->getNumTranscripts();
  my $geneID=$gene->getId();
  my $chr=$gene->getSubstrate();
  print "HG000xxx\t1\t$geneID\t$numIsoforms\t$chr\n";
}



