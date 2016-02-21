#!/usr/bin/perl
use strict;

open(IN,"/home/bmajoros/1000G/ethnicity.txt") || die;
while(<IN>) {
  chomp;
  my @fields=split; next unless @fields>=2;
  my ($id,$pop)=@fields;
  #next unless $pop eq "CEU";
  next unless -e "/home/bmajoros/1000G/assembly/combined/$id/RNA";
  open(ALIGN,"/home/bmajoros/1000G/assembly/combined/$id/RNA/align_summary.txt") || die;
  my $reads;
  while(<ALIGN>) { if(/Input\s*:\s*(\d+)/) { $reads=$1; last } }
  close(ALIGN);
  print "$pop\t$reads\n";
}
close(IN);



