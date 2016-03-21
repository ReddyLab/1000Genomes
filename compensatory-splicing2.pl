#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;
use FastaReader;

my $name=ProgramName::get();
die "$name <path-to-individual> <hap:1/2>\n" unless @ARGV==2;
my ($pathToIndiv,$hap)=@ARGV;
chop $pathToIndiv if($pathToIndiv=~/\/$/);
my $essex="$pathToIndiv/$hap.essex";
$pathToIndiv=~/combined\/(\S+)/ || die $pathToIndiv;
my $indiv=$1;
chomp $infile;
my $fasta="$pathToIndiv/$hap.fasta";
$reader=new FastaReader($filename);

my ($seq,$seqID);
my $parser=new EssexParser($essex);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexFBI($elem);
  next unless $report->getStatusString() eq "splicing-changes";
  next if $elem->findDescendent("premature-stop");
  my $array=$elem->findDescendents("transcript");
  my $ok=0;
  foreach my $transcript (@$array) {
    my $change=$transcript->getAttribute("structure-change");
    if($change eq "exon-skipping" &&
       $transcript->getAttribute("fate") ne "NMD") { $ok=1 }
  }
  next unless $ok;
  my $substrate=$report->getSubstrate();
  my $transcriptID=$report->getTranscriptID();
  my $geneID=$report->getGeneID();
  my $transcript=$report->getMappedTranscript();
  my $transcriptSeq=loadSequence($transcript);
  if($transcriptSeq=~/\*\S/) {
    print "$indiv\t$hap\t$geneId\t$transcriptId\t$transcriptSeq\n";
  }

}



sub loadSequence
{
  my ($transcript)=@_;
  my $substrate=$transcript->getSubstrate();
  while($substrate ne $seqID) {
    my ($defline,$sequence)=$reader->nextSequence();
    die unless $defline;
    $defline=~/>(\S+)/ || die $defline;
    $seqID=$1;
    $seq=$sequence;
  }
  return $transcript->loadTranscriptSeq(\$seq);
}




