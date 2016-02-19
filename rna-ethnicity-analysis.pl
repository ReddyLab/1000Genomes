#!/usr/bin/perl
use strict;

my $TABLE_FILE="table.tmp";
my $THOUSAND="/home/bmajoros/1000G";
my $POP="$THOUSAND/ethnicity.txt";
my $RNA="$THOUSAND/assembly/rna-table.txt";

# Load the list of individuals actually present in our data
my %present;
#my @dirs=`ls $THOUSAND/assembly/combined`;
#foreach my $dir (@dirs) {
#  chomp $dir;
#  next unless $dir=~/HG\d+/ || $dir=~/NA\d+/;
#  $present{$dir}=1;
#}
open(IN,$RNA) || die $RNA;
my $line=<IN>; chomp $line; my @fields=split/\s+/,$line;
close(IN);
foreach my $ID (@fields) { $present{$ID}=1 }

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
#my $sum==0;
#foreach my $key (@ethnicities) { $sum+=$multinomial{$key} }
#foreach my $key (@ethnicities) { $multinomial{$key}/=$sum }

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
  my (%counts,%nonCounts);
  for(my $i=2 ; $i<$numFields ; ++$i) {
    my $ID=$header[$i];
    next unless $present{$ID};
    my $ethnic=$ethnicity{$ID}; die unless length($ethnic)>0;
    if($fields[$i]>0) { ++$counts{$ethnic} }
    else { ++$nonCounts{$ethnic} }
  }
  my $N=0;
  #foreach my $key (@ethnicities) { $N+=$counts{$key} }
  #print "N=$N\n";
  my $numEth=@ethnicities;
  open(OUT,">$TABLE_FILE") || die $TABLE_FILE;
  print OUT "2 $numEth\n";
  foreach my $key (@ethnicities) {
    my $count=0+$counts{$key};
    my $nonCount=0+$nonCounts{$key};
    #my $expectedCount=$multinomial{$key}*$N;
    #my $antiCount=$multinomial{$key}-$count;
    #print "$key\t$count\t$nonCount\n";
    print OUT "$count\t$nonCount\n";
  }
  #print "===============\n";
  close(OUT);
  my $result=`/home/bmajoros/cia/BOOM/chi-square $TABLE_FILE`;
  chomp $result;
  my @fields=split/\s+/,$result;
  die $result unless @fields>=2;
  my ($P,$indep)=@fields;
  if($P<0.05) { print "$transcript\t$gene\t$P\n" }
}
close(IN);




