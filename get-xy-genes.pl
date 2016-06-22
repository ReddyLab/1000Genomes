#!/usr/bin/perl
use strict;
$|=1;

my $THOUSAND="/home/bmajoros/1000G";
my $INFILE="$THOUSAND/assembly/local-genes.gff";
my $OUTFILE="$THOUSAND/assembly/xy.txt";

my (%seen);
open(OUT,">$OUTFILE") || die $OUTFILE;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=9;
  my $chr=$fields[0];
  next unless $chr eq "chrX" || $chr eq "chrY";
  my ($transcript,$gene);
  if(/transcript_id=([^;]+)/) { $transcript=$1 }
  if(/gene_id=([^;]+)/) { $gene=$1 }
  my $key="$gene $transcript";
  next if $seen{$key};
  $seen{$key}=1;
  print OUT "$chr\t$gene\t$transcript\n";
}
close(OUT);

