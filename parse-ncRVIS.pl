#!/usr/bin/perl
use strict;

my $DIR="/home/bmajoros/intolerance/RVIS";
my $INFILE="$DIR/ncRVIS.txt";
my $OUTFILE="$DIR/ncRVIS-parsed.txt";

open(OUT,">$OUTFILE") || die $OUTFILE;
open(IN,$INFILE) || die;
<IN>; # header
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my ($id1,$id2,$X,$Y,$score,$percentile)=@fields;
  print OUT "$id1\t$score\t$percentile\n";
  if($id2 ne $id1) { print OUT "$id2\t$score\t$percentile\n" }
}
close(IN);
close(OUT);


