#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $INFILE="$ASSEMBLY/structure-changes.txt";
my $OUT_CRYPTIC="$ASSEMBLY/cryptic-histogram.txt";
my $OUT_SKIPPING="$ASSEMBLY/skipping-histogram.txt";

my (%cryptic,%skipping);
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=5;
  my ($indiv,$hap,$gene,$transcript,$change)=@fields;
  if($change eq "cryptic-site") { ++$cryptic{$indiv} }
  elsif($change eq "exon-skipping") { ++$skipping{$indiv} }
}
close(IN);

open(OUT_CRYPTIC,">$OUT_CRYPTIC") || die $OUT_CRYPTIC;
open(OUT_SKIPPING,">$OUT_SKIPPING") || die $OUT_SKIPPING;
my @indivs=keys %cryptic;
foreach my $indiv (@indivs) {
  my $numCryptic=0+$cryptic{$indiv};
  my $numSkipping=0+$skipping{$indiv};
  my $ratio=$numCryptic/$numSkipping;
  print "$ratio\n";
  print OUT_CRYPTIC "$numCryptic\n";
  print OUT_SKIPPING "$numSkipping\n";
}
close(OUT_CRYPTIC);
close(OUT_SKIPPING);









