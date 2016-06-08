#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  #my $fbi=new EssexFBI($root);
  #my $transcriptID=$fbi->getTranscriptID();
  #my $geneID=$fbi->getGeneID();
  my $status=$root->findDescendent("status");
  next unless $status;
  next if $status->hasDescendentOrDatum("bad-annotation");
  next unless $status->hasDescendentOrDatum("mapped");
  my $numChildren=$status->numElements();
  for(my $i=0 ; $i<$numChildren ; ++$i) {
    my $child=$status->getIthElem($i);
    if(EssexNode::isaNode($child)) {
      my $tag=$child->getTag();
      print "tag $tag\n";
    }
    else {
      print "nontag $child\n";
    }
  }

}


