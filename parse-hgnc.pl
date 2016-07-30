#!/usr/bin/perl
use strict;

my $ENSEMBL="/home/bmajoros/ensembl/gene-names";

open(OUT,">$ENSEMBL/parsed.txt") || die;
open(IN,"$ENSEMBL/download.txt") || die;
<IN>; # header
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=2;
  my ($num,$approved,$previous,$synonyms,$ensembl)=@fields;
  if($approved=~/(\S)~withdrawn/) { $approved=$1 }
  #if($approved=~/\S/) { print "$ensembl\t$approved\n" }
  @fields=split/[, ]+/,$previous;
  foreach my $field (@fields) { print "$ensembl\t$field\n" }
}
close(IN);
close(OUT);



