#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $BASE="/home/bmajoros/1000G/assembly";
my $INFILE="$BASE/ENSG00000198947.gff";

my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($INFILE);

my ($best,$bestNumExons);
foreach my $transcript (@$transcripts) {
  my $numExons=$transcript->numExons();
  if($numExons>$bestNumExons) {
    $best=$transcript;
    $bestNumExons=$numExons;
  }
}
print $best->toGff();


