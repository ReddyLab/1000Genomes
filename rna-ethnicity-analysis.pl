#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $POP="$THOUSAND/ethnicity.txt";
my $RNA="$THOUSAND/assembly/rna-table.txt";

# Load the list of individuals actually present in our data
my %present;
my @dirs=`ls $THOUSAND/assembly/combined`;
foreach my $dir (@dirs) {
  chomp $dir;
  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
  $present{$dir}=1;
}

# Read the ethnicity file
my (%ethnicity,%multinomial);
open(IN,$POP) || die $POP;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=2;
  my ($ID,$pop)=@fields;
  next unless $present{$ID};
  $ethnicity{$ID}=$pop;
  ++$multinomial{$pop};
}
close(IN);
my @ethnicities=keys %multinomial;

# Normalize the multinomial into a proper distribution
my $sum==0;
foreach my $key (@ethnicities) { $sum+=$multinomial{$key} }
foreach my $key (@ethnicities) { $multinomial{$key}/=$sum }

# Process the RNA counts file
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
      next unless $present{$ID};
      my $ethnic=$ethnicity{$ID}; die unless length($ethnic)>0;
      ++$counts{$ethnic};
    }
  }
  my $N=0;
  foreach my $key (@ethnicities) { $N+=$counts{$key} }
  foreach my $key (@ethnicities) {
    my $count=0+$counts{$key};
    my $expectedCount=$multinomial{$key}*$N;
    print "$key\t$count\t$expectedCount\n";
  }
  print "===============\n";
}
close(IN);




