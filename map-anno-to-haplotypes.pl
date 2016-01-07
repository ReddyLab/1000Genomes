#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use FastaReader;
use FastaWriter;

# Globals
my $GAP_OPEN=5;
my $GAP_EXTEND=1;
my $BANDWIDTH=50;
my $HOME="/home/bmajoros";
my $MAPPER="$HOME/cia/map-annotations";
my $ALIGNER="$HOME/cia/BOOM/banded-smith-waterman";
my $SUBST_MATRIX="$HOME/alignment/matrices/NUC.4.4";

# Parse command line
my $name=ProgramName::get();
die "$name <local-genes.gff> <ref-genome-dir> <personal-genome-dir>\n"
  unless @ARGV==3;
my ($localGenes,$refDir,$genomeDir)=@ARGV;

# Initialization
my $fastaWriter=new FastaWriter;
my $refGenome="$refDir/1.fasta";
my $refFasta="$genomeDir/ref.fasta";
my $altFasta="$genomeDir/alt.fasta";
my $refGffFile="$genomeDir/ref.gff";
my $altGffFile="$genomeDir/alt.gff";
my $combinedGFF="$genomeDir/mapped.gff";
unlink($combinedGFF) if -e $combinedGFF;
my $tempGff="$genomeDir/temp.gff";
$genomeDir=~/combined\/([^\/]+)$/ || die $genomeDir;
my $ID=$1;
my $cigarFile="$genomeDir/alignment.cigar";

# Load GFF and hash by gene ID
my %geneHash;
my $gffReader=new GffTranscriptReader;
my $genes=$gffReader->loadGenes($localGenes);
my $numGenes=@$genes;
for(my $i=0 ; $i<$numGenes ; ++$i) {
  my $gene=$genes->[$i];
  my $geneID=$gene->getId();
  $geneHash{$geneID}=$gene;
}

# Process each haplotype of this individual
for(my $haplotype=1 ; $haplotype<=2 ; ++$haplotype) {
  my $refReader=new FastaReader($refGenome);
  my $personalGenomeFile="$genomeDir/$haplotype.fasta";
  my $genomeReader=new FastaReader($personalGenomeFile);
  while(1) {
    my ($altDef,$altSeq)=$genomeReader->nextSequence();
    last unless defined $altDef;
    $altDef=~/^>(\S+)_\d\s/ || die $altDef;
    my $geneID=$1;
    my ($refDef,$refSeq);
    while(1) {
      ($refDef,$refSeq)=$refReader->nextSequence();
      die unless defined $refDef;
      $refDef=~/^>(\S+)\s/ || die $refDef;
      my $refGeneID=$1;
      last if $refGeneID eq $geneID;
    }

    # Align ref to alt gene to get CIGAR string for the mapper
    writeFasta(">ref",$refSeq,$refFasta);
    writeFasta(">alt",$altSeq,$altFasta);
    System("$ALIGNER -q -c $cigarFile $SUBST_MATRIX $GAP_OPEN $GAP_EXTEND $refFasta $altFasta DNA $BANDWIDTH");

    # Get the gene annotation and map each isoform separately
    my $gene=$geneHash{$geneID); die unless $gene;
    my $numTrans=$gene->getNumTranscripts();
    for(my $i=0 ; $i<$numTrans ; ++$i) {
      my $transcript=$gene->getIthTranscript($i);
      my $gff=$transcript->toGff();
      writeGFF($gff,$refGffFile);

      # Run the mapper to map the annotation across the alignment
      my $substrate="$geneID\_$haplotype";
      System("$MAPPER -s $substrate $refGffFile $cigarFile $altGff");

      # Add the mapped transcript to the output file
      System("cat $altGff >> $combinedGFF");
    }
  }
  $refReader->close();
  $genomeReader->close();
  die "ok";
}
unlink($altGffFile); unlink($refGffFile); unlink($cigarFile);
unlink($altFasta); unlink($refFasta); unlink($tempGff);

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
  print OUT "$gff";
  close(OUT);
}


sub System
{
  my ($cmd)=@_;
  #print "$cmd\n";
  system($cmd);
}

