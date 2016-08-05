#!/usr/bin/perl
use strict;
use EssexParser;
use GffTranscriptReader;
use FastaReader;
use TempFilename;
use Translation;

my $THOUSAND="/home/bmajoros/1000G";
my $GENOME_DIR="$THOUSAND/assembly/combined/HG00096";
my $ICE_FILE="$GENOME_DIR/out.ice";
my $TWO_BIT="/data/reddylab/Reference_Data/hg19.2bit";
my $ENSEMBL="/home/bmajoros/ensembl/coding-and-noncoding.gff";
my $tempFile=TempFilename::generate();
my %startCodons; $startCodons{"ATG"}=1;

# Load the original ensembl GFF
my $gffReader=new GffTranscriptReader();
my $byTranscriptID=$gffReader->loadTranscriptIdHash($ENSEMBL);

# Process the ICE output file
my ($notFound,$sampleSize);
my $parser=new EssexParser($ICE_FILE);
while(1) {
  my $report=$parser->nextElem(); last unless $report;
  my $status=$report->findChild("status"); next unless $status;
  my $code=$status->getIthElem(0); next unless $code;

  # Find a transcript with no-stop-codon
  next unless $code eq "bad-annotation";
  my $array=$status->findDescendents("bad-start");
  next unless @$array>0;
  my $geneID=$report->getAttribute("substrate");
  my $transcriptID=$report->getAttribute("transcript-ID");
  ++$sampleSize;

  # Get ensembl GFF for this transcript
  my $transcript=$byTranscriptID->{$transcriptID};
  die "$transcriptID not found in ensembl GFF" unless $transcript;
  my $startCoord=getStartCoord($transcript);
  my $strand=$transcript->getStrand();

  # Extract sequence from 2bit file
  my $substrate=$transcript->getSubstrate();
  if($strand eq "+") { $startCoord-=3 }
  my $begin=$startCoord;
  my $end=$begin+6;
  system("twoBitToFa -seq=$substrate -start=$begin -end=$end $TWO_BIT $tempFile");
  my $seq=FastaReader::firstSequence($tempFile); die unless length($seq)==6;
  if($strand eq "-") { $seq=Translation::reverseComplement(\$seq) }
  my $firstCodon=substr($seq,0,3); my $secondCodon=substr($seq,3,3);
  if($startCodons{$firstCodon} || $startCodons{$secondCodon}) {
    print "found\t$firstCodon\t$secondCodon\t$transcriptID\n";
    next
  }
  ++$notFound;
}
unlink($tempFile) if -e $tempFile;
print "$notFound of $sampleSize had no start codon\n";




sub getStartCoord
{
  my ($transcript)=@_;
  my $strand=$transcript->getStrand();
  my $firstExon=$transcript->getIthExon(0);
  if($strand eq "+") { return $firstExon->getBegin() }
  else { return $firstExon->getEnd()-3 }
}

