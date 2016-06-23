#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
$|=1;

my $name=ProgramName::get();
die "$name <indiv> <hap> <in.essex> <outfile>\n" unless @ARGV==4;
my ($indiv,$hap,$infile,$outfile)=@ARGV;

open(OUT,">$outfile") || die "can't write to file: $outfile";
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $status=$root->findChild("status");
  if($status->hasDescendentOrDatum("broken-donor") ||
     $status->hasDescendentOrDatum("broken-acceptor")) {
    my $refTrans=$root->findChild("reference-transcript");
    my $chr=$refTrans->getAttribute("substrate");
    my $geneID=$root->getAttribute("gene-ID");
    my $transcriptID=$root->getAttribute("transcript-ID");
    print OUT "$indiv\t$hap\t$geneID\t$transcriptID\t$chr";
  }
}
close(OUT);




