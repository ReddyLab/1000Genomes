#!/usr/bin/perl
use strict;

open(IN,"sacct -u bmajoros | grep ICE | grep FAILED |") || die;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my $id=shift @fields;
  open(PIPE,"jobinfo.pl $id |") || die;
  while(<PIPE>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($key,$value)=@fields;
    print "$key\t$value\n";
  }
}
close(IN);
