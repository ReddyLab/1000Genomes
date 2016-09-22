#!/usr/bin/perl
use strict;
use EssexParser;
$|=1;

my $BASE="/home/bmajoros/1000G/assembly/DMD";
my $INDIR="$BASE/out";

my $noChange;
my @files=`ls $INDIR/*.essex`;
foreach my $file (@files) {
  chomp $file; $file=~/([^\/]+)\.essex/ || die $file;
  my $id=$1;
  my $parser=new EssexParser("$file");
  my $root=$parser->nextElem();
  $parser->close();
  my $status=$root->pathQuery("report/status");
  die "no status" unless $status;
  my $splicingChanges=$status->hasDescendentOrDatum("splicing-changes");
  if(!$splicingChanges) { ++$noChange; next; }
  my $altStructs=$status->findChild("alternate-structures");
  die unless $altStructs;
  my $transcripts=$altStructs->findChildren("transcript");
  my ($exonSkipping,$crypticSites);
  foreach my $transcript (@$transcripts) {
    my $type=$transcript->getAttribute("structure-change");
    if($type eq "exon-skipping") { ++$exonSkipping }
    elsif($type eq "cryptic-site") { ++$crypticSites }
  }
  #die unless $exonSkipping>0;
  $crypticSites+=0;
  $exonSkipping+=0;
  print "$id\t$exonSkipping\t$crypticSites\n";
}
print "$noChange had no splicing changes\n";



