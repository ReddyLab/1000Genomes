#!/usr/bin/perl
use strict;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $OUTFILE="$ASSEMBLY/alt-genes.txt";

open(OUT,">$OUTFILE") || die $OUTFILE;
my @indivs=`ls $COMBINED`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  process("$COMBINED/$indiv/RNA/1and2.gff",$indiv);
}
close(OUT);

sub process
{
  my ($filename,$indiv)=@_;
  my %seen;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    next unless/ALT\d_([^\"]+)/;
    my $transcript=$!;
    chomp; my @fields=split; next unless @fields>=8;
    my $substrate=$fields[0];
    $substrate=~/(\S+)_(\d)/ || die $substrate;
    my ($gene,$allele)=($1,$2);
    my $key="$allele\t$transcript";
    next if $seen{$key};
    print OUT "$indiv\t$allele\t$transcript\n";
    $seen{$key}=1;
  }
  close(IN);
}


