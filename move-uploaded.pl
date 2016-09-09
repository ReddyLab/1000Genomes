#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <from-dir> <list.txt> <to-dir>\n" unless @ARGV==3;
my ($fromDir,$listFile,$toDir)=@ARGV;

my @files=`ls $fromDir`;
foreach my $file (@files) {
  chomp;
  next unless $file=~/essex.gz/;
  my $cmd="mv $fromDir/$file $toDir";
  print "$cmd\n";
}
