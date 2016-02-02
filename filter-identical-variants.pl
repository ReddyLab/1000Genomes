#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile> <outfile>" unless @ARGV==2;
my ($infile,$outfile)=@ARGV;

open(IN,$infile) || die $infile;
open(OUT,">$outfile") || die $outfile;
while(<IN>) {
  next unless(/VCF_WARNING.*NESTED_VARIANTS/);
  chomp;
  my @fields=split;
  next unless @fields==6;
  my $v1=$fields[4]; my $v2=$fields[5];
  $v1=~/\S+:\S+:(\d+):(\S+):(\S+)/ || die $v1;
  my ($pos1,$ref1,$alt1)=($1,$2,$3);
  $v2=~/\S+:\S+:(\d+):(\S+):(\S+)/ || die $v2;
  my ($pos2,$ref2,$alt2)=($1,$2,$3);
  next if $pos1==$pos2 && $ref1 eq $ref2 && $alt1 eq $alt2;
  print OUT "$_\n";
}
close(OUT);
close(IN);


