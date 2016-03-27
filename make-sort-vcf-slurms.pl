#!/usr/bin/perl
use strict;

my $DIR="/home/bmajoros/1000G/vcf/GRCh38";
my @files=`ls $DIR/*.vcf.gz`;
foreach my $file (@files) {
  next unless(/chr([^\.]+)\.vcf\.gz/);
  my $id=$1;
  my $outfile="chr$id.sorted.vcf.gz";
  my $cmd="cat $DIR/$file | bgzip -d | vcf-sort | bgzip > $DIR/$outfile";
  print "$cmd\n";
}

