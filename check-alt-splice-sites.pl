#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use FastaReader;
use Translation;

my $REF="/home/bmajoros/1000G/assembly/combined/HG00096/1.fasta";
my $GFF="/home/bmajoros/1000G/assembly/combined/HG00096/mapped-1.gff";

my %hash;
my $reader=new GffTranscriptReader;
my $genes=$reader->loadGenes($GFF);
my $numGenes=@$genes;
for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$genes->[$i];
  my $id=$gene->getId();
  $id.="_1";
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
    @$exons=sort {$a->getBegin() <=> $b->getBegin()} @$exons;
    my $numExons=@$exons;
    for(my $i=0 ; $i<$numExons ; ++$i) {
      my $exon=$exons->[$i];
      my $begin=$exon->getBegin(); my $end=$exon->getEnd();
      if($i>0) {
	my $signal=substr($seq,$begin-2,2);
	if($strand eq "-") {
	  $signal=Translation::reverseComplement(\$signal);
	  print "donor\t$signal\t$id\n";
	}
	else { print "acceptor\t$signal\t$id\n" }
      }
      if($i+1<$numExons) {
	my $signal=substr($seq,$end,2);
	if($strand eq "-") {
	  $signal=Translation::reverseComplement(\$signal);
	  print "acceptor\t$signal\t$id\n";
	}
	else { print "donor\t$signal\t$id\n" }
      }
    }
  }
}



