#!/usr/bin/perl
use strict;

open(IN,"/home/bmajoros/1000G/assembly/local-CDS-and-UTR.gff") || die;
while(<IN>) {
  
}
close(IN);

open(IN,"/home/bmajoros/1000G/assembly/ethnicity-results.txt") || die;
while(<IN>) {
  chomp;
  if(/(ENST\S+)/) {
    
  }
}
close(IN);

