#!/usr/bin/perl
use strict;
use ProgramName;
$|=1;

my $MAX_VARIANTS=-1;

my $name=ProgramName::get();
die "$name <in.vcf.gz>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (@indexToID,%counts,$variantNum);
open(IN,"cat $infile | gunzip |") || die "can't open $infile";
while(<IN>) {
  next if(/^##/);
  chomp; my @fields=split/\t/,$_; next unless @fields>=9;
  my $n=@fields;
  if($fields[0] eq "#CHROM") {
    for(my $i=9 ; $i<$n ; ++$i) {
      my $id=$fields[$i];
      $indexToID[$i]=$id;
    }
  }
  else {
    ++$variantNum;
    last unless $MAX_VARIANTS<0 || $variantNum<$MAX_VARIANTS;
    for(my $i=9 ; $i<$n ; ++$i) {
      my $G=$fields[$i];
      my $id=$indexToID[$i];
      my @fields=split/\|/,$G;
      my $count=0;
      foreach my $field (@fields) { if($field>0) {++$count} }
      $counts{$id}+=$count;
      #my $debug=$counts{$id};
      #print "$id : $debug + $count\n";
    }
  }
}
close(IN);

my @keys=keys %counts;
foreach my $indiv (@keys) {
  my $count=$counts{$indiv};
  print "$indiv\t$count\n";
}


