#!/usr/bin/perl
use strict;

my $BASE="/home/bmajoros/1000G/assembly";
my $INFILE="$BASE/crypskip-fpkm2.txt";

my (%sum,%N);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($transcript,$sites,$fpkm)=@fields;
  $sum{$sites}+=$fpkm;
  ++$N{$sites};
}
close(IN);

for(my $i=0 ; $i<6 ; ++$i) {
  my $sum=$sum{$i};
  my $n=$N{$i};
  my $mean=$sum/$n;
  print "$i\t$mean\n";
}




