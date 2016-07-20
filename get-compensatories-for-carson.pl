#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/compensatory-indels.txt";

my %transcripts;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  next if(/NOT CORRECTED/);
  chomp; my @fields=split; next unless @fields>=6;
  my ($indiv,$hap,$gene,$transcript,$AA,$indels)=@fields;
  my @indels=split/,/,$indels;
  my $numIndels=@indels;
  $transcripts{$transcript}->{len}=$AA;
  ++$transcripts{$transcript}->{num};
  $transcripts{$transcript}->{gene}=$gene;
  $transcripts{$transcript}->{numIndels}=$numIndels;
}
close(IN);

print "transcript\tgene\t#indivs\t#aminoacids\t#indels\n";
my @keys=keys %transcripts;
foreach my $key (@keys) {
  my $rec=$transcripts{$key};
  my $len=$rec->{len}; my $num=$rec->{num};
  my $gene=$rec->{gene}; my $indels=$rec->{numIndels};
  print "$key\t$gene\t$num\t$len\t$indels\n";
}


