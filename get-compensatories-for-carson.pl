#!/usr/bin/perl
use strict;

my $ANCESTRY="/home/bmajoros/1000G/vcf/gender-and-ancestry.txt";
my $THOUSAND="/home/bmajoros/1000G/assembly";
my $INFILE="$THOUSAND/compensatory-indels.txt";

my (%ethnicity,%ethnicSampleSize);
open(IN,$ANCESTRY) || die "can't open $ANCESTRY\n";
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=4;
  my ($indiv,$gender,$subpop,$superpop)=@fields;
  $ethnicity{$indiv}=$superpop;
  $ethnicSampleSize{$superpop}+=2; # alleles, not individuals
}
close(IN);

my %transcripts;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  next if(/NOT CORRECTED/);
  chomp; my @fields=split; next unless @fields>=6;
  my ($indiv,$hap,$gene,$transcript,$AA,$indels)=@fields;
  my @indels=split/,/,$indels;
  my $numIndels=@indels;
  #my $ethnicity=$ethnicity{$indiv};
  #$transcripts{$transcript}->{ethnicity}->{$ethnicity}++;
  $transcripts{$transcript}->{len}=$AA;
  $transcripts{$transcript}->{indivs}->{$indiv}->{$hap}=1;
  $transcripts{$transcript}->{gene}=$gene;
  $transcripts{$transcript}->{numIndels}=$numIndels;
}
close(IN);

print "transcript\tgene\t#hetero\t#homo\t#aminoacids\t#indels";
my @ethnicities=keys %ethnicSampleSize;
foreach my $ethnicity (@ethnicities) { print "\t$ethnicity" }
print "\n";
my @keys=keys %transcripts;
foreach my $transcriptID (@keys) {
  my $rec=$transcripts{$transcriptID};
  my $len=$rec->{len}; my $gene=$rec->{gene}; my $indels=$rec->{numIndels};
  my $indivs=$rec->{indivs};
  my @indivs=keys %$indivs;
  my $hetero=0; my $homo=0; my %ethnicCounts;
  foreach my $indiv (@indivs) {
    my $ethnicity=$ethnicity{$indiv};
    my $numAlleles=keys %{$indivs->{$indiv}};
    $ethnicCounts{$ethnicity}+=$numAlleles;
    if($numAlleles==1) { ++$hetero }
    elsif($numAlleles==2) { ++$homo }
    else { die "numAlleles=$numAlleles" }
  }
  print "$transcriptID\t$gene\t$hetero\t$homo\t$len\t$indels";
  foreach my $ethnicity (@ethnicities) {
    my $count=0+$ethnicCounts{$ethnicity};
    my $proportion=$count/$ethnicSampleSize{$ethnicity};
    $proportion=int($proportion*10000+5/9)/10000;
    print "\t$count ($proportion)";
  }
  print "\n";
}


