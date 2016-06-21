#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;
$|=1;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (%splicingChangeCoding,%splicingChangeNoncoding,%splicingChanges,
    %altCounts);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcriptID=$fbi->getTranscriptID();
  my $geneID=$fbi->getGeneID();
  my $type=$root->findChild("reference-transcript")->getAttribute("type");
  my $status=$root->findChild("status");
  my $statusString=$fbi->getStatusString();
  if($statusString eq "mapped") { # mapped: includes too-many-vcf-errors
    if($status->hasDescendentOrDatum("too-many-vcf-errors")) { next }
    if($status->hasDescendentOrDatum("premature-stop")) {

    }
    if($status->hasDescendentOrDatum("frameshift")) {
      
    }
  }
  else { # splicing-changes/no-transcript/bad-annotation
    if($statusString eq "splicing-changes") {
      ++$splicingChanges{$geneID};
      if($type eq "protein-coding") { ++$splicingChangeCoding{$geneID} }
      else { ++$splicingChangeNoncoding{$geneID} }
      my $alts=$root->findDescendent("alternate-structures");
      my $numAlts=$alts ? @$alts : 0;
      my $brokenSite=$status->findChild("broken-donor");
      if(!$brokenSite) { $brokenSite=$status->findChild("broken-acceptor") }
      if(!$brokenSite) { die "splicing changes but no broken site!" }
      my $pos=$brokenSite->getIthElem(0);
      $altCounts{"$geneID $pos"}=$numAlts;

      if($status->hasDescendentOrDatum("frameshift")) {
	
      }
    }
  }
}
$parser->close();

#my (%splicingChangeCoding,%splicingChangeNoncoding,%splicingChanges,
#    %altCounts);

# Splicing changes in coding vs. noncoding genes
my $splicingChanges=keys %splicingChanges;
my $splicingChangeCoding=keys %splicingChangeCoding;
my $splicingChangeNoncoding=keys %splicingChangeNoncoding;
my $proportion=$splicingChangeCoding/$splicingChanges;
print "$proportion = $splicingChangeCoding/$splicingChanges coding genes had splicing changes\n";

print "[done]\n";



