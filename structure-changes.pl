#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;
$|=1;

my $name=ProgramName::get();
die "$name <in.essex> <outfile> <indiv> <allele#>\n" unless @ARGV==4;
my ($infile,$outfile,$indiv,$hap)=@ARGV;

my %seen;
open(OUT,">$outfile") || die "can't write to file: $outfile\n";
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcriptID=$fbi->getTranscriptID();
  next if $seen{$transcriptID};
  $seen{$transcriptID}=1;
  my $geneID=$fbi->getGeneID();
  my $status=$fbi->getStatusString();
  if($status eq "splicing-changes") {
    my $altStructs=$root->pathQuery("report/status/alternate-structures");
    my $numTrans=$altStructs->numElements();
    for(my $i=0 ; $i<$numTrans ; ++$i) {
      my $transcript=$altStructs->getIthElem($i);
      my $id=$transcript->getAttribute("ID");
      $id="ALT$i\_$id\_$hap";
      my $structChange=$transcript->findChild("structure-change");
      my $numElem=$structChange->numElements();
      for(my $i=0 ; $i<$numElem ; ++$i) {
	my $child=$structChange->getIthElem($i);
	if(!EssexNode::isaNode($child)) {
	  print OUT "$indiv\t$hap\t$geneID\t$id\t$child\n";
	}
      }
    }
  }
  undef $root; undef $fbi;
}
close(OUT);

print STDERR "[done]\n";

