#!/usr/bin/perl
use strict;
use ProgramName;
use GffTranscriptReader;

#my $MIN_FPKM=1;
my $EXPRESSED="/home/bmajoros/1000G/assembly/expressed.txt";

my $name=ProgramName::get();
die "$name <min-FPKM-expressed-genes> <min-reads> <indiv> <in.gff> <allele> <junctions.bed> <prefix=ALT|SIM> <blacklist> <nmd-list> <out-readcounts>\n" unless @ARGV==10;
my ($MIN_FPKM,$MIN_READS,$indiv,$gffFile,$allele,$junctionsFile,$PREFIX,$BLACKLIST,$NMD,$READS_FILE)=@ARGV;

# Load normalization values
my %normalization;
#open(IN,"/home/bmajoros/1000G/assembly/combined/$indiv/RNA/readcounts.txt")
open(IN,"/home/bmajoros/1000G/assembly/combined/$indiv/RNA2/readcounts-unfiltered.txt")
  || die;
while(<IN>) {
  chomp; my @fields=split; next unless @fields==2;
  my ($gene,$reads)=@fields;
  $normalization{$gene}=$reads;
}
close(IN);

# Load list of transcripts expressed in this cell type
my %expressed;
open(IN,$EXPRESSED) || die $EXPRESSED;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($gene,$transcript,$meanFPKM,$sampleSize)=@fields;
  next unless $meanFPKM>=$MIN_FPKM;
  if($transcript=~/\S\S\S\d+_(\S+)/) {$transcript=$1}
  $expressed{$transcript}=1;
}
close(IN);

open(READS,">$READS_FILE") || die $READS_FILE;

# Load blacklist (ALTs or SIMs that happen to match an existing isoform)
my %blacklist;
loadBlacklist($BLACKLIST,\%blacklist);
loadNMD($NMD,\%blacklist,$PREFIX); ###

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
my $sampleSize=0; my $numFound=0; my $totalSampleSize; my $supported;
my $supportedCryptic=0; my $supportedSkipping=0;
my $crypticChecked=0; my $skippingChecked=0;
my $normalized=0;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$transcripts->[$i];
  my $id=$transcript->getTranscriptId();
  next if $blacklist{$id};
  next unless $id=~/(\S\S\S)\d+_(\S+)/;
  next unless $1 eq $PREFIX;
  my $parentID=$2;
  my $parent=$transcriptHash->{$parentID};
  die $parentID unless $parent;
  my $baseNoHap=$parentID;
  if($baseNoHap=~/(\S+)_\d+/) { $baseNoHap=$1 }
  next unless $expressed{$baseNoHap};
  next unless $parent->getStrand() eq $transcript->getStrand();
  my $geneID=$transcript->getGeneId();
  my $geneIntrons=$introns->{$geneID};
  if(!$geneIntrons) { $geneIntrons=[] }
  my $found;
  if($transcript->numExons()<$parent->numExons()) {
    $found=exonSkipping($transcript,$parent,$geneIntrons);
    if($found>=0) { ++$skippingChecked }
  }
  else {
    $found=crypticSplicing($transcript,$parent,$geneIntrons);
    if($found>=0) { ++$crypticChecked }
  }
  if($found==-1) { ++$supported; ++$totalSampleSize; next }
  elsif($found==-2) { next }
  else { 
    my $normalized="NA";
    my $Z=$normalization{$geneID};
    if($Z>0) { $normalized=$found/$Z }
    my $score=$transcript->{score};
    my $extraFields=$transcript->parseExtraFields();
    my $extraHash=$transcript->hashExtraFields($extraFields);
    my $change=$extraHash->{"structure-change"};
    if(!defined($change)) { $change="UNDEFINED" }
    print READS "$id\t$found\t$normalized\t$score\t$change\n";
  }
  ++$sampleSize; ++$totalSampleSize;
  if($found>0) { ++$supported }
  $numFound+=$found;
  my $Z=$normalization{$geneID};
  if($Z>0) { $normalized+=$found/$Z }
}
close(READS);

# Compute summary stats
#my $readsPerJunction=$numFound/$sampleSize;
exit unless $sampleSize>0;
my $readsPerJunction=$normalized/$sampleSize;
print "readsPerJunction=$readsPerJunction ($numFound / $sampleSize)\n";
$supported=$supportedCryptic+$supportedSkipping;
$totalSampleSize=$crypticChecked+$skippingChecked;
my $percentSupported=$supported/$totalSampleSize;
print "supported isoforms: $percentSupported ($supported / $totalSampleSize)\n";
print "supported cryptic:\t$supportedCryptic\t$crypticChecked\n";
print "supported skipping:\t$supportedSkipping\t$skippingChecked\n";

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
	if($reads>=$MIN_READS) { ++$supportedSkipping }
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
	if($reads>=$MIN_READS) { ++$supportedCryptic }
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
  my %counts;
  open(IN,$filename) || die "Can't open $filename";
  <IN>; # header
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=10;
    my ($gene,$begin,$end,$junc,$reads,$strand,$b,$e,$color,$two,$overhangs)=
      @fields;
    $overhangs=~/(\d+),(\d+)/ || die $overhangs;
    my $donor=$begin+$1; my $acceptor=$end-$2;
    #my $record=[$donor,$acceptor,$reads];
    #push @{$introns->{$gene}},$record;
    $counts{"$gene $donor $acceptor"}+=$reads;
  }
  close(IN);
  my @keys=keys %counts;
  foreach my $key (@keys) {
    my $reads=$counts{$key};
    $key=~/(\S+) (\d+) (\d+)/ || die $key;
    my ($gene,$donor,$acceptor)=($1,$2,$3);
    my $record=[$donor,$acceptor,$reads];
    push @{$introns->{$gene}},$record;
  }
  return $introns;
}


sub parseTophat_old {
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

