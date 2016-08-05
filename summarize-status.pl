#!/usr/bin/perl
use strict;
use EssexParser;
use EssexICE;
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
  my $ice=new EssexICE($root);
  #my $transcriptID=$ice->getTranscriptID();
  #my $geneID=$ice->getGeneID();
  my $transcriptID=$root->getAttribute("transcript-ID");
  my $status=$root->findDescendent("status");
  next unless $status;
  next if $status->hasDescendentOrDatum("bad-annotation");
  next if $status->hasDescendentOrDatum("too-many-vcf-errors");
#  next unless $status->hasDescendentOrDatum("mapped") ||
#     $status->hasDescendentOrDatum("splicing-changes") ||
#        $status->hasDescendentOrDatum("no-transcript");
  my $numChildren=$status->numElements();
  my $splicingChanges;
  my $statusString=$status->getIthElem(0);
  for(my $i=0 ; $i<$numChildren ; ++$i) {
    my $child=$status->getIthElem($i);
    if(EssexNode::isaNode($child)) {
      my $tag=$child->getTag();
      ++$hash{$tag};
      if($tag eq "splicing-changes") { $splicingChanges=1 }
      #print "tag $tag\n" unless $tag eq "protein-differs";
    }
    else {
      if($child eq "splicing-changes") { $splicingChanges=1 }
      ++$hash{$child};
      #print "nontag $child\n" unless $child eq "mapped";
    }
    #my $mapped=$status->findDescendent("mapped-transcript");
    #if($mapped && $mapped->hasDescendentOrDatum("NMD")) {
  }
  if($statusString eq "mapped" && $status->hasDescendentOrDatum("NMD")) {
    #print "$transcriptID mapped NMD\n";
    ++$hash{"mapped-NMD"};
  }
  if($splicingChanges && $ice->allAltStructuresLOF()) {
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




