#!/usr/bin/perl
use strict;
use EssexParser;
use EssexFBI;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
}


