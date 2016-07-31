#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $INFILE="$ASSEMBLY/structure-changes.txt";

my (%cryptic,%skipping);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$hap,$gene,$transcript,$change)=@fields;
  if($change eq "cryptic-site") { ++$cryptic{$indiv} }
  elsif($change eq "exon-skipping") { ++$skipping{$indiv} }

}
close(IN);










