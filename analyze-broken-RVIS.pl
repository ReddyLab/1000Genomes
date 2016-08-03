#!/usr/bin/perl
use strict;
use ProgramName;
$|=1;

my $name=ProgramName::get();
die "$name <MIN_COUNT> <homozygotes_only:0/1> <broken.txt>\n" unless @ARGV==3;
my ($MIN_COUNT,$HOMOZYGOTES_ONLY,$BROKEN)=@ARGV;

my $RVIS="/home/bmajoros/intolerance/RVIS/RVIS.txt";
#my $RVIS="/home/bmajoros/intolerance/RVIS/ncRVIS-parsed.txt";
#my $BROKEN="/home/bmajoros/1000G/assembly/broken.txt";
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
  #$RVIS{$ensembl}=$rvis;
  $RVIS{$ensembl}=$percentile;
}
close(IN);

my %alleles;
open(IN,$BROKEN) || die $BROKEN;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$allele,$gene,$transcript,$chr)=@fields;
  next if $chr eq "chrX" || $chr eq "chrY";
  if($gene=~/(\S+)\./) { $gene=$1 }
  $alleles{$gene}->{$indiv}->{$allele}=1;
}
close(IN);

my %counts;
my @genes=keys %alleles;
foreach my $gene (@genes) {
  my $alleles=$alleles{$gene};
  my @indivs=keys %$alleles;
  foreach my $indiv (@indivs) {
    my $hash=$alleles->{$indiv};
    my @keys=keys %$hash;
    if($HOMOZYGOTES_ONLY && @keys==2 || !$HOMOZYGOTES_ONLY && @keys>0) {
      my $rvis=$RVIS{$gene};
      next unless defined $rvis;
      ++$counts{$gene};
    }
  }
}

my @genes=keys %counts;
foreach my $gene (@genes) {
  my $count=$counts{$gene};
  my $rvis=$RVIS{$gene};
  die unless defined $rvis;
  next unless $count>=$MIN_COUNT;
  next unless $rvis=~/\d/;
  print "$count\t$rvis\n";
  #if($rvis<20) { print STDERR "$gene\t$count\t$rvis\n" }
}

