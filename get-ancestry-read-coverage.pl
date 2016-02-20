#!/usr/bin/perl
use strict;

open(IN,"/home/bmajoros/1000G/ethnicity.txt") || die;
while(<IN>) {
  chomp;
  @fields=split; next unless @fields>=2;
  my ($id,$pop)=@fields;
  next unless $pop eq "CEU";
  open(ALIGN,"/home/bmajoros/1000G/assembly/combined/$id/RNA/align_summary.txt") || die;
  while(<ALIGN>) {
    
  }
  close(ALIGN);
}
close(IN);



