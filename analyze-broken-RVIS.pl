#!/usr/bin/perl
use strict;

my $MIN_COUNT=100;
my $RVIS="/home/bmajoros/intolerance/RVIS/RVIS.txt";
my $BROKEN="/home/bmajoros/1000G/assembly/broken.txt";
my $NAMES="/home/bmajoros/ensembl/gene-names/combined.txt";

my %toEnsembl;
open(IN,$NAMES) || die $NAMES;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($ensembl,$id)=@fields;
  $toEnsembl{$id}=$ensembl;
}
close(IN);

my %RVIS; # indexed by ensembl id
open(IN,$RVIS) || die $RVIS;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($id,$rvis,$percentile)=@fields;
  my $ensembl=$toEnsembl{$id};
  next unless $ensembl;
  $RVIS{$ensembl}=$rvis;
}
close(IN);

my %counts;
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$transcript,$chr)=@fields;
  next if $chr eq "chrX" || $chr eq "chrY";
  if($gene=~/(\S+)\./) { $gene=$1 }
  my $rvis=$RVIS{$gene};
  next unless defined $rvis;
  ++$counts{$gene};
}
close(IN);

my @genes=keys %counts;
foreach my $gene (@genes) {
  my $count=$counts{$gene};
  my $rvis=$RVIS{$gene};
  die unless defined $rvis;
  next unless $count>=$MIN_COUNT;
  print "$count\t$rvis\n";
}

