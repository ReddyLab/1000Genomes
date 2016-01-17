#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $THOUSAND="/home/bmajoros/1000G";
my $INFILE="/home/bmajoros/ensembl/coding-and-noncoding.gff";
my $OUT_EXONS="$THOUSAND/assembly/reference-exons.gff";
my $OUT_CDS="$THOUSAND/assembly/reference-CDS.gff";

my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($INFILE);

my @codingTypes=("initial-exon","internal-exon","final-exon","single-exon");
my %codingTypes;
foreach my $type (@codingTypes) { $codingTypes{$type}=1 }

open(EXONS,">$OUT_EXONS") || die $OUT_EXONS;
open(CDS,">$OUT_CDS") || die $OUT_CDS;
my $numTrans=@$transcripts;
for(my $i=0 ; $i<$numTrans ; ++$i) {
  my $trans=$transcripts->[$i];
  my $exons=$trans->{exons};
  next unless @$exons>0; #die $trans->getID() unless @$exons>0;
  my $exon=$exons->[0];
  my $exonType=$exon->{type};
  my $proteinCoding=0;
  my $extraFields=$trans->{extraFields};
  if($extraFields=~/protein/) {
    foreach my $exon (@$exons) { $exon->setType("CDS") }
    my $gff=$trans->toGff();
    print CDS $gff;
  }
  my $exons=$trans->getRawExons();
  my ($substrate,$source,$begin,$end,$strand);
  $source=$trans->getSource();
  $strand=$trans->getStrand();
  $substrate=$trans->getSubstrate();
  foreach my $exon (@$exons) {
    my $gff=$exon->toGff();
    print EXONS $gff;
    if(!defined($begin) || $exon->getBegin()<$begin)
      { $begin=$exon->getBegin() }
    if(!defined($end) || $exon->getEnd()>$end)
      { $end=$exon->getEnd() }
  }
  ++$begin; # GFF is 1-based
  print EXONS "$substrate\t$source\ttranscript\t$begin\t$end\t.\t$strand\t.\t$extraFields\n";
}
close(CDS);
close(EXONS);





