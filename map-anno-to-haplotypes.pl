#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use FastaReader;
use FastaWriter;

# Globals
my $MAPPER="/home/bmajoros/map-annotations";
my $ALIGNER="/home/bmajoros/cia/BOOM/banded-smith-waterman";
my $MATRIX="/home/bmajoros/alignment/matrices/NUC.4.4";

# Parse command line
my $name=ProgramName::get();
die "$name <local-genes.gff> <ref-genome-dir> <personal-genome-dir>\n"
  unless @ARGV==3;
my ($localGenes,$refFasta,$genomeDir)=@ARGV;

# Initialization
my $fastaWriter=new FastaWriter;
my $refFasta="$genomeDir/ref.fasta";
my $altFasta="$genomeDir/alt.fasta";
my $refGffFile="$genomeDir/ref.gff";
my $altGffFile="$genomeDir/alt.gff";

# Load GFF and hash by gene ID
my %geneHash;
my $gffReader=new GffTranscriptReader;
my $genes=$gffReader->loadGenes($localGenes);
my $numGenes=@$genes;
for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$genes->[$i];
  my $geneID=$gene->getId();
  $geneHash{$geneID);
}

# Process each haplotype of this individual
$genomeDir=~/combined\/([\/]+)/ || die $genomeDir;
my $ID=$1;
for(my $haplotype=1 ; $haplotype<=2 ; ++$haplotype) {
  my $refReader=new FastaReader($refFasta);
  my $personalGenomeFile="$genomeDir/$haplotype.fasta";
  my $genomeReader=new FastaReader($personalGenomeFile);
  while(1) {
    my ($personalDef,$personalSeq)=$genomeReader->nextSequence();
    last unless defined $personalDef;
    $personalDef=~/^>(\S+)_\d\s/ || die $personalDef;
    my $geneID=$1;
    my ($refDef,$refSeq);
    while(1) {
      ($refDef,$refSeq)=$refReader->nextSequence();
      die unless defined $refDef;
      $refDef=~/^>(\S+)\s/ || die $refDef;
      my $refGeneID=$1;
      last if $refGeneID eq $geneID;
    }

    # Align ref to personal gene to get CIGAR string for the mapper
    my $cigarFile="$genomeDir/$ID.cigar";
    writeFasta(">alt",$personalSeq,$altFasta);
    writeFasta(">ref",$refSeq,$refFasta);
    System("$ALIGNER -q -c $cigarFile $MATRIX 10 1 $refFasta $altFasta DNA 50");

    # Get the gene and map each isoform separately
    my $gene=$geneHash{$geneID); die unless $gene;
    my $numTrans=$gene->getNumTranscripts();
    for(my $i=0 ; $i<$numTrans ; ++$i) {
      my $transcript=$gene->getIthTranscript($i);
      my $gff=$transcript->toGff();
      writeGFF($gff,$refGffFile);

      # Run the mapper to map the annotation across the alignment
      System("$MAPPER $refGffFile $cigarFile $altGff");

    }

  }
  $refReader->close();
  $genomeReader->close();
}
unlink($altFasta); unlink($refFasta);


#===============================================================
sub writeFasta
{
  my ($def,$seq,$filename)=@_;
  $fastaWriter->writeFasta($def,$seq,$filename);
}



sub writeGFF
{
  my ($gff,$file)=@_;
  open(OUT,">$file") || die $file;
  print OUT "$gff\n";
  close(OUT);
}


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}

