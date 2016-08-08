#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
$|=1;

my $BROKEN="/home/bmajoros/1000G/assembly/inactivated.txt";
my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";

my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($GFF);
my $numTranscripts=@$transcripts;

my (%byCdsLen,%cdsLen);
for(my $i=0 ; $i<$numTranscripts ; ++$i) {
  my $transcript=$transcripts->[$i];
  #my $cdsLen=int($transcript->getLength()/1000);
  my $cds=$transcript->getLength(); next unless $cds>0;
  my $cdsLen=int(log($cds)/log(2));
  push @{$byCdsLen{$cdsLen}},$transcript;
  $cdsLen{$transcript->getTranscriptId()}=$cdsLen;
}

# Substitute broken genes for randomly selected ones with the desired trait
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($indiv,$allele,$gene,$transcriptID)=@fields;
  my $cdsLen=$cdsLen{$transcriptID};
  my $array=$byCdsLen{$cdsLen};
  my $n=$array ? @$array : 0;
  next unless $n>0;
  my $random=$array->[int(rand($n))];
  my $transID=$random->getTranscriptId();
  my $geneID=$random->getGeneId();
  my $chr=$random->getSubstrate();
  print "$indiv\t$allele\t$geneID\t$transID\t$chr\n";
}
close(IN);


