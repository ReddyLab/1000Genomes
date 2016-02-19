#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $POP="$THOUSAND/ethnicity.txt";
my $RNA="$THOUSAND/assembly/rna-table.txt"

my %ethnicity;
open(IN,$POP) || die $POP;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=2;
  my ($ID,$pop)=@fields;
  $ethnicity{$ID}=$pop;
}
close(IN);

my @header;
open(IN,$RNA) || die $RNA;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>100;
  if($fields[0] eq "transcript") { @header=@fields; next }
  my $transcript=$fields[0];
  my $gene=$fields[1];
  my $numFields=@fields;
  my %counts;
  for(my $i=2 ; $i<$numFields ; ++$i) {
    if($fields[$i]>0) {
      my $ID=$header[$i];
      my $ethnic=$ethnicity{$ID}; die unless length($ethnicity)>0;
      ++$counts{$ethnicity};
    }
  }
  my @keys=keys %counts;
  foreach my $key (@keys) {
    my $count=$counts{$key};
    print "$key\t$count\n";
  }
}
close(IN);




