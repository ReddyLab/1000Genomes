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
  die unless @$exons>0;
  my $exon=$exons->[0];
  my $exonType=$exon->{type};
  my $proteinCoding=0;
  if($codingTypes{$exonType} || $trans->{extraFields}=~/protein/) {
    my $gff=$trans->toGff();
    print CDS $gff;
  }
  my $exons=$trans->getRawExons();
  foreach my $exon (@$exons) {
    $exon->toGff();
    print EXONS $exon;
  }
}
close($CDS);
close(EXONS);





