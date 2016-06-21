#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexFBI;
$|=1;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (%tooManyErrors,%badAnnotation,%NMD,%prematureStop,%startCodonChange,
    %splicingChanges,%frameshift,%annotationOK);
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $fbi=new EssexFBI($root);
  my $transcriptID=$fbi->getTranscriptID();
  my $geneID=$fbi->getGeneID();
  my $status=$root->findChild("status");
  my $statusString=$fbi->getStatusString();
  if($statusString eq "mapped") { # mapped: includes too-many-vcf-errors
    ++$annotationOK{$geneID};
    if($status->hasDescendentOrDatum("too-many-vcf-errors")) {
      ++$tooManyErrors{$geneID};
      next }
    if($status->hasDescendentOrDatum("NMD")) { ++$NMD{$geneID} }
    if($status->hasDescendentOrDatum("frameshift")) { ++$frameshift{$geneID} }
    if($status->hasDescendentOrDatum("premature-stop"))
      { ++$prematureStop{$geneID} }
    if($status->hasDescendentOrDatum("start-codon-change"))
      { ++$startCodonChange{$geneID} }
  }
  else { # splicing-changes/no-transcript/bad-annotation
    if($statusString eq "bad-annotation") { ++$badAnnotation{$geneID} }
    else { ++$annotationOK{$geneID} }
    if($statusString eq "splicing-changes") { ++$splicingChanges{$geneID} }
  }
}
$parser->close();

# Too many VCF errors
my $errors=keys %tooManyErrors;
print "$errors genes had too many VCF errors\n";

# Bad annotation
my $badAnnos=keys %badAnnotation;
print "$badAnnos genes had bad annotations\n";

# Genes with at least one transcript suffering NMD
my $nmdGenes=keys %NMD;
print "$nmdGenes mapped genes had NMD\n";

# Premature stop
my $numPrematureStop=keys %prematureStop;
print "$numPrematureStop mapped genes had a premature stop\n";

# Start codon change
my $numStartChange=keys %startCodonChange;
print "$numStartChange mapped genes had a change to the start codon\n";

# Splicing changes
my $numSplicingChanges=keys %splicingChanges;
print "$numSplicingChanges genes had splicing changes\n";

# Frameshift
my $numFrameshift=%frameshift;
print "$numFrameshift mapped genes had a frameshift indel\n";

# Annotation is OK
my $annoOK=keys %annotationOK;
print "$annoOK genes had a valid annotation\n";

