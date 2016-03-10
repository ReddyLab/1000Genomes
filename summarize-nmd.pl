#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my ($success,$N);
open(IN,$infile) || die $infile;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($transcriptID,$nmdMean,$funcMean,$nmdSD,$funcSD,$nmdN,$funcN)=@fields;
  if($nmdMean<$funcMean) { ++$success }
  ++$N;
}
close(IN);

my $percent=$success/$N;
print "$percent\n";


