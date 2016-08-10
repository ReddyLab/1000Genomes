#!/usr/bin/perl
use strict;
use ProgramName;
use SummaryStats;
$|=1;

my $name=ProgramName::get();
die "$name <MIN_COUNT> <homozygotes_only:0/1> <genes.txt> <background.out>\n"
  unless @ARGV==4;
my ($MIN_COUNT,$HOMOZYGOTES_ONLY,$GENES,$OUT_BG)=@ARGV;

my $RVIS="/home/bmajoros/intolerance/subRVIS/subRVIS.txt";
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
  chomp; my @fields=split; next unless @fields>=8;
  my ($triplet,$gene,$subGERP,$genicRVIS,$subRVIS,$count,$mrt,$coverage)
    =@fields;
  my $ensembl=$toEnsembl{$gene};
  next unless $ensembl;
  push @{$RVIS{$ensembl}},$subRVIS;
}
close(IN);

my (%alleles,$n);
open(IN,$GENES) || die $GENES;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=1;
  my ($gene)=@fields;
  if($gene=~/(\S+)\./) { $gene=$1 }
  my $array=$RVIS{$gene};
  next unless defined $array;
  my ($mean,$SD,$min,$max)=SummaryStats::summaryStats($array);
  print "$SD\n";
  ++$n;
}
close(IN);

open(OUT,">$OUT_BG") || die $OUT_BG;
my @keys=keys %RVIS;
my $numKeys=@keys;
for(my $i=0 ; $i<$numKeys ; ++$i) {
  my $gene=$keys[$i];
  my $array=$RVIS{$gene};
  next unless @$array>1;
  my ($mean,$SD,$min,$max)=SummaryStats::summaryStats($array);
  print OUT "$SD\n";
}
close(OUT);

