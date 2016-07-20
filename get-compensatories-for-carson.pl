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
  $transcripts{$transcript}->{indivs}->{$indiv}->{$hap}=1;
  $transcripts{$transcript}->{gene}=$gene;
  $transcripts{$transcript}->{numIndels}=$numIndels;
}
close(IN);

print "transcript\tgene\t#hetero\t#homo\t#aminoacids\t#indels\n";
my @keys=keys %transcripts;
foreach my $transcriptID (@keys) {
  my $rec=$transcripts{$transcriptID};
  my $len=$rec->{len}; my $gene=$rec->{gene}; my $indels=$rec->{numIndels};
  my $indivs=$rec->{indivs};
  my @indivs=keys %$indivs;
  my $hetero=0; my $homo=0;
  foreach my $indiv (@indivs) {
    my $numAlleles=keys %{$indivs->{$indiv}};
    if($numAlleles==1) { ++$hetero }
    elsif($numAlleles==2) { ++$homo }
    else { die "numAlleles=$numAlleles" }
  }
  print "$transcriptID\t$gene\t$hetero\t$homo\t$len\t$indels\n";
}


