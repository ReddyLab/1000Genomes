#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use FastaReader;
$|=1;

my $BROKEN="/home/bmajoros/1000G/assembly/broken.txt";
my $GFF="/home/bmajoros/1000G/assembly/local-genes.gff";
my $FASTA="/home/bmajoros/1000G/assembly/combined/ref/1.fasta";

my $reader=new GffTranscriptReader;
my $transcripts=$reader->loadGFF($GFF);
my $numTranscripts=@$transcripts;

my %bySubstrate;
for(my $i=0 ; $i<$numTranscripts ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $substrate=$transcript->getGeneId();
  push @{$bySubstrate{$substrate}},$transcript;
}

my (%byGC,%gc);
my $reader=new FastaReader($FASTA);
while(1) {
  my ($def,$seq)=$reader->nextSequence();
  last unless $def;
  $def=~/>([\s_]+)/ || die;
  my $substrate=$1;
  my $GC=$seq=~s/([GC]+)/$1/g;
  my $ACGT=$seq=~s/([ACGT]+)/$1/g;
  my $gc=int($GC/$ACGT*10);
print "GC = $gc\n";
  my $transcripts=$bySubstrate{$substrate};
  foreach my $transcript (@$transcripts) {
    push @{$byGC{$gc}},$transcript;
    $gc{$transcript->getTranscriptId()}=$gc;
  }
}

# Substitute broken genes for randomly selected ones with the desired trait
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$transcriptID,$chr)=@fields;
  my $gc=$gc{$transcriptID};
  my $array=$byGC{$gc};
  my $n=$array ? @$array : 0;
  next unless $n>0;
  my $random=$array->[int(rand($n))];
  my $transID=$random->getTranscriptId();
  my $geneID=$random->getGeneId();
  my $chr=$random->getSubstrate();
  print "$indiv\t$allele\t$geneID\t$transID\t$chr\n";
}
close(IN);


