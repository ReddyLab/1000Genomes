#!/usr/bin/perl
use strict;
use ProgramName;
use SummaryStats;
$|=1;

my $name=ProgramName::get();
die "$name <inactivated-genes.txt> <background.out>\n"
  unless @ARGV==4;
my ($GENES,$OUT_BG)=@ARGV;

my $OMIM="/home/bmajoros/intolerance/OMIM/disease-genes.txt";
my $NAMES="/home/bmajoros/ensembl/gene-names/combined.txt";

my %toEnsembl;
open(IN,$NAMES) || die $NAMES;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($ensembl,$id)=@fields;
  $toEnsembl{$id}=$ensembl;
}
close(IN);

my %OMIM; # indexed by ensembl id
open(IN,$OMIM) || die $OMIM;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=1;
  my ($gene)=@fields;
  my $ensembl=$toEnsembl{$gene};
  next unless $ensembl;
  $OMIM{$ensembl}=1;
}
close(IN);

my (%alleles,$sampleSize,$hits);
open(IN,$GENES) || die $GENES;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=1;
  my ($gene)=@fields;
  if($gene=~/(\S+)\./) { $gene=$1 }
  if($OMIM{$gene}) { ++$hits }
  ++$sampleSize;
}
close(IN);
print "$hits\n";

open(OUT,">$OUT_BG") || die $OUT_BG;
my @keys=keys %toEnsembl;
my $numKeys=@keys;
for(my $i=0 ; $i<1000 ; ++$i) {
  my $hits=0;
  for(my $j=0 ; $j<$sampleSize ; ++$j) {
    my $gene=$keys[$i];
    my $ensembl=$toEnsembl{$gene};
    if($OMIM{$ensembl}) { ++$hits }
  }
  print OUT "$hits\n";
}
close(OUT);

