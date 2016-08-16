#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use Transcript;
$|=1;

my $name=ProgramName::get();
die "$name <haplotype> <in.essex>\n" unless @ARGV==2;
my ($hap,$infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  my $altStructsNode=
    $root->pathQuery("report/status/alternate-structures");
  next unless $altStructsNode;
  my $altStructs=$altStructsNode->findChildren("transcript");
  my $altNum=0;
  my $transcriptID=$root->getAttribute("transcript-ID");
  foreach my $transcript (@$altStructs) {
    my $altID="ALT$altNum\_$transcriptID\_$hap";
    my $change=$transcript->getAttribute("structure-change");
    my $mappedTranscript=$root->pathQuery("report/mapped-transcript");
    if($change eq "cryptic-site") {
      my $brokenSiteNode=$root->pathQuery("report/status/broken-donor");
      if(!$brokenSiteNode)
	{ $brokenSiteNode=$root->pathQuery("report/status/broken-acceptor") }
      my $brokenPos=$brokenSiteNode->getIthElem(0);
      my $crypticSiteNode=$transcript->findChild("cryptic-site");
      my $siteType=$crypticSiteNode->getIthElem(0);
      my $crypticPos=$crypticSiteNode->getIthElem(1);
      my $distance=$brokenPos-$crypticPos;
      my $originalExonLen=getExonLen($mappedTranscript,$brokenPos);
      print "$altID\t$change\t$distance\t$siteType\t$originalExonLen\n";
    }
    else {
      die unless $mappedTranscript;
      my $skippedExon=findSkippedExon($mappedTranscript,$transcript);
      my $L=$skippedExon->getLength();
      print "$altID\t$change\t$L\n";
    }
    ++$altNum;
  }
}
print STDERR "[done]\n";

sub getExonLen {
  my ($transcriptNode,$splicePos)=@_;
  my $transcript=new Transcript($transcriptNode);
  my $exons=$transcript->getRawExons();
  my %hash;
  foreach my $exon (@$exons) {
    my ($begin,$end)=($exon->getBegin(),$exon->getEnd());
    if($begin==$splicePos || $end==$splicePos)
      { return $end-$begin }
  }
  die "can't find exon";
}

sub findSkippedExon {
  my ($mappedTranscriptNode,$altTranscriptNode)=@_;
  my $mappedTranscript=new Transcript($mappedTranscriptNode);
  my $altTranscript=new Transcript($altTranscriptNode);
  my $mappedExons=$mappedTranscript->getRawExons();
  my $altExons=$altTranscript->getRawExons();
  my %hash;
  foreach my $exon (@$altExons) {
    my ($begin,$end)=($exon->getBegin(),$exon->getEnd());
    $hash{"$begin $end"}=1;
  }
  foreach my $exon (@$mappedExons) {
    my ($begin,$end)=($exon->getBegin(),$exon->getEnd());
    if(!$hash{"$begin $end"}) { return $exon }
  }
  die "no skipped exon found";
}




