#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile>\n" unless @ARGV==1;
my ($INFILE)=@ARGV;

my $THOUSAND="/home/bmajoros/1000G";
my $ASSEMBLY="$THOUSAND/assembly";

my $cryptic=0; my $crypticN=0;
open(IN,$INFILE) || die $INFILE;
while(<IN>) {
  chomp;
  if(/supported cryptic:\s+(\d+)\s+(\d+)/) { $cryptic=$1; $crypticN=$2 }
  elsif(/supported skipping:\s+(\d+)\s+(\d+)/) {
    my $skipping=$1;
    my $skippingN=$2;
#    my $ratio=($cryptic+1)/($skipping+1);
    my $ratio=($cryptic/$crypticN)/($skipping/$skippingN);
    print "$ratio\n";
  }
}
close(IN);










