#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;

my $name=ProgramName::get();
die "$name <haplotype> <in.essex>\n" unless @ARGV==2;
my ($hap,$infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $altStructsNode=
    $root->pathQuery("report/status/alternate-structures/transcript");
  next unless $altStructNode;
  my $altStructs=$altStructNode->findChildren("transcript");
  my $altNum=0;
  my $transcriptID=$root->getAttribute("transcript-ID");
  foreach my $transcript (@$altStructs) {
    my $altID="ALT$altNum\_$transcriptID\_$hap";
    my $change=$transcript->getAttribute("structure-change");
    print "$altID\t$change\n";
    ++$altNum;
  }
}


