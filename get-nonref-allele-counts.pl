#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.vcf>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (@indexToID,%counts);
open(IN,$infile) || die "can't open $infile";
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
    for(my $i=9 ; $i<$n ; ++$i) {
      my $G=$fields[$i];
      my $id=$indexToID[$i];
      my @fields=split/\|/,$G;
      my $count;
      foreach my $field (@fields) { if($field>0) {++$count} }
      $counts{$id}+=$count;
    }
  }
}
close(IN);

