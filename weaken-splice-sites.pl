#!/usr/bin/perl
use strict;
use GffTranscriptReader;
use FastaReader;
use FastaWriter;

# This script weakens splice sites by changing the bases flanking the
# actual splice site.  This is used to test ICE.

my $MAX_SEQ=10000;
my $THOUSAND="/home/bmajoros/1000G";
my $COMBINED="$THOUSAND/assembly/combined";
my $INDIV="$COMBINED/HG00096";
my $IN_GFF="$INDIV/mapped.gff";
my $IN_FASTA="$INDIV/1.fasta";
my $OUT_FASTA="weakened.fasta";
my @ALPHA=('A','C','G','T');

my $gffReader=new GffTranscriptReader;
my $bySubstrate=$gffReader->hashBySubstrate($IN_GFF);

my $fastaWriter=new FastaWriter;
open(OUT,">$OUT_FASTA") || die $OUT_FASTA;
my $numOutput=0;
my $fastaReader=new FastaReader($IN_FASTA);
while(1) {
  if($numOutput>$MAX_SEQ) { last }
  my ($def,$seq)=$fastaReader->nextSequence();
  last unless $def;
  $def=~/^>(\S+)\s+\/coord=\S+:\d+-\d+:(\S)/ || die $def;
  my ($geneID,$strand)=($1,$2);
  next unless $strand eq "+";
  my $transcripts=$bySubstrate->{$geneID};
  next unless $transcripts;
  my $numTranscripts=@$transcripts;
  next unless $numTranscripts>0;
  my $index=int(rand($numTranscripts));
  my $transcript=$transcripts->[$index];
  my $numExons=$transcript->numExons();
  $index=int(rand($numExons));
  my $exon=$transcript->getIthExon($index);
  my $type=$exon->getType();
  if($type eq "single-exon") { next }
  if($type eq "initial-exon") { weakenSite($exon->getEnd(),\$seq) }
  elsif($type eq "internal-exon") {
    if(rand(1)<0.5) { weakenSite($exon->getEnd(),\$seq) }
    else { weakenSite($exon->getBegin()-2,\$seq) }
  }
  elsif($type eq "final-exon") { weakenSite($exon->getBegin()-2,\$seq) }
  else { die "unknown exon type: $type" }
  $fastaWriter->addToFastaRef($def,\$seq,\*OUT);
  foreach my $transcript (@$transcripts) { undef $transcript }
  undef $transcripts;
  ++$numOutput;
}
close(OUT);

sub weakenSite
{
  my ($pos,$seqRef)=@_;
  my $victim;
  if(int(rand(1))<0.5) # left
    { $victim=$pos-1-int(rand(3)) }
  else # right
    { $victim=$pos+2+int(rand(3)) }
  my $old=substr($$seqRef,$victim,1);
  my $newIndex=int(rand(4));
  my $new=$ALPHA[$newIndex];
  if($new eq $old) { $new=$ALPHA[($newIndex+1)%4] }
  substr($$seqRef,$victim,1,$new);
}







