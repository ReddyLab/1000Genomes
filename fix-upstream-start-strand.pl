#!/usr/bin/perl
use strict;
use EssexParser;
use ProgramName;

my $name=ProgramName::get();
die "$name in.essex > out.essex\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $status=$root->findChild("status");
  if(!$status) { die "no status node" }
  my $statusString=$status->getIthElem(0);
  if($statusString eq "splicing-changes") {
    my $altNode=$status->findChild("alternate-structures");
    if($altNode && $altNode->hasDescendentOrDatum("new-upstream-start-codon")){
      my $numTranscripts=$altNode->numElements();
      for(my $i=0 ; $i<$numTranscripts ; ++$i) {
	my $transcript=$altNode->getIthElem($i);
	next unless $transcript->getTag() eq "transcript";
	next unless
	  $transcript->hasDescendentOrDatum("new-upstream-start-codon");
	my $parentStrand=
	  $root->pathQuery("report/reference-transcript/strand")
	    ->getIthElem(0);
	if($transcript->getAttribute("strand") ne $parentStrand) {
	  print STDERR "correcting child to match strand $parentStrand\n";
	  my $L=$root->getAttribute("alt-length");
	  
	}
      }
    }
  }
  $root->print(\*STDOUT);
}

print STDERR "[done]\n";






