#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use FastaReader;

my $REF="/home/bmajoros/1000G/assembly/combined/ref/1.fasta";
my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";

my %hash;
my $reader=new GffTranscriptReader;
my $genes=$reader->loadGenes($GFF);
my $numGenes=@$genes;
for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$genes->[$i];
  my $id=$gene->getId();
  $hash{$id}=$gene;
}

my $reader=new FastaReader($REF);
while(1) {
  my ($def,$seq)=$reader->nextSequence();
  last unless $def;
  $def=~/>(\S+)/ || die $def;
  my $id=$1;
  my $gene=$hash{$id};
  die $id unless $gene;
  my $numTrans=$gene->getNumTranscripts();
  for(my $i=0 ; $i<$numTrans ; ++$i) {
    my $transcript=$gene->getIthTranscript($i);
    my $strand=$transcript->{strand};
    my $chr=$transcript->{substrate};
    my $exons=$transcript->{exons};
    my $numExons=@$exons;
    for(my $i=0 ; $i<$numExons ; ++$i) {
      my $exon=$exons->[$i];
      my $begin=$exon->getBegin(); my $end=$exon->getEnd();
      
    }
  }
}



