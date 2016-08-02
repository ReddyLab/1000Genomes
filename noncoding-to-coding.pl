#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

print "reason\tGeneID\tTranscriptID\tOldOrfLen\tNewOrfLen\tRefStartScore\tAltStartScore\tStartScoreCutoff\n";
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem(); last unless $root;
  my $change=$root->pathQuery("report/status/noncoding-to-coding");
  next unless $change;
  my $geneID=$root->getAttribute("gene-ID");
  my $transcriptID=$root->getAttribute("transcript-ID");
  my $reason=$change->getAttribute("reason");
  my $orflenNode=$change->findChild("ORF-length");
  my $oldOrfLen=$orflenNode->getIthElem(0);
  my $newOrfLen=$orflenNode->getIthElem(2);
  my $refStartScore=$change->getAttribute("ref-start-score");
  my $altStartScore=$change->getAttribute("alt-start-score");
  my $startScoreCutoff=$change->getAttribute("start-score-cutoff");
  print "$reason\t$geneID\t$transcriptID\t$oldOrfLen\t$newOrfLen\t$refStartScore\t$altStartScore\t$startScoreCutoff\n";
}
