#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;
$|=1;

my $MAX_COUNT;#=100;

my $name=ProgramName::get();
die "$name <infile>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (%hash,$sampleSize);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  #my $transcriptID=$fbi->getTranscriptID();
  #my $geneID=$fbi->getGeneID();
  my $transcriptID=$root->getAttribute("transcript-ID");
  my $status=$root->findDescendent("status");
  next unless $status;
  next if $status->hasDescendentOrDatum("bad-annotation");
  next if $status->hasDescendentOrDatum("too-many-vcf-errors");
  next unless $status->hasDescendentOrDatum("mapped");





}
