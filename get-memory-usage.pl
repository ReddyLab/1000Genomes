#!/usr/bin/perl
use strict;

open(IN,"sacct -u bmajoros | grep COMPLETED |") || die;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my $id=shift @fields;
  open(PIPE,"jobinfo.pl $id |") || die;
  while(<PIPE>) {
    chomp; my @fields=split; next unless @fields>=2;
    my ($key,$value)=@fields;
    if($key eq "MaxVMSize") { print "$value\n" }
  }
}
close(IN);
