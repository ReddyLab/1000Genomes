#!/usr/bin/perl
use strict;
use GffTranscriptReader;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $CARSON="$THOUSAND/carson.txt";
my $GFF="$THOUSAND/local-genes.gff";

open(BG,">isoform-counts-bkg.txt") || die;
my $reader=new GffTranscriptReader;
my $allGenes=$reader->loadGenes($GFF);
my %geneHash;
my $numGenes=@$allGenes;
for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$allGenes->[$i];
  my $id=$gene->getId();
  if($id=~/(\S+)\./) { $id=$1 }
  $geneHash{$id}=$gene;
  my $numTrans=$gene->getNumTranscripts();
  print BG "$numTrans\n";
}
close(BG);

open(FG,">isoform-counts-RVIS.txt") || die;
open(IN,$CARSON) || die $CARSON;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($geneID,$count,$RVIS)=@fields;
  my $gene=$geneHash{$geneID};
  my $numTrans=$gene->getNumTranscripts();
  print FG "$numTrans\n";
}
close(IN);
close(FG);


