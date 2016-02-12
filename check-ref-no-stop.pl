#!/usr/bin/perl
use strict;
use EssexParser;
use GffTranscriptReader;
use FastaReader;
use TempFilename;
use Translation;

my $THOUSAND="/home/bmajoros/1000G";
my $GENOME_DIR="$THOUSAND/assembly/combined/HG00096";
my $FBI_FILE="$GENOME_DIR/out.fbi";
my $TWO_BIT="/data/reddylab/Reference_Data/hg19.2bit";
my $ENSEMBL="/home/bmajoros/ensembl/coding-and-noncoding.gff";
my $tempFile=TempFilename::generate();
my %stopCodons;
$stopCodons{"TGA"}=$stopCodons{"TAG"}=$stopCodons{"TAA"}=1;

# Load the original ensembl GFF
my $gffReader=new GffTranscriptReader();
my $byTranscriptID=$gffReader->loadTranscriptIdHash($ENSEMBL);

# Process the FBI output file
my ($notFound,$sampleSize);
my $parser=new EssexParser($FBI_FILE);
while(1) {
  my $report=$parser->nextElem(); last unless $report;
  my $status=$report->findChild("status"); next unless $status;
  my $code=$status->getIthElem(0); next unless $code;

  # Find a transcript with no-stop-codon
  next unless $code eq "bad-annotation";
  my $array=$status->findDescendents("no-stop-codon");
  next unless @$array>0;
  my $geneID=$report->getAttribute("substrate");
  my $transcriptID=$report->getAttribute("transcript-ID");
  ++$sampleSize;

  # Get ensembl GFF for this transcript
  my $transcript=$byTranscriptID->{$transcriptID};
  die "$transcriptID not found in ensembl GFF" unless $transcript;
  my $stopCoord=getStopCoord($transcript);
  my $strand=$transcript->getStrand();

  # Extract sequence from 2bit file
  my $substrate=$transcript->getSubstrate();
  if($strand eq "-") { $stopCoord-=3 }
  my $begin=$stopCoord;
  my $end=$begin+6;
  system("twoBitToFa -seq=$substrate -start=$begin -end=$end $TWO_BIT $tempFile");
  my $seq=FastaReader::firstSequence($tempFile); die unless length($seq)==6;
  if($strand eq "-") { $seq=Translation::reverseComplement(\$seq) }
  my $firstCodon=substr($seq,0,3); my $secondCodon=substr($seq,3,3);
  if($stopCodons{$firstCodon} || $stopCodons{$secondCodon}) {
    print "found\t$firstCodon\t$secondCodon\t$transcriptID\n";
    next
  }
  ++$notFound;
}
unlink($tempFile) if -e $tempFile;
print "$notFound of $sampleSize had no stop codon\n";




sub getStopCoord
{
  my ($transcript)=@_;
  my $strand=$transcript->getStrand();
  my $lastExon=$transcript->getIthExon($transcript->numExons()-1);
  if($strand eq "+") { return $lastExon->getEnd()-3 }
  else { return $lastExon->getBegin() }
}

