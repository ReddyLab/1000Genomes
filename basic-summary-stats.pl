#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  if($fbi->getStatusString() eq "mapped") {
    my $variants=$root->pathQuery("mapped-transcript/variants");
    if($variants) {
      my $cdsVariants=$variants->findChild("CDS-variants");
      my $numCdsVariants=$cdsVariants ? $cdsVariants->numElements() : 0;
      my $utrVariants=$variants->findChild("UTR-variants");
      my $numUtrVariants=$utrVariants ? $utrVariants->numElements() : 0;
      print "$numCdsVariants\t$numUtrVariants\n";
    }
  }
  else { # splicing-changes/no-transcript/bad-annotation
  }
}
$parser->close();






