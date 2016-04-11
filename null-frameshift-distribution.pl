#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $GFF="/home/bmajoros/ensembl/protein-coding.gff";

my $reader=new GffTranscriptReader();
my $array=$reader->loadGFF($GFF);
my $n=@$array;
for(my $i=0 ; $i<$n; ++$i) {
  my $transcript=$array->[$i];
  my $L=$transcript->getLength();
  my $affectedLen=int(rand($L));
  print "$affectedLen\n";
}





