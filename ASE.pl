#!/usr/bin/perl
use strict;
$|=1;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $RNA="$ASSEMBLY/rna.txt";
my $BROKEN="$ASSEMBLY/broken.txt";
my $GENES_WITH_ALTS="$ASSEMBLY/alt-genes.txt";
my %xy; # genes on X/Y chromosomes
loadXY("$ASSEMBLY/xy.txt",\%xy);
my %altGenes;
loadAltGenes($GENES_WITH_ALTS,\%altGenes);

# Load the list of broken transcripts (those with a broken splice site)
my (%brokenAlleles,%brokenIsoforms,$brokenAlleleInstances);
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$transcript,$chr)=@fields;
  next if($chr eq "chrX" || $chr eq "chrY");
  $brokenAlleles{$transcript}->{$indiv}->{$allele}=1;
  $brokenIsoforms{$gene}->{"$indiv $allele"}->{$transcript}=1;
  ++$brokenAlleleInstances;
}
close(IN);

# How often are multiple isoforms of a gene broken?
my ($brokenGeneInstances,$multiplyBroken);
my @brokenGenes=keys %brokenIsoforms;
foreach my $gene (@brokenGenes) {
  my $hash1=$brokenIsoforms{$gene};
  my @indivAlleles=keys %$hash1;
  foreach my $indivAllele (@indivAlleles) {
    ++$brokenGeneInstances;
    my $hash2=$hash1->{$indivAllele};
    my $numBrokenIsoforms=keys %$hash2;
    if($numBrokenIsoforms>1) { ++$multiplyBroken }
  }
}
my $proportion=$multiplyBroken/$brokenGeneInstances;
print "$proportion = $multiplyBroken/$brokenGeneInstances : of all the instances of a broken gene in an individual, in this many of those genes were multiple transcripts affected\n";

# Process the expression file
my (%expr,%brokenExpressed,$expressedBrokenInstances,%expressedALT,
    %expressedInAnyone);
open(IN,$RNA) || die "can't open file: $RNA";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  next if $fields[0] eq "indiv";
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next if $xy{$gene};
  $expr{$transcript}->{$indiv}->{$allele}=$FPKM;
  if($brokenAlleles{$transcript}->{$indiv}->{$allele})
    { $brokenExpressed{$transcript}=1; ++$expressedBrokenInstances }

  #if($transcript=~/^ALT\d+_(\S+)/) {
  #  my $id=$1;
  #  #print "$transcript $id $indiv $allele\n";
  #  $expressedALT{"$id $indiv $allele"}=1;
  #  $expressedInAnyone{"$id $indiv $allele"}=1;
  #}
  #elsif($altGenes{"$transcript $indiv $allele"}) {
  #  #print "\t\t\t$transcript $indiv $allele\n";
  #  $expressedInAnyone{"$transcript $indiv $allele"}=1;
  #}

  if($transcript=~/^ALT\d+_(\S+)/) {
    my $id=$1;
    $expressedALT{$id}=1;
    $expressedInAnyone{$id}=1;
  }
  elsif($altGenes{$transcript}) { $expressedInAnyone{$transcript}=1 }
}
close(IN);

# How often are the proposed ALT structures actually expressed?
my $numAltStructures=keys %expressedInAnyone;
my $numAltExpressed=keys %expressedALT;
my $proportion=$numAltExpressed/$numAltStructures;
print "$proportion = $numAltExpressed/$numAltStructures : of all those instances where a transcript in an individual has proposed ALT structures, in how many of those instances was there at least one ALT structure that was expressed?\n";

# Quantify expression of supposedly broken transcripts
my $proportion=$expressedBrokenInstances/$brokenAlleleInstances;
print "$proportion = $expressedBrokenInstances/$brokenAlleleInstances : of all the instances of broken alleles, this many were quantified with nonzero expression by StringTie\n";
my @broken=keys %brokenAlleles;
my $numBroken=@broken;
my $brokenExpressed=keys %brokenExpressed;
my $proportion=$brokenExpressed/$numBroken;
print "$proportion = $brokenExpressed/$numBroken : of all the transcripts broken in at least one individual, this many of those transcripts were found expressed by StringTie in at least one of the instances where it was supposedly broken\n";

# Tabulate cases of ASE
my ($same,$different,%ASEtranscripts,%allTranscripts);
my @transcripts=keys %expr;
foreach my $transcript (@transcripts) {
  my $hash1=$expr{$transcript};
  my @indivs=keys %$hash1;
  foreach my $indiv (@indivs) {
    my $hash2=$hash1->{$indiv};
    my @alleles=keys %$hash2;
    next unless @alleles==2;
    if($hash2->{1} eq $hash2->{2}) { ++$same; $ASEtranscripts{$transcript}=1 }
    else { ++$different }
    $allTranscripts{$transcript}=1;
  }
}
my $total=$same+$different;
my $proportionDifferent=$different/$total;
print "$proportionDifferent = $different/$total : in this many instances of a transcript in an individual were the two copies estimated to have unequal expression values in that individual\n";
my $ASEtranscripts=keys %ASEtranscripts;
my $allTranscripts=keys %allTranscripts;
my $proportion=$ASEtranscripts/$allTranscripts;
print "$proportion = $ASEtranscripts/$allTranscripts of all transcripts had ASE in at least one individual\n";

#======================================================================
sub loadXY
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($chr,$gene,$transcript)=@fields;
    $hash->{$gene}=1;
  }
  close(IN);
}
#======================================================================
sub loadAltGenes
{
  my ($filename,$hash)=@_;
  open(IN,$filename) || die "can't open file: $filename\n";
  while(<IN>) {
    chomp; my @fields=split; next unless @fields>=3;
    my ($indiv,$allele,$transcript)=@fields;
    #$hash->{$transcript}->{$indiv}->{$allele}=1;
    #$hash->{"$transcript $indiv $allele"}=1;
    $hash->{$transcript}=1;
  }
  close(IN);
}
#======================================================================
#======================================================================
#======================================================================
#======================================================================
#======================================================================
