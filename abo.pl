#!/usr/bin/perl
use strict;

my $BASE="/home/bmajoros/splicing/ethnic/abo";

process("$BASE/HG00096-1.txt","$BASE/HG00096-1.gff");
process("$BASE/HG00096-2.txt","$BASE/HG00096-2.gff");
process("$BASE/ref.txt","$BASE/ref.gff");

###########################################################

sub process {
  my ($infile,$outfile)=@_;
  open(IN,$infile) || die $infile;
  open(OUT,">$outfile") || die $outfile;
  while(<IN>) {
    next unless(/\(\S+\)/);
    $_=$1;
    chomp; my @fields=split; next unless @fields>=6;
    # (initial-exon 25815 25843 0 - 0)
  }
  close(IN); close(OUT);
}


