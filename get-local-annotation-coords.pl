#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $COORDINATE_ERROR=1; # Because of bug in Transcript.pm (now fixed).
                        # Will need to change this to 0 if I ever regenerate
                        # the individual genes#.gff files and use them to
                        # rebuild the personal genomes
my $MARGIN=1000;
my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
#my $IN_FILE="/home/bmajoros/ensembl/coding-and-noncoding.gff";
#my $OUT_FILE="/home/bmajoros/1000G/assembly/local-genes.gff";

process("$ASSEMBLY/reference-exons.gff", "$ASSEMBLY/local-genes.gff","exon");
process("$ASSEMBLY/reference-CDS.gff", "$ASSEMBLY/local-CDS.gff","CDS");


sub process
{
  my ($infile,$outfile,$exonType)=@_;
  open(OUT,">$outfile") || die $outfile;
  my $reader=new GffTranscriptReader;
  my $genes=$reader->loadGenes($infile);
  my $numGenes=@$genes;
  for(my $i=0 ; $i<$numGenes ; ++$i) {
    my $gene=$genes->[$i];
    my $begin=$gene->getBegin();
    my $numTrans=$gene->getNumTranscripts();
    for(my $i=0 ; $i<$numTrans ; ++$i) {
      my $transcript=$gene->getIthTranscript($i);
      $transcript->shiftCoords($MARGIN-$begin+$COORDINATE_ERROR);
      foreach my $exon (@{$transcript->{exons}}) { $exon->setType($exonType) }
    }
    my $gff=$gene->toGff();
    print OUT $gff;
  }
  close(OUT);
}

