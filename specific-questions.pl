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
    %altCounts,%codingGenes,%noncodingGenes,%splicingChangesTranscript,
    %splicingChangesLOF,%LOF,%noLOF);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcriptID=$fbi->getTranscriptID();
  my $geneID=$fbi->getGeneID();
  my $type=$root->findChild("reference-transcript")->getAttribute("type");
  if($type eq "protein-coding") { $codingGenes{$geneID}=1 }
  else { $noncodingGenes{$geneID}=1 }
  my $status=$root->findChild("status");
  my $statusString=$fbi->getStatusString();
  if($statusString eq "mapped") { # mapped: includes too-many-vcf-errors
    if($status->hasDescendentOrDatum("too-many-vcf-errors")) { next }
    if($fbi->mappedNMD(50) || $fbi->mappedNoStart() || $fbi->mappedNonstop()
       || $fbi->lossOfCoding() ||
       $fbi->proteinDiffers() && $fbi->getProteinMatch()<50)
      { ++$LOF{$geneID}->{$transcriptID} }
    else { ++$noLOF{$geneID}->{$transcriptID} }
  }
  else { # splicing-changes/no-transcript/bad-annotation
    if($statusString eq "splicing-changes") {
      ++$splicingChanges{$geneID};
      ++$splicingChangesTranscript{$transcriptID};
      if($fbi->allAltStructuresLOF()) {
	$splicingChangesLOF{$transcriptID}=1;
	++$LOF{$geneID}->{$transcriptID}; }
      else { ++$noLOF{$geneID}->{$transcriptID} }
      if($type eq "protein-coding") { ++$splicingChangeCoding{$geneID} }
      else { ++$splicingChangeNoncoding{$geneID} }
      my $alts=$root->findDescendent("alternate-structures");
      my $numAlts=$alts ? $alts->numElements() : 0;
      my $brokenSite=$status->findChild("broken-donor");
      if(!$brokenSite) { $brokenSite=$status->findChild("broken-acceptor") }
      if(!$brokenSite) { die "splicing changes but no broken site!" }
      my $pos=$brokenSite->getIthElem(0);
      $altCounts{"$geneID $pos"}=$numAlts;
      
    }
  }
}
$parser->close();

# Splicing changes in coding vs. noncoding genes
my $splicingChanges=keys %splicingChanges;
my $splicingChangeCoding=keys %splicingChangeCoding;
my $splicingChangeNoncoding=keys %splicingChangeNoncoding;
my $proportion=$splicingChangeCoding/$splicingChanges;
print "$proportion = $splicingChangeCoding/$splicingChanges coding genes had splicing changes\n";
my $codingGenes=keys %codingGenes; my $noncodingGenes=%noncodingGenes;
my $allGenes=$codingGenes+$noncodingGenes;
my $proportion=$codingGenes/$allGenes;
print "$proportion = $codingGenes/$allGenes coding genes present\n";

# How often splicing changes result in LOF
my $splicingChangesTranscript=keys %splicingChangesTranscript;
my $splicingChangesLOF=keys %splicingChangesLOF;
my $proportion=$splicingChangesLOF/$splicingChangesTranscript;
print "$proportion=$splicingChangesLOF/$splicingChangesTranscript transcripts with splicing changes had LOF in all alt structures\n";

# Splicing changes causing LOF in some isoforms but not others
my @genes=keys %LOF;
my ($totalLOF,$mixedLOF);
foreach my $gene (@genes) {
  ++$totalLOF;
  if(defined($noLOF{$gene})) { ++$mixedLOF }
}
my $proportion=$mixedLOF/$totalLOF;
print "$proportion = $mixedLOF/$totalLOF of LOF genes had LOF in some isoforms but not others\n";

# Numbers of alternate structures
my @altCounts=values %altCounts;
foreach my $altCount (@altCounts) { print "ALT_STRUCTURES\t$altCount\n" }


print "[done]\n";



