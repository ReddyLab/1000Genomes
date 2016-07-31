#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get(;
die "$name <infile>\n" unless @ARGV==1;
my ($INFILE)=@ARGV;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";

my $cryptic=0;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp;
  if(/supported cryptic:\s(\d+)/) { $cryptic=$1 }
  elsif(/supported skipping:\s+(\d+)/) {
    $skipping=$2;
    my $ratio=$cryptic/$skipping;
    print "$ratio\n";
  }
}
close(IN);










