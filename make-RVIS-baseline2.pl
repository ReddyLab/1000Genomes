#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
$|=1;

my $BROKEN="/home/bmajoros/1000G/assembly/inactivated2.txt";
my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";

my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($GFF);
my $numTranscripts=@$transcripts;

my (%byNumExons,%numExons);
for(my $i=0 ; $i<$numTranscripts ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $numExons=$transcript->numExons();
  push @{$byNumExons{$numExons}},$transcript;
  $numExons{$transcript->getTranscriptId()}=$numExons;
}

# Substitute broken genes for randomly selected ones with the desired trait
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($indiv,$allele,$gene,$transcriptID)=@fields;
  my $numExons=$numExons{$transcriptID};
  my $array=$byNumExons{$numExons};
  my $n=$array ? @$array : 0;
  next unless $n>0;
  my $random=$array->[int(rand($n))];
  my $transID=$random->getTranscriptId();
  my $geneID=$random->getGeneId();
  my $chr=$random->getSubstrate();
  print "$indiv\t$allele\t$geneID\t$transID\t$chr\n";
}
close(IN);


