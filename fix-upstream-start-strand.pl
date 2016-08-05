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
  #if($statusString eq "mapped") {
  #  my $newStart=$status->findChild("new-upstream-start-codon");
  #  if($newStart) { $newStart->changeTag("putative-upstream-start-codon") }
  #}
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
	  #print STDERR "correcting child to match strand $parentStrand\n";
	  my $L=$root->getAttribute("alt-length");
	  my $strandNode=$transcript->findChild("strand");
	  $strandNode->setIthElem(0,$parentStrand);
	  fixExons($transcript,"exons",$L,$parentStrand);
	  fixExons($transcript,"UTR",$L,$parentStrand);
	}
      }
    }
  }
  my $array=$root->findDescendents("source");
  foreach my $source (@$array) {
    if($source->getIthElem(0) eq "ICE") { $source->setIthElem(0,"ICE") }
  }
  $root->print(\*STDOUT);
  print "\n";
}

print STDERR "[done]\n";




#####################################################################
sub fixExons {
  my ($transcript,$label,$L,$strand)=@_;
  my $exons=$transcript->findChild($label);
  if(!$exons) { return }
  my $numExons=$exons->numElements();
  for(my $i=0 ; $i<$numExons ; ++$i) {
    # (single-exon 12966 13065 0 + 0))
    my $exon=$exons->getIthElem($i);
    my $begin=$exon->getIthElem(0); my $end=$exon->getIthElem(1);
    $exon->setIthElem(0,$L-$end);
    $exon->setIthElem(1,$L-$begin);
    $exon->setIthElem(3,$strand);
  }
}




