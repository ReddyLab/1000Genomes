#!/usr/bin/perl
use strict;
use EssexParser;
$|=1;

my $INFILE="/home/bmajoros/1000G/assembly/combined/HG00096/1.essex";

my $parser=new EssexParser($INFILE);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  next if($root->hasDescendentOrDatum("bad-annotation"));
  next if($root->hasDescendentOrDatum("too-many-vcf-errors"));
  my $trans=$root->pathQuery("report/reference-transcript/translation");
  next unless $trans;
  my $protein=$trans->getIthElem(0);
  chop $protein;
  #print "$protein\n\n"
  my $len=length($protein);
  print "$len\n";
}
