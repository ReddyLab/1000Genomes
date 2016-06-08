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
  my $numChildren=$status->numElements();
  my $splicingChanges;
  for(my $i=0 ; $i<$numChildren ; ++$i) {
    my $child=$status->getIthElem($i);
    if(EssexNode::isaNode($child)) {
      my $tag=$child->getTag();
      ++$hash{$tag};
      #print "tag $tag\n" unless $tag eq "protein-differs";
    }
    else {
      ++$hash{$child};
      #print "nontag $child\n" unless $child eq "mapped";
    }
    #my $mapped=$status->findDescendent("mapped-transcript");
    #if($mapped && $mapped->hasDescendentOrDatum("NMD")) {
  }
  if($status->hasDescendentOrDatum("NMD")) {
    #print "$transcriptID mapped NMD\n";
    ++$hash{"mapped-NMD"};
  }
  if($splicingChanges && $fbi->allAltStructuresLOF()) {
    ++$hash{"splicing-changes-all-LOF"}
  }
  ++$sampleSize;
  if($MAX_COUNT>0 && $sampleSize>$MAX_COUNT) { last }
}

my @keys=keys %hash;
foreach my $key (@keys) {
  my $value=$hash{$key};
  print "$key\t$value\n";
}
print "[done]\n";




