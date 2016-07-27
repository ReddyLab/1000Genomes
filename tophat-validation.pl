#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

my $name=ProgramName::get();
die "$name <in.gff> <junctions.bed> <prefix=ALT|SIM>\n" unless @ARGV==3;
my ($gffFile,$junctionsFile,$PREFIX)=@ARGV;

# Load the TopHat junctions file
my $introns=parseTophat($junctionsFile);

# Load the GFF file
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($gffFile);
my $transcriptHash=hashTranscriptIDs($transcripts);

# Process all ALT/SIM structures
my $n=@$transcripts;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $id=$transcript->getTranscriptId();
  next unless $id=~/(\S\S\S)\d+_(\S+)/;
  next unless $1 eq $PREFIX;
  my $parentID=$2;
  my $parent=$transcriptHash->{$parentID};
  die $parentID unless $parent;
  my $geneID=$transcript->getGeneId();
  my $geneIntrons=$introns->{$geneID};
  if(!$geneIntrons) { $geneIntrons=[] }
  if($transcript->numExons()<$parent->numExons())
    { exonSkipping($transcript,$parent,$geneIntrons) }
  else { crypticSplicing($transcript,$parent,$geneIntrons) }
}

# Terminate
print STDERR "[done]\n";



#########################################################################
#########################################################################

sub exonSkipping {
  my ($child,$parent,$junctions)=@_;
  my $numChildExons=$child->numExons(); my $numParentExons=$parent->numExons();
  die "$numChildExons vs $numParentExons"
    unless $numChildExons==$numParentExons-1;
  for(my $i=0 ; $i<$numParentExons ; ++$i) {
    my $exon=$parent->getIthExon($i);
    my $begin=$exon->getBegin(); my $end=$exon->getEnd();
    my $childExon=$child->getIthExon($i);
    if($childExon->getBegin()==$begin && $childExon->getEnd()==$end) { next }
    if($i<1 || $i>=$numChildExons) { die "$i vs. $numChildExons" }
    my $strand=$child->getStrand();
    my ($intronBegin,$intronEnd);
    if($strand eq "+") {
      $intronBegin=$child->getIthExon($i-1)->getEnd();
      $intronEnd=$child->getIthExon($i)->getBegin();
    }
    else { # strand eq "-"
      $intronBegin=$child->getIthExon($i)->getEnd();
      $intronEnd=$child->getIthExon($i-1)->getBegin();
    }
    foreach my $junction (@$junctions) {
      my ($begin,$end)=@$junction;
      if($begin==$intronBegin && $end==$intronEnd) {
	print "found $strand $begin $end\n";
      }
    }
  }
}


sub crypticSplicing {
  my ($child,$parent,$junctions)=@_;
  my $numChildExons=$child->numExons(); my $numParentExons=$parent->numExons();
  die "$numChildExons vs $numParentExons"
    unless $numChildExons==$numParentExons;

}


sub hashTranscriptIDs {
  my ($transcripts)=@_;
  my $hash={};
  my $n=@$transcripts;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $id=$transcript->getTranscriptId();
    $hash->{$id}=$transcript;
  }
  return $hash;
}


sub parseTophat {
  my ($filename)=@_;
  my $introns={};
  open(IN,$filename) || die "Can't open $filename";
  <IN>; # header
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=10;
    my ($gene,$begin,$end,$junc,$reads,$strand,$b,$e,$color,$two,$overhangs)=
      @fields;
    $overhangs=~/(\d+),(\d+)/ || die $overhangs;
    my $donor=$begin+$1; my $acceptor=$end-$2;
    my $record=[$donor,$acceptor];
    push @{$introns->{$gene}},$record;
  }
  close(IN);
  return $introns;
}





