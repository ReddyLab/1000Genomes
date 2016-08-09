#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/scan/ice-scan.txt";

my (%seen,$sites,$sitesOK);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=3;
  my ($gene,$pos,$ok)=@fields;
  my $key="$gene $pos";
  next if $seen{$key};
  $seen{$key}=1;
  ++$sites;
  $sitesOK+=$ok;
}
close(IN);

my $r=$sitesOK/$sites*100;
print "$sitesOK / $sites = $r\n";



