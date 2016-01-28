#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;
use FastaReader;
use FastaWriter;

# Globals
my $HOME="/home/bmajoros";
my $MAPPER="$HOME/cia/map-annotations";

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
my $refGff="$genomeDir/ref.gff";
my $altGff="$genomeDir/alt.gff";
my $combinedGFF="$genomeDir/mapped.gff";
unlink($combinedGFF) if -e $combinedGFF;
my $tempGff="$genomeDir/temp.gff";
$genomeDir=~/combined\/([^\/]+)$/ || die $genomeDir;
my $ID=$1;
my $altIsRef=$ID eq "ref";
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
  next if $altIsRef && $haplotype>1;
  my $personalGenomeFile="$genomeDir/$haplotype.fasta";
  my $genomeReader=new FastaReader($personalGenomeFile);
  while(1) {
    my ($altDef,$altSeq)=$genomeReader->nextSequence();
    last unless defined $altDef;
    #print "$altIsRef : $altDef\n";
    my ($geneID,$cigar);
    if($altIsRef) 
      { $altDef=~/^>(\S+)\s.*\/cigar=(\S+)/ || die $altDef;
	($geneID,$cigar)=($1,$2) }
    else { $altDef=~/^>(\S+)_\d\s.*\/cigar=(\S+)/ || die $altDef;
	   ($geneID,$cigar)=($1,$2) }
    #print "geneID=$geneID\tcigar=$cigar\n";

    # Write cigar string into file
    open(CIGAR,">$cigarFile") || die $cigarFile;
    print CIGAR "$cigar\n";
    close(CIGAR);

    # Get the gene annotation and map each isoform separately
    my $gene=$geneHash{$geneID}; die $geneID unless $gene;
    my $numTrans=$gene->getNumTranscripts();
    for(my $i=0 ; $i<$numTrans ; ++$i) {
      my $transcript=$gene->getIthTranscript($i);
      my $gff=$transcript->toGff();
      writeGFF($gff,$refGff);

      # Run the mapper to map the annotation across the alignment
      my $substrate=$altIsRef ? $geneID : "$geneID\_$haplotype";
      System("$MAPPER -s $substrate $refGff $cigarFile $altGff");

      # Add the mapped transcript to the output file
      System("cat $altGff >> $combinedGFF");
    }
  }
  $genomeReader->close();
}
unlink($altGff); unlink($refGff); unlink($cigarFile);
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

