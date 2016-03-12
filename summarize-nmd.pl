#!/usr/bin/perl
use strict;
use ProgramName;

my $MIN_RPKM=1;

my $name=ProgramName::get();
die "$name <infile> <min-sample-size>\n" unless @ARGV==2;
my ($infile,$minN)=@ARGV;

my ($success,$N);
open(IN,$infile) || die $infile;
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  #my ($transcriptID,$nmdMean,$funcMean,$nmdSD,$funcSD,$nmdN,$funcN)=@fields;
  #next unless $nmdN>=$minN && $funcN>=$minN && $funcMean>$MIN_RPKM;
  #if($nmdMean<$funcMean) { ++$success }
  my ($transcriptID,$mean0,$mean1,$mean2,$n0,$n1,$n2)=@fields;
  next unless $n0+$n1>=$minN && $n2>=$minN && $mean2>=$MIN_RPKM;

  ++$N;
}
close(IN);

my $percent=$success/$N;
print "$percent\tn=$N\n";


