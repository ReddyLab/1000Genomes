#!/usr/bin/perl
use strict;

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

my %seen;
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($gene,$transcript,$chr)=@fields;
  next if $seen{$gene};
  $seen{$gene}=1;
  next if $chr eq "chrX" || $chr eq "chrY";
  if($gene=~/(\S+)\./) { $gene=$1 }
  #print "looking up $gene.\n";
  my $rvis=$RVIS{$gene};
  next unless defined $rvis;
  print "$gene\t$rvis\n";
}
close(IN);



