#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexICE;
use Transcript;
$|=1;

my $name=ProgramName::get();
die "$name <indiv> <hap> <in.essex>\n" unless @ARGV==3;
my ($indiv,$hap,$infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $newStartNode=$elem->pathQuery("report/status/new-upstream-start-codon");
  next unless $newStartNode;
  my $refNode=$newStartNode->findChild("reference");
  next unless $refNode;
  my $altLen=$elem->getAttribute("alt-length");
  my $geneID=$elem->getAttribute("gene-ID");
  my $transcriptID=$elem->getAttribute("transcript-ID");
  my $reason=$refNode->getIthElem(0);
  my $nmd=$newStartNode->hasDescendentOrDatum("NMD");
  my $transcriptNode=$newStartNode->findChild("transcript");
  my $uORF=new Transcript($transcriptNode);
  my $mappedTranscript=$elem->pathQuery("report/mapped-transcript");
  my $downstreamORF=new Transcript($mappedTranscript);
  my $strand=$downstreamORF->getStrand();
  if($strand eq "-") {
    $uORF->reverseComplement($altLen);
    $downstreamORF->reverseComplement($altLen);
  }
  $uORF->sortExons();
  $downstreamORF->sortExons();
  my ($UORFbegin,$UORFend)=$uORF->getCDSbeginEnd();
  my ($DORFbegin,$DORFend)=$downstreamORF->getCDSbeginEnd();
  $UORFbegin=$uORF->mapToTranscript($UORFbegin);
  $UORFend=$uORF->mapToTranscript($UORFend-1)+1;
  $DORFbegin=$downstreamORF->mapToTranscript($DORFbegin);
  $DORFend=$downstreamORF->mapToTranscript($DORFend-1)+1;
  my $splicedLength=$downstreamORF->getLength();
  my $status=$nmd ? "NMD" : "OK";
  print "$indiv\t$hap\t$geneID\t$transcriptID\t$UORFbegin\t$UORFend\t$DORFbegin\t$DORFend\t$altLen\t$status\n";
}
