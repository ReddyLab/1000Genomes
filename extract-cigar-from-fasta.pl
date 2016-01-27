#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.fasta>\n" unless @ARGV==1;
my ($infile)=@ARGV;

open(IN,$infile) || die "can't open $infile";
while(<IN>) {
  chomp;
  if(/>(\S+)\s.*\/cigar=(\S+)/) {
    my ($id,$cigar)=($1,$2);
    print "$id\t$cigar\n";
  }
}
close(IN);
# >ENSG00000272636_1 /coord=chr17:4808-32427:- /margin=1000 /cigar=27619M

