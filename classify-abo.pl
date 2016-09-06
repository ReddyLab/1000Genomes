#!/usr/bin/perl
use strict;

my $INFILE="abo.txt";

my %indiv;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($ind,$hap,$protein,$rna,$strand,$numExons,$exons)=@fields;
  my @exons=split/,/,$exons;
  my $exons=[];
  foreach my $exon (@exons) {
    $exon=~/(\d+)-(\d+)/ || die $exon;
    push @$exons,[$1,$2];
  }
  $indiv{$ind}->{$hap}=
    {
     protein=>$protein,
     rna=>$rna,
     numExons=>$numExons
    };
}
close(IN);



