#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $COORDINATE_ERROR=1; ### because of bug in Transcript.pm (now fixed)
my $MARGIN=1000;
my $IN_FILE="/home/bmajoros/ensembl/coding-and-noncoding.gff";
my $OUT_FILE="/home/bmajoros/1000G/assembly/local-genes.gff";

open(OUT,">$OUT_FILE") || die $OUT_FILE;
my $reader=new GffTranscriptReader;
my $genes=$reader->loadGenes($IN_FILE);
my $numGenes=@$genes;
for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$genes->[$i];
  my $begin=$gene->getBegin();
  my $numTrans=$gene->getNumTranscripts();
  for(my $i=0 ; $i<$numTrans ; ++$i) {
    my $transcript=$gene->getIthTranscript($i);
    $transcript->shiftCoords($MARGIN-$begin+$COORDINATE_ERROR);
  }
  my $gff=$gene->toGff();
  print OUT $gff;
}
close(OUT);


