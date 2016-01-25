#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.gff>\n" unless @ARGV==1;
my ($infile)=@ARGV;

open(IN,$infile) || die $infile;
while(<IN>) {
  chomp;
  my @fields=split;
  next unless @fields>=8;
  next unless @fields[2] eq "transcript";
  $_=~/transcript_id "([^"]+)";/ || die $_;
  my $stTransID=$1;
  $_=~/reference_id "([^"]+)";/ || die $_;
  my $transID=$1;
  print "$transID\t$stTransID\n";
}
close(IN);

# ENSG00000000419_1       StringTie       transcript      1002    24685   1000    -       .       gene_id "STRG.1"; transcript_id "STRG.1.1"; reference_id "ENST00000371588_1"; ref_gene_id "ENSG00000000419_1"; cov "32.103718"; FPKM "9.951096"; TPM "24.299459";






