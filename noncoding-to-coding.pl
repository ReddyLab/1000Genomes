#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

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
  
}
