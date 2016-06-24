#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $RNA="$ASSEMBLY/rna.txt";
my $BROKEN="$ASSEMBLY/broken.txt";
my %xy; # genes on X/Y chromosomes
loadXY("$ASSEMBLY/xy.txt",\%xy);


# Load the list of broken transcripts (those with a broken splice site)
my (%brokenAlleles,%brokenIsoforms,$brokenAlleleInstances);
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$transcript,$chr)=@fields;
  next if($chr eq "chrX" || $chr eq "chrY");
  $brokenAlleles{$transcript}->${$indiv}->{$allele}=1;
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
    my $numBrokenIsoforms=keys %$hash;
    if($numBrokenIsoforms>1) { ++$multiplyBroken }
  }
}
my $proportion=$multiplyBroken/$brokenGeneInstances;
print "$proportion = $multiplyBroken/$brokenGeneInstances : of all the instances of a broken gene in an individual, in this many of those genes were multiple transcripts affected\n";

# Process the expression file
my (%expr,%brokenExpressed);
open(IN,$RNA) || die "can't open file: $RNA";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  next if $fields[0] eq "indiv";
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next if $xy{$gene};
  $expr{$transcript}->{$indiv}->{$allele}=$FPKM;
  if($brokenAlleles{$transcript}->{$indiv}->{$alele})
    { $brokenExpressed{$transcript}=1; ++$expressedBrokenInstances }
}
close(IN);

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
    else { ++$different; $allTranscripts{$transcript}=1 }
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
#======================================================================
#======================================================================
#======================================================================
#======================================================================
#======================================================================
