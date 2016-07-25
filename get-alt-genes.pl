#!/usr/bin/perl
use strict;
$|=1;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";
my $COMBINED="$ASSEMBLY/combined";
my $OUTFILE="$ASSEMBLY/alt-genes.txt";

open(OUT,">$OUTFILE") || die $OUTFILE;
my @indivs=`ls $COMBINED`;
foreach my $indiv (@indivs) {
  chomp $indiv;
  next unless $indiv=~/HG\d+/ || $indiv=~/NA\d+/;
  next unless -e "$COMBINED/$indiv/RNA/stringtie.gff";
  #process("$COMBINED/$indiv/RNA/1and2.gff",$indiv);
  process("$COMBINED/$indiv/1.gff",$indiv);
  process("$COMBINED/$indiv/2.gff",$indiv);
}
close(OUT);
print STDERR "[done]\n";

sub process
{
  my ($filename,$indiv)=@_;
  my %seen;
  open(IN,$filename) || die $filename;
  while(<IN>) {
    next unless/ALT\d_([^_\"]+)/;
    my $transcript=$1;
    chomp; my @fields=split; next unless @fields>=8;
    my $substrate=$fields[0];
    $substrate=~/(\S+)_(\d)/ || die $substrate;
    my ($gene,$allele)=($1,$2);
    my $key="$allele\t$transcript";
    next if $seen{$key};
    #print "$indiv\t$allele\t$transcript\n";
    print OUT "$indiv\t$allele\t$transcript\n";
    $seen{$key}=1;
  }
  close(IN);
}


