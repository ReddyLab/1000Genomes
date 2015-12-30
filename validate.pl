#!/usr/bin/perl
use strict;
use FastaReader;

my $FASTA="/home/bmajoros/1000G/assembly/fasta/0";

my @files=`ls $FASTA`;
my $numFiles=@files;
for(my $i=0 ; $i<$numFiles ; ++$i) {
  my $file=$files[$i];
  chomp $file;
  next unless $file=~/\.fasta$/;
  my $refReader=new FastaReader("$FASTA/ref-1.fasta");
  my $indReader=new FastaReader("$FASTA/$file");
  while(1) {
    my ($refDef,$refSeq)=$refReader->nextSequence();
    last unless $refDef;
    $refDef=~/>(\S+)\s+\/coord=(chr[^:]+):(\d+)-(\d+):(\S)\s+/ || die $refDef;
    my ($refGene,$refChr,$refBegin,$refEnd,$refStrand)=($1,$2,$3,$4,$5);
    my ($indDef,$indSeq)=$indReader->nextSequence();
    $indDef=~/>(\S+)\s+\/coord=(chr[^:]+):(\d+)-(\d+):(\S)\s+/ || die $indDef;
    my ($indGene,$indChr,$indBegin,$indEnd,$indStrand)=($1,$2,$3,$4,$5);
    print "$refGene\n";
    die "$refGene vs. $indGene" unless $refGene eq $indGene;
    # >ENSG00000218839 /coord=chr9:33392-36856:- /margin=1000


  }

}



