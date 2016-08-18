#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/compensatory.txt";
my $OUT_LENGTHS="$THOUSAND/compensatory-lengths-nonredundant.txt";

open(LENGTHS,">$OUT_LENGTHS") || die $OUT_LENGTHS;
my %seen;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=6;
  my ($indiv,$hap,$gene,$transcript,$L,$variants)=@fields;
  next if $seen{$gene};
  $seen{$gene}=1;
  @fields=split/,/,$variants;
  my (@variants,%exons);
  foreach my $variant (@fields) {
    $variant=~/(\d+)=(\d)(?)\(exon(\d+)\)/ || die $variant;
    my ($pos,$l,$indel,$exon)=($1,$2,$3,$4);
    $exons{$exon}=1;
  }
  next unless keys(%exons)==1;
  print LENGTHS "$L\n";
}
close(IN);
close(LENGTHS);


