#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.fasta> <haplotype[1/2]> <out.fasta>\n" unless @ARGV==3;
my ($infile,$hap,$outfile)=@ARGV;

open(OUT,">$outfile") || die $outfile;
open(IN,$infile) || die $infile;
while(<IN>) {
  if(/^>(\S+)(.*)/) {
    print OUT ">$1\_$hap$2\n";
  }
  else { print OUT }
}
close(IN);
close(OUT);

