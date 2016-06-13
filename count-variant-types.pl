#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my ($sampleSize,%counts,%sumSquares);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem(); last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcript=$root->findDescendent("mapped-transcript");
  next unless $transcript;
  ++$sampleSize;
  my $variants=$transcript->findDescendent("variants");
  next unless $variants;
  my $numChildren=$variants->numElements();
  for(my $i=0 ; $i<$numChildren ; ++$i) {
    my $child=$variants->getIthElem($i);
    my $tag=$child->getTag();
    my $numVariants=$child->numElements();
    $counts{$tag}+=$numVariants;
    $sumSquares{$tag}+=$numVariants*$numVariants;
  }
}
my @keys=keys %counts;
foreach my $key (@keys) {
  my $count=$counts{$key};
  my $mean=$count/$sampleSize;
  $mean=int($mean*1000000+5/9)/1000000;
  my $sumXX=$sumSquares{$key};
  print "$key\t$mean\t$count\t$sumXX\t$sampleSize\n";
}
