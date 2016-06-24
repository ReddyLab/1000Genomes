#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $RNA="$ASSEMBLY/rna.txt";
my $BROKEN="$ASSEMBLY/broken-genes.txt";

# Load the list of broken transcripts (those with a broken splice site)
my %broken;
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($gene,$transcript,$chr)=@fields;
  next if($chr eq "chrX" || $chr eq "chrY");
  $broken{$transcript}=1;
}
close(IN);

# Process the expression file
my (%expr,%brokenExpressed);
open(IN,$RNA) || die "can't open file: $RNA";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  next if $fields[0] eq "indiv";
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  $expr{$gene}->{$indiv}->{$allele}=$FPKM;
  if($broken{$transcript}) { $brokenExpressed{$transcript}=1 }
}
close(IN);

# Quantify expression of supposedly broken transcripts
my @broken=keys %broken;
my $numBroken=@broken;
my $brokenExpressed=keys %brokenExpressed;
my $proportion=$brokenExpressed/$numBroken;
print "$proportion = $brokenExpressed/$numBroken broken transcripts were expressed\n";


# Tabulate cases of ASE
my ($same,$different);
my @genes=keys %expr;
foreach my $gene (@genes) {
  my $hash1=$expr{$gene};
  my @indivs=keys %$hash1;
  foreach my $indiv (@indivs) {
    my $hash2=$hash1->{$indiv};
    my @alleles=keys %$hash2;
    next unless @alleles==2;
    if($hash2->{1} eq $hash2->{2}) { ++$same }
    else { ++$different }
  }
}
my $total=$same+$different;
my $proportionDifferent=$different/$total;
print "$proportionDifferent = $different/$total transcripts had ASE\n";


