#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <from-dir> <list.txt> <to-dir>\n" unless @ARGV==3;
my ($fromDir,$listFile,$toDir)=@ARGV;

open(IN,$listFile) || die $listFile;
while(<IN>) {
  chomp;
  $_=~/Uploading file:\s*(\S+)/ || next;
  my $file=$1;
  next unless $file=~/essex.gz/;
  my $cmd="mv $fromDir/$file $toDir";
  print "$cmd\n";
}
