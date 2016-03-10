#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile> <min-sample-size>\n" unless @ARGV==2;
my ($infile,$minN)=@ARGV;

my ($success,$N);
open(IN,$infile) || die $infile;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($transcriptID,$nmdMean,$funcMean,$nmdSD,$funcSD,$nmdN,$funcN)=@fields;
  next unless $nmdN>=$minN && $funcN>=$minN;
  if($nmdMean<$funcMean) { ++$success }
  ++$N;
}
close(IN);

my $percent=$success/$N;
print "$percent\n";


