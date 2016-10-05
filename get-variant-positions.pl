#!/bin/env perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.vcf>\n" unless @ARGV==1;
my ($vcf)=@ARGV;

open(IN,"cat $vcf | gunzip |") || die "can't read $vcf\n";
while(<IN>) {
  chomp; next if(/^\s*#/);
  my @fields=split; next unless @fields>=9;
  my ($chr,$pos,$variant)=@fields;
  if($variant eq ".") {$variant="chr$chr\@$pos"}
  print "$pos\t$variant\n";
}
close(IN);

