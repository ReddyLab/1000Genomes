#!/usr/bin/perl
use strict;
use EssexParser;
use EssexICE;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my $parser=new EssexParser($infile);
while(1) {
  my $elem=$parser->nextElem();
  last unless $elem;
  my $report=new EssexICE($elem);
  my $status=$report->getStatusString();
  # mapped/splicing-changes/no-transcript



}


