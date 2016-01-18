#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use FastaReader;
use Translation;
use ProgramName;

my $name=ProgramName::get();
die "$name <HG####>\n" unless @ARGV==1;
my ($indiv)=@ARGV;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $REF="$COMBINED/$indiv/1.fasta";
my $GFF="$COMBINED/$indiv/mapped.gff";
my $OUTFILE="$COMBINED/$indiv/splice-sites.txt";

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

open(OUT,">$OUTFILE") || die $OUTFILE;
my $reader=new FastaReader($REF);
while(1) {
  my ($def,$seq)=$reader->nextSequence();
  last unless $def;
  $def=~/>(\S+)/ || die $def;
  my $id=$1;
  my $gene=$hash{$id};
  next unless $gene->getSubstrate()=~/_1/;
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
	  print OUT "donor\t$signal\t$id\n";
	}
	else { print OUT "acceptor\t$signal\t$id\n" }
      }
      if($i+1<$numExons) {
	my $signal=substr($seq,$end,2);
	if($strand eq "-") {
	  $signal=Translation::reverseComplement(\$signal);
	  print OUT "acceptor\t$signal\t$id\n";
	}
	else { print OUT "donor\t$signal\t$id\n" }
      }
    }
  }
}
close(OUT);


