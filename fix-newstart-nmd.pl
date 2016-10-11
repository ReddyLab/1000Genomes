#!/usr/bin/perl
use strict;
use EssexParser;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.essex> <out.essex>\n" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

open(OUT,">$outfile") || die $outfile;
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $stopNode=
    $root->pathQuery("report/status/new-upstream-start-codon/premature-stop");
  if($stopNode) {
    my $numChildren=$stopNode->numElements();
    for(my $i=0 ; $i<$numChildren ; ++$i) {
      my $child=$stopNode->getIthElem($i);
      if(!EssexNode::isaNode($child) && $child eq "NMD") {
	$stopNode->setIthElem($i,"hypothetical-NMD");
      }
    }
  }
  $root->print(\*OUT);
  print OUT "\n";
}
close(OUT);


