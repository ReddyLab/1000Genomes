#!/usr/bin/perl
use strict;

my $BASE="/home/bmajoros/1000G/assembly/test";
my $INFILE="$BASE/human-chr10.vcf.gz";

open(IN,"cat $INFILE | gunzip |") || die;
open(OUT,">tetra.vcf.gz") || die;
while(<IN>) {
  if(/#CHROM/) {
    my @fields=split;
    for(my $i=0 ; $i<10 ; ++$i) {
      print OUT $fields[$i];
      if($i<9) { print OUT "\t" }
    }
    print OUT "\n";
  }
  elsif(/#/) { print OUT }
  else {
    for(my $i=0 ; $i<10 ; ++$i) {
      print OUT $fields[$i];
      if($i<9) { print OUT "\t" }
    }
    my $a=int(rand(2)); print "$a|";
    my $b=int(rand(2)); print "$b";
    print OUT "\n";
  }
}
close(OUT);
close(IN);



