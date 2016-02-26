#!/usr/bin/perl
$|=1;
use strict;
use EssexParser;
use ProgramName;

my $MIN_PERCENT_MATCH=50;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (%counts,%flags);
my $parser=new EssexParser($infile);
while(1) {
  my $report=$parser->nextElem();
  last unless $report;
  my $status=$report->findChild("status");
  next unless $status;
  my $code=$status->getIthElem(0);
  next unless $code;
  my ($inactivated,$why);
  if($code eq "mapped") {
    my $PTC=$status->findChild("premature-stop");
    if($status->findChild("frameshift")) { $why="frameshift" }
    else { $why="sequence-variant" }
    if($PTC && $PTC->getIthElem(0) eq "NMD") { $inactivated="NMD" }
    else {
      my $n=$status->numElements();
      for(my $i=0 ; $i<$n ; ++$i) {
	my $child=$status->getIthElem($i);
	if(!EssexNode::isaNode($child) && ($child eq "nonstop-decay"
	   || $child eq "no-start-codon"))
	  { $inactivated=$child }
      }
      if(!$inactivated) {
	my $differ=$status->findChild("protein-differs");
	if($differ) {
	  my $match=$differ->findChild("percent-match");
	  my $percent=$match->getIthElem(0);
	  if($percent<$MIN_PERCENT_MATCH) { $inactivated="protein-differs" }
	}
      }
    }
  }
  elsif($code eq "no-transcript" && ($status->findChild("broken-donor") ||
	$status->findChild("broken-acceptor"))) {
    $report->print(\*STDOUT);
    $why="INTERNAL_ERROR";
    if($status->findChild("broken-donor")) { $why="broken-donor" }
    elsif($status->findChild("broken-acceptor")) { $why="broken-acceptor" }
    $inactivated="no-transcript";
  }
  elsif($code eq "no-start-codon") {
    $why="sequence-variant";
    if($status->findChild("broken-donor")) { $why="broken-donor" }
    elsif($status->findChild("broken-acceptor")) { $why="broken-acceptor" }
    $inactivated="no-start-codon";
  }
  elsif($code eq "splicing-changes" && ($status->findChild("broken-donor") ||
	$status->findChild("broken-acceptor"))) {
    $why="splicing-changes";
    if($status->findChild("broken-donor")) { $why="broken-donor" }
    elsif($status->findChild("broken-acceptor")) { $why="broken-acceptor" }
    my $ref=$report->findChild("reference-transcript");
    my $refType=$ref->getAttribute("type");
    my $alts=$status->findChild("alternate-structures");
    if($alts) {
      my $fates=$alts->findDescendents("fate");
      if($fates) {
	foreach my $fate (@$fates) {
	  last if $inactivated;
	  my $state=$fate->getIthElem(0);
	  if($state eq "NMD") { $inactivated="NMD" }
	  elsif($state eq "noncoding" && $refType eq "protein-coding")
	    { $inactivated="loss-of-coding-potential" }
	}
      }
    }
  }
  if($inactivated) {
    my $transID=$report->getAttribute("transcript-ID");
    my $geneID=$report->getAttribute("gene-ID");
    print "$geneID\t$transID\t$inactivated\t$why\n";
  }
}


#(status
#   mapped
#   (premature-stop NMD)
#   (protein-differs
#      (percent-match 16.56 477/2881))
#(status
#   mapped
#   nonstop-decay
#(status
#   splicing-changes
#   (weakened-donor 21416 aacagg_GT_aaaacagata -21.3023 cagagg_GT_aaaacagata -21.7532)
#   (alternate-structures
#      (transcript
#         (structure-change exon-skipping)
#         (UTR
#            (five_prime_UTR 25480 25658 0 + 0))
#         (fate noncoding))))


