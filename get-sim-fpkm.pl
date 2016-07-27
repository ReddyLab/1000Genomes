#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.gff> <in.tab.txt>\n" unless @ARGV==2;
my ($GFF,$TAB)=@ARGV;

# Process the GFF file
my %FPKM;
open(IN,$GFF) || die "can't open $GFF";
while(<IN>) {
  if(/transcript_id\s+"\S\S\S\d+_[^\"]+"/) { $FPKM{$1}=0 }
}
close(IN);

# Process the tab.txt file
open(IN,$TAB) || die "can't open $TAB";
<IN>; # header
while(<IN>) {
  chomp; my @fields=split; next unless @fields>=7;
  my ($indiv,$allele,$gene,$transcript,$cov,$FPKM,$TPM)=@fields;
  next unless $transcript=~/\S\S\S\d+_[^\"]+/;
  $FPKM{$transcript}=$FPKM;
}
close(IN);

# Dump table to output
my @keys=keys %FPKM;
@keys=sort {$FPKM{$a} <=> $FPKM{$b}} @keys;
my $n=@keys;
for(my $i=0 ; $i<$n ; ++$i) {
  my $transcript=$keys[$i];
  my $fpkm=$FPKM{$transcript};
  print "$transcript\t$fpkm\n";
}



