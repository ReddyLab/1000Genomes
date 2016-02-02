#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.vcf> <individual>\n" unless @ARGV==2;
my ($vcf,$indiv)=@ARGV;

open(IN,$vcf) || die $vcf;
my $index;
while(<IN>) {
  chomp;
  if(/^#CHROM/) {
    my @fields=split;
    for(my $i=0 ; $i<9 ; ++$i) { shift @fields }
    my $n=@fields;
    for(my $i=0 ; $i<$n ; ++$i) {
      if($fields[$i] eq $indiv) { $index=$i; last }
    }
    last
  }
}

while(<IN>) {
  chomp;
  my @fields=split/\s+/,$_;
  my $chr=shift @fields;
  my $pos=shift @fields;
  my $rs=shift @fields;
  my $ref=shift @fields;
  my $alt=shift @fields;
  for(my $i=0 ; $i<4 ; ++$i) { shift @fields }
  my $genotype=$fields[$index];
  $genotype=~/(\d)\|(\d)/ || die $genotype;
  my ($left,$right)=($1,$2);
  next unless $left>0 || $right>0;
  print "$rs:$chr:$pos:$ref:$alt\t$genotype\n";
}
close(IN);
