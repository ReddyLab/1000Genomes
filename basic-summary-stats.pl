#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;
$|=1;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (%tooManyErrors);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcriptID=$fbi->getTranscriptID();
  my $geneID=$fbi->getGeneID();
  my $status=$root->findChild("status");
  my $statusString=$fbi->getStatusString();
  if($statusString eq "mapped") { # includes too-many-vcf-errors
    if($status->hasDescendentOrDatum("too-many-vcf-errors"))
      { ++$tooManyErrors{$geneID} }
  }
  else { # splicing-changes/no-transcript/bad-annotation
  }
}
$parser->close();






