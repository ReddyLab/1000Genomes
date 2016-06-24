#!/usr/bin/perl
use strict;

my $THOUSSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $RNA="$ASSEMBLY/rna.txt";
my $STRUCTURE="$ASSEMBLY/structure-changes.txt";

my (%changeType);
open(IN,$STRUCTURE) || die $STRUCTURE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$altTransID,$change)=@fields;
  $altTransID=~/ALT(\d+)_(\S+)_\d+/ || die $altTransID;
  my ($altNum,$transcriptID)=($1,$2);
  $changeType{$altTransID}=$change;
}
close(IN);

my (%counts);
open(IN,$RNA) || die $RNA;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  next if $fields[0] eq "indiv";
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next unless $transcript=~/^ALT/ && $FPKM>0;
  my $altTransID="$transcript\_$allele";
  my $change=$changeType{$altTransID};
  ++counts{$change};
}
close(IN);

my @keys=keys %counts;
my $total=0;
foreach my $key (@keys) { $total+=$counts{$key} };
foreach my $key (@keys) {
  my $count=$counts{$key};
  my $proportion=$count/$total;
  print "$proportion = $count/$total $key\n";
}

