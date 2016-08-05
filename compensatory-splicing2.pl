#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexICE;
use FastaReader;
use Translation;

my $name=ProgramName::get();
die "$name <path-to-individual> <hap:1/2>\n" unless @ARGV==2;
my ($pathToIndiv,$hap)=@ARGV;
chop $pathToIndiv if($pathToIndiv=~/\/$/);
my $essex="$pathToIndiv/$hap-filtered.essex";
$pathToIndiv=~/combined\/(\S+)/ || die $pathToIndiv;
my $indiv=$1;
my $fasta="$pathToIndiv/$hap.fasta";
my $reader=new FastaReader($fasta);

my ($seq,$seqID);
my $parser=new EssexParser($essex);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexICE($elem);
  next unless $report->getStatusString() eq "splicing-changes";
  #next if $elem->findDescendent("premature-stop");
  my $array=$elem->findDescendents("transcript");
  my $ok=0;
  foreach my $transcript (@$array) {
    my $change=$transcript->getAttribute("structure-change");
    if($change eq "exon-skipping" &&
       $transcript->getAttribute("fate") ne "NMD") { $ok=1 }
  }
  next unless $ok;
  my $transcriptID=$report->getTranscriptID();
  my $geneID=$report->getGeneID();
  my $mapped=$elem->findDescendent("mapped-transcript");
  my $protein=$mapped->getAttribute("translation");
  #print "$protein\n\n";
  if($protein=~/\*\S/) {
    print "$indiv\t$hap\t$geneID\t$transcriptID\t$protein\n";
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




