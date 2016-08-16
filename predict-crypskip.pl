#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

my $name=ProgramName::get();
die "$name <indiv> <in.gff> <allele> <junctions.bed> <prefix=ALT|SIM> <blacklist> <nmd-list> <out-readcounts>\n" unless @ARGV==8;
my ($indiv,$gffFile,$allele,$junctionsFile,$PREFIX,$BLACKLIST,$NMD,$READS_FILE)=@ARGV;

# Load info about which isoforms use exon skipping vs. cryptic site activation
my %crypSkip;
my $crypSkipFile="/home/bmajoros/1000G/assembly/combined/$indiv/$allele.crypskip";
open(IN,$crypSkipFile) || die $crypSkipFile;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($geneID,$altID,$type,$L)=@fields;
  $altID=~/ALT\d_(\S+)/ || die $altID;
  my $transcriptID=$1;
  my $rec={ type=>$type};
  if($type eq "exon-skipping") { $rec->{length}=$L }
  else { $rec->{distance}=$L; $rec->{exonLen}=$fields[5] }
  $crypSkip{$transcriptID}->{$altID}=$rec;
}
close(IN);

open(READS,">$READS_FILE") || die $READS_FILE;

# Load blacklist (ALTs or SIMs that happen to match an existing isoform)
my %blacklist;
loadBlacklist($BLACKLIST,\%blacklist);
loadNMD($NMD,\%blacklist,$PREFIX);

# Load the TopHat junctions file
my $introns=parseTophat($junctionsFile);

# Load the GFF file
my $reader=new GffTranscriptReader();
my $transcripts=$reader->loadGFF($gffFile);
coalesceExons($transcripts);
my $transcriptHash=hashTranscriptIDs($transcripts);

# Process all ALT/SIM structures
my %seen;
my $n=@$transcripts;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $id=$transcript->getTranscriptId();
  next unless $id=~/(\S\S\S)\d+_(\S+)/;
  next unless $1 eq $PREFIX;
  my $baseID=$2;
  next if $blacklist{$id};
  my $parentID=$2;
  my $parent=$transcriptHash->{$parentID};
  die $parentID unless $parent;
  next unless $parent->getStrand() eq $transcript->getStrand();
  my $geneID=$transcript->getGeneId();
  my $geneIntrons=$introns->{$geneID};
  if(!$geneIntrons) { $geneIntrons=[] }
  my $found;
  if($transcript->numExons()<$parent->numExons()) {
    $found=exonSkipping($transcript,$parent,$geneIntrons);
  }
  else {
    $found=crypticSplicing($transcript,$parent,$geneIntrons);
  }
  if($found==-1) { next }
  elsif($found==-2) { next }
  else { $crypSkip{$baseID}->{$id}->{found}=$found }
}
close(READS);

# Compute summary stats
my @transcriptIDs=keys %crypSkip;
my $numTranscripts=@transcriptIDs;
for(my $i=0 ; $i<$numTranscripts ; ++$i) {
  my $transcriptID=$transcriptIDs[$i];
  my $hash=$crypSkip{$transcriptID};
  my @alts=keys %$hash;
  my $numCryptic=0; my $numSkipping=0;
  foreach my $alt (@alts) {
    my $rec=$hash->{$alt};
    if($rec->{type} eq "cryptic-site") { ++$numCryptic }
    else { ++$numSkipping }
  }
  print "$numCryptic\t$numSkipping\n";
}

# Terminate
print STDERR "[done]\n";



#########################################################################
#########################################################################

sub exonSkipping {
  my ($child,$parent,$junctions)=@_;
  my $numChildExons=$child->numExons(); my $numParentExons=$parent->numExons();
  if($numChildExons!=$numParentExons-1) { return -2 }
  for(my $i=0 ; $i<$numParentExons ; ++$i) {
    if($i>=$numChildExons) { return -2 }
    my $exon=$parent->getIthExon($i);
    my $begin=$exon->getBegin(); my $end=$exon->getEnd();
    my $childExon=$child->getIthExon($i);
    if($childExon->getBegin()==$begin && $childExon->getEnd()==$end) { next }
    if($i<1 || $i>=$numChildExons) { return -2 }
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
      my ($begin,$end,$reads)=@$junction;
      if($begin==$intronBegin && $end==$intronEnd) {
	my $transcriptID=$child->getTranscriptId();
	my $geneID=$child->getGeneId();
	my $key="$geneID $begin $end";
	if($seen{$key}) { return -1 }
	$seen{$key}=1;
	return $reads;
      }
    }
    last;
  }
  return 0;
}


sub crypticSplicing {
  my ($child,$parent,$junctions)=@_;
  my $numChildExons=$child->numExons(); my $numParentExons=$parent->numExons();
  if($numChildExons>$numParentExons) { return -2 }
  for(my $i=0 ; $i<$numParentExons ; ++$i) {
    my $exon=$parent->getIthExon($i);
    my $begin=$exon->getBegin(); my $end=$exon->getEnd();
    my $childExon=$child->getIthExon($i);
    if($childExon->getBegin()==$begin && $childExon->getEnd()==$end) { next }
    if($i<1 || $i>=$numChildExons) { return -2 }
    my $strand=$child->getStrand();
    my ($intronBegin,$intronEnd);
    if($strand eq "+") {
      if($childExon->getBegin()!=$begin) {
	$intronBegin=$child->getIthExon($i-1)->getEnd();
	$intronEnd=$childExon->getBegin(); }
      else {
	$intronBegin=$childExon->getEnd();
	$intronEnd=$child->getIthExon($i+1)->getBegin(); }
    }
    else { # strand eq "-"
      if($childExon->getBegin()!=$begin) {
	$intronBegin=$child->getIthExon($i+1)->getEnd();
	$intronEnd=$childExon->getBegin(); }
      else {
	$intronBegin=$childExon->getEnd();
	$intronEnd=$child->getIthExon($i-1)->getBegin(); }
    }
    foreach my $junction (@$junctions) {
      my ($begin,$end,$reads)=@$junction;
      if($begin==$intronBegin && $end==$intronEnd) {
	my $transcriptID=$child->getTranscriptId();
	my $geneID=$child->getGeneId();
	my $key="$geneID $begin $end";
	if($seen{$key}) { return -1 }
	$seen{$key}=1;
	return $reads;
      }
    }
    last;
  }
  return 0;
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
    my $record=[$donor,$acceptor,$reads];
    push @{$introns->{$gene}},$record;
  }
  close(IN);
  return $introns;
}


sub coalesceExons {
  my ($transcripts)=@_;
  my $n=@$transcripts;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    $transcript->{exons}=$transcript->getRawExons();
    $transcript->{UTR}=[];
  }
  return;
}


sub loadBlacklist {
  my ($filename,$hash)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=6;
    my ($indiv,$allele,$chr,$gene,$transcript,$ALT)=@fields;
    $ALT=~/\S\S\S\d+_(\S+)/ || die $ALT;
    my $id="$ALT\_$allele";
    $hash->{$id}=1;
  }
  close(IN);
}

sub loadNMD {
  my ($filename,$hash,$prefix)=@_;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=7;
    my ($indiv,$allele,$chr,$gene,$transcript,$ALT,$status)=@fields;
    $ALT=~/\S\S\S(\d+_\S+)/ || die $ALT; # The prefix may be wrong...that's ok
    my $id="$prefix$1\_$allele";
    if($status eq "NMD") { $hash->{$id}=1 }
  }
  close(IN);
}

