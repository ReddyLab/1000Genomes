#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.sx>\n" unless @ARGV>=1;
my ($infile)=@ARGV;

my @stack;
open(IN,$infile) || die "can't read file: $infile\n";
while(<IN>) {
  if(/^(\s+)(\S.*)/) {
    my ($indent,$rest)=($1,$2);
    print "$indent";
    if($rest=~/^\((\S+)(.*)/) {
      my ($tag,$rest)=($1,$2);
      
    }
  }
}
close(IN);
